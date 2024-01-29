/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import AVFoundation
import MobileCoreServices
import UIKit


//let mediaUI = UIImagePickerController()


enum VideoHelper {
        
    
  static func orientationFromTransform(
    _ transform: CGAffineTransform
  ) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
    var assetOrientation = UIImage.Orientation.up
    var isPortrait = false
    let tfA = transform.a
    let tfB = transform.b
    let tfC = transform.c
    let tfD = transform.d

    if tfA == 0 && tfB == 1.0 && tfC == -1.0 && tfD == 0 {
      assetOrientation = .right
      isPortrait = true
    } else if tfA == 0 && tfB == -1.0 && tfC == 1.0 && tfD == 0 {
      assetOrientation = .left
      isPortrait = true
    } else if tfA == 1.0 && tfB == 0 && tfC == 0 && tfD == 1.0 {
      assetOrientation = .up
    } else if tfA == -1.0 && tfB == 0 && tfC == 0 && tfD == -1.0 {
      assetOrientation = .down
    }
    return (assetOrientation, isPortrait)
  }

  static func startMediaBrowser(
    delegate: RecordVideoViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate,
    sourceType: UIImagePickerController.SourceType
  ) {
      
      print("start media browser entered")
    
    

      guard UIImagePickerController.isSourceTypeAvailable(sourceType)
        else {
            print("wrecked")
            return
            
        }

      
      delegate.mediaUI = UIImagePickerController()
      
     
      delegate.mediaUI!.sourceType = .camera
      delegate.mediaUI!.videoQuality = .typeHigh
      delegate.mediaUI!.cameraDevice = .front
      delegate.mediaUI!.sourceType = sourceType
      delegate.mediaUI!.mediaTypes = [UTType.movie.identifier]
      delegate.mediaUI!.showsCameraControls = false
      delegate.mediaUI!.allowsEditing = true
      delegate.mediaUI!.delegate = delegate
      delegate.mediaUI!.cameraOverlayView = delegate.cameraViewObject?.cameraView
      delegate.mediaUI!.cameraOverlayView?.frame = (delegate.cameraViewObject?.cameraView.frame)!
      
      
    
      let translate = CGAffineTransform(translationX: 0.0, y: 71.0); //This slots the preview exactly in the middle of the screen by moving it down 71 points
      delegate.mediaUI!.cameraViewTransform = translate;
      
      let screenBounds = UIScreen.main.bounds.size

      print("Test scale: \(screenBounds.height / screenBounds.width)")
      let scale = translate.scaledBy(x: 1.2, y: 1.2)
      delegate.mediaUI!.cameraViewTransform = scale;

      delegate.present(delegate.mediaUI!, animated: true, completion: nil)

  }
    
    


  static func videoCompositionInstruction(
    _ track: AVCompositionTrack,
    asset: AVAsset
  ) -> AVMutableVideoCompositionLayerInstruction {
    let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]

    let transform = assetTrack.preferredTransform
    let assetInfo = orientationFromTransform(transform)

    let scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
    if assetInfo.isPortrait {
      let scaleToFitRatioX = UIScreen.main.bounds.width / assetTrack.naturalSize.height
      let scaleToFitRatioY = UIScreen.main.bounds.height / assetTrack.naturalSize.width



      let scaleFactor = CGAffineTransform(
        scaleX: (scaleToFitRatioX),
        y: scaleToFitRatioY).translatedBy(x: (UIScreen.main.bounds.width*(1/scaleToFitRatioX)), y: 0).scaledBy(x: -1.0, y: 1.0)
      instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),at: .zero)
//        var transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0);
//        transform = transform.scaledBy(x: -1.0, y: 1.0);
//        instruction.setTransform(assetTrack.preferredTransform.concatenating(transform),at: .zero)

//        let transform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//        instruction.setTransform(
//          assetTrack.preferredTransform.concatenating(transform),
//          at: .zero)
    } else {
      let scaleFactor = CGAffineTransform(
        scaleX: scaleToFitRatio,
        y: scaleToFitRatio)
      var concat = assetTrack.preferredTransform.concatenating(scaleFactor)
        .concatenating(CGAffineTransform(
          translationX: 0,
          y: UIScreen.main.bounds.width / 2))
      if assetInfo.orientation == .down {
        let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        let windowBounds = UIScreen.main.bounds
        let yFix = assetTrack.naturalSize.height + windowBounds.height
        let centerFix = CGAffineTransform(
          translationX: assetTrack.naturalSize.width,
          y: yFix)
        concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
      }
      instruction.setTransform(concat, at: .zero)
    }

    return instruction
  }
}

