//
//  cartViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 09/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit

class cartViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadCheckOutJSONDataGET()
    }
    
    func loadCheckOutJSONDataGET()
    {
        let url = URL(string: "https://tummypolice.iyangi.com/api/v1/checkout")
        
        if let url = url{
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                guard let data =  data else { print("URLSession not workig")
                    return }
                do
                {
                    let checkOutDetails = try JSONDecoder().decode(Checkout.self, from: data)
                    print(checkOutDetails)
                }
                catch
                {
                    print("error:\(error)")
                }
            }
            task.resume()
        }
    }

    

}
