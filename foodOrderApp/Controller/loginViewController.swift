//
//  loginViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 25/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit
import Foundation

class loginViewController: UIViewController//, UITextFieldDelegate
{
    //MARK :- LogIn IB Outlets
    
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
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
        setTextDelegate()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        if(defaults.bool(forKey: "isUserLoggedIn") == true)
        {
            self.lblClientName.text = "Hello \((defaults.string(forKey: "userName")!))"
            self.lblClientName.isHidden = false
            self.btnLogout.isHidden = false
            self.viewLogin.isHidden = true
        }
        else
        {
            viewLogin.isHidden = false
            viewSignUp.isHidden = true
            btnLogout.isHidden = true
        }
    }
    
    func setTextDelegate()
    {
        txtRegName.delegate = self
        txtRegEmail.delegate = self
        txtRegPassword.delegate = self        
        txtPassword.delegate = self
    }
    
    @IBAction func btnLoginTapped(_ sender: UIButton)
    {
        if(txtPhone.text!.isEmpty)
        {
            displayAlert(vc: self, title: "", message: "Please enter the phone no.")
        }
        else
        {
            loadLoginData(txtPhone.text!)
        }
        txtPhone.resignFirstResponder()
    }
    
    @IBAction func unwindTologinVC(segue:UIStoryboardSegue)
    {}
    
    func loadLoginData(_ phoneNumber: String)
    {
        let searchURL = URL(string: "\(urlMainString)/login")
        var searchURLRequest = URLRequest(url: searchURL!)
        
        searchURLRequest.httpMethod = "POST"
        searchURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do
        {
            let jsonBody = try JSONEncoder().encode(LoginRequest(phone: phoneNumber))
            searchURLRequest.httpBody = jsonBody
        }
        catch
        {
            print(error)
        }
        
        URLSession.shared.dataTask(with: searchURLRequest){ data, response,error in
            guard let data =  data else { return }
            do
            {
                guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode)
                    else { print(error as Any);return}
                
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                if let name = loginResponse.username
                {
                    self.saveUserDetailsLocally(loginResponse)
                    
                    DispatchQueue.main.async
                    {
                        self.lblClientName.text = "Hello \(name)"
                        self.lblClientName.isHidden = false
                        self.btnLogout.isHidden = false
                        self.viewLogin.isHidden = true
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        displayAlert(vc: self, title: "Failed Login Attempt", message: "User does not exist")
                    }
                }
            }
            catch{ print(error) }
        }.resume()
    }
    
    @IBAction func btnSignupTapped(_ sender: UIButton)
    {
        viewLogin.isHidden = true
        viewSignUp.isHidden = false
    }
    
    @IBAction func btnLogoutTapped(_ sender: UIButton)
    {
        clearUserDefaults()
        clearView()
        
        viewLogin.isHidden = false
        viewSignUp.isHidden = true
        btnLogout.isHidden = true
        lblClientName.isHidden = true
        logOutUser()
    }
    
    @IBAction func btnRegisterTapped(_ sender: UIButton)
    {
        if(checkInput())
        {
            registerUser()
        }
        txtRegPhone.resignFirstResponder()
    }
    
    func logOutUser()
    {
        let url = URL(string: "\(urlMainString)/logout")

        if let url = url{
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                guard let _ =  data else { print("URLSession not workig")
                    return }
            }
            task.resume()
        }
    }
    
    func checkInput()->Bool
    {
        if(txtRegName.text!.isEmpty || txtRegEmail.text!.isEmpty || txtRegPhone.text!.isEmpty || txtRegPassword.text!.isEmpty)
        {
            displayAlert(vc: self, title: "", message: "Please enter the required details.")
            return false
        }
        
        if(txtRegPhone.text?.count != 10)
        {
            displayAlert(vc: self, title: "", message: "Please enter a valid 10-digit phone number.")
            return false
        }
        
        if(txtRegPassword.text!.count < 8)
        {
            displayAlert(vc: self, title: "", message: "Password has to be minimum of 8 characters.")
            return false
        }
        else
        {
            if(!txtRegPassword.text!.isAlphanumeric)
            {
                displayAlert(vc: self, title: "", message: "Password can have only alpha-numeric characters.")
                return false
            }
        }
        if(!isValidEmail(txtRegEmail.text!))
        {
            displayAlert(vc: self, title: "", message: "Please enter a valid email address.")
            return false
        }
        return true
    }
    
    func isValidEmail(_ email: String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func registerUser()
    {
        let searchURL = URL(string: "\(urlMainString)/register")
        var searchURLRequest = URLRequest(url: searchURL!)
        
        searchURLRequest.httpMethod = "POST"
        searchURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do
        {
            let jsonBody = try JSONEncoder().encode(SignUpRequest(
                username: txtRegName.text,
                password: txtRegPassword.text,
                email: txtRegEmail.text,
                phone: txtRegPhone.text
            ))
            searchURLRequest.httpBody = jsonBody
        }
        catch{ print(error) }
        
        URLSession.shared.dataTask(with: searchURLRequest){data, response,error in
            guard let data =  data else { return }
            do
            {                
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode)
                    else { print(error as Any); return }
                        
                let signUpDetailsResponse = try JSONDecoder().decode(SignUpResponse.self, from: data)
                
                if signUpDetailsResponse.username != nil
                {
                    DispatchQueue.main.async
                    {
                        displayAlert(vc: self, title: "", message: "Registration successful.")
                        self.viewSignUp.isHidden = true
                        self.loadLoginData(self.txtRegPhone.text!)
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        displayAlert(vc: self, title: "", message: "Sorry. Could not register. Try after sometime.")
                    }
                }
            }
            catch
            {
                print(error)
            }
        }.resume()
    }
    
    func clearView()
    {
        txtPhone.text = nil
        txtPassword.text = nil
        txtRegName.text = nil
        txtRegPhone.text =  nil
        txtRegEmail.text = nil
        txtRegPassword.text = nil
    }
    
    func clearUserDefaults()
    {
        if let bundleID = Bundle.main.bundleIdentifier
        {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    func saveUserDetailsLocally(_ loginResponse: LoginResponse)
    {
        defaults.set(loginResponse.msg, forKey: "userMessage")
        defaults.set(loginResponse.session, forKey: "userSession")
        defaults.set(loginResponse.id, forKey: "userId")
        defaults.set(loginResponse.username, forKey: "userName")
        defaults.set(loginResponse.phone, forKey: "userPhone")
        defaults.set(loginResponse.email, forKey: "userEmail")
        defaults.set(true, forKey: "isUserLoggedIn")
    }
}

extension String
{
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

extension loginViewController:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
