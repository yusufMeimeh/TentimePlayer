//
//  PlayerCell.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 21/09/2023.
//

import UIKit

class PlayerCell: UICollectionViewCell {
    
    var player = TenTimePlayer.shared

    @IBOutlet private weak var playerView: UIView!
    @IBOutlet private weak var playerImageView: UIImageView!
    let mediaPlayerView = InlinePlayer.initFromNib()

    func configureCell(image: String) {
        playerImageView.kf.setImage(with: URL(string: image))
    }
    
    func playVideo() {
        playerImageView.isHidden = true
        playerView.addSubview(mediaPlayerView)
        mediaPlayerView.fillSuperview()
        mediaPlayerView.delegate = self
        let playerData = PlayerData(identifier: "1",
                                    thumbImage: "https://i.ytimg.com/vi/aqz-KE-bpKQ/maxresdefault.jpg",
                                    moviePath: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
                                    movieName: "BigBuckBunny",
                                    elapsedTime: 0)
        player.loadMediContent(playerData)
    }
    
    func pauseVideo() {
        playerImageView.isHidden = false
        mediaPlayerView.removeFromSuperview()
        player.endPlayer()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        playerImageView.image = UIImage()
    }
    
}


extension PlayerCell: MediaPlayerViewDelegate {
   
  
}
