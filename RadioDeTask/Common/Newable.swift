//
//  Newable.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 24.02.24.
//

import UIKit

protocol Newable {
	init()
}

extension UIView: Newable {}

extension Newable where Self: UIView {
	static func new(_ creatorFunc: (Self) -> Void) -> Self {
		let instance = self.init()
		creatorFunc(instance)
		instance.translatesAutoresizingMaskIntoConstraints = false
		return instance
	}
}
