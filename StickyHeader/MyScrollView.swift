//
//  MyScrollView.swift
//  StickyHeader
//
//  Created by shaohua on 2/8/20.
//  Copyright © 2020 United Nations. All rights reserved.
//

import UIKit

class MyScrollView: UIScrollView, UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // otherGestureRecognizer: navigationController.interactivePopGestureRecognizer
        if let cls = NSClassFromString("UILayoutContainerView"),
            otherGestureRecognizer.view?.isKind(of: cls) == true,
            contentOffset.x == 0, // 已到最左

            // UIScrollViewPanGestureRecognizer
            let pan = gestureRecognizer as? UIPanGestureRecognizer,
            pan.translation(in: self).x > 0 { // 右划
            return true
        }
        return false
    }
}
