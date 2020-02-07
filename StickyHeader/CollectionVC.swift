//
//  CollectionVC.swift
//  StickyHeader
//
//  Created by shaohua on 2/7/20.
//  Copyright © 2020 United Nations. All rights reserved.
//

import UIKit

private let reuseIdentifier = "UICollectionViewCell"

class CollectionVC: UICollectionViewController {
    init() {
        let flow = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width / 2
        flow.itemSize = CGSize(width: width, height: width / 3 * 4)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        super.init(collectionViewLayout: flow)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let colors = [UIColor.red, UIColor.green, UIColor.blue]
        cell.backgroundColor = colors[indexPath.row % 3]
        return cell
    }

}
