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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .plain, target: self, action: #selector(onRight))

        view.backgroundColor = .white
        _ = UILabel().then { v in
            v.text = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            v.numberOfLines = 0

            view.addSubview(v)
            v.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    @objc func onRight() {
        self.navigationController?.pushViewController(ParentVC(), animated: true)
    }
}

