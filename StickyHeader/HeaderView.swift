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

        image.then { v in
            v.image = UIImage(named: "headerBg")
            v.contentMode = .scaleAspectFill
            v.clipsToBounds = true

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 穿透
        return nil
    }

}
