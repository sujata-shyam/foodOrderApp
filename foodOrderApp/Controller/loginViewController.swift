//
//  loginViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 25/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit
import Foundation

class loginViewController: UIViewController
{
    //MARK :- LogIn IB Outlets
    
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var lblClientName: UILabel!
    
    @IBOutlet weak var btnLogout: UIButton!
    
    //MARK :- SignUp IB Outlets
    
    @IBOutlet weak var viewSignUp: UIView!
    @IBOutlet weak var txtRegName: UITextField!
    @IBOutlet weak var txtRegPhone: UITextField!
    @IBOutlet weak var txtRegEmail: UITextField!
    @IBOutlet weak var txtRegPassword: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func btnLoginTapped(_ sender: UIButton)
    {
        if(txtPhone.text!.isEmpty)
        {
            displayAlert(title: "", message: "Please enter the phone no.")
        }
        else
        {
            loadLoginData()
        }
    }
    
    func loadLoginData()
    {
        let searchURL = URL(string: "https://tummypolice.iyangi.com/api/v1/login")
        var searchURLRequest = URLRequest(url: searchURL!)
        
        searchURLRequest.httpMethod = "POST"
        searchURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do
        {
            let jsonBody = try JSONEncoder().encode(LoginRequest(
                phone: txtPhone.text
            ))
            searchURLRequest.httpBody = jsonBody
            
            print(jsonBody)
        }
        catch
        {
            print(error)
        }
        
        URLSession.shared.dataTask(with: searchURLRequest){ data, response,error in
            guard let data =  data else { return }
        
            print(data)
            do
            {
                if let response1 = response
                {
                    print(response1)
                }
                
                guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode)
                else {
                print(error as Any)
                return
                }
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                print(loginResponse)
                
                if let name = loginResponse.username
                {
                    DispatchQueue.main.async
                    {
                        self.lblClientName.text = "Hello \(name))"
                        self.lblClientName.isHidden = false
                        self.btnLogout.isHidden = false
                        self.viewLogin.isHidden = true
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                    self.displayAlert(title: "Failed Login Attempt", message: "User does not exist")
                    }
                }
            }
            catch
            {
                print(error)
            }
        }.resume()
    }
    
    func displayAlert(title: String, message: String)
    {
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler:nil ))
        present(alert, animated: true)
    }
    
    @IBAction func btnSignupTapped(_ sender: UIButton)
    {
        viewLogin.isHidden = true
        viewSignUp.isHidden = false
    }
    
    
    @IBAction func btnLogoutTapped(_ sender: UIButton){
    }
    
    @IBAction func btnRegisterTapped(_ sender: UIButton)
    {
        registerUser()
        checkInput()
    }
    
//    func checkInput()
//    {
//        if(txtRegName.text?.isEmpty)
//        {
//            
//        }
//        
//    }
    
    func registerUser()
    {
        let searchURL = URL(string: "https://tummypolice.iyangi.com/api/v1/register")
        
        var searchURLRequest = URLRequest(url: searchURL!)
        
        searchURLRequest.httpMethod = "POST"
        searchURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do
        {
            let jsonBody = try JSONEncoder().encode(SignUpRequest(
                username: txtRegName.text,
                password: txtRegPassword.text,
                email: txtRegEmail.text,
                phone: txtPhone.text
            ))
            searchURLRequest.httpBody = jsonBody
            
            print(jsonBody)
        }
        catch
        {
            print(error)
        }
        
        URLSession.shared.dataTask(with: searchURLRequest){data, response,error in
            guard let data =  data else { return }
            print(data)
            do
            {
//                if let response1 = response
//                {
//                    print(response1)
//                }
                
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode)
                    else {
                        print(error as Any)
                        return
                }
                
                let signUpDetailsResponse = try JSONDecoder().decode(SignUpResponse.self, from: data)
                print(signUpDetailsResponse)
            }
            catch
            {
                print(error)
            }
        }.resume()
    }
}
