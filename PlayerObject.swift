//
//  PlayerObject.swift
//  Adami
//
//  Created by Jack Cockfield on 2022-09-07.
//

import Foundation
import AVFoundation


class PlayerObject {
    
    var avPlayer = AVPlayer()
    
    init(playItem: AVPlayerItem) {
        avPlayer = AVPlayer(playerItem: playItem)
    }

}
