//
//  StickyPagesDataComponent.swift
//  StickyHeader
//
//  Created by shaohua on 2022/3/20.
//  Copyright © 2022 United Nations. All rights reserved.
//

import UIKit

protocol StickyPagesDataService : AnyObject {
    var numberOfPages: Int { get }
    func childScrollView(index: Int) -> UIScrollView?
    func childController(index: Int) -> UIViewController
}

class StickyPagesDataComponent : BaseComponent {
    let dataSources: [UIViewController] = [TableVC(), CollectionVC(), TableVC()]

    required init(context: SimpleContainer) {
        super.init(context: context)
        context.register(self, forType: StickyPagesDataService.self)
    }
}

extension StickyPagesDataComponent : StickyPagesDataService {
    func childController(index: Int) -> UIViewController {
        return dataSources[index]
    }

    func childScrollView(index: Int) -> UIScrollView? {
        let child = dataSources[index]
        return (child as? UICollectionViewController)?.collectionView ?? child.view as? UIScrollView
    }

    var numberOfPages: Int {
        return dataSources.count
    }
}
