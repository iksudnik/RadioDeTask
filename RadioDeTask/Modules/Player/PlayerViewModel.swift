//
//  PlayerViewModel.swift
//  RadioDeTask
//
//  Created by Ilya Sudnik on 25.02.24.
//

import Foundation
import AVFoundation

/// Very simple implementation
/// Just to test that everything is downloaded

final class PlayerViewModel {

	let fileUrl: URL
	let imageUrl: URL?
	let title: String

	private var player: AVAudioPlayer?
	@Published var isPlaying = false

	init(fileUrl: URL, imageUrl: URL?, title: String) {
		self.fileUrl = fileUrl
		self.imageUrl = imageUrl
		self.title = title

		loadAudioFile()
	}

	private func loadAudioFile() {
		do {
			player = try AVAudioPlayer(contentsOf: fileUrl)
			player?.prepareToPlay()
		} catch {
			print("Failed to load: \(error)")
		}
	}

	func togglePlayPause() {
		guard let player = player else { return }

		if isPlaying {
			player.pause()
			isPlaying.toggle()
		} else {
			do {
				try AVAudioSession.sharedInstance().setCategory(.playback)
				try AVAudioSession.sharedInstance().setActive(true)
				player.play()
				isPlaying.toggle()
			} catch {
				print("Failed to setup audio session: \(error)")
			}
		}
	}

	func cleanUp() {
		if let player = player, player.isPlaying {
			player.stop()
		}
	}
}
