//
//  VideoObject.swift
//  Adami
//
//  Created by Jack Cockfield on 2022-09-07.
//

import Foundation
import AVFoundation
import UIKit

protocol VideoObjectDelegate: AnyObject {
    var playerObjects: [PlayerObject] { get set }
    var avAssets: [AVAsset] { get set }
    var mediaUI: UIImagePickerController?  { get set }
    var beatTimeArrayCMTime: [CMTime] { get set }
    var beatTimeArrayStartTimes: [CMTime] { get set }
    var beatTimeArrayStartTimesWith0: [CMTime] { get set }
    
    func addToBeatTimeArrayCMTime(newElement: CMTime)
    
    func addToBeatTimeArrayStartTimes(newElement: CMTime)
    
    func addToBeatTimeArrayStartTimesWith0(newElement: CMTime)
}


class VideoObject {
    
    weak var delegate: VideoObjectDelegate?

    var mixComposition = AVMutableComposition()
    
    var mainInstruction = AVMutableVideoCompositionInstruction()
    
    unowned let storedAsset: AVAsset
    
//    var videoPlayer = AVPlayer()
    
    var thumbnails: [UIImage] = []
    
    var isPaused = true
    
    var playItem: AVPlayerItem?
    
    var amountOfClips: Int
    
    var beatLength = CMTime()
    
    var beatLengths = [CMTime()]
    
    var cellSize = CGSize(width: 150, height: 150)
    
    var cellSpacing = 8
    
    var audioAsset: AVAsset


    init(avAsset: AVAsset, songURL: URL, beatLengthArray: [CMTime]) {
        
        print("beatTimeArrayCMTime: ", beatLengths.first)
        
        beatLengths = beatLengthArray
        
        storedAsset = avAsset
        
        amountOfClips = 0
        
        audioAsset = AVAsset(url: songURL)
                
//        let amountOfClipsUnrounded = (CMTimeGetSeconds(avAsset.duration) / CMTimeGetSeconds(beatLength))
//
//        amountOfClips = Int(amountOfClipsUnrounded.rounded(.towardZero))
        
        let holder = getAmountOfClipsAndCompositionLength(assetDuration: storedAsset.duration)
        
        amountOfClips = holder.amountOfClips
        
        let compositionLength = holder.compositionLength
        
        var startTime = CMTime.zero
        
        print("amount of clips: ", amountOfClips)
        
        
        for index in 0...(amountOfClips-1) {
            

            print("for loop at index: \(index)")
            print("start time: \(startTime)")

            guard
              let track = mixComposition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
              else { return }
                
            // 3
            print("beatLengths: \(index) has time: \(beatLengths[index])")
            do {
              try track.insertTimeRange(
                CMTimeRangeMake(start: startTime, duration: beatLengths[index]),
                of: avAsset.tracks(withMediaType: .video)[0],
                at: startTime)
            } catch {
              print("Failed to load track")
              

              return
            }
            
            
            print("Tracks loaded")
        
            let instruction = VideoHelper.videoCompositionInstruction(
              track,
              asset: avAsset)
            
            let imgGenerator = AVAssetImageGenerator(asset: avAsset)
            imgGenerator.appliesPreferredTrackTransform = true

            do{
                let cgImage = try imgGenerator.copyCGImage(at: startTime, actualTime: nil)
                // !! check the error before proceeding
                var uiImage = UIKit.UIImage(cgImage: cgImage)
                uiImage = resizeWithScale(sourceImage: uiImage, scaledToWidth: cellSize.width)
                
                
                
                thumbnails.append(uiImage)

                }catch {
                    print ("ya done fucked up")

            }
            
            startTime = CMTimeAdd(startTime, beatLengths[index])
            
            
            
            instruction.setOpacity(0.0, at: startTime)
                        
            mainInstruction.layerInstructions.append(instruction)
            
            
        
    }
        
//        let totalDuration = startTime

        print("Calculated comp time: \(compositionLength)")
        print("Asset time: \(avAsset.duration)")
        print("Calculated comp time seconds: \(compositionLength.seconds)")
        print("Asset time seconds: \(avAsset.duration.seconds)")


        mainInstruction.timeRange = CMTimeRangeMake(
          start: .zero,
          duration: compositionLength)

        print("Instruction compilation")
        
        

        
          let audioTrack = mixComposition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: 0)
          do {
            try audioTrack?.insertTimeRange(
              CMTimeRangeMake(
                start: CMTime.zero,
                duration: compositionLength),
              of: audioAsset.tracks(withMediaType: .audio)[0],
              at: .zero)
          } catch {
            print("Failed to load Audio track")
          }

        
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = CGSize(
          width: UIScreen.main.bounds.width,
          height: UIScreen.main.bounds.height)
        print("mix comp: \(mixComposition)")
        playItem = AVPlayerItem(asset: mixComposition)
        playItem?.videoComposition = mainComposition

    }
    func resizeWithScale (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth

        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    func getAmountOfClipsAndCompositionLength(assetDuration: CMTime) -> (amountOfClips: Int, compositionLength: CMTime) {
        var tempTime = CMTimeMake(value: 0, timescale: 1000)
        var counter = 0
        print("stored asset duration: ", assetDuration.seconds)

        while(tempTime < assetDuration) {
            print("Beat length: ", beatLengths[counter])
            tempTime = CMTimeAdd(tempTime, beatLengths[counter])
            counter = counter + 1
        }
        return (counter, tempTime)
    }
    func switchInstruction(index: Int, index2: Int,videoObject: VideoObject, firstTrackIndex: Int, secondTrackIndex: Int) {
        
        let swapTime1 = getSwitchTime(index: index)
        let swapTime2 = getSwitchTime(index: index2)
        
        

        let beatLength1 = beatLengths[index]
        let beatLength2 = beatLengths[index2]

//        let swapTime1 = CMTimeMultiply(beatLength1, multiplier: Int32(index))
//        let swapTime2 = CMTimeMultiply(beatLength2, multiplier: Int32(index2))


        
        print("First track index: \(firstTrackIndex)")
        print("Second track index: \(secondTrackIndex)")
    
        
        mixComposition.tracks[index].removeTimeRange(CMTimeRangeMake(start: swapTime1, duration: beatLength1))
        
        var secondTempInstruction = mainInstruction.layerInstructions[index]
        
        var tempInstruction = videoObject.mainInstruction.layerInstructions[index2]
        
        var track1ID = tempInstruction.trackID
        var track2ID = secondTempInstruction.trackID
        print("TrackID1: \(track2ID)")
        print("TrackID2: \(track1ID)")
        
        
        
        
        do {
          try  mixComposition.tracks[index].insertTimeRange(
            CMTimeRangeMake(start: swapTime2, duration: beatLength1),
            of: (delegate?.avAssets[secondTrackIndex].tracks(withMediaType: .video)[0])!,
            at: swapTime1)
        } catch {
          print("Failed to swap track")
          return
        }
        if(firstTrackIndex != secondTrackIndex && track1ID != track2ID) {
            print("Good luck")
            let newInstruction = VideoHelper.videoCompositionInstruction(
                mixComposition.tracks[index],
                asset: storedAsset)
            let time = CMTimeAdd(swapTime1, beatLength1)
              
            newInstruction.setOpacity(0.0, at: time)
            tempInstruction = newInstruction
            
            let newSecondInstruction = VideoHelper.videoCompositionInstruction(
                videoObject.mixComposition.tracks[index2],
                asset: (delegate?.avAssets[secondTrackIndex])!)
            let secondTime = CMTimeAdd(swapTime2, beatLength2)
              
            newSecondInstruction.setOpacity(0.0, at: secondTime)
            secondTempInstruction = newSecondInstruction
        }
        
        
                

        
        mainInstruction.layerInstructions[index] = tempInstruction
        
        


        
        
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = CGSize(
          width: UIScreen.main.bounds.width,
          height: UIScreen.main.bounds.height)
        let newPlayItem = AVPlayerItem(asset: mixComposition)
        newPlayItem.videoComposition = mainComposition
        
        let newPlayerObject = PlayerObject(playItem: newPlayItem)
        
        delegate?.playerObjects[firstTrackIndex] = newPlayerObject
        
        //Second track swap
        
        videoObject.mixComposition.tracks[index2].removeTimeRange(CMTimeRangeMake(start: swapTime2, duration: beatLength2))
        
        do {
            try  videoObject.mixComposition.tracks[index2].insertTimeRange(
            CMTimeRangeMake(start: swapTime1, duration: beatLength2),
            of: (delegate?.avAssets[firstTrackIndex].tracks(withMediaType: .video)[0])!,
            at: swapTime2)
        } catch {
          print("Failed to swap track")
          return
        }
        if(firstTrackIndex != secondTrackIndex && track1ID != track2ID) {
            print("Good luck x2 mr bingas")
            
            let newSecondInstruction = VideoHelper.videoCompositionInstruction(
                videoObject.mixComposition.tracks[index2],
                asset: (delegate?.avAssets[secondTrackIndex])!)
            let secondTime = CMTimeAdd(swapTime2, beatLength2)
              
            newSecondInstruction.setOpacity(0.0, at: secondTime)
            secondTempInstruction = newSecondInstruction
        }
        
        track1ID = tempInstruction.trackID
        track2ID = secondTempInstruction.trackID
        print("TrackID1 (after switch): \(track1ID)")
        print("TrackID2 (after switch): \(track2ID)")
        videoObject.mainInstruction.layerInstructions[index2] = secondTempInstruction


        
        
        let secondMainComposition = AVMutableVideoComposition()
        secondMainComposition.instructions = [videoObject.mainInstruction]
        secondMainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        secondMainComposition.renderSize = CGSize(
          width: UIScreen.main.bounds.width,
          height: UIScreen.main.bounds.height)
        let secondNewPlayItem = AVPlayerItem(asset: videoObject.mixComposition)
        secondNewPlayItem.videoComposition = secondMainComposition
        
        let secondNewPlayerObject = PlayerObject(playItem: secondNewPlayItem)
        
        delegate?.playerObjects[secondTrackIndex] = secondNewPlayerObject
        
        //Swap thumbnail
        
        let tempThumbnail = thumbnails[index]
        
        thumbnails[index] = videoObject.thumbnails[index2]
        
        videoObject.thumbnails[index2] = tempThumbnail
        
    }
    
    func getSwitchTime(index: Int) ->  CMTime {
        var switchTime = CMTimeMake(value: 0,timescale: 1000)
        if (index>0) {
            for i in 1..<(index + 1) {
                switchTime = CMTimeAdd(switchTime, beatLengths[i-1])
            }
        }
        print("Switch time: \(switchTime)")
        return switchTime
    }
    
    func addFlashTransition(trackIndex: Int, index: Int, index2: Int, transitionTime: CMTime) {
        
        let rampUpTime = CMTimeSubtract(transitionTime, CMTimeMake(value: 1, timescale: 8))
        
        let firstHalfTransitionTimeRange = CMTimeRange(start: rampUpTime, end: transitionTime)
        
        let rampDownTime = CMTimeAdd(transitionTime, CMTimeMake(value: 1, timescale: 8))
        
        let secondHalfTransitionTimeRange = CMTimeRange(start: transitionTime, end: rampDownTime)
        
        let firstHalfTransitionInstruction = mainInstruction.layerInstructions[index] as! AVMutableVideoCompositionLayerInstruction
        
        let secondHalfTransitionInstruction = mainInstruction.layerInstructions[index2] as! AVMutableVideoCompositionLayerInstruction
        
        firstHalfTransitionInstruction.setOpacityRamp(fromStartOpacity: 1, toEndOpacity: 0, timeRange: firstHalfTransitionTimeRange)
        
        secondHalfTransitionInstruction.setOpacityRamp(fromStartOpacity: 0, toEndOpacity: 1, timeRange: secondHalfTransitionTimeRange)
        
        mainInstruction.layerInstructions[index] = firstHalfTransitionInstruction
        mainInstruction.layerInstructions[index2] = secondHalfTransitionInstruction
        
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = CGSize(
          width: UIScreen.main.bounds.width,
          height: UIScreen.main.bounds.height)
        let newPlayItem = AVPlayerItem(asset: mixComposition)
        newPlayItem.videoComposition = mainComposition
        
        let newPlayerObject = PlayerObject(playItem: newPlayItem)
        
        delegate?.playerObjects[trackIndex] = newPlayerObject
        
        
        
        
    }

    
}
