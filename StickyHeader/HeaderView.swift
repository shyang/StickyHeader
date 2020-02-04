//
//  HeaderView.swift
//  StickyHeader
//
//  Created by shaohua on 2/4/20.
//  Copyright © 2020 United Nations. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    let ImageHeight: CGFloat = 380
    let TabBarHeight: CGFloat = 56
    lazy var HeaderHeight: CGFloat = { ImageHeight + TabBarHeight }()

    let image = UIImageView()
    let tabBar = TabBar()

    init() {
        super.init(frame: .zero)

        backgroundColor = .gray

        image.then { v in
            addSubview(v)

            v.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(ImageHeight)
            }
        }

        tabBar.then { v in
            addSubview(v)

            v.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(image.snp.bottom)
                make.height.equalTo(TabBarHeight)
            }
        }
    }

    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        print(gesture.location(in: self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if tabBar.frame.contains(point) {
            return super.hitTest(point, with: event)
        }
        return nil
    }

}
