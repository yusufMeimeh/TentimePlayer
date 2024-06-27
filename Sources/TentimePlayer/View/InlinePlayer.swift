//
//  InlinePlayer.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 21/09/2023.
//

import UIKit

class InlinePlayer: MediaPlayerView {
    override class func initFromNib() -> MediaPlayerView {
        let className = String(describing: InlinePlayer.self)
        return Bundle.init(for: InlinePlayer.self).loadNibNamed(className, owner: self, options: nil)!.first as! InlinePlayer
    }
}
