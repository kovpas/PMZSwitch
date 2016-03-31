//
//  PMZSwitch.swift
//  PMZSwitch
//
//  Created by Pavel S. Mazurin on 11/11/15.
//
//

import QuartzCore
import UIKit

internal let defaultFrame = CGRectMake(0, 0, 50, 30)
internal let borderMargin = CGFloat(17)
internal let animationDuration = CFTimeInterval(0.3)

@IBDesignable @objc public class PMZSwitch : UIControl, UIGestureRecognizerDelegate {

    // MARK: - Properties -
    // MARK: public
    /**
     *   Set (without animation) whether the switch is on or off
     */
    @IBInspectable public var on: Bool {
        get {
            return switchValue
        }
        set {
            switchValue = newValue
            self.setOn(newValue, animated: false)
        }
    }
    
    @IBInspectable public var thumbTintColor: UIColor {
        get {
            return thumbView.thumbTintColor
        }
        set {
            thumbView.thumbTintColor = newValue
        }
    }
    
    @IBInspectable public var onThumbTintColor: UIColor {
        get {
            return thumbView.onThumbTintColor
        }
        set {
            thumbView.onThumbTintColor = newValue
        }
    }
    
    @IBInspectable public var shadowColor: UIColor {
        get {
            return thumbView.shadowColor
        }
        set {
            thumbView.shadowColor = newValue
        }
    }
    
    // MARK: internal
    internal var backgroundView: UIView!
    internal var thumbView: PMZISwitchAnimatedThumb!
    // MARK: private
    private var startTrackingPoint: CGPoint = CGPoint.zero
    private var startThumbFrame: CGRect = CGRect.zero
    private var switchValue: Bool = false
    private var ignoreTap: Bool = false
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    private var maxThumbOffset: CGFloat {
        return self.bounds.width - thumbView.frame.width - borderMargin * 2
    }

    private var originalThumbRect: CGRect {
        let squareRect = CGRectMake(0, 0, self.bounds.height, self.bounds.height)
        return CGRectInset(squareRect, borderMargin, borderMargin)
    }

    
    // MARK: - Lifecycle -
    /**
     *   Initialization
     */
    public convenience init() {
        self.init(frame: defaultFrame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    override public init(frame: CGRect) {
        let initialFrame = CGRectIsEmpty(frame) ? defaultFrame : frame
        super.init(frame: initialFrame)
        
        self.setup()
    }
    
    /**
     *   Setup the individual elements of the switch and set default values
     */
    private func setup() {
        // background
        backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = UIColor.whiteColor()
        backgroundView.layer.cornerRadius = self.frame.height * 0.5
        backgroundView.userInteractionEnabled = false
        backgroundView.clipsToBounds = true
        self.addSubview(backgroundView)
        
        // thumb
        thumbView = PMZISwitchAnimatedThumb(frame: originalThumbRect)
        self.addSubview(thumbView)
        
        on = false
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PMZSwitch.handleTapGesture(_:)))
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Tap gesture recognizer handler -
    
    func handleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        if ignoreTap {
            return
        }
        
        if gestureRecognizer.state == .Ended {
            thumbView.toggle(true)
            setOn(!on, animated: true)
        }
    }

    // MARK: - UIControl tracking methods -
    
    override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        startTrackingPoint = touch.locationInView(self)
        startThumbFrame = thumbView.frame
        thumbView.startTracking()

        return true
    }
    
    override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        ignoreTap = true

        // Get touch location
        let lastPoint = touch.locationInView(self)
        let thumbMinPosition = originalThumbRect.origin.x
        let thumbMaxPosition = originalThumbRect.origin.x + maxThumbOffset
        let touchXOffset = lastPoint.x - startTrackingPoint.x
        
        var desiredFrame = CGRectOffset(startThumbFrame, touchXOffset, 0)
        desiredFrame.origin.x = min(max(desiredFrame.origin.x, thumbMinPosition), thumbMaxPosition)
        thumbView.frame = desiredFrame

        if on { // left <- right
            thumbView.animationProgress = (thumbMaxPosition - desiredFrame.origin.x) / maxThumbOffset
        } else { // left -> right
            thumbView.animationProgress = (desiredFrame.origin.x - thumbMinPosition) / maxThumbOffset
        }
        
        return true
    }
    
    override public func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)
        
        if thumbView.center.x > self.bounds.midX {
            setOn(true, animated: true)
        }
        else {
            setOn(false, animated: true)
        }
        
        ignoreTap = false
    }
    
    override public func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
        if !ignoreTap {
            return
        }

        // just animate back to the original value
        if on {
            showOn(true)
        } else {
            showOff(true)
        }
        ignoreTap = false
    }
    
    // MARK: - Public API -
    /**
     *   Sets the state of the switch to on or off, optionally animating the transition.
     */
    public func setOn(isOn: Bool, animated: Bool) {
        switchValue = isOn
        
        if on {
            showOn(animated)
        }
        else {
            showOff(animated)
        }
    }
    
    /**
     *   Detects whether the switch is on or off
     *
     *	 @return	Bool true if switch is on, false otherwise
     */
    public func isOn() -> Bool {
        return on
    }
    
    // MARK: - Private methods -

    /**
     *   Updates the looks of the switch to be in the on position
     *   optionally make it animated
     */
    private func showOn(animated: Bool) {
        thumbView.endTracking(true)

        UIView.animateWithDuration(animationDuration, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseIn, UIViewAnimationOptions.BeginFromCurrentState], animations: {
            self.thumbView.frame = CGRectOffset(self.originalThumbRect, self.maxThumbOffset, 0)
        }, completion: nil)
    }
    
    /**
     *   Updates the looks of the switch to be in the off position
     *   optionally make it animated
     */
    private func showOff(animated: Bool) {
        thumbView.endTracking(false)

        UIView.animateWithDuration(animationDuration, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseIn, UIViewAnimationOptions.BeginFromCurrentState], animations: {
            self.thumbView.frame = self.originalThumbRect
        }, completion: nil)
    }
}
