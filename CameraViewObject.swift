//
//  CameraViewObject.swift
//  Adami
//
//  Created by Jack Cockfield on 2022-09-07.
//

import Foundation
import AVFoundation
import UIKit


class CameraViewObject {
    var cameraView = UIView()
    var countDown = 3
    var button = UIButton(type: .custom)
    var label = UILabel()
    weak var delegate: VideoObjectDelegate?
    unowned let parent: RecordVideoViewController
    
    init(parent: RecordVideoViewController){
        self.parent = parent
       
        setUpOverlay()
        
        hideLabel()
        
        cameraView.frame = parent.view.frame
    }
    
    func setUpOverlay(){
        setUpLabel()
        setUpButton()
        cameraView.addSubview(button)
        cameraView.addSubview(label)
    }
    
    func setUpButton() {
        button.setTitle("Record", for: .normal)
        button.isUserInteractionEnabled = true
        button.frame = CGRect(x: parent.view.center.x-45, y: parent.view.center.y + 355, width: 90, height: 90)
        button.addTarget(self, action: #selector(self.didPressShootButton), for: .touchUpInside)
    }
    
    func setUpLabel() {
        label.frame = CGRect(x: parent.view.center.x-90, y: parent.view.center.y-90, width: 180, height: 180)
        label.text = String(countDown)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.textColor = .white
        label.font = label.font.withSize(100)
    }
    func updateLabel(int: Int) {
        label.text = String(int)
    }
    func hideLabel() {
        label.isHidden = true
    }
    func showLabel() {
        label.isHidden = false
    }
    @IBAction func didPressShootButton(){
        if(!parent.isRecording) {

            parent.startTimer()
        
            print("Recording")
            parent.isRecording = true
            
        } else {
            parent.audioPlayer.stop()
            delegate?.mediaUI!.stopVideoCapture()
            parent.isRecording = false
            print("Stop Recording")
            button.setTitleColor(.white, for: .normal)

        }
    }
    
}
