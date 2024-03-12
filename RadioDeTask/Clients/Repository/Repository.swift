//
//  Repository.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 24.02.24.
//

import Foundation

// MARK: - Interface

struct Repository {
	var episodes: () async throws -> [Episode]
	var updateIsDownloaded: (_ isDownloaded: Bool, _ episodeId: String) async throws -> Void
}


// MARK: - Live client

extension Repository {
	
	static func live(database: DatabaseClient, apiClient: ApiClient) -> Self {
		return Self(episodes: {
			let storedEpisodes = try await database.episodes()
			if !storedEpisodes.isEmpty {
				return storedEpisodes
			}

			let remoteEpisodes = try await apiClient.episodes()
			try await database.saveEpisodes(remoteEpisodes)
			return remoteEpisodes
		}, updateIsDownloaded: { isDownloaded, episodeId in
			try await database.updateIsDownloaded(isDownloaded, episodeId)
		})
	}
}


// MARK: Mock client

extension Repository {
	static var mock: Self {
		return Self(episodes:  {
			return [.mock1, .mock2]
		}, updateIsDownloaded: { _, _ in })
	}
}

