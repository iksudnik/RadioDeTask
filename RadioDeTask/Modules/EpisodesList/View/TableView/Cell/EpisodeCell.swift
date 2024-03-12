//
//  EpisodeCell.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 24.02.24.
//

import UIKit
import Combine

enum DownloadState {
	case notDownloaded
	case inProgress(_ percent: Int)
	case downloaded(_ fileUrl: URL)
}

extension DownloadState: Equatable, Hashable {
	static func == (lhs: DownloadState, rhs: DownloadState) -> Bool {
		switch (lhs, rhs) {
		case (.notDownloaded, .notDownloaded),
			(.downloaded, .downloaded):
			return true
		case let (.inProgress(lhs), .inProgress(rhs)):
			return lhs == rhs
		default:
			return false
		}
	}
}

final class EpisodeViewModel {
	let id: String
	let title: String
	let description: String
	let publishDate: String
	let duration: String
	let logoUrl: URL?
	let remoteUrl: URL?

	@Published var downloadState: DownloadState = .notDownloaded

	init(from episode: Episode) {
		self.id = episode.id
		self.title = episode.title
		self.description = episode.description
		self.publishDate = DateFormatter.publushDateFormatter.string(from: episode.publishDateFixed)
		self.duration = DateComponentsFormatter.durationFormatter.string(from: episode.duration) ?? "-"
		self.logoUrl = URL(string: episode.parentLogo300x300)
		self.remoteUrl = URL(string: episode.url)

		if episode.isDownloaded == true {
			downloadState = .downloaded(fileUrl)
		}
	}
}

extension EpisodeViewModel: Hashable {
	static func == (lhs: EpisodeViewModel, rhs: EpisodeViewModel) -> Bool {
		return lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

final class EpisodeCell: UITableViewCell {

	private enum Sizes {
		static let sideOffset: CGFloat = 16
		static let logoHeight: CGFloat = 54
		static let logoCornerRadius: CGFloat = 6
		static let imageBottomOffset: CGFloat = 8
	}

	private let logoImageView = UIImageView.new {
		$0.contentMode = .scaleAspectFit
		$0.layer.cornerRadius = Sizes.logoCornerRadius
		$0.clipsToBounds = true
	}

	private let downloadView = DownloadView.new { _ in }

	private let titleLabel = UILabel.new {
		$0.font = .systemFont(ofSize: 12, weight: .semibold)
	}

	private let descriptionLabel = UILabel.new {
		$0.font = .systemFont(ofSize: 11, weight: .regular)
		$0.numberOfLines = 5
	}

	private let dateLabel = UILabel.new {
		$0.font = .systemFont(ofSize: 11, weight: .semibold)
	}

	private let durationLabel = UILabel.new {
		$0.font = .systemFont(ofSize: 11, weight: .semibold)
	}

	private lazy var dataDurationStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [dateLabel, durationLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.spacing = Sizes.sideOffset
		stackView.distribution = .equalSpacing

		return stackView
	}()

	private lazy var labelsStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [titleLabel, dataDurationStackView, descriptionLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .leading

		return stackView
	}()

	private var cancellable: AnyCancellable?

	init(){
		super.init(style: .default, reuseIdentifier: Self.identifier)
		setupViews()
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		cancellable?.cancel()
		cancellable = nil
	}

	private func setupViews() {

		selectionStyle = .none
		
		contentView.addSubviews(logoImageView, downloadView, labelsStackView)

		NSLayoutConstraint.activate {

			logoImageView.heightAnchor.constraint(equalToConstant: Sizes.logoHeight)
			logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor)
			logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Sizes.sideOffset)

			logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
												   constant: Sizes.sideOffset)

			downloadView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: Sizes.imageBottomOffset)
			downloadView.leadingAnchor.constraint(equalTo: logoImageView.leadingAnchor)
			downloadView.trailingAnchor.constraint(equalTo: logoImageView.trailingAnchor)

			labelsStackView.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: Sizes.sideOffset)
			labelsStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor,
												 constant: -Sizes.sideOffset)
			labelsStackView.topAnchor.constraint(equalTo: logoImageView.topAnchor)
		}
	}
}

extension EpisodeCell: Reusable {
	
	func setup(with data: EpisodeViewModel) {
		
		titleLabel.text = data.title
		descriptionLabel.text = data.description
		dateLabel.text = data.publishDate
		durationLabel.text = data.duration

		cancellable = data.$downloadState
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
			self?.downloadView.update(state: data.downloadState)
		}

		Task {
			await logoImageView.loadImage(from: data.logoUrl,
										  placeholder: ImagePlaceholderView.init)
		}
	}
}

// MARK: - Preview

#Preview(traits: .sizeThatFitsLayout) {
	let cell = EpisodeCell()
	let model = EpisodeViewModel(from: .mock2)
	cell.setup(with: model)
	return cell.contentView
}
