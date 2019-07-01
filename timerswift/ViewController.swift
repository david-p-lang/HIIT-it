import UIKit
import CoreBluetooth
import AVFoundation
import MediaPlayer


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var imageView:UIImageView = UIImageView()
    var navBar:UIImageView = UIImageView()
    var connectionBarButton:UIButton = UIButton()
    var setupBarButton:UIButton = UIButton()
    var workoutBarButton:UIButton = UIButton()

    //connection
    let heartRateDisplay:UILabel = UILabel()
    let scanButton:UIButton = UIButton()
    let promptConnect = UILabel()
    
    //setup
    let HRGModButton:UIButton = UIButton()
    let intModButton:UIButton = UIButton()
    let restModButton:UIButton = UIButton()
    let warmupModButton:UIButton = UIButton()
    let cooldownModButton:UIButton = UIButton()
    
    let displayView:UIView = UIView()
 
    @IBOutlet weak var workoutPhase: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hrLabel: UILabel!
    @IBOutlet weak var nextSegLabel: UILabel!
    @IBOutlet weak var nextGoalLabel: UILabel!
    

    let startButton:UIButton = UIButton()
    let nextPhaseButton:UIButton = UIButton()
    let songTitle: UILabel = UILabel()
    let songSlider: UISlider = UISlider()
    let forwardButton:UIButton = UIButton()
    let backButton:UIButton = UIButton()
    let playMusic:UIButton = UIButton()
    let playlistButton:UIButton = UIButton()
    let increaseHRButton:UIButton = UIButton()
    let decreaseHRButton:UIButton = UIButton()
    let playerView:UIImageView = UIImageView()
    var isWorkoutStarted = false
    
    @IBOutlet weak var resultsTable: UITableView!
    
    //Custom classes
    var theMonitor = HeartRateLEMonitor()
    
    var theWorkout = Workout()
    
    //Workout Variable
    var phaseChangeDetector = 0
    var aboveGoal = false
    var justGettingThere = false
    var loadedOnce = false

    //start connection timer
    var connectionTimer: Timer!
    var count:Int = 0
    var timerActivated = false
    
    var notification:NotificationCenter = NotificationCenter.default

    
    //Music 
    var mediaQuery = MPMediaQuery.playlists()
    var playlists:[AnyObject]!
    var musicPlayer:AVQueuePlayer!
    var myPlayer:MPMusicPlayerController = MPMusicPlayerController.applicationMusicPlayer
    var playlistPath:NSIndexPath?
    var notifications:NotificationCenter = NotificationCenter.default
    var songLength:Float!
    var musicTimer:Timer!
    var musicShouldPlay = true
    var playlistHasBeenOpened = true
    var musicDefaults = UserDefaults.standard
    
    //AUDIO PLAYER
    
    var theVoice = VoiceGuide()
    var alarmSound = NSURL()
    var audioPlayer = AVAudioPlayer()
    var soundReady = false
    var avas = AVAudioSession()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        self.playlists = mediaQuery.collections
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        avas = AVAudioSession.sharedInstance()
        //try
            //audioResponse:AnyObject = avas.setPreferredOutputNumberOfChannels(3) as AnyObject
        //catch
        do {
            try avas.setCategory(AVAudioSession.Category.ambient)
        } catch  {
            print("/(Error)")
        }

        
        if loadedOnce == false {
            theWorkout.timerCount = self.theWorkout.warmupTime
        } else {
        }
        loadedOnce = true
        
        
        
        notification.addObserver(self, selector: Selector(("chooseMonitor:")), name: NSNotification.Name(rawValue: "devices"), object: nil)
        notification.addObserver(self, selector: Selector(("receiveHeartRate:")), name: NSNotification.Name(rawValue: "heartRateBroadcast"), object: nil)
     
    }
    
    func setupScreen() {
        imageView.image = UIImage(named: "launchimage")
        imageView.contentMode = UIView.ContentMode.center
        let connectionWidth = Int(self.view.bounds.width/3)
        let setupWidth = connectionWidth
        let workoutButtonWidth = connectionWidth + 3 //connectionWidth * 2 - Int(self.view.bounds.width)
        
        print("screen \(self.view.bounds.width)  button   \(connectionWidth + setupWidth + workoutButtonWidth)")
        


        promptConnect.frame = CGRect(x: 0, y: Int(self.view.frame.height/2), width: Int(self.view.frame.width), height: 50)
        promptConnect.text = "Connect a Bluetooth Heart Rate Monitor"
        promptConnect.textColor = UIColor.white
        promptConnect.textAlignment = NSTextAlignment.center
        //self.view.addSubview(promptConnect)

    
        connectionBarButton.frame = CGRect(x: 0, y: Int(self.view.bounds.height - 44), width: connectionWidth, height: 44)
        connectionBarButton.setTitle("Connect", for: UIControlState.normal)
        connectionBarButton.addTarget(self, action: #selector(ViewController.connect), for: UIControlEvents.touchUpInside)
        connectionBarButton.setBackgroundImage(UIImage(named: "buttonback"), for: UIControlState.normal)
        self.view.addSubview(connectionBarButton)
        
        setupBarButton.frame = CGRect(x: connectionWidth, y: Int(self.view.bounds.height - 44), width: setupWidth, height: 44)
        setupBarButton.setTitle("Setup", for: UIControlState.normal)
        setupBarButton.addTarget(self, action: #selector(ViewController.setup), for: UIControlEvents.touchUpInside)
        setupBarButton.setBackgroundImage(UIImage(named: "buttonback"), for: UIControlState.normal)
        self.view.addSubview(setupBarButton)

        workoutBarButton.frame = CGRect(x: connectionWidth * 2, y: Int(self.view.bounds.height - 44), width: workoutButtonWidth, height: 44)
        workoutBarButton.setTitle("Workout", for: UIControlState.normal)
        workoutBarButton.addTarget(self, action: #selector(ViewController.workout), for: UIControlEvents.touchUpInside)
        workoutBarButton.setBackgroundImage(UIImage(named: "buttonback"), for: UIControlState.normal)
        self.view.addSubview(workoutBarButton)
        
    }
    
    @objc func connect() {
        print("hit connect")
        sideBarDidSelectButtonAtIndex(index: 0)
    }
    @objc func setup() {
        sideBarDidSelectButtonAtIndex(index: 1)
    }
    @objc func workout() {
        sideBarDidSelectButtonAtIndex(index: 2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func sideBarDidSelectButtonAtIndex(index: Int) {
        if index == 0{
            imageView.backgroundColor = UIColor.blue
            imageView.image = UIImage(named: "launchimage")
            
            promptConnect.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            theMonitor.startUpCentralManager()
            
            hideSetupItems()
            hideWorkoutItems()
            setupMusicPlayerBar()
            
            heartRateDisplay.text = "Get Connected"
            heartRateDisplay.font = UIFont.systemFont(ofSize: 25)
            heartRateDisplay.textColor = UIColor.white
            heartRateDisplay.textAlignment = NSTextAlignment.center
            heartRateDisplay.frame = CGRect(x: 0, y: 30, width: self.view.bounds.width, height: 50)
            self.view.addSubview(heartRateDisplay)
            
            scanButton.frame = CGRect(x: 0, y: 140, width: Int(self.view.bounds.width), height: 50)
            scanButton.setBackgroundImage(UIImage(named: "buttonback"), for: UIControlState.normal)
            scanButton.setTitle("Find Monitor", for: UIControlState.normal)
            scanButton.addTarget(self, action: #selector(ViewController.scan), for: UIControlEvents.touchUpInside)
            self.view.addSubview(scanButton)
            
            if playlistHasBeenOpened == false {
                playlistButton.frame = CGRect(x: 0, y:self.view.bounds.height - 40, width: self.view.bounds.width, height: 40)
                playlistButton.setImage(UIImage(named: "playlist"), for: UIControlState.normal)
                playlistButton.addTarget(self, action: #selector(ViewController.showPlaylist), for: UIControlEvents.touchUpInside)
                self.view.addSubview(playlistButton)
                
            } else {
                setupMusicPlayerBar()
            }
            
            if theMonitor.currentHeartRate >= 10 {
                theVoice.tellUser(guidance: "Monitor already connected")
            }
            
        } else if index == 1{
            imageView.backgroundColor = UIColor.clear
            imageView.image = UIImage(named: "launchimage")
            
            hideConnectionItems()
            hideWorkoutItems()
            setupMusicPlayerBar()
            
            HRGModButton.frame = CGRect(x: 0, y: 100, width: self.view.bounds.width, height: 50)
            HRGModButton.setBackgroundImage(UIImage(named: "buttonback"), for: UIControlState.normal)
            HRGModButton.setTitle("Heart Rate Goal: " + String(theWorkout.heartRateGoal), for: UIControlState.normal)
            HRGModButton.addTarget(self, action: #selector(ViewController.modHRG), for: UIControlEvents.touchUpInside)
            self.view.addSubview(HRGModButton)
            
            intModButton.frame = CGRect(x: 0, y: 155, width: self.view.bounds.width, height: 50)
            intModButton.setBackgroundImage(UIImage(named: "buttonback"), for: UIControlState.normal)
            intModButton.setTitle("Interval number: " + String(theWorkout.intervalCount), for: UIControlState.normal)
            intModButton.addTarget(self, action: #selector(ViewController.modInt), for: UIControlEvents.touchUpInside)
            self.view.addSubview(intModButton)
            
            restModButton.frame = CGRect(x: 0, y: 210, width: self.view.bounds.width, height: 50)
            restModButton.setBackgroundImage(UIImage(named: "buttonback"), for: UIControlState.normal)
            restModButton.setTitle("Rest time: " + displayTime(theTime: theWorkout.restTime), for: UIControlState.normal)
            restModButton.addTarget(self, action: #selector(ViewController.modRest), for: UIControlEvents.touchUpInside)
            self.view.addSubview(restModButton)
            
            warmupModButton.frame = CGRect(x: 0, y: 265, width: self.view.bounds.width, height: 50)
            warmupModButton.setBackgroundImage(UIImage(named: "buttonback"), for: UIControlState.normal)
            warmupModButton.setTitle("Warmup Time: " + displayTime(theTime: theWorkout.warmupTime), for: UIControlState.normal)
            warmupModButton.addTarget(self, action: #selector(ViewController.modWarmup), for: UIControlEvents.touchUpInside)
            self.view.addSubview(warmupModButton)
            
            cooldownModButton.frame = CGRect(x: 0, y: 320, width: self.view.bounds.width, height: 50)
            cooldownModButton.setBackgroundImage(UIImage(named: "buttonback"), for: UIControlState.normal)
            cooldownModButton.setTitle("Cooldown Time: " + displayTime(theTime: theWorkout.cooldownTime), for: UIControlState.normal)
            cooldownModButton.addTarget(self, action: #selector(ViewController.modCooldown), for: UIControlEvents.touchUpInside)
            self.view.addSubview(cooldownModButton)
            
            if playlistHasBeenOpened == false {
                playlistButton.frame = CGRect(x: 0, y:self.view.bounds.height - 40, width: self.view.bounds.width, height: 40)
                playlistButton.setImage(UIImage(named: "playlist"), for: UIControlState.normal)
                playlistButton.addTarget(self, action: #selector(ViewController.showPlaylist), for: UIControlEvents.touchUpInside)
                self.view.addSubview(playlistButton)
                
            } else {
                setupMusicPlayerBar()
            }

        } else if index == 2 {
            imageView.backgroundColor = UIColor.clear
            imageView.image = UIImage(named: "launchimage")
            
            hideConnectionItems()
            hideSetupItems()
            setupMusicPlayerBar()
            
            displayView.frame = CGRect(x: 0, y: 10, width: self.view.bounds.width, height: 300)
            self.view.addSubview(displayView)
            
            workoutPhaseDes.frame = CGRect(x: 2, y: 0, width: Int(self.view.bounds.width * 0.4) - 10, height: Int(displayView.bounds.height/4))
            workoutPhaseDes.text = "Segment: "
            workoutPhaseDes.textColor = UIColor.white
            workoutPhaseDes.font = UIFont.systemFont(ofSize: 15)
            workoutPhaseDes.textAlignment = NSTextAlignment.left
            displayView.addSubview(workoutPhaseDes)
            
            timeLabelDes.frame = CGRect(x: 2, y: 40, width: Int(self.view.bounds.width * 0.4) - 10, height: Int(displayView.bounds.height/4))
            timeLabelDes.text = "Time: "
            timeLabelDes.textColor = UIColor.white
            timeLabelDes.font = UIFont.systemFont(ofSize: 15)
            timeLabelDes.textAlignment = NSTextAlignment.left
            displayView.addSubview(timeLabelDes)
            
            hrLabelDes.frame = CGRect(x: 2, y: 80, width: Int(self.view.bounds.width * 0.4) - 10, height: Int(displayView.bounds.height/4))
            hrLabelDes.text = "Heart Rate: "
            hrLabelDes.textColor = UIColor.white
            hrLabelDes.font = UIFont.systemFont(ofSize: 15)
            hrLabelDes.textAlignment = NSTextAlignment.left
            displayView.addSubview(hrLabelDes)
            
            nextSegLabelDes.frame = CGRect(x: 2, y: 120, width: Int(self.view.bounds.width * 0.4) - 10, height: Int(displayView.bounds.height/4))
            nextSegLabelDes.text = "Next Segment: "
            nextSegLabelDes.textColor = UIColor.white
            nextSegLabelDes.font = UIFont.systemFont(ofSize: 15)
            nextSegLabelDes.textAlignment = NSTextAlignment.left
            displayView.addSubview(nextSegLabelDes)
            
            //D I S P L A Y  V A L U E S
            
            workoutPhase.frame = CGRect(x: Int(displayView.bounds.height * 0.4), y: 0, width: Int(self.view.bounds.width * 0.6), height: Int(displayView.bounds.height/4))
            workoutPhase.text = theWorkout.phase[theWorkout.phaseIndex]
            workoutPhase.textColor = UIColor.white
            workoutPhase.font = UIFont.systemFont(ofSize: 25)
            workoutPhase.textAlignment = NSTextAlignment.left
            displayView.addSubview(workoutPhase)
            
            timeLabel.frame = CGRect(x: Int(displayView.bounds.height * 0.4), y: 40, width: Int(self.view.bounds.width * 0.6), height: Int(displayView.bounds.height/4))
            timeLabel.text = theWorkout.displayCount()
            timeLabel.textColor = UIColor.white
            timeLabel.font = UIFont.systemFont(ofSize: 25)
            timeLabel.textAlignment = NSTextAlignment.left
            displayView.addSubview(timeLabel)
            
            hrLabel.frame = CGRect(x: Int(displayView.bounds.height * 0.4), y: 80, width: Int(self.view.bounds.width * 0.6), height: Int(displayView.bounds.height/4))
            hrLabel.text = "--"
            hrLabel.textColor = UIColor.white
            hrLabel.font = UIFont.systemFont(ofSize: 25)
            hrLabel.textAlignment = NSTextAlignment.left
            displayView.addSubview(hrLabel)
            
            nextSegLabel.frame = CGRect(x: Int(displayView.bounds.height * 0.4), y: 120, width: Int(self.view.bounds.width * 0.6), height: Int(displayView.bounds.height/4))
            nextSegLabel.text = theWorkout.phase[theWorkout.phaseIndex + 1]
            nextSegLabel.textColor = UIColor.white
            nextSegLabel.font = UIFont.systemFont(ofSize: 25)
            nextSegLabel.textAlignment = NSTextAlignment.left
            displayView.addSubview(nextSegLabel)
            
            // N E X T  G O A L  C O N T R O L
            
            nextGoalLabel.frame = CGRect(x: 61, y: 200, width: Int(self.view.bounds.width - 122), height: 40)
            nextGoalLabel.text = "Goal: " + String(theWorkout.heartRateGoal) + " (bpm)"
            nextGoalLabel.textColor = UIColor.white
            nextGoalLabel.font = UIFont.systemFont(ofSize: 20)
            nextGoalLabel.textAlignment = NSTextAlignment.center
            self.view.addSubview(nextGoalLabel)
            
            increaseHRButton.frame = CGRect(x: self.view.bounds.width - 60, y: 200, width: 60, height: 40)
            increaseHRButton.setImage(UIImage(named: "up"), for: UIControlState.normal)
            increaseHRButton.addTarget(self, action: #selector(ViewController.increaseHRGoal), for: UIControlEvents.touchUpInside)
            self.view.addSubview(increaseHRButton)

            decreaseHRButton.frame = CGRect(x: 0, y: 200, width: 60, height: 40)
            decreaseHRButton.setImage(UIImage(named: "down"), for: UIControlState.normal)
            decreaseHRButton.addTarget(self, action: #selector(ViewController.decreaseHRGoal), for: UIControlEvents.touchUpInside)
            self.view.addSubview(decreaseHRButton)
            
            // W O R K O U T  C O N T R O L
           
            startButton.frame = CGRect(x: 0, y: 260, width: self.view.bounds.width, height: 50)
            startButton.setBackgroundImage(UIImage(named: "buttonback"), for: UIControlState.normal)
            startButton.setTitle("Start", for: UIControlState.normal)
            startButton.addTarget(self, action: #selector(ViewController.start), for: UIControlEvents.touchUpInside)
            self.view.addSubview(startButton)
            
            nextPhaseButton.frame = CGRect(x: 0, y: 330, width: self.view.bounds.width, height: 50)
            nextPhaseButton.setBackgroundImage(UIImage(named: "buttonback"), for: UIControlState.normal)
            nextPhaseButton.setTitle("Skip to Next Segment", for: UIControlState.normal)
            nextPhaseButton.addTarget(self, action: #selector(ViewController.nextPhase), for: UIControlEvents.touchUpInside)
            self.view.addSubview(nextPhaseButton)
            
            if playlistHasBeenOpened == false {
                playlistButton.frame = CGRect(x: 0, y:self.view.bounds.height - 40, width: self.view.bounds.width, height: 40)
                playlistButton.setImage(UIImage(named: "playlist"), for: UIControlState.normal)
                playlistButton.addTarget(self, action: #selector(ViewController.showPlaylist), for: UIControlEvents.touchUpInside)
                self.view.addSubview(playlistButton)

            } else {
                setupMusicPlayerBar()
            }
        } else if index == 3 {
            imageView.backgroundColor = UIColor.clear
            imageView.image = UIImage(named: "launchimage")
            
            hideWorkoutItems()
            hideConnectionItems()
            hideSetupItems()
            setupMusicPlayerBar()
            
            if resultsTable != nil {
                resultsTable.frame = CGRect(x: 0, y: 50, width: self.view.bounds.width, height: self.view.bounds.height - 200)
            }
            resultsTable.delegate = self
            resultsTable.dataSource = self
            self.view.addSubview(resultsTable)
            
        } else if index == 4 {
            imageView.backgroundColor = UIColor.clear
            imageView.image = UIImage(named: "launchimage")
            
            hideWorkoutItems()
            hideConnectionItems()
            hideSetupItems()
            setupMusicPlayerBar()

        }
        
    }
    func hideConnectionItems() {
        promptConnect.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        scanButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        heartRateDisplay.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    func hideSetupItems() {
        HRGModButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        intModButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        restModButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        warmupModButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        cooldownModButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    func hideWorkoutItems() {
        workoutPhaseDes.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        timeLabelDes.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        hrLabelDes.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        nextSegLabelDes.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        workoutPhase.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        timeLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        hrLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        nextSegLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        nextGoalLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        adjustGoalLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        startButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        nextPhaseButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        songTitle.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        songSlider.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        playMusic.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        decreaseHRButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        increaseHRButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    @objc func modHRG() {
        performSegue(withIdentifier: "HRGSegue", sender: self)
    }
    @objc func modInt() {
        performSegue(withIdentifier:"intSegue", sender: self)
    }
    @objc func modRest() {
        performSegue(withIdentifier:"restSegue", sender: self)
    }
    @objc func modWarmup() {
        performSegue(withIdentifier:"warmupSegue", sender: self)
    }
    @objc func modCooldown() {
        performSegue(withIdentifier:"cooldownSegue", sender: self)
    }
    @objc func results() {
        performSegue(withIdentifier:"resultsSegue", sender: self)
    }
    
    func displayTime(theTime: Int) ->String {
        let displayMinuteTime = String(theTime / 60) + ":"
        if theTime % 60 < 10 {
            let displaySecondsTime = "0" + String(theTime % 60)
            return displayMinuteTime + displaySecondsTime
        } else {
            let displaySecondsTime = String(theTime % 60)
            return displayMinuteTime + displaySecondsTime
        }
    }
    @objc func scan(){
        theMonitor.startUpCentralManager()
    }
    
    func chooseMonitor (notification: NSNotification) {
        let deviceMessage = notification.userInfo
        guard let connectedMessage = deviceMessage!["theDevices"] else {return}
        //guard let scannedMessage = deviceMessage!["thePeripheralState"] else {return}
        
        let alertController = UIAlertController(title: "Available Connected Device(s)", message: "Select Monitor", preferredStyle: .actionSheet)
        
        if String(describing: connectedMessage) == "checkPeriphs" {
            if self.theMonitor.periphs.count > 0 {
                for i in 0...self.theMonitor.periphs.count - 1 {
                    let deviceOne = UIAlertAction(title: self.theMonitor.periphs[i].name, style: .default) { (action) in
                        self.theMonitor.centralManager.connect(self.theMonitor.periphs[i] as! CBPeripheral, options: nil)
                    }
                    alertController.addAction(deviceOne)
                    
                    
                }
            } else {
                if timerActivated == false {
                    connectionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: Selector(("timeout")), userInfo: nil, repeats: true)
                    timerActivated = true
                }
                
            }         }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
        
    }
    //==================GET HEART RATE FROM NOTIFICATION CENTER================
    func receiveHeartRate(notification: NSNotification) {
        let heartRateMessage = notification.userInfo
        if let message = heartRateMessage!["message"] {
            heartRateDisplay.text = message as? String
            if let heartNum = message as? Int {
                self.theMonitor.currentHeartRate = heartNum

                if theWorkout.phase[theWorkout.phaseIndex] == "Rest" {
                    aboveGoal = false
                    justGettingThere = false
                    if theWorkout.phase[theWorkout.phaseIndex] == "High Intensity" {
                        if heartNum > (theWorkout.heartRateGoal - 5) && justGettingThere == false {
                            theVoice.tellUser(guidance: "Almost there")
                            justGettingThere = true
                        }
                        if heartNum >= theWorkout.heartRateGoal && aboveGoal == false && justGettingThere == true {
                            theVoice.tellUser(guidance: "Good job")
                            aboveGoal = true
                            print("hit heart rate test")
                            theWorkout.timesToGoal.append(theWorkout.timerCount)
                        }
                        if heartNum <= theWorkout.heartRateGoal - 1 && aboveGoal == true && justGettingThere == true {
                            aboveGoal = false
                            justGettingThere = false
                            print(theWorkout.phaseUpdate())
                        }
                        //================ GATHER HEART RATE DATA FOR MAX THIS SET ====
                        if heartNum >= theWorkout.heartRateGoal {
                            theWorkout.abovePeakRates.append(heartNum)
                        }
                        if heartNum >= theWorkout.heartRateGoal && aboveGoal == false {
                            theWorkout.abovePeakRatesToGoal.append(heartNum)
                        }
                    }
                }
            } else {
                return
            }
        }
    }
    
        func prepare(for segue: UIStoryboardSegue, sender: AnyObject!) {
        print("segue call")
        if segue.identifier == "HRGSegue" {
            let vc = segue.destination as! WorkoutItemViewController
            vc.itemValue = String(theWorkout.heartRateGoal)
            vc.itemKey = "Heart Rate Goal"
            vc.theWorkoutManager = theWorkout
            vc.imageViewHolder = imageView
        }
        if segue.identifier == "intSegue" {
            let vc = segue.destination as! WorkoutItemViewController
            vc.itemValue = String(theWorkout.intervalCount)
            vc.itemKey = "Interval Count"
            vc.theWorkoutManager = theWorkout
            vc.imageViewHolder = imageView
        }
        if segue.identifier == "restSegue" {
            let vc = segue.destination as! WorkoutItemViewController
            vc.itemValue = String(theWorkout.restTime)
            vc.itemKey = "Rest Time"
            vc.theWorkoutManager = theWorkout
            vc.imageViewHolder = imageView
        }
        if segue.identifier == "warmupSegue" {
            let vc = segue.destination as! WorkoutItemViewController
            vc.itemValue = String(theWorkout.warmupTime)
            vc.itemKey = "Warmup Time"
            vc.theWorkoutManager = theWorkout
            vc.imageViewHolder = imageView
        }
        if segue.identifier == "cooldownSegue" {
            let vc = segue.destination as! WorkoutItemViewController
            vc.itemValue = String(theWorkout.cooldownTime)
            vc.itemKey = "Cooldown Time"
            vc.theWorkoutManager = theWorkout
            vc.imageViewHolder = imageView
        }
        if segue.identifier == "resultsSegue" {
            let vc = segue.destination as! ResultsViewController
            vc.theWorkout = theWorkout
        }
    }
    //workout button functions
    @objc func start() {
        if isWorkoutStarted == false {
            startButton.setTitle("Pause", for: UIControlState.normal)
            theWorkout.timer = Timer.init(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
            isWorkoutStarted = true
        } else {
            startButton.setTitle("Start", for: UIControlState.normal)
            isWorkoutStarted = false
            theWorkout.timer.invalidate()
        }
    }
    @objc func nextPhase() {
        if theWorkout.phase[theWorkout.phaseIndex] == "Complete" {
            nextPhaseButton.addTarget(self, action: #selector(ViewController.results), for: UIControlEvents.touchUpInside)
            nextPhaseButton.setTitle("Results", for: UIControlState.normal)
            //performSegue(withIdentifier:"workoutResultsSegue", sender: self)
        } else {
            print(theWorkout.phaseUpdate())
        }
    }
    @objc func increaseHRGoal() {
        theWorkout.heartRateGoal = theWorkout.heartRateGoal + 1
        nextGoalLabel.text = "Goal: \(theWorkout.heartRateGoal) (bpm)"
    }
    @objc func decreaseHRGoal() {
        theWorkout.heartRateGoal = theWorkout.heartRateGoal - 1
        nextGoalLabel.text = "Goal: \(theWorkout.heartRateGoal) (bpm)"
        
    }

    //================================WORKOUT TIMER AND PHASE FUNCTIONS========================
    @objc func updateTimer() {
        timeLabel.text = theWorkout.counting()
        if theWorkout.phaseIndex > phaseChangeDetector && theWorkout.phase[theWorkout.phaseIndex] != "Warmup" {
            let theWords = theWorkout.phase[theWorkout.phaseIndex]
            theVoice.tellUser(guidance: theWords)
        }
        if theWorkout.phase[theWorkout.phaseIndex] == "High Intensity" {
            workoutPhase.text = theWorkout.phase[theWorkout.phaseIndex] + " " + String(((theWorkout.phaseIndex - 1) / 2) + 1)
            if theWorkout.phaseIndex + 1 <= theWorkout.phase.count {
                nextSegLabel.text = theWorkout.phase[theWorkout.phaseIndex + 1]
            } else {
                nextSegLabel.text = "Complete"
            }
            if aboveGoal == true {
                workoutPhase.text = "Slow HR"
            }
        } else if theWorkout.phase[theWorkout.phaseIndex] == "Warmup" {
            workoutPhase.text = theWorkout.phase[theWorkout.phaseIndex]
            if theWorkout.phaseIndex + 1 <= theWorkout.phase.count {
                nextSegLabel.text = theWorkout.phase[theWorkout.phaseIndex + 1]
            } else {
                nextSegLabel.text = "Complete"
            }
        } else if theWorkout.phase[theWorkout.phaseIndex] == "Cooldown" {
            workoutPhase.text = theWorkout.phase[theWorkout.phaseIndex]
            if theWorkout.phaseIndex + 1 <= theWorkout.phase.count {
                nextSegLabel.text = theWorkout.phase[theWorkout.phaseIndex + 1]
            } else {
                nextSegLabel.text = "Complete"
            }
        } else {
            workoutPhase.text = theWorkout.phase[theWorkout.phaseIndex] + " " + String(((theWorkout.phaseIndex - 1) / 2) + 1)
            if theWorkout.phaseIndex + 1 < theWorkout.phase.count {
                nextSegLabel.text = theWorkout.phase[theWorkout.phaseIndex + 1]
                nextPhaseButton.setTitle("Next Segment", for: UIControlState.normal)
            } else {
                nextSegLabel.text = "Complete"
                nextPhaseButton.setTitle("Results", for: UIControlState.normal)
                nextPhaseButton.addTarget(self, action: #selector(ViewController.results), for: UIControlEvents.touchUpInside)
            }
        }
        phaseChangeDetector = theWorkout.phaseIndex
    }
    
    //Music functions
    @objc func showPlaylist() {
        playlistHasBeenOpened = true
        self.playlists = mediaQuery.collections
        //print("playlist count: \(playlists.count)")
        
        let alertController = UIAlertController(title: "Playlists", message: "Choose your playlist", preferredStyle: .actionSheet)
        
        for i in 0...playlists.count - 1 {
            let aPlaylist = UIAlertAction(title: playlists[i].name, style: .default) { (action) in
                self.myPlayer.setQueue(with: self.playlists[i] as! MPMediaItemCollection)
                let theSelectedPlaylist:MPMediaItemCollection = self.playlists[i] as! MPMediaItemCollection
                self.myPlayer.repeatMode = MPMusicRepeatMode.all
                self.myPlayer.prepareToPlay()
                self.myPlayer.nowPlayingItem = theSelectedPlaylist.items[0] 
                self.songTitle.text = "\(self.myPlayer.nowPlayingItem?.value(forProperty: MPMediaItemPropertyTitle) ?? "")"
                //self.musicDefaults.setObject(self.playlists[i].name, forKey: "selectedPlaylist")
                //print(self.playlists[i].name)
                
            }
            alertController.addAction(aPlaylist)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        
        self.present(alertController, animated: true) {
            // ...
        }
        musicShouldPlay = true
        setupMusicPlayerBar()
        
    }
    
    func setupMusicPlayerBar() {
        
        playlistButton.frame = CGRect(x: 10, y:self.view.bounds.height - 90, width: 40, height: 40)
        playlistButton.setImage(UIImage(named: "playlist"), for: UIControlState.normal)
        playlistButton.addTarget(self, action: #selector(ViewController.showPlaylist), for: UIControlEvents.touchUpInside)
        self.view.addSubview(playlistButton)
        
        if musicShouldPlay == true {
            playMusic.frame = CGRect(x: Int(self.view.bounds.width/2 - 10), y: Int(self.view.bounds.height - 90), width: 40, height: 40)
            playMusic.setImage(UIImage(named: "play"), for: UIControlState.normal)
            playMusic.addTarget(self, action: #selector(MPMediaPlayback.play), for: UIControlEvents.touchUpInside)
            self.view.addSubview(playMusic)
        } else {
            playMusic.frame = CGRect(x: Int(self.view.bounds.width/2 - 10), y: Int(self.view.bounds.height - 90), width: 40, height: 40)
            playMusic.setImage(UIImage(named: "pause"), for: UIControlState.normal)
            playMusic.addTarget(self, action: #selector(MPMediaPlayback.play), for: UIControlEvents.touchUpInside)
            self.view.addSubview(playMusic)
        }
        
        forwardButton.frame = CGRect(x: Int(self.view.bounds.width/2 + 50), y: Int(self.view.bounds.height - 90), width: 40, height: 40)
        forwardButton.setImage(UIImage(named: "forward"), for: UIControlState.normal)
        forwardButton.addTarget(self, action: #selector(ViewController.next as (ViewController) -> () -> ()), for: UIControlEvents.touchUpInside)
        self.view.addSubview(forwardButton)

        backButton.frame = CGRect(x: Int(self.view.bounds.width/2 - 80), y: Int(self.view.bounds.height - 90), width: 40, height: 40)
        backButton.setImage(UIImage(named: "back"), for: UIControlState.normal)
        backButton.addTarget(self, action: #selector(ViewController.back), for: UIControlEvents.touchUpInside)
        self.view.addSubview(backButton)
        
        songTitle.frame = CGRect(x: 0, y: Int(self.view.bounds.height - 130), width: Int(self.view.bounds.width), height: 40)
        songTitle.textAlignment = NSTextAlignment.center
        songTitle.textColor = UIColor.white
        if self.myPlayer.nowPlayingItem != nil {
            self.songTitle.text = "\(self.myPlayer.nowPlayingItem?.value(forProperty: MPMediaItemPropertyTitle) ?? "")"
        }
        self.view.addSubview(songTitle)
        
        songSlider.frame = CGRect(x: 0, y: Int(self.view.bounds.height - 170), width: Int(self.view.bounds.width), height: 40)
        songSlider.addTarget(self, action: #selector(ViewController.setCurrentPlayPosition), for: UIControlEvents.valueChanged)
        //self.view.addSubview(songSlider)

    }
    
    func play() {
        if musicShouldPlay == true {
            if myPlayer.nowPlayingItem == nil {
                if musicDefaults.object(forKey: "selectedPlaylist") != nil {
                    for i in 0...playlists.count - 1 {
                        if self.playlists[i].name == musicDefaults.object(forKey: "selectedPlaylist") as? String {
                            myPlayer.setQueue(with: playlists[i] as! MPMediaItemCollection)
                        }
                    }
                } else {
                    myPlayer.setQueue(with: MPMediaQuery.songs())
                }
            }
            myPlayer.play()
            songTitle.text = "\(myPlayer.nowPlayingItem?.value(forProperty:MPMediaItemPropertyTitle) ?? "")"
            let floatTime = Float(myPlayer.currentPlaybackTime)
            songSlider.value = floatTime
            songLength = Float(truncating: myPlayer.nowPlayingItem?.value(forProperty:String(MPMediaItemPropertyPlaybackDuration)) as! NSNumber)
            songSlider.maximumValue = songLength
            myPlayer.beginGeneratingPlaybackNotifications()
            self.notifications.addObserver(self, selector: #selector(ViewController.handleNowPlayingItemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: self.myPlayer)
            self.notifications.addObserver(self, selector: #selector(ViewController.handlePlaybackStateChanged), name:NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: self.myPlayer)
            musicTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateSongSlider), userInfo: nil, repeats: true)
            musicShouldPlay = false
            playMusic.setImage(UIImage(named: "pause"), for: UIControlState.normal)

        } else {
            myPlayer.pause()
            musicShouldPlay = true
            playMusic.setImage(UIImage(named: "play"), for: UIControlState.normal)
        }
    }
    
    
    @objc func setCurrentPlayPosition() {
        self.myPlayer.currentPlaybackTime = TimeInterval(songSlider.value)
    }
    func next() {
        myPlayer.skipToNextItem()
        if self.myPlayer.nowPlayingItem != nil {
            self.songTitle.text = "\(self.myPlayer.nowPlayingItem?.value(forProperty: MPMediaItemPropertyTitle) ?? "")"
        }
    }
    @objc func back() {
        myPlayer.skipToPreviousItem()
        if self.myPlayer.nowPlayingItem != nil {
            self.songTitle.text = "\(self.myPlayer.nowPlayingItem?.value(forProperty:MPMediaItemPropertyTitle) ?? "")"
        }
    }
    
    @objc func handleNowPlayingItemChanged() {
        print("playlist song changed")
        if self.myPlayer.nowPlayingItem != nil {
            self.songTitle.text = "\(self.myPlayer.nowPlayingItem?.value(forProperty:MPMediaItemPropertyTitle) ?? "")"
            songSlider.value = 0.0
            songLength = Float(truncating: myPlayer.nowPlayingItem?.value(forProperty:String(MPMediaItemPropertyPlaybackDuration)) as! NSNumber)
            songSlider.maximumValue = songLength
            print("index of now playing item: \(myPlayer.indexOfNowPlayingItem)")
        }
        
    }
    @objc func handlePlaybackStateChanged() {
        print("playback state changed")
        
        
    }
    @objc func updateSongSlider() {
        songSlider.value = Float(myPlayer.currentPlaybackTime)
    }
    
    func playSound(){
        if(soundReady){
            //audioPlayer.play()
            soundReady = false
        }
    }
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool){
        //Prepare to play after Sound finished playing
        // soundReady = audioPlayer.prepareToPlay()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        _ = UITableViewCell()
        return "Results"
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return theWorkout.timesToGoal.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! CustomTableViewCell
        cell.setCell(maxHR: theWorkout.maxALLSets[indexPath.row], timeTG: theWorkout.timesToGoal[indexPath.row], goalHR: theWorkout.completedHRGoals[indexPath.row], hIRates: theWorkout.abovePeakRateSets[indexPath.row])
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.clear
        } else {
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        }
        
        return cell
    }

    
    
    
}

