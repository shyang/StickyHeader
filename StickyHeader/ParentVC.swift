//
//  ParentViewController.swift
//  StickyHeader
//
//  Created by shaohua on 2/4/20.
//  Copyright © 2020 United Nations. All rights reserved.
//

import UIKit

class ParentVC: UIViewController, UIScrollViewDelegate, TabBarDelegate, UIGestureRecognizerDelegate {
    var scrollView = MyScrollView()
    let headerView = HeaderView()
    let dataSources: [UIViewController] = [TableVC(), CollectionVC(), TableVC()]

    deinit {
        print("deinit", self)
    }

    let w = UIScreen.main.bounds.size.width
    let h = UIScreen.main.bounds.size.height

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "主页"
        automaticallyAdjustsScrollViewInsets = false

        _ = scrollView.then { v in
            view.addSubview(v)
            v.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            v.contentSize = CGSize(width: w * CGFloat(dataSources.count), height: 0 /* magic */)
            v.isPagingEnabled = true
            v.showsHorizontalScrollIndicator = false
            v.showsVerticalScrollIndicator = false
            v.isDirectionalLockEnabled = true
            v.bounces = false
            if #available(iOS 11.0, *) {
                v.contentInsetAdjustmentBehavior = .never
            }
            v.delegate = self
            // 处理 headerView 上的点击事件
            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))
        }

        _ = headerView.then { v in
            view.addSubview(v)
            v.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
            }
            v.tabBar.delegate = self
        }

        dataSources.enumerated().forEach { idx, child in
            child.title = String(format: "Tab %d", idx)
            self.addChild(child)
            child.didMove(toParent: self)

            scrollView.addSubview(child.view)
            child.view.snp.makeConstraints { make in
                make.left.equalTo(w * CGFloat(idx))
                make.top.equalTo(0)
                make.width.equalTo(w)
                make.height.equalTo(h)
            }

            if let scroll = getScrollView(child) {
                if #available(iOS 11.0, *) {
                    scroll.contentInsetAdjustmentBehavior = .never
                }
                scroll.contentInset = UIEdgeInsets(top: headerView.intrinsicContentSize.height, left: 0, bottom: 0, right: 0)
                scroll.contentOffset = .init(x: 0, y: -headerView.intrinsicContentSize.height) // >= iOS 14
                scroll.delegate = self
                scroll.tag = idx
            }
        }

        tabBarDidSelect(0)
    }

    // headerView 区域禁用左划
    @objc func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }

        // UIScrollViewPanGestureRecognizer: 只有 headerView 下方允许
        if gestureRecognizer.view == scrollView {
            return gestureRecognizer.location(in: gestureRecognizer.view).y > headerView.frame.maxY
        }

        // fullscreenPan: headerView 右划或下方第一页右划允许
        return pan.translation(in: scrollView).x > 0 &&
            (gestureRecognizer.location(in: gestureRecognizer.view).y <= headerView.frame.maxY ||
            scrollView.contentOffset.x == 0)
    }

    private func getScrollView(_ child: UIViewController) -> UIScrollView? {
        return (child as? UICollectionViewController)?.collectionView ?? child.view as? UIScrollView
    }

    @objc func onTapped(gesture: UITapGestureRecognizer) {
        if headerView.tabBar.frame.contains(gesture.location(in: headerView)) {
            headerView.tabBar.onTapped(gesture: gesture)

            gesture.cancelsTouchesInView = true
        } else {
            gesture.cancelsTouchesInView = false // 让下方 UI 继续响应
        }
    }

    func tabBarDidSelect(_ index: Int) {
        scrollView.setContentOffset(CGPoint(x: w * CGFloat(index), y: scrollView.contentOffset.y), animated: true)
    }

    var currIndex = 0
    @objc func scrollViewDidEndScrollingAnimation() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)

        currIndex = Int(scrollView.contentOffset.x / w)
//        print("curr", currIndex)
    }

    let kStatusBarHeight = UIApplication.shared.statusBarFrame.size.height
    func scrollViewDidScroll(_ sender: UIScrollView) {
        let anchor = -kTabBarHeight - kStatusBarHeight // 上限
        if sender == scrollView {
            headerView.tabBar.scrollViewDidScroll(sender)

            // 水平滚动时复制一定范围内的 offset，否则 UI 抖动
            // https://stackoverflow.com/questions/993280/how-to-detect-when-a-uiscrollview-has-finished-scrolling
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(scrollViewDidEndScrollingAnimation), with: nil, afterDelay: 0.3)

            var x = Int(sender.contentOffset.x / w)

            // 连续滑动时动画来不及停止
            if currIndex < x {
                currIndex = x
            }

            if x == currIndex {
                x = currIndex + 1
            }

            print("H", sender.contentOffset.x, currIndex, "=>", x)

            if x < 0 || x >= dataSources.count {
                return
            }

            guard let fromView = getScrollView(dataSources[currIndex]) else {
                return
            }
            guard let toView = getScrollView(dataSources[x]) else {
                return
            }

            let top = min(fromView.contentOffset.y, anchor)
            /*
             无条件复制是 twitter、tiktok 等采用的行为：不保留原有 contentOffset，但绝无高度跳跃
             有条件复制：可以保留原有 contentOffset，但会有高度跳跃
             */
            // if toView.contentOffset.y < top {
                print("from", fromView.tag, "to", toView.tag, top)
                toView.contentOffset.y = top
            // }
            return
        }

        // 垂直滚动
        var y = sender.contentOffset.y
        if (y >= anchor) {
            y = anchor
        }
        let newY = -y - headerView.intrinsicContentSize.height
        print("V", sender.tag, y, newY)
        headerView.snp.updateConstraints { (make) in
            make.top.equalTo(newY)
        }

        // 过拉放大, drag to zoom in headerView bg
        if newY > 0 {
            headerView.image.snp.updateConstraints { make in
                make.top.equalTo(-newY)
                make.height.equalTo(kImageHeight + newY)
            }
        } else {
            headerView.image.snp.updateConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(kImageHeight)
            }
        }
    }
}
