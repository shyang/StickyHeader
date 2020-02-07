//
//  ParentViewController.swift
//  StickyHeader
//
//  Created by shaohua on 2/4/20.
//  Copyright © 2020 United Nations. All rights reserved.
//

import UIKit

class ParentVC: UIViewController, UIScrollViewDelegate, TabBarDelegate, UIGestureRecognizerDelegate {
    var scrollView = UIScrollView()
    let headerView = HeaderView()
    let dataSources: [UIViewController] = [TableVC(), CollectionVC(), TableVC()]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    let w = UIScreen.main.bounds.size.width
    let h = UIScreen.main.bounds.size.height

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "主页"
        automaticallyAdjustsScrollViewInsets = false


        scrollView.then { v in
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

        headerView.then { v in
            view.addSubview(v)
            v.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(headerView.HeaderHeight)
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

            if let scroll = (child as? UICollectionViewController)?.collectionView ?? child.view as? UIScrollView {
                if #available(iOS 11.0, *) {
                    scroll.contentInsetAdjustmentBehavior = .never
                }
                scroll.contentInset = UIEdgeInsets(top: headerView.HeaderHeight, left: 0, bottom: 0, right: 0)
                scroll.delegate = self
                scroll.tag = idx
            }
        }

        tabBarDidSelect(0)
    }

    @objc func onTapped(gesture: UITapGestureRecognizer) {
        if headerView.tabBar.frame.contains(gesture.location(in: headerView)) {
            headerView.tabBar.onTapped(gesture: gesture)
        }
    }

    // https://stackoverflow.com/questions/24710258/no-swipe-back-when-hiding-navigation-bar-in-uinavigationcontroller/41248703#41248703
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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

    let StatusBarHeight = UIApplication.shared.statusBarFrame.size.height
    func scrollViewDidScroll(_ sender: UIScrollView) {
        let anchor = -headerView.TabBarHeight - StatusBarHeight // 上限
        if sender == scrollView {
            headerView.tabBar.scrollViewDidScroll(sender)

            // 水平滚动时复制一定范围内的 offset，否则 UI 抖动，TODO 还不完美
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

//            print("H", sender.contentOffset.x, currIndex, "=>", x)

            if x < 0 || x >= dataSources.count {
                return
            }

            guard let fromView = dataSources[currIndex].view as? UIScrollView else {
                return
            }
            guard let toView = dataSources[x].view as? UIScrollView else {
                return
            }

            let top = min(fromView.contentOffset.y, anchor)
            if toView.contentOffset.y < top {
//                print("from", fromView.tag, "to", toView.tag, top)
                toView.contentOffset.y = top
            }
            return
        }

        // 垂直滚动
        var y = sender.contentOffset.y
        if (y >= anchor) {
            y = anchor
        }
        let newY = -y - headerView.HeaderHeight
//        print("V", sender.tag, y, newY)
        headerView.frame.origin.y = newY

        // 过拉放大, drag to zoom in headerView bg
        if newY > 0 {
            headerView.image.snp.updateConstraints { make in
                make.top.equalTo(-newY)
                make.height.equalTo(headerView.ImageHeight + newY)
            }
        } else {
            headerView.image.snp.updateConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(headerView.ImageHeight)
            }
        }
    }
}
