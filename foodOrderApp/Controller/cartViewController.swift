//
//  cartViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 09/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit

class cartViewController: UIViewController {

    @IBOutlet weak var imgViewRestaurant: UIImageView!
    @IBOutlet weak var txtViewRestaurantName: UITextView!
    @IBOutlet weak var txtViewRestaurantAddr: UITextView!
    
    @IBOutlet weak var checkoutTableView: UITableView!
    
    @IBOutlet weak var lblItemTotalAmt: UILabel!
    @IBOutlet weak var lblRestaurantChargesAmt: UILabel!
    @IBOutlet weak var lblDeliveryFeeAmt: UILabel!
    @IBOutlet weak var lblFinalBillAmt: UILabel!
    
    var currencySymbol = ""
    var arrCartItemDetail = [CartItemDetail]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        checkoutTableView.delegate = self
        checkoutTableView.dataSource = self
        currencySymbol = getSymbolForCurrencyCode(code: "INR")!
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        setRestaurantDefaults()
        loadCheckOutJSONDataGET()
    }
    func setRestaurantDefaults()
    {
        //let restaurantId = defaults.string(forKey: "restaurantId")
        let restaurantName = defaults.string(forKey: "restaurantName")
        let restaurantCity = defaults.string(forKey: "restaurantCity")

        txtViewRestaurantName.text = restaurantName
        txtViewRestaurantAddr.text = restaurantCity
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
                    if ((checkOutDetails.restaurantId != "") || (checkOutDetails.restaurantId != nil))
                    {
                        if(checkOutDetails.cartItems.count > 0)
                        {
                            self.arrCartItemDetail = Array(checkOutDetails.cartItems.values) as! [CartItemDetail]
                            
                            let itemTotal = self.calculateItemTotal()
                            
                            DispatchQueue.main.async
                            {
                                self.lblItemTotalAmt.text = self.currencySymbol + " " + String(itemTotal)
                                self.lblDeliveryFeeAmt.text = self.currencySymbol + " " + String((checkOutDetails.bill?.deliveryfee)!)
                                self.lblRestaurantChargesAmt.text = self.currencySymbol + " " + "50"
                                
                                self.lblFinalBillAmt.text = self.currencySymbol + " " + String(itemTotal + (checkOutDetails.bill?.deliveryfee)! + 50)
                            
                                self.checkoutTableView.reloadData()
                            }
                        }
                    }
                }
                catch
                {
                    print("error:\(error)")
                }
            }
            task.resume()
        }
    }

    @IBAction func btnPlaceOrderTapped(_ sender: UIButton)
    {
        
    }
    
    func calculateItemTotal()->Double
    {
        var itemTotal = 0.0
        for item in arrCartItemDetail
        {
            itemTotal = itemTotal + (item.price! * Double(item.quantity!))
        }
        return itemTotal
    }
    
}

extension cartViewController:UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrCartItemDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkoutItemsTableViewCell", for: indexPath) as? checkoutTableViewCell
        
        cell?.lblName.text = arrCartItemDetail[indexPath.row].name
        cell?.lblCost.text = currencySymbol + " " +  String(Int(arrCartItemDetail[indexPath.row].price!))
        cell?.lblQuantity.text = String(Int(arrCartItemDetail[indexPath.row].quantity!))

        return cell!
    }
    
}
