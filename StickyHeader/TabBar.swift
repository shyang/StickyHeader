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

    let labels = [UILabel(), UILabel(), UILabel()]
    let titles = ["A", "B", "C"]
    let count = 3
    let indicator = UIView() // 黄色漂浮下标

    func onTapped(gesture: UIGestureRecognizer) {
        let x = gesture.location(in: self).x
        let to = Int(x * CGFloat(count) / self.bounds.size.width)
        print("selected", to)
        delegate?.tabBarDidSelect(to)
    }

    init() {
        super.init(frame: .zero)

        labels.enumerated().forEach { (idx, v) in
            addSubview(v)
            v.textColor = .white
            v.backgroundColor = .lightGray
            v.textAlignment = .center
            v.font = UIFont.systemFont(ofSize: 15)
            v.text = titles[idx]

            v.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview().dividedBy(count)

                if idx == 0 {
                    make.left.equalToSuperview()
                } else if idx == count - 1 {
                    make.right.equalToSuperview()
                } else {
                    make.left.equalTo(labels[idx - 1].snp.right)
                }
            }
        }

        indicator.then { v in
            v.backgroundColor = .yellow

            addSubview(v)
            v.snp.makeConstraints { make in
                make.height.equalTo(3)
                make.width.equalTo(16)
                make.centerX.equalTo(labels[0]) // initial
                make.bottom.equalToSuperview().offset(-8)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func scrollViewDidScroll(_ sender: UIScrollView) {
        let x = sender.contentOffset.x
        let w = sender.contentSize.width
        indicator.frame.origin.x = self.bounds.width * (CGFloat(0.5) / CGFloat(count) + x / w) - 16 / 2
    }
}
