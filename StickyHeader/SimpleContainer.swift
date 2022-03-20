//
//  SimpleContainer.swift
//  StickyHeader
//
//  Created by shaohua on 2022/3/17.
//  Copyright © 2022 United Nations. All rights reserved.
//

import Foundation

class Weak {
    weak var target: AnyObject?
    init(target: AnyObject?) {
        self.target = target
    }
}

// a simple thread-safe (protocol/class -> object) associative container
public class SimpleContainer {

    private var services: [AnyHashable: Any] = [:]
    // https://www.objc.io/issues/2-concurrency/low-level-concurrency-apis/
    private var isolationQueue = DispatchQueue(label: "isolation-queue", attributes: .concurrent)

    // add non-weak
    public func registerRetained<T>(_ instance: T, forType: T.Type) {
        isolationQueue.async(flags: .barrier) {
            let key = String(describing: forType)
            self.services[key] = instance
        }
    }
    
    // add weak
    public func register<T>(_ instance: T, forType: T.Type) {
        isolationQueue.async(flags: .barrier) {
            let key = String(describing: forType)
            self.services[key] = Weak(target: instance as AnyObject)
        }
    }
    
    public func resolveObject<T>(_ type: T.Type) -> T? {
        var object: T?
        isolationQueue.sync {
            let key = String(describing: type)
            let value = self.services[key]
            
            if let value = value as? Weak, let extract = value.target as? T {
                object = extract
            } else if let value = value as? T {
                object = value
            } else {
                assert(false, "\(key) not registered yet")
            }
        }
        return object
    }
}
