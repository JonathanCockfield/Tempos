//
//  ViewController.swift
//  Adami
//
//  Created by Jack Cockfield on 2021-02-05.
//

import UIKit
import MobileCoreServices
import AVKit
import MediaPlayer
import Photos
import aubio



class VideoCell: UICollectionViewCell {}

class RecordVideoViewController: UIViewController, AVAudioPlayerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, VideoObjectDelegate {
    
    //Objects
    
    var cameraViewObject: CameraViewObject?
    
    //Arrays
    
    var videoObjects: [VideoObject] = []
    
    var playerObjects: [PlayerObject] = []
    
    var avAssets: [AVAsset] = []
    
    var collectionViews: [UICollectionView] = []
    
    var beatTimeArrayCMTime: [CMTime] = []
    
    func addToBeatTimeArrayCMTime(newElement: CMTime) {
        beatTimeArrayCMTime.append(newElement)
    }
    
    var beatTimeArrayStartTimes: [CMTime] = []
    
    func addToBeatTimeArrayStartTimes(newElement: CMTime) {
        beatTimeArrayStartTimes.append(newElement)
    }
    
    var beatTimeArrayStartTimesWith0: [CMTime] = [CMTime(value: 0, timescale: 1000)]
    
    func addToBeatTimeArrayStartTimesWith0(newElement: CMTime) {
        beatTimeArrayStartTimesWith0.append(newElement)
    }
    
    //View Controllers
    
    let avPlayerViewController = AVPlayerViewController()
    
    let songRetrieverTableViewController = SongRetrieverTableViewController()
    
    
    
    
    var mediaUI: UIImagePickerController?

    
    //
    
    //Views
    
    weak var cameraView: UIView!
    
    var collectionview: UICollectionView!
    
    let circleView = UIView()
    
    var blackBar = UIView()
    
    var collectionViewHolder = UIView()
    
    //
    
    //Players
    
    var audioPlayer = AVAudioPlayer()
    
    var videoPlayer = AVPlayer()
    
    var playerHolder = AVPlayer()
    
    var pulseTimers: [Timer] = []

    //
    
    //Booleans
    
    var isRecording = false
    
    var isPlaying = false
        
    var isVideoPlayerSetUp = false
    
    var isPaused = true
    
    var isVideoPlayerAdded = false
    
    var isSwapVideoActivated = false
    
    var isSplitVideoActivated = false
    
    var isFlashTransitionActivated = false
    
    var isJoinVideoActivated = false
    
    //
    
    //Numeric Values
    
    var testNumber = 5
    
    var firstClipTrackIndex = Int()
    
    var firstClipIndex = Int()
    
    var secondClipTrackIndex = Int()
    
    var secondClipIndex = Int()
    
    var selectVideoClipCount = 0
    
    var countDown = 3
    
    var beatCount = 0
    
    //
    
    //Dimension Values
    
    var cellSize = CGSize(width: 150, height: 150)
    
    var cellSpacing = 8
    
    var bottomBar = 30
    
    //
    
    //Labels
    
    var countDownLabel = UILabel()
    
    var beatCountLabel = UILabel()
    
    //
    

    //Outlets
    
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    @IBOutlet weak var swapButtonOutlet: UIButton!
    
    @IBOutlet weak var splitButtonOutlet: UIButton!
    
    @IBOutlet weak var joinButtonOutlet: UIButton!
    
    @IBOutlet weak var slowButtonOutlet: UIButton!
    
    @IBOutlet weak var reverseButtonOutlet: UIButton!
    
    @IBOutlet weak var flashButtonOutlet: UIButton!
    
    @IBOutlet weak var editMenu: UIView!
    
    //
    
    //Actions
    
    @IBAction func activateSwapVideo(_ sender: Any) {
        if(!isSwapVideoActivated) {
            print("swapping activated")
            isSwapVideoActivated = true
            reloadCollectionViewData()
            avPlayerViewController.view.layer.opacity = 0.2
            
            addButtonOutlet.isHidden = true
            
            splitButtonOutlet.isHidden = true
            
            joinButtonOutlet.isHidden = true
            
            slowButtonOutlet.isHidden = true
            
            reverseButtonOutlet.isHidden = true
            
            flashButtonOutlet.isHidden = true
        } else {
            print("swapping ended")
            isSwapVideoActivated = false
            reloadCollectionViewData()
            avPlayerViewController.view.layer.opacity = 1
            
            addButtonOutlet.isHidden = false
            
            splitButtonOutlet.isHidden = false
            
            joinButtonOutlet.isHidden = false
            
            slowButtonOutlet.isHidden = false
            
            reverseButtonOutlet.isHidden = false
            
            flashButtonOutlet.isHidden = false
            
        }
        
    }
    
    @IBAction func addButtonInMenu(_ sender: Any) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
    }
    
    @IBAction func splitButtonAction(_ sender: Any) {
        if(!isSplitVideoActivated) {
            isSplitVideoActivated = true
            
            reloadCollectionViewData()
            
            avPlayerViewController.view.layer.opacity = 0.2
            
            addButtonOutlet.isHidden = true
            
            swapButtonOutlet.isHidden = true
            
            joinButtonOutlet.isHidden = true
            
            slowButtonOutlet.isHidden = true
            
            reverseButtonOutlet.isHidden = true
            
            flashButtonOutlet.isHidden = true
        } else {
            isSplitVideoActivated = false
            
            reloadCollectionViewData()
            
            avPlayerViewController.view.layer.opacity = 1
            
            addButtonOutlet.isHidden = false
            
            swapButtonOutlet.isHidden = false
            
            joinButtonOutlet.isHidden = false
            
            slowButtonOutlet.isHidden = false
            
            reverseButtonOutlet.isHidden = false
            
            flashButtonOutlet.isHidden = false
        }
        
    }
    
    @IBAction func joinButtonAction(_ sender: Any) {
    }
    
    
    @IBAction func slowButtonAction(_ sender: Any) {

    }
    
    @IBAction func reverseButtonAction(_ sender: Any) {
    }
    
    @IBAction func flashButtonAction(_ sender: Any) {
        if(!isFlashTransitionActivated) {
            print("flash transition activated")
            isFlashTransitionActivated = true
            reloadCollectionViewData()
            avPlayerViewController.view.layer.opacity = 0.2
            
            addButtonOutlet.isHidden = true
            
            swapButtonOutlet.isHidden = true
            
            splitButtonOutlet.isHidden = true
            
            joinButtonOutlet.isHidden = true
            
            slowButtonOutlet.isHidden = true
            
            reverseButtonOutlet.isHidden = true
            
        } else {
            print("swapping ended")
            isFlashTransitionActivated = false
            reloadCollectionViewData()
            avPlayerViewController.view.layer.opacity = 1
            
            swapButtonOutlet.isHidden = false
            
            addButtonOutlet.isHidden = false
            
            splitButtonOutlet.isHidden = false
            
            joinButtonOutlet.isHidden = false
            
            slowButtonOutlet.isHidden = false
            
            reverseButtonOutlet.isHidden = false
            
            
        }
    }
    
    //
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        songRetrieverTableViewController.delegate = self
        
        chooseSong()
                
    }
    
    private func setupCircleView() {
        let diameter: CGFloat = 50
        circleView.frame = CGRect(x: (view.bounds.width - diameter) / 2,
                                  y: (view.bounds.height - diameter) / 2,
                                  width: diameter,
                                  height: diameter)
        circleView.backgroundColor = .red
        circleView.layer.cornerRadius = diameter / 2
        view.addSubview(circleView)
    }
    
    private func setupNumberLabel() {
        let diameter: CGFloat = 50
        beatCountLabel.frame = CGRect(x: (view.bounds.width - diameter) / 2,
                                  y: (view.bounds.height - diameter) / 2,
                                  width: diameter/2,
                                  height: diameter/2)
        beatCountLabel.backgroundColor = .white
        beatCountLabel.text = String(beatCount)
        view.addSubview(beatCountLabel)
    }
    
    private func updateBeatCountLabel(int: Int) {
        beatCountLabel.text = String(int)
    }
    
    func startBeatIndicator() {
//        let pulseTimes: [CMTime] = [CMTime(seconds: 2, preferredTimescale: 1),
//                                            CMTime(seconds: 4, preferredTimescale: 1),
//                                            CMTime(seconds: 6, preferredTimescale: 1)]
                
        for time in beatTimeArrayStartTimes {
            DispatchQueue.main.asyncAfter(deadline: .now() + time.seconds) {
                        print("Beat time in pulser: ", time.seconds)
                        self.beatCount+=1
                self.updateBeatCountLabel(int: 1)
                        self.pulseCircle()
                    }
                }
    }
    
    private func startPulsingAtTimes(_ times: [CMTime]) {
         for time in times {
             let timer = Timer.scheduledTimer(withTimeInterval: (time.seconds-0.05), repeats: false) { [weak self] _ in
                 self?.pulseCircle()
             }
             pulseTimers.append(timer)
         }
     }

     func stopAndResetPulse() {
         // Stop animations on the circle and reset its transform
         circleView.layer.removeAllAnimations()
         circleView.transform = CGAffineTransform.identity
         
         // Invalidate timers
         pulseTimers.forEach { $0.invalidate() }
         pulseTimers.removeAll()
     }
    
    private func pulseCircle() {
            let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.duration = 0.1
            pulseAnimation.fromValue = 1.0
            pulseAnimation.toValue = 1.7
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            pulseAnimation.autoreverses = true
            circleView.layer.add(pulseAnimation, forKey: "pulse")
        }
    
    func restructureCollectionViews() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = cellSize
        layout.scrollDirection = .horizontal
//        var startingPoint = CGPoint()
        layout.itemSize = cellSize
        if(videoObjects.count > 1) {
            for (index, collectionView) in collectionViews.enumerated() {
                switch videoObjects.count {
                case 2:
                    cellSize = CGSize(width: 130, height: 130)
                    cellSpacing = 7
                    let height = UIScreen.main.bounds.height - (CGFloat((2-index)) * cellSize.height)
                    let startingPoint = CGPoint(x: 0, y: Int(height) - bottomBar - (cellSpacing - (index * cellSpacing)))
                    collectionView.frame = CGRect(origin: startingPoint, size: CGSize(width: UIScreen.main.bounds.width, height: cellSize.height))
                    collectionView.collectionViewLayout = layout

                case 3:
                    cellSize = CGSize(width: 110, height: 110)
                    cellSpacing = 6
                    let height = UIScreen.main.bounds.height - (CGFloat((3-index)) * cellSize.height)
                    let startingPoint = CGPoint(x: 0, y: (Int(height) - (cellSpacing - (index * cellSpacing))) - bottomBar)
                    collectionView.frame = CGRect(origin: startingPoint, size: CGSize(width: UIScreen.main.bounds.width, height: cellSize.height))
                    collectionView.collectionViewLayout = layout
                default:
                    print("default")
                }
            }
        }
    }

    
    func createCollectionView() -> UICollectionView{
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = cellSize
        layout.scrollDirection = .horizontal
        var startingPoint = CGPoint()

        startingPoint = CGPoint(x: 0, y: Int(UIScreen.main.bounds.height - cellSize.height) - bottomBar - 20)

        let frame = CGRect(origin: startingPoint, size: CGSize(width: UIScreen.main.bounds.width, height: cellSize.height))
        
        
        let videoCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        videoCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: String(videoObjects.count - 1))
        videoCollectionView.tag = videoObjects.count - 1
       
        
        videoCollectionView.backgroundColor = UIColor.clear
        videoCollectionView.showsHorizontalScrollIndicator = false
        
        videoCollectionView.dataSource = self
        videoCollectionView.delegate = self
        
        return videoCollectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoObjects[collectionView.tag].amountOfClips
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        let imageView: UIImageView=UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: cellSize))
        
        var flippedImage = UIImage()
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(collectionView.tag), for: indexPath as IndexPath)
        flippedImage = videoObjects[collectionView.tag].thumbnails[indexPath.row].withHorizontallyFlippedOrientation()
           
        let numberLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: cellSize))
        
        numberLabel.text = String(indexPath.row + 1)
        numberLabel.textColor = .white
        numberLabel.clipsToBounds = true
        numberLabel.textAlignment = .center
        numberLabel.font = numberLabel.font.withSize(40)
        
        let radius: CGFloat = 30
        cell.layer.cornerRadius = radius
        
        imageView.image = flippedImage

        imageView.clipsToBounds = true

        imageView.layer.cornerRadius = radius
        
        cell.isSelected = false
        
        cell.contentView.removeAllSubviews()
        
        cell.contentView.addSubview(imageView)
        if(isSwapVideoActivated || isFlashTransitionActivated) {
            print("labels activated")
            cell.contentView.addSubview(numberLabel)
        }

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        cell.contentView.addGestureRecognizer(swipeDown)
        cell.contentView.tag = indexPath.row
        
        let borderColor = UIColor.white
        
//        cell.layer.borderColor = borderColor.withAlphaComponent(opacity).cgColo=
        
        cell.layer.borderColor = borderColor.cgColor
        cell.layer.borderWidth = 2
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return CGFloat(cellSpacing)
    }
    
    func swapVideo(indexPath: IndexPath, collectionView: UICollectionView) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            print("cell selected")
            cell.layer.borderColor = #colorLiteral(red: 0.5045119524, green: 1, blue: 0.9686291814, alpha: 1)
            cell.layer.borderWidth = 3
            cell.layer.opacity = 0.5
        }
        if(selectVideoClipCount == 0) {
            firstClipTrackIndex = collectionView.tag
            firstClipIndex = indexPath.row
            selectVideoClipCount = 1
            collectionView.cellForItem(at: indexPath)?.isSelected = true
        } else {
            secondClipTrackIndex = collectionView.tag
            secondClipIndex = indexPath.row
            selectVideoClipCount = 0
            collectionView.cellForItem(at: indexPath)?.isSelected = true

            videoObjects[firstClipTrackIndex].switchInstruction(index: firstClipIndex, index2: secondClipIndex, videoObject: videoObjects[secondClipTrackIndex], firstTrackIndex: firstClipTrackIndex, secondTrackIndex: secondClipTrackIndex)
            avPlayerViewController.view.layer.opacity = 1
            isSwapVideoActivated = false
            reloadCollectionViewData()
        }
    }
    
    func splitVideo(indexPath: IndexPath, collectionView: UICollectionView) {
        
    }
    
    func addFlashTransition(indexPath: IndexPath, collectionView: UICollectionView) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            print("cell selected")
            cell.layer.borderColor = #colorLiteral(red: 0.5045119524, green: 1, blue: 0.9686291814, alpha: 1)
            cell.layer.borderWidth = 3
            cell.layer.opacity = 0.5
        }
        if(selectVideoClipCount == 0) {
            firstClipTrackIndex = collectionView.tag
            firstClipIndex = indexPath.row
            selectVideoClipCount = 1
            collectionView.cellForItem(at: indexPath)?.isSelected = true
        } else {
            let transitionTime = beatTimeArrayCMTime[firstClipTrackIndex]
            secondClipIndex = indexPath.row
            selectVideoClipCount = 0
            collectionView.cellForItem(at: indexPath)?.isSelected = true
            
            videoObjects[collectionView.tag].addFlashTransition(trackIndex: collectionView.tag, index: firstClipIndex, index2: secondClipIndex, transitionTime: transitionTime)
            avPlayerViewController.view.layer.opacity = 1
            isFlashTransitionActivated = false
            reloadCollectionViewData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        if(isSwapVideoActivated) {
            swapVideo(indexPath: indexPath, collectionView: collectionView)
        }
        if (isFlashTransitionActivated) {
            addFlashTransition(indexPath: indexPath, collectionView: collectionView)
        }
        else {
            collectionView.cellForItem(at: indexPath)?.isSelected = false
            
            avPlayerViewController.player = playerObjects[collectionView.tag].avPlayer

            videoPlayer = avPlayerViewController.player!
            
            toggleUI()
            isPaused = false
            
            var playTime = beatTimeArrayStartTimesWith0[indexPath.row]
            

            print("play time start: \(playTime)")
            videoPlayer.seek(to: playTime)
            videoPlayer.seek(to: playTime) { [self] Bool in
                print("play time current time in closure:\(videoPlayer.currentTime().seconds)")
                videoPlayer.play()
            }
            print("play time current time:\(videoPlayer.currentTime().seconds)")
            
        }

    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            let index = swipeGesture.view!.tag
            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
            case .down:
                print("Swiped down")
                videoObjects[0].switchInstruction(index: index, index2: index, videoObject: videoObjects[1], firstTrackIndex: 0, secondTrackIndex: 1)
            case .left:
                print("Swiped left")
            case .up:
                print("Swiped up")
            default:
                break
            }
            print("Tag: \(swipeGesture.view!.tag)")

        }
    }

    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (Timer) in
            if self!.countDown > 0 {
                print ("\(self!.countDown) seconds")
                self?.countDown -= 1
                self?.cameraViewObject?.showLabel()
                self?.cameraViewObject?.updateLabel(int: (self!.countDown + 1))
            } else {
                self?.countDown = 3
                Timer.invalidate()
                self?.cameraViewObject?.hideLabel()
                self?.cameraViewObject?.button.setTitleColor(.red, for: .normal)
                do {
                    let sPlayer = try AVAudioPlayer(contentsOf: self!.songRetrieverTableViewController.getSongURL())
                    self?.audioPlayer = sPlayer
                    self?.audioPlayer.prepareToPlay()
                    self?.audioPlayer.play()
                    self?.mediaUI!.startVideoCapture()
                }
                catch {
                    print(error)
                }
                self?.startVideoLengthTimer()

            }
        }
    }
    

    
    func startVideoLengthTimer() {
        var counter = 8
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (Timer) in
            if counter > 0 {
                print(counter)
                counter -= 1
            } else {
                counter = 10
                Timer.invalidate()
                self?.audioPlayer.stop()
                self?.mediaUI!.stopVideoCapture()
                self?.isRecording = false
                self?.cameraViewObject?.button.setTitleColor(.white, for: .normal)
            }
        }
    }

    
    func record() {
        print("Record UI activated")
        
        let cameraViewObjectToBeStored = CameraViewObject(parent: self)
        
        cameraViewObject = cameraViewObjectToBeStored
        
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)

    }
    
    
    func chooseSong() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: NSNotification.Name(rawValue: "modalIsDimissed"), object: nil)
        self.view.addSubview(songRetrieverTableViewController.view)
        songRetrieverTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        songRetrieverTableViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        songRetrieverTableViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        songRetrieverTableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        songRetrieverTableViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    @objc func handleModalDismissed() {
        record()
    }
    
    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      dismiss(animated: true, completion: nil)
      
      guard
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
        mediaType == (UTType.movie.identifier),
        // 1
        let urlHolder = info[UIImagePickerController.InfoKey.mediaURL] as? URL
      
        else { return }
        
        
        videoCompiler(url: urlHolder)

    }
    
    func videoCompiler(url: URL)
    {

        let avAsset = AVAsset(url: url)
        
        avAssets.append(avAsset)
        
        let videoObject = VideoObject(avAsset: avAsset, songURL: songRetrieverTableViewController.getSongURL(), beatLengthArray: beatTimeArrayCMTime)
        
        videoObject.delegate = self
        

        videoObjects.append(videoObject)
        

        let playerObject = PlayerObject(playItem: videoObjects[videoObjects.count-1].playItem!)
        
        playerObjects.append(playerObject)
        
        playerHolder = playerObject.avPlayer
        
        avPlayerViewController.player = playerHolder
        videoPlayer = avPlayerViewController.player!
        
        avPlayerViewController.showsPlaybackControls = false
        
//        parent.setUpCollectionView()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        
        avPlayerViewController.view.addGestureRecognizer(gesture)
        
        addChild(avPlayerViewController)
       
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd),
                                                                 name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                                 object: nil) // Add observer
        
        videoPlayer.seek(to: CMTime.zero)

        
        if(!isVideoPlayerAdded) {
            setUpUI()
        }
        
        //Create and add collection view

        let newCollectionView = createCollectionView()
        
        collectionViews.append(newCollectionView)
        
        restructureCollectionViews()
        
        
        view.addSubview(newCollectionView)
        
        view.bringSubviewToFront(collectionViewHolder)
        
        reloadCollectionViewData()
        
        isPaused = false
        
        toggleUI()
        
        isPaused = true

        
    }
    
    func setUpUI() {
        view.addSubview(avPlayerViewController.view)
        isVideoPlayerAdded = true
    
        view.addSubview(swapButtonOutlet)

        view.addSubview(addButtonOutlet)
        
        view.addSubview(splitButtonOutlet)
        
        view.addSubview(joinButtonOutlet)
        
        view.addSubview(slowButtonOutlet)
        
        view.addSubview(reverseButtonOutlet)
        
        view.addSubview(flashButtonOutlet)
        
        setupCircleView()
        
        setupNumberLabel()

        
        
        //Create and add blackbar UIView
        
        let barFrame = CGRect(x: 0, y: Int(UIScreen.main.bounds.height) - bottomBar, width: Int(UIScreen.main.bounds.width), height: bottomBar)
        
        blackBar = UIView(frame: barFrame)
        
        blackBar.backgroundColor = UIColor.black
        
        view.addSubview(blackBar)
        
        //Create and add collectionView holder
        
        let collectionViewHolderFrame = CGRect(x: -15, y: Int(UIScreen.main.bounds.height - cellSize.height) - bottomBar - 40, width: Int(UIScreen.main.bounds.width) + 30, height: Int(cellSize.height) + 80)
        
//            let collectionViewHolderFrame = CGRect(x: 0, y: Int(UIScreen.main.bounds.height - cellSize.height) - bottomBar - 40, width: Int(UIScreen.main.bounds.width), height: Int(cellSize.height) + 80)
        
        collectionViewHolder = UIView(frame: collectionViewHolderFrame)
        
        collectionViewHolder.backgroundColor = .clear
        
        collectionViewHolder.layer.borderColor = UIColor.white.cgColor
        
        collectionViewHolder.layer.borderWidth = 2
        
        let radius: CGFloat = 23
        
        collectionViewHolder.layer.cornerRadius = radius
        
        collectionViewHolder.isUserInteractionEnabled = false
        
//            view.addSubview(collectionViewHolder)
    }
    

    
    func reloadCollectionViewData() {
        for view in collectionViews {
            view.reloadData()
        }
    }
    
    func toggleUI() {
        if(!isPaused) {
            print("unhiding")
            for view in collectionViews {
                view.isHidden = false
            }
            swapButtonOutlet.isHidden = false

            addButtonOutlet.isHidden = false
            
            splitButtonOutlet.isHidden = false
            
            joinButtonOutlet.isHidden = false
            
            slowButtonOutlet.isHidden = false
            
            reverseButtonOutlet.isHidden = false
            
            flashButtonOutlet.isHidden = false
            
            blackBar.isHidden = false
        } else {
            print("hiding")
            for view in collectionViews {
                view.isHidden = true
            }
            swapButtonOutlet.isHidden = true

            addButtonOutlet.isHidden = true
            
            splitButtonOutlet.isHidden = true
            
            joinButtonOutlet.isHidden = true
            
            slowButtonOutlet.isHidden = true
            
            reverseButtonOutlet.isHidden = true
            
            flashButtonOutlet.isHidden = true
            
            blackBar.isHidden = true
        }
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        isPaused = false
        print("reached end")
        videoPlayer.seek(to: CMTime.zero)
        avPlayerViewController.player = nil
        avPlayerViewController.player = playerHolder
        videoPlayer = avPlayerViewController.player!
        toggleUI()
        stopAndResetPulse()
        isPaused = true
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        if(isPaused) {
            print("play")
            toggleUI()
            avPlayerViewController.player = playerHolder
            videoPlayer = avPlayerViewController.player!
            videoPlayer.play()
            startPulsingAtTimes(beatTimeArrayStartTimes)
            isPaused = false
        } else {
            print("pause")
            toggleUI()
            videoPlayer.pause()
            avPlayerViewController.player = nil
            avPlayerViewController.player = playerHolder
            videoPlayer = avPlayerViewController.player!
            stopAndResetPulse()
            isPaused = true
        }
    }
}



extension RecordVideoViewController: UIImagePickerControllerDelegate {
}

extension RecordVideoViewController: UINavigationControllerDelegate {
}



extension UIView {
    /// Remove all subview
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension UIImage {
    public func resized(to target: CGSize) -> UIImage {
        let ratio = min(
            target.height / size.height, target.width / size.width
        )
        let new = CGSize(
            width: size.width * ratio, height: size.height * ratio
        )
        let renderer = UIGraphicsImageRenderer(size: new)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: new))
        }
    }
}

