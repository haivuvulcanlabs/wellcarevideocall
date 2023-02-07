//
//  AgoraVideoViewer+Buttons.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// This file mostly contains programatically created MPButtons,
// The buttons call the following methods found in AgoraVideoViewer+VideoControl.swift:
// leaveChannel, toggleCam, toggleMic, flipCamera, toggleBroadcast, toggleBeautify

extension AgoraVideoViewer {
#if os(iOS)
    fileprivate func platformContainerSizing(
        _ frameOriginX: inout CGFloat, _ frameOriginY: inout CGFloat, _ contWidth: CGFloat,
        _ resizeMask: inout UIView.AutoresizingMask, _ containerSize: inout CGSize
    ) {
        resizeMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        switch self.agoraSettings.buttonPosition {
        case .top:
            frameOriginY = 30
            resizeMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        case .left, .right:
            containerSize = CGSize(width: containerSize.height, height: containerSize.width)
            frameOriginY = (self.bounds.height - CGFloat(contWidth)) / 2
            if self.agoraSettings.buttonPosition == .left {
                frameOriginX = 30
                resizeMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
            } else {
                frameOriginX = self.bounds.width - self.agoraSettings.buttonSize - 20 - 10
                resizeMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin]
            }
        case .bottom: break
        }
    }
#elseif os(macOS)
    
    fileprivate func platformContainerSizing(
        _ frameOriginX: inout CGFloat, _ frameOriginY: inout CGFloat, _ contWidth: CGFloat,
        _ resizeMask: inout NSView.AutoresizingMask, _ containerSize: inout CGSize
    ) {
        switch self.agoraSettings.buttonPosition {
        case .top, .bottom:
            frameOriginX = (self.bounds.width - CGFloat(contWidth)) / 2
            if self.agoraSettings.buttonPosition == .top {
                frameOriginY = self.bounds.height - self.agoraSettings.buttonSize - 20 - 10
                resizeMask = [.minXMargin, .maxXMargin, .minYMargin]
            } else {
                frameOriginY = 20
                resizeMask = [.minXMargin, .maxXMargin, .maxYMargin]
            }
        case .left, .right:
            containerSize = CGSize(width: containerSize.height, height: containerSize.width)
            frameOriginY = (self.bounds.height - CGFloat(contWidth)) / 2
            if self.agoraSettings.buttonPosition == .left {
                frameOriginX = 20
                resizeMask = [.minYMargin, .maxXMargin, .maxYMargin]
            } else {
                frameOriginX = self.bounds.width - self.agoraSettings.buttonSize - 20 - 10
                resizeMask = [.minYMargin, .minXMargin, .maxYMargin]
            }
        }
    }
#endif
    
    fileprivate func positionButtonContainer(_ container: UIView, _ contWidth: CGFloat, _ buttonMargin: CGFloat) {
        var containerSize = CGSize(width: contWidth, height: self.agoraSettings.buttonSize + 40 + 20)
        var frameOriginX = (self.bounds.width - CGFloat(contWidth)) / 2
        var frameOriginY = self.bounds.height - containerSize.height
        var resizeMask: MPView.AutoresizingMask = []
        platformContainerSizing(&frameOriginX, &frameOriginY, contWidth, &resizeMask, &containerSize)
#if os(iOS)
        container.layer.cornerRadius = self.agoraSettings.buttonSize / 3
        container.clipsToBounds = true
#elseif os(macOS)
        container.layer?.cornerRadius = self.agoraSettings.buttonSize / 3
#endif
        container.frame = CGRect(origin: CGPoint(x: frameOriginX, y: frameOriginY), size: containerSize)
        container.autoresizingMask = resizeMask
    }
    
    /// Add all the relevant buttons.
    /// The buttons are set to add to their respective parent views
    /// Whenever called, so I'm discarding the result for most of them here.
    internal func addVideoButtons(to container: UIView) {
        let builtinButtons = [
            self.getFlipButton(), self.getCameraButton(), self.getEndCallButton(), self.getMicButton(), self.getChatButton()
        ].compactMap { $0 }
        
        let buttons = builtinButtons + (self.delegate?.extraButtons() ?? [])
        let buttonSize = self.agoraSettings.buttonSize
        let buttonCount = CGFloat(buttons.count)
        let contWidth = UIScreen.main.bounds.width - 10
        
        let buttonMargin = (contWidth - (buttonSize * buttonCount)) / buttonCount
        
        if builtinButtons.isEmpty {
            return
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .equalCentering
        container.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 40),
            stackView.heightAnchor.constraint(equalToConstant: buttonSize),
            stackView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 30)
        ])
        buttons.enumerated().forEach({ (elem) in
            let button = elem.element
            
            stackView.addArrangedSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: buttonSize),
                button.heightAnchor.constraint(equalToConstant: buttonSize),
            ])
            //            #if os(iOS)
            //            container.addSubview(button)
            //            #elseif os(macOS)
            //            container.addSubview(button)
            //            #endif
            //            button.frame = CGRect(
            //                origin: CGPoint(x: buttonMargin, y: 40),
            //                size: CGSize(width: buttonSize, height: buttonSize)
            //            )
            //            switch self.agoraSettings.buttonPosition {
            //            case .top, .bottom:
            //                button.frame.origin.x += (buttonMargin + buttonSize) * CGFloat(elem.offset)
            //            case .left, .right:
            //                button.frame.origin.y += (buttonMargin + buttonSize) * CGFloat(elem.offset)
            //            }
            //            #if os(iOS)
            ////            button.layer.cornerRadius = buttonSize / 2
            //            if elem.offset < builtinButtons.count {
            ////                button.backgroundColor = self.agoraSettings.colors.buttonDefaultNormal
            ////                button.tintColor = self.agoraSettings.colors.buttonTintColor
            //            }
            //            #elseif os(macOS)
            //            button.isBordered = false
            //            button.layer?.cornerRadius = buttonSize / 2
            //            if elem.offset < builtinButtons.count {
            ////                button.layer?.backgroundColor = self.agoraSettings.colors.buttonDefaultNormal.cgColor
            ////                button.contentTintColor = self.agoraSettings.colors.buttonTintColor
            //            }
            //            #endif
        })
        self.setCamAndMicButtons()
        //        let contWidth = CGFloat(buttons.count) * (buttonSize + buttonMargin) + buttonMargin
        
        positionButtonContainer(container, contWidth, 0)
    }
    
    internal func setCamAndMicButtons() {
        self.camButton?.isOn = !self.agoraSettings.cameraEnabled
        self.micButton?.isOn = !self.agoraSettings.micEnabled
#if os(iOS)
        self.camButton?.backgroundColor = UIColor.clear
        self.micButton?.backgroundColor = UIColor.clear
#elseif os(macOS)
        self.camButton?.layer?.backgroundColor = UIColor.clear.cgColor
        self.micButton?.layer?.backgroundColor = UIColor.clear.cgColor
        if let cambtn = self.camButton, cambtn.isOn, !cambtn.alternateTitle.isEmpty {
            swap(&cambtn.title, &cambtn.alternateTitle)
        }
        if let micbtn = self.micButton, micbtn.isOn, !micbtn.alternateTitle.isEmpty {
            swap(&micbtn.title, &micbtn.alternateTitle)
        }
#endif
    }
    
    @discardableResult
    internal func getControlContainer() -> UIView {
        if let controlContainer = self.controlContainer {
            return controlContainer
        }
        
        
        
#if os(iOS)
        let container = UIView()
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPanTray(_:)))
        container.addGestureRecognizer(gesture)
        
        container.backgroundColor = UIColor.black.withAlphaComponent(0.64)
        container.isHidden = true
        container.layer.cornerRadius = 24
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
#elseif os(macOS)
        let container = NSVisualEffectView()
        container.blendingMode = .withinWindow
        container.material = .menu
        container.wantsLayer = true
#endif
        container.isHidden = true
        self.addSubview(container)
#if os(iOS)
        container.isUserInteractionEnabled = true
#endif
        
        let handlerImageView = UIImageView(image: UIImage(named: "ic-handler"))
        handlerImageView.contentMode = .scaleAspectFit
        container.addSubview(handlerImageView)
        handlerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            handlerImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            handlerImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            handlerImageView.widthAnchor.constraint(equalToConstant: 25),
            handlerImageView.heightAnchor.constraint(equalToConstant: 4)
        ])
        self.controlContainer = container
        self.addVideoButtons(to: container)
        return container
    }
    
    /// Get the button for enabling/disabling the camera
    /// - Returns: The button for enabling/disabling the camera if enabled, otherwise nil
    @objc open func getCameraButton() -> MPButton? {
        if !self.agoraSettings.enabledButtons.contains(.cameraButton) { return nil }
        if let camButton = self.camButton { return camButton }
        
        let button = MPButton.newToggleButton(
            unselected: MPButton.videoSymbol, selected: MPButton.muteVideoSelectedSymbol
        )
#if os(iOS)
        button.addTarget(self, action: #selector(toggleCam), for: .touchUpInside)
#elseif os(macOS)
        button.target = self
        button.action = #selector(self.toggleCam)
#endif
        
        self.camButton = button
        return button
    }
    
    /// Get the button for muting/unmuting the microphone
    /// - Returns: The button for muting/unmuting the microphone if enabled, otherwise nil
    @objc open func getMicButton() -> MPButton? {
        if !self.agoraSettings.enabledButtons.contains(.micButton) { return nil }
        if let micButton = self.micButton { return micButton }
        
        let button = MPButton.newToggleButton(
            unselected: "ic-mic", selected: MPButton.muteMicSelectedSymbol
        )
        button.setImage(UIImage(named: "ic-mic"), for: .normal)
        if let muteMicSelectedSymbol = MPButton.muteMicSelectedSymbol {
            button.setImage(UIImage(systemName: muteMicSelectedSymbol), for: .selected)
        }
        
        button.tintColor = UIColor.white
#if os(iOS)
        button.addTarget(self, action: #selector(toggleMic), for: .touchUpInside)
#elseif os(macOS)
        button.target = self
        button.action = #selector(toggleMic)
#endif
        
        self.micButton = button
        return button
    }
    
    /// Get the button for sharing the current screen. This button is available for macOS only.
    /// iOS screen sharing must be implemented using `RPSystemBroadcastPickerView`.
    /// - Returns: The button for sharing screen if enabled, otherwise nil
    @objc open func getScreenShareButton() -> MPButton? {
#if os(iOS)
        return nil
#elseif os(macOS)
        if !self.agoraSettings.enabledButtons.contains(.screenShareButton) { return nil }
        
        if let ssButton = self.screenShareButton { return ssButton }
        let button = MPButton.newToggleButton(
            unselected: MPButton.screenShareSymbol
        )
        button.target = self
        button.action = #selector(toggleScreenShare)
        //        prepareSystemBroadcaster()
        self.screenShareButton = button
        return button
#endif
    }
    
    //    func prepareSystemBroadcaster() {
    //        let frame = CGRect(x: 0, y:0, width: 60, height: 60)
    //        let systemBroadcastPicker = RPSystemBroadcastPickerView(frame: frame)
    //        systemBroadcastPicker.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
    //        if let url = Bundle.main.url(forResource: "Agora-ScreenShare-Extension", withExtension: "appex", subdirectory: "PlugIns") {
    //            if let bundle = Bundle(url: url) {
    //                systemBroadcastPicker.preferredExtension = bundle.bundleIdentifier
    //            }
    //        }
    //        self.addSubview(systemBroadcastPicker)
    //    }
    
    /// Get the button for flipping the camera from front to rear facing
    /// - Returns: The button for flipping the camera if enabled, otherwise nil
    @objc open func getFlipButton() -> MPButton? {
        if !self.agoraSettings.enabledButtons.contains(.flipButton) { return nil }
        if let flipButton = self.flipButton { return flipButton }
#if os(iOS)
        let button = MPButton.newToggleButton(unselected: MPButton.cameraRotateSymbol)
        button.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        
        self.flipButton = button
        return button
#elseif os(macOS)
        return nil
#endif
    }
    
    /// Get the button for enabling/disabling the beautify effect.
    /// - Returns: The button if enabled, otherwise nil
    @objc open func getBeautifyButton() -> MPButton? {
        if !self.agoraSettings.enabledButtons.contains(.beautifyButton) { return nil }
        if let beautyButton = self.beautyButton {
            return beautyButton
        }
        
        let button = MPButton.newToggleButton(unselected: MPButton.wandSymbol)
#if os(iOS)
        button.addTarget(self, action: #selector(toggleBeautify), for: .touchUpInside)
#elseif os(macOS)
        button.target = self
        button.action = #selector(toggleBeautify)
#endif
        
        self.beautyButton = button
        return button
    }
    
    @objc open func getChatButton() -> MPButton? {
        if let chatButton = self.chatButton {
            return chatButton
        }
        
        let button = MPButton.newToggleButton(unselected: MPButton.chatSymbol)
        button.addTarget(self, action: #selector(tappedChatButton), for: .touchUpInside)
        
        self.chatButton = button
        return button
    }
    
    @objc open func getEndCallButton() -> MPButton? {
        if let chatButton = self.endCallButton {
            return chatButton
        }
        
        let button = MPButton.newToggleButton(unselected: MPButton.endcallSymbol)
        button.addTarget(self, action: #selector(tappedEndCallButton), for: .touchUpInside)
        
        self.endCallButton = button
        return button
    }
    
    
    @objc open func getLayoutButton() -> MPButton? {
        if let layoutButton = self.layoutButton {
            return layoutButton
        }
        
        let button = MPButton.newToggleButton(unselected: MPButton.layoutSymbol)
        button.addTarget(self, action: #selector(tappedLayoutButton), for: .touchUpInside)
        self.layoutButton = button
        return button
    }
    
    @objc open func getInputAudioButton() -> MPButton? {
        if let audioInputButton = self.audioInputButton {
            return audioInputButton
        }
        
        let button = MPButton.newToggleButton(unselected: MPButton.bluetoothSymbol)
        button.addTarget(self, action: #selector(tappedAudioInoutButton), for: .touchUpInside)
        
        self.audioInputButton = button
        return button
    }
    
    @objc open func getFlashButton() -> MPButton? {
        if let flashButton = self.flashButton {
            return flashButton
        }
        
        let button = MPButton.newToggleButton(unselected: MPButton.flashSymbol)
        button.addTarget(self, action: #selector(tappedFlashButton), for: .touchUpInside)
        
        self.flashButton = button
        return button
    }
    
    @objc open func getBackButton() -> MPButton? {
        if let backButton = self.backButton {
            return backButton
        }
        
        let button = MPButton.newToggleButton(unselected: "ic-back")
        button.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        
        self.backButton = button
        return button
    }
    
    func layoutTopButtons() {
        
        guard let container = self.topButtonContainer else {
            return
        }
        
        
        NSLayoutConstraint.activate([
            topButtonStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            topButtonStackView.centerYAnchor.constraint(equalTo: container.centerYAnchor
                                                       ),
            topButtonStackView.widthAnchor.constraint(equalTo: container.widthAnchor),
            topButtonStackView.heightAnchor.constraint(equalTo: container.heightAnchor),
            
        ])
        
        for button in topButtonStackView.arrangedSubviews {
            button.frame.size = CGSize(width: 41, height: 41)
            //            button.removeAllConstraints()
            //            button.translatesAutoresizingMaskIntoConstraints = false
            //            NSLayoutConstraint.activate([
            //                button.widthAnchor.constraint(equalToConstant: 41),
            //                button.heightAnchor.constraint(equalToConstant: 41)
            //            ])
            button.backgroundColor = [UIColor.red, UIColor.green, UIColor.yellow, UIColor.purple].randomElement()
        }
        
    }
    
    @IBAction func didPanTray(_ sender: UIPanGestureRecognizer) {
        guard let controlContainer = controlContainer else { return }
        var translation = sender.translation(in: self)
        var velocity = sender.velocity(in: self)
        
        print("hai translation \(translation)")
        
        let maxOffsetY = UIScreen.main.bounds.height - controlContainer.frame.height/2 - ((self.style == .expand ? bottomTableHeight : 0))
        let minOffsetY =  UIScreen.main.bounds.height - 30 + controlContainer.frame.height/2
        if sender.state == .began {
            trayOriginalCenter = controlContainer.center
            
        } else if sender.state == .changed {
            
            var newOffsetY = trayOriginalCenter.y + translation.y
            newOffsetY = max(minOffsetY, newOffsetY)
            newOffsetY = min(maxOffsetY, newOffsetY)
            
            print("hai translation \(newOffsetY) ->\(maxOffsetY). ->\(minOffsetY)  ->\(translation.y)")
            controlContainer.center = CGPoint(x: controlContainer.center.x, y: newOffsetY)
            
        } else if sender.state == .ended {
            if velocity.y > 0 {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    controlContainer.center = CGPoint(x: controlContainer.center.x, y: minOffsetY)
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    controlContainer.center = CGPoint(x: controlContainer.center.x, y: maxOffsetY)
                })
            }
        }
    }
}
