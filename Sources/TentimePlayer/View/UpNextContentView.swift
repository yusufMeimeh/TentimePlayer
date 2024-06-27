//
//  UpNextContent.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 25/09/2023.
//

import Foundation

import UIKit
import Kingfisher

class UpNextContentView: UIView {
    
    // MARK: - Outlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackTop: NSLayoutConstraint!
    @IBOutlet weak var textStack: UIStackView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var timer : Timer?
    var labelTimer: Timer?
    var timeLeft: TimeInterval = 30
    var endTime: Date?
    
    // MARK: - Closures
    var timerFinished: (() -> Void)?
    var nextTapped: (() -> Void)?
    var cancelTapped: (() -> Void)?
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        let nib = String(describing: UpNextContentView.self)
        Bundle.main.loadNibNamed(nib, owner: self, options: nil)
        addSubview(contentView)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        timerView.createCircularPath()
        
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        
//        textStack.spacing = UIView.isRTL() ? 2 : 6
//        stackTop.constant = IPAD ? (UIView.isRTL() ? 2 : 8) : (UIView.isRTL() ? 4 : 12)
        
        timerLabel.textColor = .white
        titleLabel.textColor = .white

//        subtitleLabel
//            .with(textColor: UIColor.TTWhiteColor)
//            .with(font: .regular(size: IPAD ? 18 : 13))
//            .with(heightMultiplier: 0.7)
//            .with(alignment: UIView.isRTL() ? .right : .left)
//            .with(lines: 2)
//            .adjustsFontSizeToFitWidth = false
//        subtitleLabel.lineBreakMode = .byTruncatingTail

        playButton.setTitle("play next", for: .normal)
        playButton.setTitleColor(.white, for: .normal)
        playButton.backgroundColor = UIColor.blue
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
//        cancelButton.backgroundColor = .clear
    }
    
    // MARK: - Public Function
    
    func configure(with imageURL: String, _ title: String, _ description: String) {
        
        imageView.kf.setImage(with: URL(string: imageURL), placeholder: UIImage(named: "icDefaultCard"))
        titleLabel.text = title
//        subtitleLabel.text = description
//        subtitleLabel.isHidden = music
        
        imageWidth.constant = 160
    }
    
    func runTimer(with duration : Double) {
        startTimer(with: duration)
    }
  
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            labelTimer?.invalidate()
            timer = nil
            labelTimer = nil
            timerLabel.text =  "Up next timer 0"

        }
    }
    
    func pauseTimer() {
        timer?.invalidate()
        labelTimer?.invalidate()
        timer = nil
        labelTimer = nil
    }
    
    func resumeTimer(with duration : Double) {
        startTimer(with: duration)
    }
    // MARK: - Private Functions
    
    private func startTimer(with duration : Double) {
        timeLeft = duration
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { [weak self] _ in
                self?.timerFinished?()
                self?.labelTimer?.invalidate()
                self?.labelTimer = nil
                self?.timerLabel.text = "UP Next time 0"
            })
            endTime = Date().addingTimeInterval(timeLeft)
            labelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        }
    }

    @objc private func updateTimeLabel() {
        if timeLeft > 0 {
            print("timeLeft ---> \(timeLeft)")
            timeLeft = endTime?.timeIntervalSinceNow ?? 0
        
            
            if timeLeft < 1 &&  timeLeft > 0 {
                timerLabel.text = "\(Int(timeLeft.rounded(.up)))" + "seconds"
            }else {
                timerLabel.text = "\(Int(timeLeft.rounded(.up)))"
            }
        } else {
            timerLabel.text = "0 seconds"
            stopTimer()
            labelTimer?.invalidate()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func nextTapped(_ sender: UIButton) {
        stopTimer()
        nextTapped?()
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        stopTimer()
        cancelTapped?()
    }
}

