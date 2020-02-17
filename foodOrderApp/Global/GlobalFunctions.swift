//
//  GlobalFunctions.swift
//  foodOrderApp
//
//  Created by Sujata on 04/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit

let defaults = UserDefaults.standard
var activityIndicator = UIActivityIndicatorView()


func displayAlert(vc: UIViewController, title: String, message: String)
{
    let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler:nil ))
    vc.present(alert, animated: true)
}

/* BELOW function gets the different CURRENCY symbol */
func getSymbolForCurrencyCode(code: String) -> String?
{
    let locale = NSLocale(localeIdentifier: code)
    return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code)
}

func displayAlertForSettings()
{
    let alertController = UIAlertController (title: "The app needs access to your location to function.", message: "Go to Settings?", preferredStyle: .alert)
    
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    alertController.addAction(settingsAction)
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    alertController.addAction(cancelAction)
    
    if let vc = UIApplication.shared.keyWindow?.rootViewController
    {
        vc.present(alertController, animated: true, completion: nil)
    }
}

/* Below: function to start Activity Indicator */
func startActivityIndicator(vc: UIViewController)
{
    activityIndicator.center = vc.view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = UIActivityIndicatorView.Style.gray
    vc.view.addSubview(activityIndicator)
    activityIndicator.startAnimating()
    UIApplication.shared.beginIgnoringInteractionEvents()
}

/* Below: function to stop Activity Indicator */
func stopActivityIndicator(vc: UIViewController)
{
    activityIndicator.stopAnimating()
    UIApplication.shared.endIgnoringInteractionEvents()
}
