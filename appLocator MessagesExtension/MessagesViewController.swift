//
//  MessagesViewController.swift
//  appLocator MessagesExtension
//
//  Created by Alwin Mathew on 8/21/17.
//  Copyright © 2017 Alwin Mathew. All rights reserved.
//

import UIKit
import Messages
import CoreLocation

var messageLocationAddress : String = ""
var currentLongitude: Double = 0.0
var currentLatitude: Double = 0.0

extension MessagesViewController : ExpandedViewControllerDelegate, CompactViewContollerDelegate
{
    func composeMessage()
    {
        let conversation = activeConversation
        conversation?.insertText(messageLocationAddress)
        dismiss()
    }
}

class CompactViewController: UIViewController
{
    var delegate : CompactViewContollerDelegate?
    
    @IBAction func selectAppleMapsCompact(_ sender: UIButton) {
        
        let appleLongitude : String = String(format:"%f", currentLongitude)
        let appleLatitude : String = String(format:"%f", currentLatitude)
        messageLocationAddress = "http://maps.apple.com/?ll=" + appleLatitude + "," + appleLongitude + "&q=Location"
        print(messageLocationAddress)
        delegate?.composeMessage()
    }
    
    @IBAction func selectWazeMapsCompact(_ sender: UIButton)
    {
        let wazeLongitude : String = String(format:"%f", currentLongitude)
        let wazeLatitude : String = String(format:"%f", currentLatitude)
        messageLocationAddress = "https://waze.com/ul?ll=" + wazeLatitude + "," + wazeLongitude
        print(messageLocationAddress)
        delegate?.composeMessage()
    }
    
    @IBAction func selectGoogleMapsCompact(_ sender: UIButton) {
        let googleLongitude : String = String(format:"%f", currentLongitude)
        let googleLatitude : String = String(format:"%f", currentLatitude)
        messageLocationAddress = "http://maps.google.com/maps?q=" + googleLatitude + "," + googleLongitude
        print(messageLocationAddress)
        delegate?.composeMessage()
    }
    
}

class ExpandedViewController: UIViewController
{
    var delegate : ExpandedViewControllerDelegate?
    
    @IBAction func selectAppleMapsExpanded(_ sender: Any)
    {
        let appleLongitude : String = String(format:"%f", currentLongitude)
        let appleLatitude : String = String(format:"%f", currentLatitude)
        messageLocationAddress = "http://maps.apple.com/?ll=5" + appleLatitude + "," + appleLongitude
        delegate?.composeMessage()
    }
    
    @IBAction func selectWazeMapsExpanded(_ sender: Any)
    {
        let wazeLongitude : String = String(format:"%f", currentLongitude)
        let wazeLatitude : String = String(format:"%f", currentLatitude)
        messageLocationAddress = "https://waze.com/ul?ll=" + wazeLatitude + "&" + wazeLongitude
        delegate?.composeMessage()
    }
    
    @IBAction func selectGoogleMapsExpanded(_ sender: Any)
    {
        let googleLongitude : String = String(format:"%f", currentLongitude)
        let googleLatitude : String = String(format:"%f", currentLatitude)
        messageLocationAddress = "http://maps.google.com/maps?q=" + googleLatitude + "," + googleLongitude
        delegate?.composeMessage()
    }
    
}

protocol ExpandedViewControllerDelegate : class
{
    func composeMessage()
}
protocol CompactViewContollerDelegate : class
{
    func composeMessage()
}

class  MessagesViewController: MSMessagesAppViewController, CLLocationManagerDelegate {
    
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        determineMyCurrentLocation()
        
    }
    
    func determineMyCurrentLocation()
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation()
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation:CLLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        
        currentLatitude = userLocation.coordinate.latitude
        currentLongitude = userLocation.coordinate.longitude
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        presentVC(for: conversation, with: presentationStyle)
        
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        guard let conversation = activeConversation else {
            fatalError("Expected the active conversation")
        }
        
        presentVC(for: conversation, with: presentationStyle)    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    private func presentVC(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        let controller: UIViewController
        
        if presentationStyle == .compact {
            controller = instantiateCompactVC()
        } else {
            controller = instantiateExpandedVC()
        }
        
        addChildViewController(controller)
        
        // ...constraints and view setup...
        
        view.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    private func instantiateCompactVC() -> UIViewController {
        guard let compactVC = storyboard?.instantiateViewController(withIdentifier: "CompactVC") as? CompactViewController else {
            fatalError("Can't instantiate CompactViewController")
        }
        compactVC.delegate = self
        return compactVC
    }
    
    private func instantiateExpandedVC() -> UIViewController {
        guard let expandedVC = storyboard?.instantiateViewController(withIdentifier: "ExpandedVC") as? ExpandedViewController else {
            fatalError("Can't instantiate ExpandedViewController")
        }
        expandedVC.delegate = self
        
        return expandedVC
    }
    
}



