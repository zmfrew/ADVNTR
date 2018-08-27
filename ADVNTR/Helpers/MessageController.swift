//
//  MessageController.swift
//  ADVNTR
//
//  Created by Peter Gow on 28/8/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import SwiftEntryKit

class MessageController {
    
    static let shared = MessageController()
    
    // Alert shown when a user successfully signs up for ADVNTR. This is a simple alert that
    // presents from bottom of screen with no button.
    func createSuccessAlertWith(title: String, description: String) -> (EKNotificationMessageView, EKAttributes) {
        
        // Customise the alert's UI.
        var attributes = EKAttributes.bottomFloat
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.positionConstraints.maxSize = .init(width: .ratio(value: 0.7), height: .intrinsic)
        attributes.hapticFeedbackType = .success
        attributes.roundCorners = .all(radius: 8.0)
        attributes.screenBackground = .visualEffect(style: UIBlurEffectStyle.light)
        attributes.entryBackground = .color(color: UIColor.alertGreen)
        
        // Set the title and its style.
        let titleLabelStyle = EKProperty.LabelStyle.init(font: UIFont.alertTitle!, color: UIColor.lightWhite)
        let title = EKProperty.LabelContent(text: title, style: titleLabelStyle)
        
        let descriptionLabelStyle = EKProperty.LabelStyle.init(font: UIFont.alertDescription!, color: UIColor.darkWhite)
        let description = EKProperty.LabelContent(text: description, style: descriptionLabelStyle)
        
        // Set the image for the alert view.
        let image = EKProperty.ImageContent(image: UIImage(named: "alertSuccess")!, size: CGSize(width: 35, height: 35))
        
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let alertMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        let contentView = EKNotificationMessageView(with: alertMessage)
        
        return (contentView, attributes)
    }
    
    // Alerts shown for any errors during sign up/authentication. This view is a popup with a button.
    // The view will disappear automatically if the Ok button isn't pressed.
    func createAuthErrorAlertWith(title: String, description: String) -> (EKPopUpMessageView, EKAttributes) {
        
        var attributes = EKAttributes.bottomFloat
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.scroll = .disabled
        attributes.positionConstraints.maxSize = .init(width: .ratio(value: 0.7), height: .intrinsic)
        attributes.hapticFeedbackType = .error
        attributes.roundCorners = .all(radius: 8.0)
        attributes.screenBackground = .visualEffect(style: UIBlurEffectStyle.dark)
        attributes.entryBackground = .color(color: UIColor.alertRed)
        
        var titleLabelStyle = EKProperty.LabelStyle.init(font: UIFont.alertTitle!, color: UIColor.lightWhite)
        titleLabelStyle.alignment = .center
        let title = EKProperty.LabelContent(text: title, style: titleLabelStyle)
        
        var descriptionLabelStyle = EKProperty.LabelStyle.init(font: UIFont.alertDescription!, color: UIColor.darkWhite)
        descriptionLabelStyle.alignment = .center
        let description = EKProperty.LabelContent(text: description, style: descriptionLabelStyle)
        
        let image = EKProperty.ImageContent(image: UIImage(named: "alertError")!, size: CGSize(width: 35, height: 35))
        let themeImage = EKPopUpMessage.ThemeImage.init(image: image)
        
        let button = EKProperty.ButtonContent(label: .init(text: "Ok", style: .init(font: UIFont.alertTitle!, color: UIColor.black)), backgroundColor: UIColor.white, highlightedBackgroundColor: UIColor.white.withAlphaComponent(0.05))
        
        // Closure handles what occurs if the user taps the Ok button. In this case, the alert will be dismissed.
        let popUpMessage = EKPopUpMessage(themeImage: themeImage, title: title, description: description, button: button) {
            SwiftEntryKit.dismiss()
        }
        
        let contentView = EKPopUpMessageView(with: popUpMessage)
        
        return (contentView, attributes)
    }
    
    // MARK: Empty Sign Up Fields Alert Extension
    // Called when the user hasn't entered text in either or both of the sign up/in text fields
    
    func createEmptyFieldAlert() -> UIAlertController {
        let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alertController.addAction(okAction)
        return alertController
    }
    
}

