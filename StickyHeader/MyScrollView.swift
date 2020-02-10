//
//  MyScrollView.swift
//  StickyHeader
//
//  Created by shaohua on 2/8/20.
//  Copyright © 2020 United Nations. All rights reserved.
//

import UIKit

extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}

class MyScrollView: UIScrollView, UIGestureRecognizerDelegate {

    // UIScrollView's built-in pan gesture recognizer must have its scroll view as its delegate.
    // headerView 区域禁用左划，由于是平级关系，此处转发给 VC
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let delegate = parentViewController as? UIGestureRecognizerDelegate {
           return delegate.gestureRecognizerShouldBegin?(gestureRecognizer) ?? true
        }
        return true
    }

    // 全屏右划返回 2of2
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // otherGestureRecognizer: 自己安装的 UIPanGestureRecognizer
        if let cls = NSClassFromString("UILayoutContainerView"),
            otherGestureRecognizer.view?.isKind(of: cls) == true,
            contentOffset.x == 0, // 已到最左
            otherGestureRecognizer.state == .began,

            // UIScrollViewPanGestureRecognizer
            let pan = gestureRecognizer as? UIPanGestureRecognizer,
            pan.translation(in: self).x > 0 { // 右划
//            print("simul true", type(of: gestureRecognizer), gestureRecognizer.state.rawValue, type(of: otherGestureRecognizer), otherGestureRecognizer.state.rawValue)
            return true
        }
//        print("simul false", type(of: gestureRecognizer), gestureRecognizer.state.rawValue, type(of: otherGestureRecognizer), otherGestureRecognizer.state.rawValue)
        return false
    }
}
