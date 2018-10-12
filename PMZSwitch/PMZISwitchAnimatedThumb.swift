//
//  PMZISwitchAnimatedThumb.swift
//  PMZSwitch
//
//  Created by Pavel S. Mazurin on 11/11/15.
//
//

import UIKit

private let thumbSignWidth = CGFloat(7)

internal class PMZISwitchAnimatedThumb: UIView {
    
    // MARK: - Properties -
    // MARK: internal
    internal var animationProgress: CGFloat = 0 {
        didSet {
            if animationProgress > 1 {
                animationProgress = 1
            }
            if animationProgress < 0 {
                animationProgress = 0
            }
            
            thumbSignView1.layer.timeOffset = animationDuration * CFTimeInterval(animationProgress)
            thumbSignView2.layer.timeOffset = animationDuration * CFTimeInterval(animationProgress)
            backgroundView.layer.timeOffset = animationDuration * CFTimeInterval(animationProgress)
        }
    }
    
    internal var thumbTintColor: UIColor = .white {
        willSet {
            backgroundView.backgroundColor = isOn ? onThumbTintColor : newValue
        }
    }
    internal var onThumbTintColor: UIColor = .white {
        willSet {
            backgroundView.backgroundColor = isOn ? newValue : thumbTintColor
        }
    }
    internal var shadowColor: UIColor = .gray {
        willSet {
            backgroundView.layer.shadowColor = newValue.cgColor
        }
    }
    
    // MARK: private
    private var backgroundView: UIView!
    private var thumbSignView1: UIView!
    private var thumbSignView2: UIView!
    private var animationGroup1: CAAnimationGroup!
    private var animationGroup2: CAAnimationGroup!
    private var thumbAnimationGroup: CAAnimationGroup!
    private var isOn: Bool = false
    private var isTracking: Bool = false
    
    // MARK: - Lifecycle -
    /**
     *   Initialization
     */
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override internal init(frame: CGRect) {
        let squareRect = CGRect(x: 0, y: 0, width: defaultFrame.height, height: defaultFrame.height)
        let initialFrame = frame.isEmpty ? squareRect.inset(by: UIEdgeInsets(top: borderMargin, left: borderMargin, bottom: borderMargin, right: borderMargin)) : frame
        super.init(frame: initialFrame)
        setup()
    }
    
    private func setup() {
        backgroundView = UIView(frame: self.bounds)
        
        backgroundView.layer.cornerRadius = self.frame.height * 0.5
        backgroundView.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: backgroundView.layer.cornerRadius).cgPath
        backgroundView.layer.shadowRadius = 4.0
        backgroundView.layer.shadowOpacity = 0
        backgroundView.layer.shadowColor = shadowColor.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 7)
        backgroundView.layer.masksToBounds = false
        
        self.addSubview(backgroundView)
        self.isUserInteractionEnabled = false
        
        setupSignViews()
    }
    
    internal func toggle(animated: Bool) {
        resetAnimations()
        isTracking = false
        
        isOn = !isOn
        
        thumbSignView1.layer.speed = animated ? 1 : 0;
        thumbSignView2.layer.speed = animated ? 1 : 0;
        backgroundView.layer.speed = animated ? 1 : 0;
        
        thumbSignView1.layer.add(animationGroup1, forKey: "tickAnimation")
        thumbSignView2.layer.add(animationGroup2, forKey: "tickAnimation")
        backgroundView.layer.add(thumbAnimationGroup, forKey: "thumbAnimation")
    }
    
    internal func startTracking() {
        if isTracking {
            return
        }
        resetAnimations()
        isTracking = true
        
        thumbSignView1.layer.speed = 0;
        thumbSignView2.layer.speed = 0;
        backgroundView.layer.speed = 0;
        
        thumbSignView1.layer.add(animationGroup1, forKey: "tickAnimation")
        thumbSignView2.layer.add(animationGroup2, forKey: "tickAnimation")
        backgroundView.layer.add(thumbAnimationGroup, forKey: "thumbAnimation")
    }
    
    internal func endTracking(isOn: Bool) {
        self.isOn = isOn
        if !isTracking {
            return
        }
        isTracking = false
        
        thumbSignView1.layer.timeOffset = animationDuration
        thumbSignView2.layer.timeOffset = animationDuration
        backgroundView.layer.timeOffset = animationDuration
    }
    
    private func setupSignViews() {
        thumbSignView1 = createThumbSignView()
        thumbSignView1.transform = CGAffineTransform(rotationAngle: .pi/4)
        self.addSubview(thumbSignView1);
        
        thumbSignView2 = createThumbSignView()
        thumbSignView2.transform = CGAffineTransform(rotationAngle: -(.pi/4))
        self.addSubview(thumbSignView2);
    }
    
    private func createThumbSignView() -> UIView {
        let thumbSignHeight = self.bounds.height / 2 - thumbSignWidth
        let thumbSignView = UIView(frame: CGRect(x: self.bounds.width / 2 - 4, y: self.bounds.height / 2 - thumbSignHeight / 2, width: thumbSignWidth, height: thumbSignHeight))
        thumbSignView.layer.cornerRadius = thumbSignWidth / 2
        thumbSignView.backgroundColor = .white
        
        return thumbSignView
    }
    
    private func resetAnimations() {
        thumbSignView1.layer.removeAllAnimations()
        thumbSignView2.layer.removeAllAnimations()
        backgroundView.layer.removeAllAnimations()
        
        thumbSignView1.layer.timeOffset = 0
        thumbSignView2.layer.timeOffset = 0
        backgroundView.layer.timeOffset = 0
        
        let fillMode = CAMediaTimingFillMode.forwards
        let thumbSignHeight = self.bounds.height / 2 - thumbSignWidth
        
        let rotationAnimation1 = baseAnimation(keyPath: "transform.rotation", fromValue: Double.pi/4, toValue: -Double.pi + Double.pi/4)
        let scaleAnimation1 = baseAnimation(keyPath: "bounds.size.height", fromValue: thumbSignHeight, toValue: thumbSignHeight + 7)
        let moveAnimation1 = baseAnimation(keyPath: "position", fromValue: NSValue(cgPoint: thumbSignView1.center), toValue: NSValue(cgPoint: CGPoint(x: thumbSignView1.center.x + 10, y: thumbSignView1.center.y + 4)))
        
        animationGroup1 = CAAnimationGroup()
        animationGroup1.duration = animationDuration
        animationGroup1.animations = [rotationAnimation1, scaleAnimation1, moveAnimation1]
        animationGroup1.isRemovedOnCompletion = false
        animationGroup1.fillMode = fillMode
        
        let rotationAnimation2 = baseAnimation(keyPath: "transform.rotation", fromValue: -(Double.pi/4), toValue: -Double.pi - Double.pi/4)
        let scaleAnimation2 = baseAnimation(keyPath: "bounds.size.height", fromValue: thumbSignHeight, toValue: thumbSignHeight / 2 + 6)
        let moveAnimation2 = baseAnimation(keyPath: "position", fromValue: NSValue(cgPoint: thumbSignView2.center), toValue: NSValue(cgPoint: CGPoint(x: thumbSignView2.center.x - 25, y: thumbSignView2.center.y + 17)))
        
        animationGroup2 = CAAnimationGroup()
        animationGroup2.duration = animationDuration
        animationGroup2.animations = [rotationAnimation2, scaleAnimation2, moveAnimation2]
        animationGroup2.isRemovedOnCompletion = false
        animationGroup2.fillMode = fillMode
        
        let shadowOpacityAnimation = baseAnimation(keyPath: "shadowOpacity", fromValue: 0 as Any, toValue: 0.5)
        let bgColorAnimation = baseAnimation(keyPath: "backgroundColor", fromValue: thumbTintColor.cgColor, toValue: onThumbTintColor.cgColor)
        
        thumbAnimationGroup = CAAnimationGroup()
        thumbAnimationGroup.duration = animationDuration
        thumbAnimationGroup.animations = [shadowOpacityAnimation, bgColorAnimation]
        thumbAnimationGroup.isRemovedOnCompletion = false
        thumbAnimationGroup.fillMode = fillMode
    }
    
    func baseAnimation(keyPath: String, fromValue: Any?, toValue: Any?) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = animationDuration
        animation.fromValue = isOn ? toValue : fromValue
        animation.toValue = isOn ? fromValue : toValue
        
        return animation
    }
    
}
