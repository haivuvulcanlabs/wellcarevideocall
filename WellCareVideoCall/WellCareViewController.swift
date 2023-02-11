//
//  ViewController.swift
//  WellCareVideoCall
//
//  Created by vulcanlabs-hai on 06/02/2023.
//

import UIKit
import AgoraRtcKit
import MediaPlayer

class WellCareViewController: UIViewController {
    static let VideoCallInMins: Int = 5
    var agoraEngine: AgoraRtcEngineKit!
    // By default, set the current user role to broadcaster to both send and receive streams.
    var userRole: AgoraClientRole = .broadcaster
    
    // Update with the App ID of your project generated on Agora Console.
    let appID = "1a37e0ba7a96485bb1e538ab05439b96"
    // Update with the temporary token generated in Agora Console.
    var token = "007eJxTYFhydcm5TJZl6qY67zfe7p+fYnq1aJM386oo6dA6Pp7tNfsVGAwTjc1TDZISzRMtzUwsTJOSDFNNjS0SkwxMTYwtkyzN6vc+TG4IZGQoE8xhZmSAQBCfl6EktbgkPjkjMS85IzWHgQEAXB8iXQ=="
    // Update with the channel name you used to generate the token in Agora Console.
    var channelName = "test_chanchel"
    
    // Create the view object.
    var agoraView: AgoraVideoViewer!
    
    private lazy var topControlerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private lazy var layoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic-layout"), for: .normal)
        button.addTarget(self, action: #selector(tappedLayoutButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var bluetoothButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic-bluetooth"), for: .normal)
        button.addTarget(self, action: #selector(tappedBluetoothButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var flashButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic-camera-flash"), for: .normal)
        button.addTarget(self, action: #selector(tappedFlashButton(_:)), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic-back"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tappedBackButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var countdownView: UIView = {
        let view  = UIView()
        view.isHidden = true
        return view
    }()
    
    private lazy var reminderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "color745A00")?.withAlphaComponent(0.6)
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    private var countdownLabel: UILabel?
    let airplayVolume = MPVolumeView()
    private var callTimer: Timer?
    private var callTime: Int = 0
    private let userPermissin: UserPermission
    private let delegate: AgoraVideoViewerDelegate?
    var trayOriginalCenter: CGPoint = .zero
    private lazy var pipControlView: PIPControlView = {
        let view = PIPControlView()
        view.delegate = self
        return view
    }()
    
    init(userPermissin: UserPermission, delegate: AgoraVideoViewerDelegate? = nil) {
        self.userPermissin = userPermissin
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .black
        initializeAndJoinChannel()
        layoutCountdownView()
        layoutTopControls()
        
        startCallTimer()
    }


    func initializeAndJoinChannel(){
        
        agoraView = AgoraVideoViewer(
            connectionData: AgoraConnectionData(
                appId: appID,
                rtcToken: token
            ), delegate: self
        )
        agoraView.fills(view: self.view)
        
        agoraView.join(
            channel: channelName,
            with: token,
            as: .broadcaster
        )
    }
    
    func layoutTopControls() {
        
        view.addSubview(topControlerView)
        topControlerView.addSubview(airplayVolume)
        topControlerView.addSubview(buttonStackView)
        
        topControlerView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        airplayVolume.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topControlerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: hasTopNorth ? 10 : 40),
            topControlerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            topControlerView.widthAnchor.constraint(equalToConstant: 41),
            topControlerView.heightAnchor.constraint(equalToConstant: 157),
            
            buttonStackView.topAnchor.constraint(equalTo: topControlerView.topAnchor, constant: 0),
            buttonStackView.leftAnchor.constraint(equalTo: topControlerView.leftAnchor, constant: 0),
            buttonStackView.bottomAnchor.constraint(equalTo: topControlerView.bottomAnchor, constant: 0),
            buttonStackView.rightAnchor.constraint(equalTo: topControlerView.rightAnchor, constant: 0),

        ])
        
        buttonStackView.addArrangedSubview(layoutButton)
        buttonStackView.addArrangedSubview(bluetoothButton)
        buttonStackView.addArrangedSubview(flashButton)

        airplayVolume.showsVolumeSlider = true
        airplayVolume.isHidden = true
        
        NSLayoutConstraint.activate([
            airplayVolume.leftAnchor.constraint(equalTo: topControlerView.leftAnchor),
            airplayVolume.centerYAnchor.constraint(equalTo: topControlerView.centerYAnchor),
            airplayVolume.widthAnchor.constraint(equalToConstant: 20),
            airplayVolume.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func layoutCountdownView() {
        let label = UILabel()
        label.text = "12:21"
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        
        countdownLabel = label
        let recordImageView = UIImageView(image: UIImage(named: "ic-record"))
        recordImageView.contentMode = .scaleAspectFit
        
        let clockImageView = UIImageView(image: UIImage(named: "ic-clock"))
        clockImageView.contentMode = .scaleAspectFit
        
        let countDownContainer = UIView()
        
        countDownContainer.layer.cornerRadius = 5
        countDownContainer.layer.borderWidth = 1
        countDownContainer.layer.borderColor = UIColor(named: "colorFFE600")?.cgColor
        countDownContainer.clipsToBounds = true
        
        countDownContainer.addSubview(clockImageView)
        countDownContainer.addSubview(label)
        
        countdownView.addSubview(recordImageView)
        countdownView.addSubview(countDownContainer)
        
        view.addSubview(countdownView)
        countdownView.frame = CGRect(x: 26, y: hasTopNorth ? 20 : 14, width: 65, height: 18)
        recordImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recordImageView.centerYAnchor.constraint(equalTo: countdownView.centerYAnchor),
            recordImageView.leftAnchor.constraint(equalTo: countdownView.leftAnchor),
            recordImageView.widthAnchor.constraint(equalToConstant: 11),
            recordImageView.heightAnchor.constraint(equalToConstant: 11)

        ])
        
        countDownContainer.translatesAutoresizingMaskIntoConstraints = false
        clockImageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            countDownContainer.rightAnchor.constraint(equalTo: countdownView.rightAnchor),
            countDownContainer.topAnchor.constraint(equalTo: countdownView.topAnchor),
            countDownContainer.bottomAnchor.constraint(equalTo: countdownView.bottomAnchor),
            countDownContainer.leftAnchor.constraint(equalTo: countdownView.leftAnchor, constant: 15),

            clockImageView.centerYAnchor.constraint(equalTo: countDownContainer.centerYAnchor),
            clockImageView.leftAnchor.constraint(equalTo: countDownContainer.leftAnchor, constant: 2),
            clockImageView.widthAnchor.constraint(equalToConstant: 11),
            clockImageView.heightAnchor.constraint(equalToConstant: 12),
            
            label.centerYAnchor.constraint(equalTo: countDownContainer.centerYAnchor),
            label.leftAnchor.constraint(equalTo: clockImageView.rightAnchor),

        ])
        
        view.addSubview(backButton)
        backButton.frame = CGRect(x: 12, y: hasTopNorth ? 56 : 46, width: 56, height: 56)
        
        
        //setup reminderView
        view.addSubview(reminderView)
        reminderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            reminderView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            reminderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reminderView.heightAnchor.constraint(equalToConstant: 43),
            reminderView.bottomAnchor.constraint(equalTo: agoraView.streamerCollectionView.topAnchor, constant: -20)
        ])
        
        let reminderImageView = UIImageView(image: UIImage(named: "ic-alarm-big"))
        reminderImageView.contentMode = .scaleAspectFit
        reminderView.addSubview(reminderImageView)
        reminderImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            reminderImageView.centerYAnchor.constraint(equalTo: reminderView.centerYAnchor),
            reminderImageView.leftAnchor.constraint(equalTo: reminderView.leftAnchor, constant: 11),
            reminderImageView.widthAnchor.constraint(equalToConstant: 23),
            reminderImageView.heightAnchor.constraint(equalToConstant: 23),
        ])
        
        let reminderLabel = UILabel()
        reminderLabel.text = "1 minutes remain. Please wrap up your calls."
        reminderLabel.textColor = .white
        reminderLabel.font = .systemFont(ofSize: 9, weight: .medium)
        reminderView.addSubview(reminderLabel)
        reminderLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            reminderLabel.centerYAnchor.constraint(equalTo: reminderView.centerYAnchor),
            reminderLabel.leftAnchor.constraint(equalTo: reminderImageView.rightAnchor, constant: 10),
        ])
        
        let okButton = UIButton()
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        okButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        okButton.addTarget(self, action: #selector(tappedCloseReminderButton(_:)), for: .touchUpInside)
        okButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        okButton.layer.cornerRadius = 8
        okButton.clipsToBounds = true
        reminderView.addSubview(okButton)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            okButton.centerYAnchor.constraint(equalTo: reminderView.centerYAnchor),
            okButton.rightAnchor.constraint(equalTo: reminderView.rightAnchor, constant: -11),
            okButton.widthAnchor.constraint(equalToConstant: 35),
            okButton.heightAnchor.constraint(equalToConstant: 24),

        ])
    }
    
    @objc func tappedLayoutButton(_ sender: UIButton) {
        
        debugPrint("hai tappedLayoutButton")
        let segmentedStyle = [
            AgoraVideoViewer.Style.floating,
            AgoraVideoViewer.Style.grid,
            AgoraVideoViewer.Style.strip,
            AgoraVideoViewer.Style.expand
        ]
        let videoCount = self.agoraView?.userVideoLookup.count ?? 0
        let style = self.agoraView?.style ?? .floating
        
        var index = segmentedStyle.firstIndex(of: style) ?? 0
        index = (index + 1) % segmentedStyle.count
        
        if videoCount != 2, index == 1 {
            // only show gridlayout for 2 users
            index = (index + 1) % segmentedStyle.count
        }
        
        self.agoraView?.style = segmentedStyle[index]
        
        let currentStyle = self.agoraView?.style ?? .floating
        
        if currentStyle == .floating {
            buttonStackView.axis = .vertical
            topControlerView.removeFromSuperview()
            topControlerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(topControlerView)
           
            for contraint in  topControlerView.constraints {
                contraint.isActive = false
            }
            
            NSLayoutConstraint.activate([
                topControlerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: hasTopNorth ? 10 : 40),
                topControlerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
                topControlerView.widthAnchor.constraint(equalToConstant: 41),
                topControlerView.heightAnchor.constraint(equalToConstant: 157),
                
            ])
            
            topControlerView.frame.size = CGSize(width: 41, height: 157)
            backButton.frame = CGRect(x: 12, y: hasTopNorth ? 56 : 46, width: 56, height: 56)
            backButton.setImage(UIImage(named: "ic-back"), for: .normal)
            layoutButton.setImage(UIImage(named: "ic-layout"), for: .normal)
            bluetoothButton.setImage(UIImage(named: "ic-bluetooth"), for: .normal)
            flashButton.setImage(UIImage(named: "ic-camera-flash"), for: .normal)

        } else {
            buttonStackView.axis = .horizontal

            topControlerView.removeFromSuperview()
            topControlerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(topControlerView)
            for contraint in topControlerView.constraints {
                contraint.isActive = false
            }
            NSLayoutConstraint.activate([
                topControlerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: hasTopNorth ? 0 : 40),
                topControlerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
                topControlerView.heightAnchor.constraint(equalToConstant: 41),
                topControlerView.widthAnchor.constraint(equalToConstant: 157)
            ])
            topControlerView.frame.size = CGSize(width: 157, height: 41)
            backButton.frame = CGRect(x: 12 , y: hasTopNorth ? 45 : 40, width: 40, height: 40)
            backButton.setImage(UIImage(named: "ic-back-outline"), for: .normal)
            layoutButton.setImage(UIImage(named: "ic-layout-outline"), for: .normal)
            bluetoothButton.setImage(UIImage(named: "ic-bluetooth-outline"), for: .normal)
            flashButton.setImage(UIImage(named: "ic-camera-flash-outline"), for: .normal)
        }
        
        buttonStackView.removeFromSuperview()
        topControlerView.addSubview(buttonStackView)
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: topControlerView.topAnchor, constant: 0),
            buttonStackView.leftAnchor.constraint(equalTo: topControlerView.leftAnchor, constant: 0),
            buttonStackView.bottomAnchor.constraint(equalTo: topControlerView.bottomAnchor, constant: 0),
            buttonStackView.rightAnchor.constraint(equalTo: topControlerView.rightAnchor, constant: 0)
        ])
    }
    
    func hideReminderView() {
        UIView.animate(withDuration: 3) {
            self.reminderView.alpha = 0
        }
    }
    
    func showReminderView() {
        reminderView.alpha = 0
        reminderView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.reminderView.alpha = 1
        }
    }
    
    func hideCountDownView() {
        countdownView.isHidden = true
    }
}


extension WellCareViewController: AgoraVideoViewerDelegate {
    @objc func tappedBluetoothButton(_ sender: UIButton) {
        if let routePickerButton = airplayVolume.subviews.first(where: { $0 is UIButton }) as? UIButton {
           
            routePickerButton.sendActions(for: .touchUpInside)
        }
    }
    
    @objc func tappedFlashButton(_ sender: UIButton) {
        self.agoraView.tappedFlashButton()
    }
    
    @objc func tappedBackButton(_ sender: UIButton) {
       dismiss(animated: true)
    }
    
    @objc func tappedCloseReminderButton(_ sender: UIButton) {
       hideReminderView()
    }
    
    @objc func startCallTimer() {
        guard userPermissin == .doctor else { return }
        countdownView.isHidden = false
        callTimer?.invalidate()
        callTimer = nil
        callTime = 60 * WellCareViewController.VideoCallInMins
        callTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDownCallTimer(_:)), userInfo: nil, repeats: true)
    }
    
    @objc func stopCallTimer() {
        callTimer?.invalidate()
        callTimer = nil
        
    }
    
    @objc func countDownCallTimer(_ timer: Timer) {
        callTime -= 1
        
        let mins = callTime / 60
        let secs = callTime % 60
        
        countdownLabel?.text = String(format: "%2.d:%2.d", mins, secs)
        if callTime == 60 {
            showReminderView()
        }
        
        if callTime == 0 {
            stopCallTimer()
            endCallTime()
        }
    }
    
    @objc func endCallTime() {
        self.agoraView?.tappedEndCallButton()
    }
    
    func endEnterPIP() {
        let minimizedWidth = 190.0 * UIScreen.main.bounds.width / 384.0
        self.view.frame = CGRect(origin: CGPoint(x: 50, y: 50), size: CGSize(width: minimizedWidth, height: minimizedWidth))
        relayoutAgoraVideoView()
        
    }
    
    func relayoutAgoraVideoView() {
        let pip = (self.agoraView?.pip ?? false)
        topControlerView.isHidden = pip
        countdownView.isHidden = pip
        backButton.isHidden = pip
        

        view.addSubview(pipControlView)
        pipControlView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pipControlView.topAnchor.constraint(equalTo: view.topAnchor),
            pipControlView.leftAnchor.constraint(equalTo: view.leftAnchor),
            pipControlView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pipControlView.rightAnchor.constraint(equalTo: view.rightAnchor),

        ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    func exitPIP() {
        let pip = (self.agoraView?.pip ?? false)
        topControlerView.isHidden = pip
        countdownView.isHidden = pip
        backButton.isHidden = pip
        
        self.view.frame = UIScreen.main.bounds
        pipControlView.removeFromSuperview()
    }
    
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        var translation = sender.translation(in: self.view)
        var velocity = sender.velocity(in: self.view)
        let minimizedWidth = 190.0 * UIScreen.main.bounds.width / 384.0

        if sender.state == .began {
            trayOriginalCenter = self.view.center
            
        } else if sender.state == .changed {
            
            var newOffsetY = trayOriginalCenter.y + translation.y
            var newOffsetX = trayOriginalCenter.x + translation.x

            newOffsetX = max(minimizedWidth/2, newOffsetX)
            newOffsetX = min(UIScreen.main.bounds.width -  minimizedWidth/2, newOffsetX)

            
            newOffsetY = max(minimizedWidth/2, newOffsetY)
            newOffsetY = min(UIScreen.main.bounds.height - minimizedWidth/2, newOffsetY)

            self.view.center = CGPoint(x: newOffsetX, y: newOffsetY)
            
        } else if sender.state == .ended {
            
        }
    }
}

extension WellCareViewController: PIPControlViewDelegate {
    func didSelectButton(_ action: ButtonAction) {
        switch action {
        case .pip:
            agoraView?.pip = false
            exitPIP()
        case .close:
            agoraView?.tappedEndCallButton()
        case .flip:
            agoraView.flipCamera()
        case .camera:
            agoraView.toggleCam(nil)
        case .mic:
            agoraView.toggleMic(nil)
        }
    }
}

extension UIViewController {
    var hasTopNorth: Bool {
        return UIScreen.main.bounds.height >= 812
    }
}

enum UserPermission: Int {
    case doctor = 0
    case patient
}
