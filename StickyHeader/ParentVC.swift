//
//  ParentViewController.swift
//  StickyHeader
//
//  Created by shaohua on 2/4/20.
//  Copyright © 2020 United Nations. All rights reserved.
//

import UIKit

class ParentVC: UIViewController, UIScrollViewDelegate, TabBarDelegate {
    var scrollView = UIScrollView()
    let headerView = HeaderView()
    let dataSources: [UIViewController] = [ChildVC(), ChildVC(), ChildVC()]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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

            if let scroll = child.view as? UIScrollView {
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

    func tabBarDidSelect(_ index: Int) {
        scrollView.setContentOffset(CGPoint(x: w * CGFloat(index), y: scrollView.contentOffset.y), animated: true)
    }

    let StatusBarHeight = UIApplication.shared.statusBarFrame.size.height

    func scrollViewDidScroll(_ sender: UIScrollView) {
        let anchor = -headerView.TabBarHeight - StatusBarHeight // 上限
        if sender == scrollView { // 水平滚动时复制一定范围内的 offset，否则 UI 抖动，TODO 还不完美
            if sender.contentOffset.x.truncatingRemainder(dividingBy: w) == 0 { // 边界
                return
            }
            let x = Int(sender.contentOffset.x / w * 2)

            let from = [0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5] // ...
            let to   = [1, 0, 2, 1, 3, 2, 4, 3, 5, 4, 6] // ...

            guard let fromView = dataSources[from[x]].view as? UIScrollView else {
                return
            }
            guard let toView = dataSources[to[x]].view as? UIScrollView else {
                return
            }

            let top = min(fromView.contentOffset.y, anchor)
            if toView.contentOffset.y < top {
                print("from", fromView.tag, "to", toView.tag, top)
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
        print(sender.tag, y, newY)
        headerView.frame.origin.y = newY
    }
}
