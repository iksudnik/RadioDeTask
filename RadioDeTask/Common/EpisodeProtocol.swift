//
//  EpisodeProtocol.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 25.02.24.
//

import Foundation

protocol EpisodeProtocol {
	var id: String { get }
}

extension EpisodeProtocol {
	var fileUrl: URL {
		return  URL.documentsDirectory
			.appending(path: "Podcasts")
			.appending(path: id)
			.appendingPathExtension("mp3")
	}
}

extension Episode: EpisodeProtocol {}

extension EpisodeViewModel: EpisodeProtocol {}
