//
//  HeaderView.swift
//  StickyHeader
//
//  Created by shaohua on 2/4/20.
//  Copyright © 2020 United Nations. All rights reserved.
//

import UIKit

let kImageHeight: CGFloat = 380

class HeaderView: UIView {
    let image = UIImageView()
    let tabBar = TabBar()

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: kImageHeight + kTabBarHeight)
    }

    init() {
        super.init(frame: .zero)

        image.then { v in
            v.image = UIImage(named: "headerBg")
            v.contentMode = .scaleAspectFill
            v.clipsToBounds = true

            addSubview(v)
            v.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(kImageHeight)
            }
        }

        tabBar.then { v in
            addSubview(v)

            v.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(image.snp.bottom)
                make.height.equalTo(kTabBarHeight)
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
