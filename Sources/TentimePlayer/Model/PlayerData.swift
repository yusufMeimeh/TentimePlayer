//
//  PlayerData.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import Foundation

  class PlayerData: NSObject  {
    let identifier: Int
    let thumbImage: String
    let moviePath: String
    let movieName: String
    let elapsedTime: Double
    var subtitleType: String?
    var audioType: String?
    var offlinePath: String = ""
    var isAudio: Bool = false
    var relatedWorks: [PlayerData]
      
      
      init(identifier: Int, thumbImage: String, moviePath: String, movieName: String, elapsedTime: Double, subtitleType: String? = nil, audioType: String? = nil, offlinePath: String = "", isAudio: Bool = false, relatedWorks: [PlayerData]) {
          self.identifier = identifier
          self.thumbImage = thumbImage
          self.moviePath = moviePath
          self.movieName = movieName
          self.elapsedTime = elapsedTime
          self.subtitleType = subtitleType
          self.audioType = audioType
          self.offlinePath = offlinePath
          self.isAudio = isAudio
          self.relatedWorks = relatedWorks
      }
}

