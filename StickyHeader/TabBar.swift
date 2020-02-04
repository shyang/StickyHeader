//
//  TabBar.swift
//  StickyHeader
//
//  Created by shaohua on 2/4/20.
//  Copyright © 2020 United Nations. All rights reserved.
//

import UIKit

protocol TabBarDelegate: AnyObject {
    func tabBarDidSelect(_ index: Int)
}

class TabBar: UIView {

    weak var delegate: TabBarDelegate?

    @objc func onTapped(gesture: UIGestureRecognizer) {
        let x = gesture.location(in: self).x
        let to = Int(x * 3 / self.bounds.size.width)
        print("selected", to)
        delegate?.tabBarDidSelect(to)
    }

    init() {
        super.init(frame: .zero)

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))

        let r = UIView().then { v in
            v.backgroundColor = .red
            addSubview(v)
            v.snp.makeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.width.equalToSuperview().dividedBy(3)
            }
        }
        let g = UIView().then { v in
            v.backgroundColor = .green
            addSubview(v)
            v.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.equalTo(r.snp.right)
                make.width.equalToSuperview().dividedBy(3)
            }
        }
        _ = UIView().then { v in
            v.backgroundColor = .blue
            addSubview(v)
            v.snp.makeConstraints { make in
                make.right.top.bottom.equalToSuperview()
                make.left.equalTo(g.snp.right)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
