//
//  JSSAlertView
//  JSSAlertView
//
//  Created by Jay Stakelon on 9/16/14.
//  Copyright (c) 2014 Jay Stakelon / https://github.com/stakes  - all rights reserved.
//
//  Inspired by and modeled after https://github.com/vikmeup/SCLAlertView-Swift
//  by Victor Radchenko: https://github.com/vikmeup
//

import Foundation
import UIKit

class JSSAlertView: UIViewController {
    
    var containerView:UIView!
    var modalBackgroundView:UIView!
    var modalButton:UIButton!
    var buttonLabel:UILabel!
    var modalTitleLabel:UILabel!
    var modalTextView:UITextView!
    var modalIconView:UIView!
    var rootViewController:UIViewController!
    var iconImage:UIImage!
    var iconImageView:UIImageView!
    var closeAction:(()->Void)!
    
    enum FontType {
        case Title, Text, Button
    }
    var titleFont = "HelveticaNeue-Light"
    var textFont = "HelveticaNeue"
    var buttonFont = "HelveticaNeue-Bold"
    
    var defaultColor = UIColorFromHex(0x34495e, alpha: 1)
    
    enum TextColor {
        case Dark, Light
    }
    var darkTextColor = UIColorFromHex(0x000000, alpha: 0.75)
    var lightTextColor = UIColorFromHex(0xffffff, alpha: 0.9)
    
    let baseHeight:CGFloat = 160.0
    var modalWidth:CGFloat = 290.0
    var modalHeight:CGFloat = 160.0
    let buttonHeight:CGFloat = 70.0
    let modalPadding:CGFloat = 20.0
    
    var viewWidth:CGFloat?
    var viewHeight:CGFloat?
    
    // Allow alerts to be closed/renamed in a chainable manner
    class JSSAlertViewResponder {
        let alertview: JSSAlertView
        
        init(alertview: JSSAlertView) {
            self.alertview = alertview
        }
        
        func addAction(action: ()->Void) {
            self.alertview.addAction(action)
        }
        
        func setTitleFont(fontStr: String) {
            self.alertview.setFont(fontStr, type: .Title)
        }
        
        func setTextFont(fontStr: String) {
            self.alertview.setFont(fontStr, type: .Text)
        }
        
        func setButtonFont(fontStr: String) {
            self.alertview.setFont(fontStr, type: .Button)
        }
        
        func close() {
            self.alertview.closeView()
        }
    }
    
    func setFont(fontStr: String, type: FontType) {
        switch type {
            case .Title:
                self.titleFont = fontStr
                self.modalTitleLabel.font = UIFont(name: self.titleFont, size: 24)
            case .Text:
                if self.modalTextView != nil {
                    self.textFont = fontStr
                    self.modalTextView.font = UIFont(name: self.textFont, size: 16)
                }
            case .Button:
                self.buttonFont = fontStr
                self.buttonLabel.font = UIFont(name: self.buttonFont, size: 20)
        }
        // relayout to account for size changes
        self.viewDidLayoutSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    required override init() {
        super.init()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let size = UIScreen.mainScreen().bounds.size
        self.viewWidth = size.width
        self.viewHeight = size.height
        
        var yPos:CGFloat = 0.0
        var contentWidth:CGFloat = self.modalWidth - (self.modalPadding*2)
        
        // position the icon image view, if there is one
        if self.iconImageView != nil {
            yPos += iconImageView.frame.height
            var centerX = (self.modalWidth-self.iconImageView.frame.width)/2
            self.iconImageView.frame.origin = CGPoint(x: centerX, y: self.modalPadding)
            yPos += modalPadding
        }
        
        // position the title
        let titleString = modalTitleLabel.text! as NSString
        let titleAttr = [NSFontAttributeName:modalTitleLabel.font]
        let titleSize = CGSize(width: contentWidth, height: 90)
        let titleRect = titleString.boundingRectWithSize(titleSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: titleAttr, context: nil)
        yPos += modalPadding
        self.modalTitleLabel.frame = CGRect(x: self.modalPadding, y: yPos, width: self.modalWidth - (self.modalPadding*2), height: ceil(titleRect.size.height))
        yPos += ceil(titleRect.size.height)
        
        
        // position text
        if self.modalTextView != nil {
            let textString = modalTextView.text! as NSString
            let textAttr = [NSFontAttributeName:modalTextView.font]
            let textSize = CGSize(width: contentWidth, height: 90)
            let textRect = textString.boundingRectWithSize(textSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttr, context: nil)
            self.modalTextView.frame = CGRect(x: self.modalPadding, y: yPos, width: self.modalWidth - (self.modalPadding*2), height: ceil(textRect.size.height)*2)
            yPos += ceil(textRect.size.height) + modalPadding/2
        }
        
        // position the button
        yPos += self.modalPadding
        self.modalButton.frame = CGRect(x: 0, y: yPos, width: self.modalWidth, height: self.buttonHeight)
        if self.buttonLabel != nil {
            self.buttonLabel.frame = CGRect(x: self.modalPadding, y: (self.buttonHeight/2) - 15, width: self.modalWidth - (self.modalPadding*2), height: 30)
        }
        yPos += self.buttonHeight
        
        // size the background view
        self.modalBackgroundView.frame = CGRect(x: 0, y: 0, width: self.modalWidth, height: yPos)
        
        // size the container that holds everything together
        self.containerView.frame = CGRect(x: (self.viewWidth!-self.modalWidth)/2, y: (self.viewHeight! - yPos)/2, width: self.modalWidth, height: yPos)
    }
    
    
    
    func info(viewController: UIViewController, title: String, text: String?=nil) -> JSSAlertViewResponder {
        return self.show(viewController, title: title, text: text, buttonText: nil, color: UIColorFromHex(0x3498db, alpha: 1))
    }
    
    func success(viewController: UIViewController, title: String, text: String?=nil) -> JSSAlertViewResponder {
        return self.show(viewController, title: title, text: text, buttonText: nil, color: UIColorFromHex(0x2ecc71, alpha: 1))
    }
    
    func warning(viewController: UIViewController, title: String, text: String?=nil) -> JSSAlertViewResponder {
        return self.show(viewController, title: title, text: text, buttonText: nil, color: UIColorFromHex(0xf1c40f, alpha: 1))
    }
    
    func danger(viewController: UIViewController, title: String, text: String?=nil) -> JSSAlertViewResponder {
        return self.show(viewController, title: title, text: text, buttonText: nil, color: UIColorFromHex(0xe74c3c, alpha: 1))
    }
    
    func show(viewController: UIViewController, title: String, text: String?=nil, buttonText: String?=nil, color: UIColor?=nil, iconImage: UIImage?=nil) -> JSSAlertViewResponder {
        
        self.rootViewController = viewController
        self.rootViewController.addChildViewController(self)
        self.rootViewController.view.addSubview(view)
        
        self.view.backgroundColor = UIColorFromHex(0x000000, alpha: 0.4)
        
        var baseColor:UIColor?
        if let customColor = color {
            baseColor = customColor
        } else {
            baseColor = self.defaultColor
        }
        var textColor = self.lightTextColor
        
        let sz = UIScreen.mainScreen().bounds.size
        self.viewWidth = sz.width
        self.viewHeight = sz.height
        
        // Container for the entire alert modal contents
        self.containerView = UIView()
        self.view.addSubview(self.containerView!)
        
        // Background view/main color
        self.modalBackgroundView = UIView()
        modalBackgroundView.backgroundColor = baseColor
        modalBackgroundView.layer.cornerRadius = 4
        modalBackgroundView.layer.masksToBounds = true
        self.containerView.addSubview(modalBackgroundView!)
        
        // Icon
        self.iconImage = iconImage
        if self.iconImage != nil {
            self.iconImageView = UIImageView(image: self.iconImage)
            self.containerView.addSubview(iconImageView)
        }
        
        // Title
        self.modalTitleLabel = UILabel()
        modalTitleLabel.textColor = textColor
        modalTitleLabel.numberOfLines = 0
        modalTitleLabel.textAlignment = .Center
        modalTitleLabel.font = UIFont(name: self.titleFont, size: 24)
        modalTitleLabel.text = title
        self.containerView.addSubview(modalTitleLabel)
        
        // View text
        if let text = text? {
            self.modalTextView = UITextView()
            modalTextView.editable = false
            modalTextView.textColor = textColor
            modalTextView.textAlignment = .Center
            modalTextView.font = UIFont(name: self.textFont, size: 16)
            modalTextView.backgroundColor = UIColor.clearColor()
            modalTextView.text = text
            self.containerView.addSubview(modalTextView)
        }
        
        // Button
        self.modalButton = UIButton()
        modalButton.backgroundColor = adjustBrightness(baseColor!, 0.8)
        modalButton.addTarget(self, action: "closeView", forControlEvents: .TouchUpInside)
        modalBackgroundView!.addSubview(modalButton)
        // Button text
        self.buttonLabel = UILabel()
        buttonLabel.textColor = textColor
        buttonLabel.numberOfLines = 1
        buttonLabel.textAlignment = .Center
        buttonLabel.font = UIFont(name: self.buttonFont, size: 20)
        if let text = buttonText {
            buttonLabel.text = text.uppercaseString
        } else {
            buttonLabel.text = "OK"
        }
        modalButton.addSubview(buttonLabel)
        
        // Animate it in
        self.view.alpha = 0
        UIView.animateWithDuration(0.2, animations: {
            self.view.alpha = 1
        })
        self.containerView.frame.origin.x = self.rootViewController.view.center.x
        self.containerView.frame.origin.y = self.rootViewController.view.center.y - 100
        UIView.animateWithDuration(0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: nil, animations: {
            self.containerView.center = self.rootViewController.view.center
            }, completion: { finished in
                
        })
        
        return JSSAlertViewResponder(alertview: self)
    }
    
    func addAction(action: ()->Void) {
        self.closeAction = action
    }
    
    func closeView() {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self.containerView.center.y = self.rootViewController.view.center.y + self.viewHeight!
            }, completion: { finished in
                UIView.animateWithDuration(0.1, animations: {
                    self.view.alpha = 0
                    }, completion: { finished in
                        if let action = self.closeAction? {
                            action()
                        }
                        self.removeView()
                })
                
        })
    }
    
    func removeView() {
        self.view.removeFromSuperview()
    }
    
}

// Utility methods

// For any hex code 0xXXXXXX and alpha value,
// return a matching UIColor
func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
}

// Adapted from obj-c solution at
// http://a2apps.com.au/lighten-or-darken-a-uicolor/
//
// For any UIColor and brightness value where darker <1
// and lighter (>1) return an altered UIColor.
func adjustBrightness(color:UIColor, amount:CGFloat) -> UIColor {
    var hue:CGFloat = 0
    var saturation:CGFloat = 0
    var brightness:CGFloat = 0
    var alpha:CGFloat = 0
    if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
        brightness += (amount-1.0)
        brightness = max(min(brightness, 1.0), 0.0)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    return color
}
