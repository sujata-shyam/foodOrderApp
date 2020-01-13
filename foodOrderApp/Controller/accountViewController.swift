//
//  loginViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 25/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit

class accountViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        if(defaults.bool(forKey: "isUserLoggedIn") == true)
        {
            performSegue(withIdentifier: "goToLoginPage", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
    
    @IBAction func btnLoginTapped(_ sender: UIButton)
    {
        
    }
}
