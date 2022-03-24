//
//  StickyHeaderComponent.swift
//  StickyHeader
//
//  Created by shaohua on 2022/3/20.
//  Copyright © 2022 United Nations. All rights reserved.
//

import Foundation
import UIKit

class StickyHeaderComponent : BaseComponent {
    let headerView = HeaderView()
    @Inject var dataService: StickyPagesDataService?

    required init(context: SimpleContainer) {
        super.init(context: context)
        context.register(self, forType: StickyPagesOverlayDelegate.self)
    }

    override func componentDidLoad() {
        guard let dataService = dataService else {
            return
        }
        
        controller?.view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        headerView.tabBar.delegate = context?.resolveObject(TabBarDelegate.self)

        for idx in 0...dataService.numberOfPages - 1 {
            if let scroll = dataService.childScrollView(index: idx) {
                if #available(iOS 11.0, *) {
                    scroll.contentInsetAdjustmentBehavior = .never
                }
                scroll.contentInset = UIEdgeInsets(top: headerView.intrinsicContentSize.height, left: 0, bottom: 0, right: 0)
                scroll.contentOffset = .init(x: 0, y: -headerView.intrinsicContentSize.height) // >= iOS 14
                scroll.delegate = self
                scroll.tag = idx
            }
        }
    }

    let kStatusBarHeight = UIApplication.shared.statusBarFrame.size.height
}

extension StickyHeaderComponent : StickyPagesOverlayDelegate {
    var overlayBottom: CGFloat {
        return headerView.frame.maxY
    }

    func onScroll(scrollView: UIScrollView) {
        headerView.tabBar.scrollViewDidScroll(scrollView)
    }

    func onTap(gesture: UITapGestureRecognizer) -> Bool {
        if headerView.tabBar.frame.contains(gesture.location(in: headerView)) {
            headerView.tabBar.onTapped(gesture: gesture)
            return true
        }
        return false
    }
}

extension StickyHeaderComponent : UIScrollViewDelegate {

    func scrollViewDidScroll(_ sender: UIScrollView) {
        let anchor = -kTabBarHeight - kStatusBarHeight // 上限

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
