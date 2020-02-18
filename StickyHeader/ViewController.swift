//
//  ViewController.swift
//  StickyHeader
//
//  Created by shaohua on 2/4/20.
//  Copyright © 2020 United Nations. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        view.backgroundColor = .white
        _ = UILabel().then { v in
            v.text = "Click me"
            v.numberOfLines = 0
            v.textAlignment = .center
            v.isUserInteractionEnabled = true
            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))

            view.addSubview(v)
            v.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    @objc func onTapped() {
        self.navigationController?.pushViewController(ParentVC(), animated: true)
    }
}

