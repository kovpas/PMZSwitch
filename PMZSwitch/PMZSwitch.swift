//
//  PMZSwitch.swift
//  PMZSwitch
//
//  Created by Pavel S. Mazurin on 11/11/15.
//
//

import QuartzCore
import UIKit

internal let defaultFrame = CGRect(x: 0, y: 0, width: 50, height: 30)
internal let borderMargin: CGFloat = 17
internal let animationDuration: CFTimeInterval = 0.3

@IBDesignable @objc public class PMZSwitch: UIControl, UIGestureRecognizerDelegate {
    
    // MARK: - Properties -
    // MARK: public
    /**
     *   Set (without animation) whether the switch is on or off
     */
    @IBInspectable public var on: Bool {
        get { return switchValue }
        set {
            switchValue = newValue
            self.setOn(isOn: newValue, animated: false)
        }
    }
    
    @IBInspectable public var thumbTintColor: UIColor {
        get { return thumbView.thumbTintColor }
        set { thumbView.thumbTintColor = newValue }
    }
    
    @IBInspectable public var onThumbTintColor: UIColor {
        get { return thumbView.onThumbTintColor }
        set { thumbView.onThumbTintColor = newValue }
    }
    
    @IBInspectable public var shadowColor: UIColor {
        get { return thumbView.shadowColor }
        set { thumbView.shadowColor = newValue }
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
        let squareRect = CGRect(x: 0, y: 0, width: self.bounds.height, height: self.bounds.height)
        return squareRect.inset(by: UIEdgeInsets(top: borderMargin, left: borderMargin, bottom: borderMargin, right: borderMargin))
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
        let initialFrame = frame.isEmpty ? defaultFrame : frame
        super.init(frame: initialFrame)
        
        self.setup()
    }
    
    /**
     *   Setup the individual elements of the switch and set default values
     */
    private func setup() {
        // background
        backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = self.frame.height * 0.5
        backgroundView.isUserInteractionEnabled = false
        backgroundView.clipsToBounds = true
        self.addSubview(backgroundView)
        
        // thumb
        thumbView = PMZISwitchAnimatedThumb(frame: originalThumbRect)
        self.addSubview(thumbView)
        
        on = false
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Tap gesture recognizer handler -
    
    @objc func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard !ignoreTap else { return }
        
        if gestureRecognizer.state == .ended {
            thumbView.toggle(animated: true)
            setOn(isOn: !on, animated: true)
        }
    }
    
    // MARK: - UIControl tracking methods -
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        startTrackingPoint = touch.location(in: self)
        startThumbFrame = thumbView.frame
        thumbView.startTracking()
        
        return true
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        ignoreTap = true
        
        // Get touch location
        let lastPoint = touch.location(in: self)
        let thumbMinPosition = originalThumbRect.origin.x
        let thumbMaxPosition = originalThumbRect.origin.x + maxThumbOffset
        let touchXOffset = lastPoint.x - startTrackingPoint.x
        
        var desiredFrame = startThumbFrame.offsetBy(dx: touchXOffset, dy: 0)
        desiredFrame.origin.x = min(max(desiredFrame.origin.x, thumbMinPosition), thumbMaxPosition)
        thumbView.frame = desiredFrame
        
        if on { // left <- right
            thumbView.animationProgress = (thumbMaxPosition - desiredFrame.origin.x) / maxThumbOffset
        } else { // left -> right
            thumbView.animationProgress = (desiredFrame.origin.x - thumbMinPosition) / maxThumbOffset
        }
        
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        thumbView.center.x > self.bounds.midX ? setOn(isOn: true, animated: true) : setOn(isOn: false, animated: true)
        
        ignoreTap = false
    }
    
    override public func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        guard ignoreTap else { return }
        
        // just animate back to the original value
        on ? showOn(animated: true) : showOff(animated: true)
        ignoreTap = false
    }
    
    // MARK: - Public API -
    /**
     *   Sets the state of the switch to on or off, optionally animating the transition.
     */
    public func setOn(isOn: Bool, animated: Bool) {
        switchValue = isOn
        on ? showOn(animated: animated) : showOff(animated: animated)
    }
    
    /**
     *   Detects whether the switch is on or off
     *
     *     @return    Bool true if switch is on, false otherwise
     */
    public var isOn: Bool {
        return on
    }
    
    // MARK: - Private methods -
    
    /**
     *   Updates the looks of the switch to be in the on position
     *   optionally make it animated
     */
    private func showOn(animated: Bool) {
        thumbView.endTracking(isOn: true)
        
        UIView.animate(withDuration: animated ? animationDuration : 0, delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            self.thumbView.frame = self.originalThumbRect.offsetBy(dx: self.maxThumbOffset, dy: 0)
        })
    }
    
    /**
     *   Updates the looks of the switch to be in the off position
     *   optionally make it animated
     */
    private func showOff(animated: Bool) {
        thumbView.endTracking(isOn: false)
        
        UIView.animate(withDuration: animated ? animationDuration : 0, delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            self.thumbView.frame = self.originalThumbRect
        })
    }
}
