//
//  orderProcessViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 22/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit

class orderProcessViewController: UIViewController
{
    var deliveryPersonLocation : Location? //Passed thru. segue
    var orderID : String? //Passed thru. segue
    
    @IBOutlet weak var lblOrderNumber: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        //let splitOrderNumber = orderID?.prefix(6)
        lblOrderNumber.text = "ORDER #\((orderID?.prefix(6))!)"
    }
    

    

}
