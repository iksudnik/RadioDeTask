//
//  EpisodesListViewModel.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 24.02.24.
//

import Foundation
import Combine

enum ViewState {
	case idle
	case loading
	case success([EpisodeViewModel])
	case error(Error)
}


final class EpisodesListViewModel {

	private let repository: Repository
	private let downloadManager: DownloadManager

	private var episodes: [Episode] = []

	private var cellModels: [EpisodeViewModel] = []

	@Published private(set) var viewState: ViewState = .idle
	@Published private(set) var selectedModel: EpisodeViewModel? = nil

	init(repository: Repository,
		 downloadManager: DownloadManager) {
		self.repository = repository
		self.downloadManager = downloadManager
	}
}

// MARK: - Public

extension EpisodesListViewModel {
	func loadData() async {
		episodes = []

		viewState = .loading
		do {
			episodes = try await repository.episodes()
			self.cellModels = episodes.map(EpisodeViewModel.init(from:))
			viewState = .success(cellModels)
		} catch {
			viewState = .error(error)
		}
	}

	func didSelectItem(_ index: Int) async {
		let model = cellModels[index]
		if case .downloaded = model.downloadState {
			selectedModel = model
			return
		}

		guard let url = model.remoteUrl else { return }

		if case .inProgress = model.downloadState {
			downloadManager.cancel(url)
			return
		}

		guard let downloadEvents = downloadManager.download(url, model.fileUrl) else { return }

		for await event in downloadEvents {
			switch event {
			case .initiated:
				model.downloadState = .inProgress(0)
			case let .progress(currentBytes, totalBytes):
				let percent = Int(Double(currentBytes) / Double(totalBytes) * 100)
				model.downloadState = .inProgress(max(0, min(100, percent)))
			case let .success(fileUrl):
				updateFile(fileUrl: fileUrl, for: model)
			case.cancelled:
				model.downloadState = .notDownloaded
			}
		}
	}
}

// MARK: - Private

private extension EpisodesListViewModel {
	func updateFile(fileUrl: URL, for model: EpisodeViewModel) {

		Task {
			do {
				try await repository.updateIsDownloaded(true, model.id)
				model.downloadState = .downloaded(fileUrl)
			} catch {
				model.downloadState = .notDownloaded
				print("Failed to save file")
			}
		}
	}
}
