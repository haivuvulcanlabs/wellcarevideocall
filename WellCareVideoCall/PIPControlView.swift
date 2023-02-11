//
//  PIPControlView.swift
//  WellCareVideoCall
//
//  Created by vulcanlabs-hai on 11/02/2023.
//

import Foundation
import UIKit

enum ButtonAction: Int, CaseIterable {
    case pip = 0, close, flip, camera, mic
}
protocol PIPControlViewDelegate: AnyObject {
    func didSelectButton(_ action: ButtonAction)
}

class PIPControlView: UIView {
    private lazy var maximizedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic-maximized"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapppedExitPip(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic-close"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapppedCloseButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var flipCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic-switch-camera"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapppedFlipCameraButton(_:)), for: .touchUpInside)

        return button
    }()
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic-camera"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapppedCameraButton(_:)), for: .touchUpInside)

        
        return button
    }()
    
    private lazy var micButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic-mic"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapppedMicButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 18
        return stackView
    }()
    
    var delegate: PIPControlViewDelegate?
    
    init() {
        super.init(frame: .zero)
        setupUIs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUIs() {
        addSubview(maximizedButton)
        addSubview(closeButton)
        
        maximizedButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            maximizedButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            maximizedButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4),
            maximizedButton.widthAnchor.constraint(equalToConstant: 22),
            maximizedButton.heightAnchor.constraint(equalToConstant: 22),
            
            closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            closeButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4),
            closeButton.widthAnchor.constraint(equalToConstant: 22),
            closeButton.heightAnchor.constraint(equalToConstant: 22),
            
        ])
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
        stackView.addArrangedSubview(flipCameraButton)
        stackView.addArrangedSubview(cameraButton)
        stackView.addArrangedSubview(micButton)
        
        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            flipCameraButton.heightAnchor.constraint(equalToConstant: 18),
            flipCameraButton.widthAnchor.constraint(equalToConstant: 20),
            
            cameraButton.heightAnchor.constraint(equalToConstant: 18),
            cameraButton.widthAnchor.constraint(equalToConstant: 20),
            
            micButton.heightAnchor.constraint(equalToConstant: 18),
            micButton.widthAnchor.constraint(equalToConstant: 18),
            
        ])
        
    }
    
    @objc func tapppedExitPip(_ sender: UIButton) {
        delegate?.didSelectButton(.pip)
    }
    
    @objc func tapppedCloseButton(_ sender: UIButton) {
        delegate?.didSelectButton(.close)
    }
    
    @objc func tapppedFlipCameraButton(_ sender: UIButton) {
        delegate?.didSelectButton(.flip)
    }
    
    @objc func tapppedCameraButton(_ sender: UIButton) {
        delegate?.didSelectButton(.camera)
    }
    
    @objc func tapppedMicButton(_ sender: UIButton) {
        delegate?.didSelectButton(.mic)
    }
}
