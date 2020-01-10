//
//  GlobalFunctions.swift
//  foodOrderApp
//
//  Created by Sujata on 04/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit

let defaults = UserDefaults.standard

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
