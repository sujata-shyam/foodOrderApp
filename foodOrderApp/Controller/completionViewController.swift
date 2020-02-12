//
//  completionViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 07/02/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit

class completionViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func btnLogoutTapped(_ sender: UIButton)
    {
        clearUserDefaults()
        performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    func clearUserDefaults()
    {
        /*
         defaults.set(false, forKey: "isUserLoggedIn")
         defaults.set(nil, forKey: "userMessage")
         defaults.set(nil, forKey: "userSession")
         defaults.set(nil, forKey: "userId")
         defaults.set(nil, forKey: "userPhone")
         */
        
        if let bundleID = Bundle.main.bundleIdentifier
        {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
