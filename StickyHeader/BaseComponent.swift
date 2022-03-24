//
//  BaseComponent.swift
//  StickyHeader
//
//  Created by shaohua on 2022/3/17.
//  Copyright © 2022 United Nations. All rights reserved.
//

import Foundation
import UIKit

class BaseComponent : NSObject {
    private(set) weak var context: SimpleContainer?
    private(set) weak var controller: UIViewController?

    required init(context: SimpleContainer) {
        super.init()
        self.context = context
        controller = context.resolveObject(UIViewController.self)

        for child in Mirror(reflecting: self).children {
            if var inject = child.value as? InjectContext {
                inject.context = context
            }
        }
    }

    func componentDidLoad() {
    }
    func componentWillAppear() {
    }
    // add more if needed
}
