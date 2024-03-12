//
//  MainCoordinator.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 24.02.24.
//

import UIKit
import Combine

final class MainCoordinator: Coordinator {
	var childCoordinators: [Coordinator] = []
	
	var rootViewController: UIViewController {
		navigationController
	}
	
	private let navigationController = UINavigationController()
	private let appContext: AppContext
	private var cancellables = Set<AnyCancellable>()
	
	init(appContext: AppContext) {
		self.appContext = appContext
	}
	
	func prepare() -> UIViewController? {
		return navigationController
	}
	
	func start() {
		let viewModel = EpisodesListViewModel(repository: appContext.repository,
											  downloadManager: appContext.downloadManager)
		viewModel.$selectedModel
			.compactMap { $0 }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] model in
				self?.openPlayer(for: model)
			}.store(in: &cancellables)

		let viewController = EpisodesListViewController(viewModel: viewModel)
		navigationController.setViewControllers([viewController], animated: false)
	}

	func openPlayer(for model: EpisodeViewModel) {
		guard case let .downloaded(fileUrl) = model.downloadState else {
			return
		}
		let viewModel = PlayerViewModel(fileUrl: fileUrl, imageUrl: model.logoUrl, title: model.title)
		let viewController = PlayerViewController(viewModel: viewModel)
		navigationController.pushViewController(viewController, animated: true)
	}
}

