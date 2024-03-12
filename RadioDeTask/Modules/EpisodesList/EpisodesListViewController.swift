//
//  EpisodesListViewController.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 24.02.24.
//

import UIKit
import Combine

enum Section: Int {
	case main
}

final class EpisodesListViewController: UIViewController {

	private enum Sizes {
		static let rowHeight: CGFloat = 128
	}

	private lazy var tableView: UITableView = {

		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.backgroundColor = .systemBackground
		tableView.rowHeight = Sizes.rowHeight
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.showsVerticalScrollIndicator = false

		tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.identifier)

		return tableView
	}()

	private let viewModel: EpisodesListViewModel
	private var dataSource: EpisodesListDataSource!

	private var cancellables = Set<AnyCancellable>()

	required init(viewModel: EpisodesListViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)

		self.title = AppStrings.episodesTitle

		self.dataSource = .init(tableView: tableView)

		self.viewModel.$viewState
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
			self?.didUpdate(with: state)
		}.store(in: &cancellables)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		super.loadView()
		view.backgroundColor = .systemBackground

		view.addSubviews(tableView)
		setConstraints()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = dataSource
		tableView.delegate = self

		Task {
			await viewModel.loadData()
		}
	}

	private func setConstraints() {
		NSLayoutConstraint.activate {
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		}
	}
}

// MARK: - EpisodesListViewModel updates

private extension EpisodesListViewController {

	func didUpdate(with state: ViewState) {
			switch state {
			case .idle:
				showEmptyState()
			case .loading:
				showLoading()
			case let .success(episodes):
				contentUnavailableConfiguration = .none
				dataSource.applySnapshot(items: episodes)
				if episodes.isEmpty {
					showEmptyState()
				}
			case .error(_):
				showError()
				dataSource.applySnapshot(items: [])
			}
	}

	func showEmptyState() {
		var config = UIContentUnavailableConfiguration.empty()
		config.image = UIImage(systemName: "waveform")
		config.text = AppStrings.episodesTitle
		config.secondaryText = AppStrings.emptyListTitle
		contentUnavailableConfiguration = config
	}

	func showLoading() {
		var config = UIContentUnavailableConfiguration.loading()
		config.text = AppStrings.loadingText
		config.textProperties.font = .boldSystemFont(ofSize: 18)
		contentUnavailableConfiguration = config
	}

	func showError() {
		var errorConfig = UIContentUnavailableConfiguration.empty()
		errorConfig.image = UIImage(systemName: "exclamationmark.circle.fill")
		errorConfig.text = AppStrings.fetchingErrorTitle
		errorConfig.secondaryText = AppStrings.fetchingErrorSubtitle

		var buttonConfig =  UIButton.Configuration.filled()
		buttonConfig.title = AppStrings.retryTitle
		errorConfig.button = buttonConfig

		errorConfig.buttonProperties.primaryAction = UIAction.init() { _ in

			Task { [weak self] in
				guard let self else { return }
				await viewModel.loadData()
			}
		}
		contentUnavailableConfiguration = errorConfig
	}
}

// MARK: - UITableViewDelegate

extension EpisodesListViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		Task {
			await viewModel.didSelectItem(indexPath.row)
		}
	}
}

// MARK: - Previews

#Preview("Normal") {
	let vc = EpisodesListViewController(viewModel: .init(repository: .mock, downloadManager: .mock))
	return vc
}


#Preview("Error") {
	let vc = EpisodesListViewController(viewModel: .init(repository: .init(episodes: { throw NSError() }, updateIsDownloaded: { _, _ in }),
														 downloadManager: .mock))
	return vc
}

#Preview("Empty") {
	let vc = EpisodesListViewController(viewModel:
			.init(repository: .init(episodes: { [] }, updateIsDownloaded: { _, _ in}),
				  downloadManager: .mock))
	return vc
}

