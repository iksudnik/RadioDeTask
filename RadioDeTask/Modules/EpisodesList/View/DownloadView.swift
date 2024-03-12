//
//  DownloadView.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 24.02.24.
//

import UIKit

final class DownloadView: UIView {
	private enum Sizes {
		static let spacing: CGFloat = 4
		static let cornerRadius: CGFloat = 8
	}

	private let iconView = UIImageView.new {
		$0.contentMode = .scaleAspectFit
		$0.tintColor = .white
	}

	private let percentLabel = UILabel.new {
		$0.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
		$0.textColor = .white
		$0.isHidden = true
	}

	private lazy var stackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [iconView, percentLabel])
		stackView.axis = .vertical
		stackView.spacing = Sizes.spacing
		stackView.distribution = .equalSpacing
		stackView.alignment = .center
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()


	private var state: DownloadState = .notDownloaded

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .systemBlue

		addSubview(stackView)

		update(state: state)

		NSLayoutConstraint.activate {
			stackView.getConstraintsToEdges(of: self,
											edges: .init(top: 4, left: Sizes.spacing,
														 bottom: -4, right: -Sizes.spacing))
		}

		layer.cornerRadius = Sizes.cornerRadius
		clipsToBounds = true
	}

	@available(*, unavailable)
	required init(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func update(state: DownloadState) {
		iconView.image = state.image
		if case let .inProgress(percent) = state {
			percentLabel.isHidden = false
			percentLabel.text = "\(percent)%"
		} else {
			percentLabel.isHidden = true
		}
	}
}

private extension DownloadState {
	var image: UIImage? {
		return switch self {
		case .notDownloaded: UIImage(systemName: "arrow.down.circle.fill")
		case .inProgress: UIImage(systemName: "x.circle.fill")
		case .downloaded: UIImage(systemName: "checkmark.circle.fill")
		}
	}
}


#Preview("Not Downloaded") {
	let view = DownloadView()
	view.update(state: .notDownloaded)
	return view
}


#Preview("In Progres") {
	let view = DownloadView()
	view.update(state: .inProgress(53))
	return view
}

#Preview("Downloaded") {
	let view = DownloadView()
	view.update(state: .downloaded(URL(filePath: "")))
	return view
}
