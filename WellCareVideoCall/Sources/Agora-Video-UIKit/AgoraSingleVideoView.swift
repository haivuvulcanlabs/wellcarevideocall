//
//  AgoraSingleVideoView.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import AgoraRtcKit

/// View for the individual Agora Camera Feed.
public class AgoraSingleVideoView: MPView {

    /// Is the video turned off for this user.
    public var videoMuted: Bool = true {
        didSet {
            if oldValue != videoMuted {
                self.canvas.view?.isHidden = videoMuted
                self.customCameraView?.isHidden = videoMuted
            }
            self.updateUserOptions()
        }
    }
    /// Is the microphone muted for this user.
    public var audioMuted: Bool = true {
        didSet {
            self.mutedFlag.isHidden = !audioMuted
            self.updateUserOptions()
        }
    }

    weak var singleVideoViewDelegate: SingleVideoViewDelegate?

    /// Whether the options label should be visible or not.
    public var showOptions: Bool = true {
        didSet {
            #if canImport(AgoraRtmControl)
            self.userOptions?.isHidden = !self.showOptions
            #endif
        }
    }
    /// Unique ID for this user, used by the video feed.
    var uid: UInt {
        get { self.canvas.uid }
        set { self.canvas.uid = newValue }
    }
    /// Canvas used to render the Agora RTC Video.
    public var canvas: AgoraRtcVideoCanvas
    /// View that the AgoraRtcVideoCanvas is sending the video feed to
    var hostingView: MPView? {
        self.canvas.view
    }

    var customCameraView: CustomVideoSourcePreview? {
        didSet {
            if let oldValue = oldValue {
                oldValue.removeFromSuperview()
            }
            if let customCameraView = customCameraView {
                if let defaultCamView = self.canvas.view {
                    #if os(iOS)
                    self.insertSubview(customCameraView, aboveSubview: defaultCamView)
                    #elseif os(macOS)
                    self.addSubview(customCameraView, positioned: .above, relativeTo: defaultCamView)
                    #endif
                }
                customCameraView.frame = self.bounds
                #if os(iOS)
                customCameraView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                #elseif os(macOS)
                customCameraView.autoresizingMask = [.width, .height]
                #endif
            }
        }
    }

    var micFlagColor: MPColor

    enum UserOptions: String {
        case camera
        case microphone
    }

    #if canImport(AgoraRtmControl)
    lazy var userOptions: MPView? = {
        #if os(iOS)
        let userOptionsBtn = MPButton.newToggleButton(
            unselected: MPButton.ellipsisSymbol
        )
        userOptionsBtn.layer.zPosition = 3
        userOptionsBtn.tintColor = .systemGray
        #elseif os(macOS)
        let userOptionsBtn = NSPopUpButton(frame: .zero, pullsDown: true)

//        userOptionsBtn.wantsLayer = true
//        userOptionsBtn.layer?.backgroundColor = .white
        (userOptionsBtn.cell as? NSButtonCell)?.backgroundColor = .selectedContentBackgroundColor
        self.addItems(to: userOptionsBtn)
        #endif
        self.addSubview(userOptionsBtn)
        #if os(iOS)
        userOptionsBtn.frame = CGRect(
            origin: CGPoint(x: 10, y: 10),
            size: CGSize(width: 40, height: 25)
        )
        userOptionsBtn.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
        userOptionsBtn.addTarget(self, action: #selector(optionsBtnSelected), for: .touchUpInside)
        #elseif os(macOS)
        userOptionsBtn.isBordered = false
        userOptionsBtn.wantsLayer = true
        userOptionsBtn.layer?.backgroundColor = .clear
        userOptionsBtn.frame = CGRect(
            origin: CGPoint(x: 10, y: self.frame.height - 30),
            size: CGSize(width: 40, height: 25)
        )
        userOptionsBtn.autoresizingMask = [.minYMargin, .maxXMargin]
        userOptionsBtn.target = self
        userOptionsBtn.action = #selector(optionsBtnSelected)
        #endif
//        userOptionsBtn.isHidden = true
        return userOptionsBtn
    }()
    #endif

    /// Icon to show if this user is muting their microphone
    lazy var mutedFlag: MPView = {
        #if os(iOS)
        let muteFlag = UIImageView(image: UIImage(named: "ic-mic-mute"))
//        muteFlag.tintColor = self.micFlagColor
        muteFlag.contentMode = .scaleAspectFit
        #elseif os(macOS)
        let muteFlag = MPButton()
        muteFlag.font = .systemFont(ofSize: NSFont.systemFontSize * 1.5)
        muteFlag.attributedTitle = NSAttributedString(
            string: MPButton.micSlashSymbol,
            attributes: [ NSAttributedString.Key.foregroundColor: self.micFlagColor ]
        )
        #endif
        self.addSubview(muteFlag)
        muteFlag.translatesAutoresizingMaskIntoConstraints = false
//        #if os(iOS)
////        muteFlag.frame = CGRect(
////            origin: CGPoint(x: self.frame.width - 20 - 15, y: self.frame.height - 5),
////            size: CGSize(width: 15, height: 15)
////        )
////        muteFlag.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
//
//        nslayou
//        #elseif os(macOS)
//        muteFlag.isBordered = false
//        muteFlag.wantsLayer = true
//        muteFlag.layer?.backgroundColor = .clear
//        muteFlag.frame = CGRect(
//            origin: CGPoint(x: self.frame.width - 30, y: self.frame.height - 30),
//            size: CGSize(width: 25, height: 25)
//        )
//        muteFlag.autoresizingMask = [.minYMargin, .minXMargin]
//        #endif
        
        NSLayoutConstraint.activate([
            muteFlag.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -35),
            muteFlag.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            muteFlag.widthAnchor.constraint(equalToConstant: 15),
            muteFlag.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        return muteFlag
    }()

    lazy var signalView: MPImageView = {
        let muteFlag = UIImageView(image: UIImage(named: "ic-signal-good"))
        muteFlag.contentMode = .scaleAspectFit
        self.addSubview(muteFlag)
        muteFlag.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            muteFlag.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5),
            muteFlag.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            muteFlag.widthAnchor.constraint(equalToConstant: 14),
            muteFlag.heightAnchor.constraint(equalTo: muteFlag.widthAnchor, multiplier:1)
        ])

      
        return muteFlag
    }()
    
    /// Create a new AgoraSingleVideoView to be displayed in your app
    /// - Parameters:
    ///   - uid: User ID of the `AgoraRtcVideoCanvas` inside this view
    ///   - micColor: Color to be applied when the local or remote user mutes their microphone
    ///   - delegate: Object used for accessing the AgoraRtmController and presenting alerts
    public init(
        uid: UInt, micColor: MPColor, delegate: SingleVideoViewDelegate? = nil
    ) {
        self.canvas = AgoraRtcVideoCanvas()
        self.micFlagColor = micColor
        self.singleVideoViewDelegate = delegate
        super.init(frame: .zero)
        self.setBackground()
        self.canvas.uid = uid
        let hostingView = MPView()
        hostingView.frame = self.bounds
        #if os(iOS)
        hostingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #elseif os(macOS)
        hostingView.autoresizingMask = [.width, .height]
        #endif
        self.canvas.view = hostingView
        self.addSubview(hostingView)
        self.setupMutedFlag()
        self.setupOptions(visible: false)
        self.signalView.isHidden = false
    }

    func setupOptions(visible showOptions: Bool) {
        self.showOptions = showOptions
    }

    private func setupMutedFlag() {
        self.audioMuted = true
    }

    internal func setBackground() {
        let backgroundView = MPView()
        #if os(iOS)
        backgroundView.backgroundColor = .secondarySystemBackground
        let bgButton = MPButton(type: .custom)
        bgButton.setImage(
            UIImage(
                systemName: MPButton.personSymbol,
                withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
            for: .normal
        )
        #elseif os(macOS)
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        let bgButton = MPButton()
        bgButton.title = MPButton.personSymbol
        bgButton.isBordered = false
        bgButton.isEnabled = false
        #endif
        backgroundView.addSubview(bgButton)

        bgButton.frame = backgroundView.bounds
        self.addSubview(backgroundView)
        backgroundView.frame = self.bounds
        #if os(iOS)
        bgButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #elseif os(macOS)
        bgButton.autoresizingMask = [.width, .height]
        backgroundView.autoresizingMask = [.width, .height]
        #endif
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func placeMuteAtBottom(style: AgoraVideoViewer.Style = .pinned) {
//        let size = CGSize(width: 15, height: 15)
//        let offset = CGPoint(x: self.frame.width - 20, y: self.frame.height - 20)
//        mutedFlag.frame  = CGRect(origin: offset, size: size)
        mutedFlag.removeFromSuperview()
        addSubview(mutedFlag)
        for ct in mutedFlag.constraints {
            ct.isActive = false
        }
        
        
        NSLayoutConstraint.activate([
            mutedFlag.rightAnchor.constraint(equalTo: self.rightAnchor, constant: style == .pinned ? -5 : -10),
            mutedFlag.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: style == .pinned ? -5 : -10),
            mutedFlag.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: style == .pinned ? 19.0/78.0 : 37.0 / 150.0),
            mutedFlag.heightAnchor.constraint(equalTo: mutedFlag.widthAnchor, multiplier: 1)
        ])
    }
    
    func placeMuteAtTop() {
//        let size = CGSize(width: 15, height: 15)
//        let offset = CGPoint(x: self.frame.width - 25 - signalView.frame.width, y: 5)
//        mutedFlag.frame  = CGRect(origin: offset, size: size)
        mutedFlag.removeFromSuperview()
        addSubview(mutedFlag)
        for ct in mutedFlag.constraints {
            ct.isActive = false
        }
        NSLayoutConstraint.activate([
            mutedFlag.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -35),
            mutedFlag.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            mutedFlag.widthAnchor.constraint(equalToConstant: 15),
            mutedFlag.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
}
