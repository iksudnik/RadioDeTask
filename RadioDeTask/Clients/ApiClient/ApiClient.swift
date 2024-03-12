//
//  ApiClient.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 24.02.24.
//

import Foundation

// MARK: - Interface

struct ApiClient {
	var episodes: () async throws -> [Episode]
}


// MARK: - Live client

extension ApiClient {
	private static let episodesLink = "https://prod.radio-api.net/podcasts/episodes/by-podcast-ids?podcastIds=verbrechen&count=40&offset=0"
	
	static var live: Self {
		return Self(episodes: {
			let url = URL(string: episodesLink)!
			
			let (data, _) = try await URLSession.shared.data(from: url)
			let response = try JSONDecoder().decode(EpisodesResponse.self, from: data)
			return response.episodes
		})
	}
}


// MARK: Mock client

extension ApiClient {
	static var mock: Self {
		return Self(episodes:  {
			return [.mock1, .mock2]
		})
	}
}
