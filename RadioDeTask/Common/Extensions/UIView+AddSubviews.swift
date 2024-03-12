//
//  UIView+AddSubviews.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 24.02.24.
//

import UIKit

extension UIView {
	func addSubviews(_ views: UIView...) {
		addSubviews(views)
	}
	
	func addSubviews(_ views: [UIView]) {
		for view in views {
			addSubview(view)
		}
	}
}
