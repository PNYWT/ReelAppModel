//
//  PlayerViewCell.swift
//  ReelAppModel
//
//  Created by Dev on 25/9/2566 BE.
//

import UIKit
import AVKit

class PlayerViewCell: UICollectionViewCell {

    @IBOutlet weak var vPlayer: UIView!
    var playerViewController: AVPlayerViewController?
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var sliderBar:UISlider!
    @IBOutlet weak var imgStatusPlay: UIImageView!
    var timeObserver: Any?
    
    //MARK: Collection use
    public func configPlayer(model:VideoModel?){
        if let haveModel = model{
            if let urlString = haveModel.url, let videoURL = URL(string: String(format: "%@", urlString)) {
                loadCoverImage(url: videoURL)
                
                let player = AVPlayer(url: videoURL)

                if let viewPlayer = playerViewController{
                    viewPlayer.player = player
                    viewPlayer.player?.play()
                    self.sliderBar.addTarget(self, action: #selector(onSliderValueChanged), for: .valueChanged)
                    self.addTimeObserver()
                    
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .gray
        imageCoverSetup()
        sliderSetup()
        playerVideoSetup()
        self.vContent.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let observer = timeObserver {
            if let viewPlayer = playerViewController{
                viewPlayer.player?.removeTimeObserver(observer)
            }
            timeObserver = nil
        }
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerViewController?.player?.currentItem
        )
    }
    
    //MARK: Basic setupUI
    private func imageCoverSetup(){
        coverImageView.contentMode = .scaleAspectFill
    }
    
    private func playerVideoSetup(){
        playerViewController?.removeFromParent()
        playerViewController = AVPlayerViewController()
        if let viewPlayer = playerViewController{
            viewPlayer.view.frame = self.bounds
            viewPlayer.view.backgroundColor = .clear
            viewPlayer.showsPlaybackControls = false
            vPlayer.addSubview(viewPlayer.view)
        }
    }
    
    private func sliderSetup(){
        sliderBar.setMinimumTrackImage(UIImage(named: "slider-active"), for: .normal)
        sliderBar.setMaximumTrackImage(UIImage(named: "slider-bg"), for: .normal)
        sliderBar.setThumbImage(UIImage(named: "circle_fill"), for: .normal)
        sliderBar.value = 0
        sliderBar.isUserInteractionEnabled = true
        sliderBar.inputViewController?.viewDidLayoutSubviews()
    }
    
    //MARK: Basic setupAction
    @objc func onSliderValueChanged(sender: UISlider) {
        if let viewPlayer = playerViewController{
            let time = CMTime(seconds: Double(sender.value), preferredTimescale: 600)
            viewPlayer.player?.seek(to: time)
        }
    }
    
    private func updateSlider(currentTime:Float) {
        if let viewPlayer = playerViewController ,let duration = viewPlayer.player?.currentItem?.duration {
            let durationSeconds = CMTimeGetSeconds(duration)
            let currentSeconds = CMTimeGetSeconds((viewPlayer.player?.currentTime())!)
            if !sliderBar.isTracking, !durationSeconds.isNaN, durationSeconds > 0 {
                sliderBar.maximumValue = Float(durationSeconds)
                sliderBar.value = Float(currentSeconds)
            }
        }
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        if let viewPlayer = playerViewController{
            timeObserver = viewPlayer.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                self?.updateSlider(currentTime: Float(time.seconds))
            }
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(videoDidEnd),
                name: .AVPlayerItemDidPlayToEndTime,
                object: viewPlayer.player?.currentItem
            )
        }
    }
    
    @objc func videoDidEnd(notification: NSNotification) {
        if let viewPlayer = playerViewController{
            viewPlayer.player?.seek(to: CMTime.zero)
            viewPlayer.player?.play()
        }
    }
    
    private func loadCoverImage(url:URL){
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        if let cgImage = try? imageGenerator.copyCGImage(at: .zero, actualTime: nil) {
            coverImageView.image = UIImage(cgImage: cgImage)
        }
    }
    
    func playerPlay(){
        if let viewPlayer = playerViewController{
            viewPlayer.player?.play()
            self.imgStatusPlay.isHidden = true
        }
    }
    
    func stopPlayer(){
        if let viewPlayer = playerViewController{
            viewPlayer.player?.pause()
            self.imgStatusPlay.isHidden = false
        }
    }
    
    func didselectToPlayorStop(){
        if let viewPlayer = playerViewController{
            if viewPlayer.player?.rate == 0{
                viewPlayer.player?.play()
                self.imgStatusPlay.isHidden = true
            }else{
                viewPlayer.player?.pause()
                self.imgStatusPlay.isHidden = false
            }
        }
    }
}
