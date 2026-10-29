//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Тимофей Кислов on 29.10.2026.
//

import UIKit
import AVFoundation

final class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!

    // MARK: - State (единственный источник истины)
    private let tracks = TrackLibrary.tracks
    private var currentIndex = 0

    // Плеер живёт столько же, сколько экран
    private var player: AVAudioPlayer?

    private var isPlaying: Bool { player?.isPlaying ?? false }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadTrack(at: currentIndex, autoplay: false)
    }

    // MARK: - UI config
    private func configureUI() {
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 12
        titleLabel.textAlignment = .center
        artistLabel.textAlignment = .center
    }

    // MARK: - Actions
    @IBAction func previousTapped(_ sender: UIButton) {
        let wasPlaying = isPlaying
        currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
        loadTrack(at: currentIndex, autoplay: wasPlaying)
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        if isPlaying {
            player?.pause()
        } else {
            // если не играло и плеера нет — создадим
            if player == nil {
                loadTrack(at: currentIndex, autoplay: true)
            } else {
                player?.play()
            }
        }
        refreshPlayPauseIcon()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        let wasPlaying = isPlaying
        currentIndex = (currentIndex + 1) % tracks.count
        loadTrack(at: currentIndex, autoplay: wasPlaying)
    }

    // MARK: - Track loading
    private func loadTrack(at index: Int, autoplay: Bool) {
        let track = tracks[index]
        titleLabel.text = track.title
        artistLabel.text = track.artist
        coverImageView.image = UIImage(named: track.coverImageName)

        player?.stop()
        player = makePlayer(for: track)
        player?.delegate = self

        if autoplay {
            player?.play()
        }
        refreshPlayPauseIcon()
    }

    private func makePlayer(for track: Track) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: "mp3") else {
            print("⚠️ Audio file not found in bundle: \(track.fileName).mp3")
            presentAlert("Audio file missing", message: "\(track.fileName).mp3 не найден в bundle.")
            return nil
        }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()
            return p
        } catch {
            print("⚠️ Failed to load audio: \(error)")
            presentAlert("Cannot play track", message: error.localizedDescription)
            return nil
        }
    }

    private func refreshPlayPauseIcon() {
        let name = isPlaying ? "pause.fill" : "play.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
        let image = UIImage(systemName: name, withConfiguration: config)
        playPauseButton.setImage(image, for: .normal)
    }

    private func presentAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AVAudioPlayerDelegate
extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // авто-переход на следующий трек, сохраняя состояние play
        currentIndex = (currentIndex + 1) % tracks.count
        loadTrack(at: currentIndex, autoplay: true)
    }
}

