//
//  PlayerViewController.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 25.02.24.
//

import UIKit
import Combine

final class PlayerViewController: UIViewController {

	private enum Sizes {
		static let imageWidth: CGFloat = 300
		static let spacing: CGFloat = 16
		static let buttonWidth: CGFloat = 44
	}

	private let imageView = UIImageView.new {
		$0.contentMode = .scaleAspectFit
	}

	private let titleLabel = UILabel.new {
		$0.font = .systemFont(ofSize: 16, weight: .semibold)
		$0.textAlignment = .center
		$0.numberOfLines = 0
	}

	private let playButton = UIButton.new {
		$0.tintColor = .label
	}

	private lazy var stackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, playButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = Sizes.spacing
		stackView.distribution = .equalSpacing
		stackView.alignment = .center

		return stackView
	}()

	private let viewModel: PlayerViewModel
	private var cancellables = Set<AnyCancellable>()

	required init(viewModel: PlayerViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)

		title = AppStrings.playerTitle

		titleLabel.text = viewModel.title

		playButton.addTarget(self, action: #selector(tappedPlayButton), for: .touchUpInside)

		Task {
			await imageView.loadImage(from: viewModel.imageUrl,
										  placeholder: ImagePlaceholderView.init)
		}

		self.viewModel.$isPlaying
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isPlaying in
				let imageName = isPlaying ? "pause.rectangle" : "play.rectangle"
				let config = UIImage.SymbolConfiguration(pointSize: Sizes.buttonWidth, weight: .bold, scale: .large)

				let image = UIImage(systemName: imageName, withConfiguration: config)
				self?.playButton.setImage(image, for: .normal)
		}.store(in: &cancellables)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		super.loadView()
		view.backgroundColor = .systemBackground

		view.addSubviews(stackView)
		setConstraints()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewModel.cleanUp()
	}


	private func setConstraints() {
		NSLayoutConstraint.activate {
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
			stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
			stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: Sizes.spacing)
			stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Sizes.spacing)
		}
	}

	@objc
	private func tappedPlayButton() {
		viewModel.togglePlayPause()
	}
}


#Preview {
	let vc = PlayerViewController(viewModel: .init(fileUrl: URL(fileURLWithPath: ""),
												   imageUrl: URL(string: Episode.mock1.parentLogo300x300),
												   title: Episode.mock1.title))
	return vc
}
