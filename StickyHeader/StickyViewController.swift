//
//  StickyViewController.swift
//  StickyHeader
//
//  Created by shaohua on 2022/3/15.
//  Copyright © 2022 United Nations. All rights reserved.
//


import UIKit

class StickyViewController : UIViewController {
    var context = SimpleContainer()
    var components: [BaseComponent] = []

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        
        hidesBottomBarWhenPushed = true
        title = "主页"
        automaticallyAdjustsScrollViewInsets = false

        // 先在 init 中完成 register
        context.register(self, forType: UIViewController.self)

        components = [
            StickyPagesDataComponent.self,
            StickyPagesUIComponent.self,
            StickyHeaderComponent.self,
        ].map { $0.init(context: context) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 然后在 didLoad 或更晚 resolveObject
    override func viewDidLoad() {
        super.viewDidLoad()
        components.forEach { $0.componentDidLoad() }

        view.backgroundColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        components.forEach { $0.componentWillAppear() }
    }
}
