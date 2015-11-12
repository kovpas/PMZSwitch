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
    
    internal var thumbTintColor: UIColor = UIColor.whiteColor() {
        willSet {
            backgroundView.backgroundColor = isOn ? onThumbTintColor : newValue
        }
    }
    internal var onThumbTintColor: UIColor = UIColor.whiteColor() {
        willSet {
            backgroundView.backgroundColor = isOn ? newValue : thumbTintColor
        }
    }
    internal var shadowColor: UIColor = UIColor.grayColor() {
        willSet {
            backgroundView.layer.shadowColor = newValue.CGColor
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
        let squareRect = CGRectMake(0, 0, defaultFrame.height, defaultFrame.height)
        let initialFrame = CGRectIsEmpty(frame) ? CGRectInset(squareRect, borderMargin, borderMargin) : frame
        super.init(frame: initialFrame)
        setup()
    }
    
    private func setup() {
        backgroundView = UIView(frame: self.bounds)

        backgroundView.layer.cornerRadius = self.frame.height * 0.5
        backgroundView.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: backgroundView.layer.cornerRadius).CGPath
        backgroundView.layer.shadowRadius = 4.0
        backgroundView.layer.shadowOpacity = 0
        backgroundView.layer.shadowColor = shadowColor.CGColor
        backgroundView.layer.shadowOffset = CGSizeMake(0, 7)
        backgroundView.layer.masksToBounds = false

        self.addSubview(backgroundView)
        self.userInteractionEnabled = false
        
        setupSignViews()
    }
    
    internal func toggle(animated: Bool) {
        resetAnimations()
        isTracking = false

        isOn = !isOn

        thumbSignView1.layer.speed = animated ? 1 : 0;
        thumbSignView2.layer.speed = animated ? 1 : 0;
        backgroundView.layer.speed = animated ? 1 : 0;

        thumbSignView1.layer.addAnimation(animationGroup1, forKey: "tickAnimation")
        thumbSignView2.layer.addAnimation(animationGroup2, forKey: "tickAnimation")
        backgroundView.layer.addAnimation(thumbAnimationGroup, forKey: "thumbAnimation")
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
        
        thumbSignView1.layer.addAnimation(animationGroup1, forKey: "tickAnimation")
        thumbSignView2.layer.addAnimation(animationGroup2, forKey: "tickAnimation")
        backgroundView.layer.addAnimation(thumbAnimationGroup, forKey: "thumbAnimation")
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
        thumbSignView1.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        self.addSubview(thumbSignView1);
        
        thumbSignView2 = createThumbSignView()
        thumbSignView2.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_4))
        self.addSubview(thumbSignView2);
    }
    
    private func createThumbSignView() -> UIView {
        let thumbSignHeight = self.bounds.height / 2 - thumbSignWidth
        let thumbSignView = UIView(frame: CGRectMake(self.bounds.width / 2 - 4, self.bounds.height / 2 - thumbSignHeight / 2, thumbSignWidth, thumbSignHeight))
        thumbSignView.layer.cornerRadius = thumbSignWidth / 2
        thumbSignView.backgroundColor = UIColor.whiteColor()
        
        return thumbSignView
    }
    
    private func resetAnimations() {
        thumbSignView1.layer.removeAllAnimations()
        thumbSignView2.layer.removeAllAnimations()
        backgroundView.layer.removeAllAnimations()
        
        thumbSignView1.layer.timeOffset = 0
        thumbSignView2.layer.timeOffset = 0
        backgroundView.layer.timeOffset = 0

        let fillMode = kCAFillModeForwards
        let thumbSignHeight = self.bounds.height / 2 - thumbSignWidth

        let rotationAnimation1 = baseAnimation("transform.rotation", fromValue: CGFloat(M_PI_4), toValue: CGFloat(-M_PI + M_PI_4))
        let scaleAnimation1 = baseAnimation("bounds.size.height", fromValue: thumbSignHeight, toValue: thumbSignHeight + 7)
        let moveAnimation1 = baseAnimation("position", fromValue: NSValue(CGPoint: thumbSignView1.center), toValue: NSValue(CGPoint: CGPoint(x: thumbSignView1.center.x + 10, y: thumbSignView1.center.y + 4)))
        
        animationGroup1 = CAAnimationGroup()
        animationGroup1.duration = animationDuration
        animationGroup1.animations = [rotationAnimation1, scaleAnimation1, moveAnimation1]
        animationGroup1.removedOnCompletion = false
        animationGroup1.fillMode = fillMode

        let rotationAnimation2 = baseAnimation("transform.rotation", fromValue: CGFloat(-M_PI_4), toValue: CGFloat(-M_PI - M_PI_4))
        let scaleAnimation2 = baseAnimation("bounds.size.height", fromValue: thumbSignHeight, toValue: thumbSignHeight / 2 + 6)
        let moveAnimation2 = baseAnimation("position", fromValue: NSValue(CGPoint: thumbSignView2.center), toValue: NSValue(CGPoint: CGPoint(x: thumbSignView2.center.x - 25, y: thumbSignView2.center.y + 17)))
        
        animationGroup2 = CAAnimationGroup()
        animationGroup2.duration = animationDuration
        animationGroup2.animations = [rotationAnimation2, scaleAnimation2, moveAnimation2]
        animationGroup2.removedOnCompletion = false
        animationGroup2.fillMode = fillMode
        
        let shadowOpacityAnimation = baseAnimation("shadowOpacity", fromValue: 0, toValue: 0.5)
        let bgColorAnimation = baseAnimation("backgroundColor", fromValue: thumbTintColor.CGColor, toValue: onThumbTintColor.CGColor)

        thumbAnimationGroup = CAAnimationGroup()
        thumbAnimationGroup.duration = animationDuration
        thumbAnimationGroup.animations = [shadowOpacityAnimation, bgColorAnimation]
        thumbAnimationGroup.removedOnCompletion = false
        thumbAnimationGroup.fillMode = fillMode
    }
    
    func baseAnimation(keyPath: String, fromValue: AnyObject?, toValue: AnyObject?) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = animationDuration
        animation.fromValue = isOn ? toValue : fromValue
        animation.toValue = isOn ? fromValue : toValue
        
        return animation
    }
    
}
