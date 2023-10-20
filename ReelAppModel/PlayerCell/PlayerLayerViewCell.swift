//
//  PlayerLayerViewCell.swift
//  ReelAppModel
//
//  Created by Dev on 20/10/2566 BE.
//

import UIKit
import AVFoundation

class PlayerLayerViewCell: UICollectionViewCell {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSlider()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSlider()
    }
    
    func configure(with url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        
        if let playerLayer = playerLayer {
            playerLayer.frame = contentView.bounds
            playerLayer.videoGravity = .resizeAspectFill
            contentView.layer.addSublayer(playerLayer)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        addTimeObserver()
        updateSlider()
    }
    
    func setupSlider() {
        contentView.addSubview(slider)
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        slider.addTarget(self, action: #selector(onSliderValueChanged), for: .valueChanged)
    }
    
    var timeObserver: Any?
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] _ in
            if !self?.slider.isTracking ?? false {
                self?.updateSlider()
            }
        }
    }
    
    func updateSlider() {
        if let duration = player?.currentItem?.duration {
            let durationSeconds = CMTimeGetSeconds(duration)
            let currentSeconds = CMTimeGetSeconds((player?.currentTime())!)

            if !durationSeconds.isNaN && durationSeconds > 0 {
                slider.maximumValue = Float(durationSeconds)
                slider.value = Float(currentSeconds)
            }
        }
    }
    
    @objc func onSliderValueChanged() {
        if let duration = player?.currentItem?.duration {
            let durationSeconds = CMTimeGetSeconds(duration)
            let newCurrentTime = Float64(slider.value) * durationSeconds
            player?.seek(to: CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: Int32(NSEC_PER_SEC)))
        }
    }
    
    @objc func videoDidEnd(notification: NSNotification) {
        player?.seek(to: CMTime.zero)
        player?.play()
    }
    
    func play() {
        player?.play()
    }
    
    func stop() {
        player?.pause()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }

        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }
}

