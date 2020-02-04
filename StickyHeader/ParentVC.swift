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
    var nestedView: UIScrollView?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "主页"
        automaticallyAdjustsScrollViewInsets = false

        let sz = UIScreen.main.bounds.size
        let w = sz.width
        let h = sz.height

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
                scroll.delegate = self
                scroll.contentInset = UIEdgeInsets(top: headerView.HeaderHeight, left: 0, bottom: 0, right: 0)
                scroll.tag = idx
            }
        }

        tabBarDidSelect(0)
    }

    func tabBarDidSelect(_ index: Int) {
        let w = self.view.bounds.size.width
        scrollView.setContentOffset(CGPoint(x: w * CGFloat(index), y: scrollView.contentOffset.y), animated: true)

        nestedView = dataSources[index].view as? UIScrollView
    }

    let StatusBarHeight = UIApplication.shared.statusBarFrame.size.height

    func scrollViewDidScroll(_ sender: UIScrollView) {
        let anchor = -headerView.TabBarHeight - StatusBarHeight

        var y = sender.contentOffset.y
        if (y >= anchor) {
            y = anchor
        }
        let newY = -y - headerView.HeaderHeight
        print(sender.tag, y, newY)
        headerView.frame.origin.y = newY
    }
}
