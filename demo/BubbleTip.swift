//
//  BubbleTip.swift
//
//  Created by Chris Ameter on 11/11/14.
//  Copyright (c) 2014 Christopher R. Ameter. All rights reserved.
//

import UIKit
import CoreGraphics

@available(iOS 12.0, *)
class BubbleTip : UIView {
    
    let target:AnyObject?
    let location:CGPoint?
    var text = ""
    var fontSize:CGFloat
    var position:TipPosition
    
    var tapToDismiss = true
    var fontColor = UIColor.white
    var borderColor = UIColor.white
    var fillColor = UIColor.black
    
    enum TipPosition {
        case Top
        case Bottom
    }
    
    private var wrappedText = ""
    private var label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    
    // Common init to be called from external inits
    private init(target: AnyObject?, location:CGPoint?, text:String, fontSize:CGFloat, position:TipPosition) {
        
        // Set object properties.
        self.target = target
        self.location = location
        self.text = text
        self.fontSize = fontSize
        self.position = position
        
        // Get initial frame size.
        let textSize = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)])
        let width = textSize.width + 20
        let height = textSize.height + 25
        
        // Create the view
        let myFrame = CGRect(x: 0, y: 0, width: width, height: height)
        super.init(frame: myFrame)
        
        // Set default values (these can be overriden by user after creating the BubbleTip)
        backgroundColor = UIColor.clear
        alpha = 0.75
    }
    
    convenience init(target: UIView, text:String, fontSize:CGFloat = 14, position:TipPosition = .Bottom) {
        self.init(target: target, location: nil, text: text, fontSize: fontSize, position: position)
    }
    
    convenience init(target: UIBarItem, text:String, fontSize:CGFloat = 14) {
        // Set position to bottom for navigation bar buttoms or top for tab bar buttons.
        var position = TipPosition.Bottom
        if target is UITabBarItem {
            position = .Top
        }
        self.init(target: target, location: nil, text: text, fontSize: fontSize, position: position)
    }

    convenience init(location: CGPoint, text:String, fontSize:CGFloat = 14, position:TipPosition = .Bottom) {
        self.init(target: nil, location: location, text: text, fontSize: fontSize, position: position)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        lineWrap()
        setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if tapToDismiss {
            self.isHidden = true
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            // Register for orientation change notifications if newSuperview is not nil.
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            NotificationCenter.default.addObserver(self, selector: #selector(BubbleTip.deviceOrientationChanged(notification:)), name:UIDevice.orientationDidChangeNotification, object: nil);
        } else {
            // Unregister for orientation change notifications.
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    override func draw(_ rect: CGRect) {
        // Get the screen width
        let screenWidth = window!.rootViewController!.view.bounds.size.width
        
        let width = rect.width
        let height = rect.height
        
        // Get origin X and Y coordinates
        var x:CGFloat = 0.0
        var y:CGFloat = 0.0
        if let t:AnyObject = target {
            if t is UIView {
                x = t.frame.midX - (width / 2)
                switch position {
                case .Bottom:
                    y = t.frame.maxY
                case .Top:
                    y = t.frame.minY - rect.height
                }
            } else if t is UIBarButtonItem {
                x = (t.value(forKey: "view") as! UIView).frame.midX - (width / 2)
                y = 0
            } else if t is UITabBarItem {
                x = (t.value(forKey: "view") as! UIView).frame.midX - (width / 2)
                y = superview!.frame.size.height - height
            }
        } else if let loc = location {
            x = loc.x - (width / 2)
            y = loc.y
        }
        
        // Adjust horizontal offset position to keep bubble on screen
        var offset:CGFloat = 0

        if x + width > screenWidth - 6 {
            offset = 0 - ((x + width) - screenWidth + 3)
        }
        if x < 0 {
            offset = 0 - x + 3
        }

        frame.origin.x = x + offset
        frame.origin.y = y

        // Set up drawing properties
        let context = UIGraphicsGetCurrentContext()!
        let currentFrame = rect;
        let triangleHeight:CGFloat = 10, triangleWidth:CGFloat = 20, borderRadius:CGFloat = 4, strokeWidth:CGFloat = 1

        context.setLineJoin(.round)
        context.setLineWidth(strokeWidth)
        context.setStrokeColor(borderColor.cgColor)
        context.setFillColor(fillColor.cgColor)
        
        // Draw and fill the bubble
        switch position {
        case .Bottom:
            context.beginPath();
            context.move(to: CGPoint(x: borderRadius + strokeWidth + 0.5, y: strokeWidth + triangleHeight + 0.5))
            context.addLine(to: CGPoint(x: round((currentFrame.size.width / 2.0 - triangleWidth / 2.0) + 0.5) - offset, y: triangleHeight + strokeWidth + 0.5))
            context.addLine(to: CGPoint(x: round((currentFrame.size.width / 2.0) + 0.5) - offset, y: strokeWidth + 0.5))
            context.addLine(to: CGPoint(x: round((currentFrame.size.width / 2.0 + triangleWidth / 2.0) + 0.5) - offset, y: triangleHeight + strokeWidth + 0.5))
            context.addArc(tangent1End: CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: strokeWidth + triangleHeight + 0.5), tangent2End: CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: currentFrame.size.height - strokeWidth - 0.5), radius: borderRadius - strokeWidth)
            context.addArc(tangent1End: CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: currentFrame.size.height - strokeWidth - 0.5), tangent2End: CGPoint(x: round(currentFrame.size.width / 2.0 + triangleWidth / 2.0) - strokeWidth + 0.5, y: currentFrame.size.height - strokeWidth - 0.5), radius: borderRadius - strokeWidth)
            context.addArc(tangent1End: CGPoint(x: strokeWidth + 0.5, y: currentFrame.size.height - strokeWidth - 0.5), tangent2End: CGPoint(x: strokeWidth + 0.5, y: triangleHeight + strokeWidth + 0.5), radius: borderRadius - strokeWidth)
            context.addArc(tangent1End: CGPoint(x: strokeWidth + 0.5, y: strokeWidth + triangleHeight + 0.5), tangent2End: CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: triangleHeight + strokeWidth + 0.5), radius: borderRadius - strokeWidth)
            context.closePath()
            context.drawPath(using: .fillStroke)
        case .Top:
            context.beginPath()
            context.move(to: CGPoint(x: borderRadius + strokeWidth + 0.5, y: currentFrame.size.height - strokeWidth - triangleHeight - 0.5))
            context.addLine(to: CGPoint(x: round((currentFrame.size.width / 2.0 - triangleWidth / 2.0) + 0.5) - offset, y: currentFrame.size.height - strokeWidth - triangleHeight - 0.5))
            context.addLine(to: CGPoint(x: round((currentFrame.size.width / 2.0) + 0.5) - offset, y: currentFrame.size.height - strokeWidth - 0.5))
            context.addLine(to: CGPoint(x: round((currentFrame.size.width / 2.0 + triangleWidth / 2.0) + 0.5) - offset, y: currentFrame.size.height - triangleHeight - strokeWidth - 0.5))
            context.addArc(tangent1End: CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: currentFrame.size.height - triangleHeight - strokeWidth - 0.5), tangent2End: CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: strokeWidth + triangleHeight + 0.5), radius: borderRadius - strokeWidth)
            context.addArc(tangent1End: CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: strokeWidth + 0.5), tangent2End: CGPoint(x: round(currentFrame.size.width / 2.0 + triangleWidth / 2.0) - strokeWidth + 0.5, y: strokeWidth + 0.5), radius: borderRadius - strokeWidth)
            context.addArc(tangent1End: CGPoint(x: strokeWidth + 0.5, y: strokeWidth + 0.5), tangent2End: CGPoint(x: strokeWidth + 0.5, y: strokeWidth + 0.5), radius: borderRadius - strokeWidth)
            context.addArc(tangent1End: CGPoint(x: strokeWidth + 0.5, y: currentFrame.size.height - strokeWidth - triangleHeight - 0.5), tangent2End: CGPoint(x: currentFrame.size.width - strokeWidth - 0.5, y: currentFrame.size.height - strokeWidth - triangleHeight - 0.5), radius: borderRadius - strokeWidth)
            context.closePath()
            context.drawPath(using: .fillStroke)
        }
        
        // Add Text
        var labelFrame:CGRect
        switch position {
        case .Bottom:
            labelFrame = rect.offsetBy(dx: 0, dy: 5)
        case .Top:
            labelFrame = rect.offsetBy(dx: 0, dy: -5)
        }
        label.removeFromSuperview()
        label = UILabel(frame: labelFrame)
        label.textAlignment = NSTextAlignment.center
        label.textColor = fontColor
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.numberOfLines = 0
        label.text = wrappedText
        addSubview(label)
    }
    
    @objc func deviceOrientationChanged(notification:NSNotification) {
        //Obtaining the current device orientation
        //let orientation = UIDevice.currentDevice().orientation
        lineWrap()
        setNeedsDisplay()
    }
    
    func lineWrap() {
        // Get the screen width if the view has loaded into a window
        if let screenWidth = window?.rootViewController?.view.bounds.size.width {
            
            // Reset the wrapped text and frame to the original text.
//            wrappedText = text
//            let textSize = (text as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(fontSize)])
//            frame.size.width = textSize.width + 20
//            frame.size.height = textSize.height + 25
            
            // If text is too wide to fit on screen (text width + 20 buffer (10 each side) around text in frame + 6 buffer (3 each side) around frame in window
            let textSize = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)])
            if textSize.width + 26 > screenWidth {
                // Set wrappedText to empty string
                wrappedText = ""

                // Break up text lines to handle each line separately.
                let textLines = text.components(separatedBy: "\n")
                for textLine in textLines {
                    var currentText = textLine
                    let currentTextWidth = (currentText as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)]).width
                    
                    // Get the number of line breaks needed to fit the text to the screen.
                    let numLines = (Int)(((currentTextWidth + 20) / (screenWidth - 6)) + 1)
                    
                    // If the text is too wide to fit on the screen...
                    if numLines > 1 {
                        // Get the ideal number of chars to include per line.
                        let charsPerLine = currentText.count / numLines
                        
                        // Wrap the text by inserting a newline in place of the previous space before each ideal break location.
                        var idx = currentText.startIndex
                        for line in 1..<numLines {
                            idx = currentText.index(currentText.startIndex, offsetBy: charsPerLine * line)
                            while (idx > currentText.startIndex && currentText[idx] != " ") {
                                idx = currentText.index(before: idx)
                            }
                            if idx > currentText.startIndex {
                                currentText.remove(at: idx)
                                currentText.insert("\n", at: idx)
                                
                            }
                        }
                    }
                    if wrappedText != "" {
                        wrappedText += "\n"
                    }
                    wrappedText += currentText
                }
            } else {
                // Set wrappedText to text
                wrappedText = text
            }
            // Update the frame size based on the new text size.
            //let wrappedTextSize = (wrappedText as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(fontSize)])
            let wrappedTextSize = (wrappedText as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)])
            frame.size.width = wrappedTextSize.width + 20
            frame.size.height = wrappedTextSize.height + 25
        }
    }

}

