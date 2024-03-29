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
            edge.view?.addGestureRecognizer(pan)
        }
    }
}
