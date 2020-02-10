//
//  MyNavigationController.swift
//  StickyHeader
//
//  Created by shaohua on 2/8/20.
//  Copyright © 2020 United Nations. All rights reserved.
//

import UIKit

class MyNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 全屏右划返回 1of2
        if let edge = interactivePopGestureRecognizer {
            let pan = UIPanGestureRecognizer(target: edge.delegate!, action: NSSelectorFromString("handleNavigationTransition:"))
            pan.delegate = self
            edge.view?.addGestureRecognizer(pan)
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 转发给 VC
        if let delegate = topViewController as? ParentVC {
           return delegate.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        return viewControllers.count > 1
    }
}
