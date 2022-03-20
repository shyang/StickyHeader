//
//  StickyPagesUIComponent.swift
//  StickyHeader
//
//  Created by shaohua on 2022/3/20.
//  Copyright © 2022 United Nations. All rights reserved.
//

import UIKit

protocol StickyPagesOverlayDelegate : AnyObject {
    func onTap(gesture: UITapGestureRecognizer) -> Bool
    func onScroll(scrollView: UIScrollView)

    var overlayBottom: CGFloat { get }
}

class StickyPagesUIComponent : BaseComponent {
    lazy var scrollView: UIScrollView = {
        let v = MyScrollView()
        let count = dataService?.numberOfPages ?? 1
        v.contentSize = CGSize(width: w * CGFloat(count), height: 0 /* magic */)
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
        return v
    }()

    weak var dataService: StickyPagesDataService?
    weak var overlay: StickyPagesOverlayDelegate?

    let w = UIScreen.main.bounds.size.width
    let h = UIScreen.main.bounds.size.height

    required init(context: SimpleContainer) {
        super.init(context: context)
        context.register(self, forType: TabBarDelegate.self)
    }

    override func componentDidLoad() {
        dataService = context?.resolveObject(StickyPagesDataService.self)
        overlay = context?.resolveObject(StickyPagesOverlayDelegate.self)

        guard let dataService = dataService else {
            return
        }

        controller?.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        for idx in 0 ... dataService.numberOfPages - 1 {
            let child = dataService.childController(index: idx)
            child.title = String(format: "Tab %d", idx)
            controller?.addChild(child)
            child.didMove(toParent: controller)

            scrollView.addSubview(child.view)
            child.view.snp.makeConstraints { make in
                make.left.equalTo(w * CGFloat(idx))
                make.top.equalTo(0)
                make.width.equalTo(w)
                make.height.equalTo(h)
            }
        }

        tabBarDidSelect(0)

    }

    var currIndex = 0
    @objc func scrollViewDidEndScrollingAnimation() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)

        currIndex = Int(scrollView.contentOffset.x / w)
//        print("curr", currIndex)
    }

    @objc func onTapped(gesture: UITapGestureRecognizer) {
        if overlay?.onTap(gesture: gesture) == true {
            gesture.cancelsTouchesInView = true
        } else {
            gesture.cancelsTouchesInView = false // 让下方 UI 继续响应
        }
    }
}

extension StickyPagesUIComponent : TabBarDelegate {

    func tabBarDidSelect(_ index: Int) {
        scrollView.setContentOffset(CGPoint(x: w * CGFloat(index), y: scrollView.contentOffset.y), animated: true)
    }
}

extension StickyPagesUIComponent : UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let dataService = dataService else {
            return
        }

        overlay?.onScroll(scrollView: scrollView)

        // 水平滚动时复制一定范围内的 offset，否则 UI 抖动
        // https://stackoverflow.com/questions/993280/how-to-detect-when-a-uiscrollview-has-finished-scrolling
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(scrollViewDidEndScrollingAnimation), with: nil, afterDelay: 0.3)

        var x = Int(scrollView.contentOffset.x / w)

        // 连续滑动时动画来不及停止
        if currIndex < x {
            currIndex = x
        }

        if x == currIndex {
            x = currIndex + 1
        }

        print("H", scrollView.contentOffset.x, currIndex, "=>", x)

        if x < 0 || x >= dataService.numberOfPages {
            return
        }

        guard let fromView = dataService.childScrollView(index: currIndex) else {
            return
        }
        guard let toView = dataService.childScrollView(index: x) else {
            return
        }

        let kStatusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let anchor = -kTabBarHeight - kStatusBarHeight // 上限
        let top = min(fromView.contentOffset.y, anchor)
        /*
         无条件复制是 twitter、tiktok 等采用的行为：不保留原有 contentOffset，但绝无高度跳跃
         有条件复制：可以保留原有 contentOffset，但会有高度跳跃
         */
        // if toView.contentOffset.y < top {
            print("from", fromView.tag, "to", toView.tag, top)
            toView.contentOffset.y = top
        // }
    }
}

extension StickyPagesUIComponent : UIGestureRecognizerDelegate {
    // headerView 区域禁用左划
    @objc func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let maxY = overlay?.overlayBottom else {
            return true
        }

        // UIScrollViewPanGestureRecognizer: 只有 headerView 下方允许
        return gestureRecognizer.location(in: gestureRecognizer.view).y > maxY
    }
}
