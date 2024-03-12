//
//  UIImageView+LoadImage.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 24.02.24.
//

import UIKit

/// Just quick implementation not to use external packages
/// like SDWebImage, Kingfisher or Nuke

extension UIImageView {
	func loadImage(from url: URL?,
				   placeholder: @MainActor () -> (UIView)) async {

		let subview = placeholder()

		await MainActor.run {
			addSubviews(subview)
			NSLayoutConstraint.activate {
				subview.getConstraintsToEdges(of: self)
			}
		}

		guard let url else { return }

		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			let serverImage = UIImage(data: data)

			await MainActor.run {
				subview.removeFromSuperview()
				image = serverImage
			}
		} catch { }
	}
}

