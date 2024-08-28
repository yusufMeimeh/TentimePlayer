//
//  PlayerData.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import Foundation

open class PlayerData: NSObject, ObservableObject {
    let identifier: String
    let thumbImage: String?
    let moviePath: String
    let movieName: String?
    let elapsedTime: Double
    var subtitleType: String?
    var audioType: String?
    var offlinePath: String = ""
    var isAudio: Bool = false

    public init(identifier: String,
                thumbImage: String? = nil,
                moviePath: String,
                movieName: String? = nil,
                elapsedTime: Double = 0.0,
                subtitleType: String? = nil,
                audioType: String? = nil,
                offlinePath: String = "",
                isAudio: Bool = false) {
          self.identifier = identifier
          self.thumbImage = thumbImage
          self.moviePath = moviePath
          self.movieName = movieName
          self.elapsedTime = elapsedTime
          self.subtitleType = subtitleType
          self.audioType = audioType
          self.offlinePath = offlinePath
          self.isAudio = isAudio
      }
}

