//
//  InlinePlayer.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 21/09/2023.
//

import UIKit

public class InlinePlayer: MediaPlayerView {
    override public  class func initFromNib() -> MediaPlayerView {
        let className = String(describing: InlinePlayer.self)
        let bundle = Bundle.module
        guard let view = bundle.loadNibNamed(className, owner: nil, options: nil)?.first as? InlinePlayer else {
            fatalError("Could not load nib with name: \(className)")
        }
        return view
    }
}
