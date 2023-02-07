//
//  ViewController.swift
//  WellCareVideoCall
//
//  Created by vulcanlabs-hai on 06/02/2023.
//

import UIKit
import AgoraRtcKit
import MediaPlayer

class ViewController: UIViewController {
    private lazy var bgImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bg-waitting"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var joinButton: UIButton = {
        let button = UIButton()
        button.setTitle("JOIN AS PATIENT", for: .normal)
        button.addTarget(self, action: #selector(tappedJoinAsPatientButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var joinAsDoctorButton: UIButton = {
        let button = UIButton()
        button.setTitle("JOIN AS DOCTOR", for: .normal)
        button.addTarget(self, action: #selector(tappedJoinAsDoctorButton(_:)), for: .touchUpInside)
        return button
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .black
        view.addSubview(bgImageView)
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bgImageView.rightAnchor.constraint(equalTo: view.rightAnchor),

        ])
        
        
        view.addSubview(joinButton)
        view.addSubview(joinAsDoctorButton)

        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinAsDoctorButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            joinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -80),
            joinButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 160),
            joinButton.heightAnchor.constraint(equalToConstant: 40),
            
            joinAsDoctorButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 80),
            joinAsDoctorButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            joinAsDoctorButton.widthAnchor.constraint(equalToConstant: 160),
            joinAsDoctorButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    
    @objc func tappedJoinAsDoctorButton(_ sender: UIButton) {
        let vc = WellCareViewController(userPermissin: .doctor)
        vc.modalPresentationStyle = .fullScreen
        
        present(vc, animated: true)
    }
    
    @objc func tappedJoinAsPatientButton(_ sender: UIButton) {
        let vc = WellCareViewController(userPermissin: .patient)
        vc.modalPresentationStyle = .fullScreen
        
        present(vc, animated: true)
    }
}


