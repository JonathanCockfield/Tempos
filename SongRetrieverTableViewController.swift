//
//  SongRetriever.swift
//  Adami
//
//  Created by Jack Cockfield on 2021-05-17.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import AVKit
import aubio


class SongRetrieverTableViewController: UITableViewController {
    
    //Song URL to be used to create the AVAsset known as audioAsset
    var songUrl = URL(string: "")
    
    var beatTimeArrayMS: [Float] = []
    
    weak var delegate: VideoObjectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
    }
    
    func getSongURL() -> URL {
        return songUrl!
    }
    
    func setSongURL(url: URL) {
        songUrl = url
    }
    

    let songNameArray = ["Going Bad",
                         "Look At Me!",
                         "bad guy",
                         "Clout",
                         "High",
                         "Sin",
                         "STARGAZING",
                         "Nonstop",
                         "Slow Down Love",
                         "Foot Fungus",
                         "you should see me in a crown",
                         "Demons",
                         "EVERY CHANCE I GET",
                         "Faded",
                         "TOES",
                         "High Beams",
                         "Love You Like a Love Song",
                         "Go Off",
                         "Running Up That Hill (A Deal with God)",
                         "I.Y.B."]

    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songNameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        }
        if songNameArray.count > 0 {
            cell?.textLabel!.text = songNameArray[indexPath.row]
        }
        cell?.textLabel?.numberOfLines = 0
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        songSelect(indexPath: indexPath)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            return 50.0
    }
    
    func songSelect(indexPath: IndexPath){
        let storageRef = Storage.storage().reference()
        
        let childRef = storageRef.child("songs/\(songNameArray[indexPath.row]).m4a")
    
        

        childRef.downloadURL { [unowned self](url, error) in
            if let error = error {
               print(error)
           } else {
            
            print("url: \(String(describing: url))")
            setSongURL(url: url!)

            setSongURL(url: self.downloadSound(url: url!))
            
           
           }
        }

        self.view.removeFromSuperview()
    }
    func downloadSound(url:URL) -> URL {
        let docUrl:URL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let desURL = docUrl.appendingPathComponent("tmpsong.m4a")
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (URLData, response, error) -> Void in
            do{
                let isFileFound:Bool? = FileManager.default.fileExists(atPath: desURL.path)
                if isFileFound == true{
                      print("url new: \(desURL)") //delete tmpsong.m4a & copy
                    self.getTempo(url: desURL)

                    try FileManager.default.removeItem(atPath: desURL.path)
                    try FileManager.default.copyItem(at: URLData!, to: desURL)

                } else {
                    try FileManager.default.copyItem(at: URLData!, to: desURL)
                }


            }catch let err {
                print(err.localizedDescription)
            }
                
            })
        downloadTask.resume()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalIsDimissed"), object: nil)
        return desURL
    }
    func getTempo(url: URL) {
        print("get Tempo entered")
       
        let path = UnsafeMutablePointer<char_t>(mutating: (url.path as NSString).utf8String)
        if (path != nil) {
            let hop_size : uint_t = 512
            let a = new_fvec(hop_size)
            let b = new_aubio_source(path, 0, hop_size)
            let out = new_fvec(1)
            var read: uint_t = 0
            var total_frames : uint_t = 0
            let sampleRate: UInt32 = 44100
            let tempo: OpaquePointer? = new_aubio_tempo("default", 1024, hop_size, sampleRate)
            var beatTimeHolder = CMTimeMake(value: 0, timescale: 1000)
            while (true) {
                var beatCounter = 0
                if(!beatTimeArrayMS.contains(aubio_tempo_get_last_ms(tempo))) {
                    beatTimeArrayMS.append(aubio_tempo_get_last_ms(tempo))
                    let beatTimeInt64 = Int64(aubio_tempo_get_last_ms(tempo))
                    print("beatInt64: \(beatTimeInt64)")
                    let beatTime = CMTimeMake(value: beatTimeInt64, timescale: 1000)
                    
                    
                    
                    var beatTimeFinal = CMTimeMake(value: 0, timescale: 1000)
                    print("beat at: \(aubio_tempo_get_last_ms(tempo)) ms ")
                    print("beatTime: \(beatTime)")
                    if(beatTimeInt64 > 0 ) {
                        
                        beatTimeFinal = CMTimeSubtract(beatTime, beatTimeHolder)
                        
                        delegate?.addToBeatTimeArrayCMTime(newElement: beatTimeFinal)
                        
                        delegate?.addToBeatTimeArrayStartTimes(newElement: beatTime)
                        delegate?.addToBeatTimeArrayStartTimesWith0(newElement: beatTime)
                        beatCounter = beatCounter + 1
                    }
                    beatTimeHolder = beatTime
                }
                aubio_source_do(b, a, &read)
                aubio_tempo_do(tempo, a, out)
                total_frames += read
                if (beatCounter>10) { break }
                if (read < hop_size) { break }
                
            }
            print("read", total_frames, "frames at", aubio_source_get_samplerate(b), "Hz")
            print("Total beats: \(beatTimeArrayMS.count)")
            print("beat Time first index: \(delegate?.beatTimeArrayCMTime[0])")
            del_aubio_source(b)
            del_fvec(a)
        } else {
            print("could not find file")
        }
    }
    
    
    
}



