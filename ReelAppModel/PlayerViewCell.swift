//
//  PlayerViewCell.swift
//  ReelAppModel
//
//  Created by Dev on 25/9/2566 BE.
//

import UIKit
import AVKit

class PlayerViewCell: UICollectionViewCell {

    var playerViewController: AVPlayerViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configPlayer(model:VideoModel?){
        if let haveModel = model{
            if let urlString = haveModel.url, let videoURL = URL(string: String(format: "%@", urlString)) {
                print("Add Player")
                self.backgroundColor = .gray
                let player = AVPlayer(url: videoURL)
                playerViewController = AVPlayerViewController()
                if let viewPlayer = playerViewController{
                    viewPlayer.showsPlaybackControls = false
                    viewPlayer.view.frame = contentView.bounds
                    viewPlayer.player = player
                    contentView.addSubview(viewPlayer.view)
                    viewPlayer.player?.play()
                }
            }
        }
    }
    
    func playerPlay(){
        if let viewPlayer = playerViewController{
            viewPlayer.player?.play()
        }
    }
    
    func stopPlayer(){
        if let viewPlayer = playerViewController{
            viewPlayer.player?.pause()
        }
    }
}
