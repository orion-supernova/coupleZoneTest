//
//  SoundManager.swift
//  coupleZoneTest
//
//  Created by muratcankoc on 09/06/2024.
//

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    var player: AVAudioPlayer?

    func playSound(with name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ".wav") else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")

        }
    }
    func stopAlarm() {
        // Stop AVAudioPlayer
        player?.stop()
    }
}
