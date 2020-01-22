//
//  cartViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 09/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit
import SocketIO

class cartViewController: UIViewController
{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgViewRestaurant: UIImageView!
    @IBOutlet weak var txtViewRestaurantName: UITextView!
    @IBOutlet weak var txtViewRestaurantAddr: UITextView!
    
    @IBOutlet weak var checkoutTableView: UITableView!
    
    @IBOutlet weak var lblItemTotalAmt: UILabel!
    @IBOutlet weak var lblRestaurantChargesAmt: UILabel!
    @IBOutlet weak var lblDeliveryFeeAmt: UILabel!
    @IBOutlet weak var lblFinalBillAmt: UILabel!
    
    @IBOutlet weak var btnPlaceOrder: UIButton!
    
    var currencySymbol = ""
    var arrCartItemDetail = [CartItemDetail]()
    lazy var checkoutLocal = Checkout(restaurantId:nil, cartItems:nil, bill:nil)
    
    let manager = SocketManager(socketURL: URL(string: "https://tummypolice.iyangi.com")!, config: [.log(true), .compress])
    
    var socket:SocketIOClient!

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
        txtViewRestaurantName.text = defaults.string(forKey: "restaurantName")
        txtViewRestaurantAddr.text = defaults.string(forKey: "restaurantCity")
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
                    //print(checkOutDetails)
                    if ((checkOutDetails.restaurantId != "") || (checkOutDetails.restaurantId != nil))
                    {
                        self.checkoutLocal = checkOutDetails
                        
                        if(checkOutDetails.cartItems!.count > 0)
                        {
                            self.arrCartItemDetail = Array(checkOutDetails.cartItems!.values) as! [CartItemDetail]
                            
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
        placeOrderPOST()
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
    
    func placeOrderPOST()
    {
        let loginResponseLocal = LoginResponse(
            msg: defaults.string(forKey: "userMessage"),
            session: defaults.string(forKey: "userSession"),
            id: defaults.string(forKey: "userId"),
            username: defaults.string(forKey: "userName"),
            phone: defaults.string(forKey: "userPhone"),
            email: defaults.string(forKey: "userEmail")
        )
        
        let locationLocal = Location(
            latitude: defaults.string(forKey: "restaurantLatitude"),
            longitude: defaults.string(forKey: "restaurantLongitude")
        )
        
        let searchURL = URL(string: "https://tummypolice.iyangi.com/api/v1/order")
        var searchURLRequest = URLRequest(url: searchURL!)
        
        searchURLRequest.httpMethod = "POST"
        searchURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do
        {
            let jsonBody = try JSONEncoder().encode(OrderDetail(
                userDetails: loginResponseLocal,
                order: checkoutLocal,
                location: locationLocal
            ))
            searchURLRequest.httpBody = jsonBody
            //print("jsonBody:\(jsonBody)")
        }
        catch
        {
            print(error)
        }
        
        URLSession.shared.dataTask(with: searchURLRequest){data, response,error in
            guard let data =  data else { return }
            
            do
            {
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode)
                    else
                {
                    print(error as Any)
                    return
                }
            
                let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: data)
                //print(orderResponse)
                
                if (orderResponse.orderid != nil)
                {
                    self.socket = self.manager.defaultSocket
                    self.setSocketEvents(loginResponseLocal.id!, (orderResponse.orderid?.id)!)
                    //self.closeSocketConnection()
                    
//                    DispatchQueue.main.async
//                    {
//                        displayAlert(vc: self, title: "", message: "Order placed.")
//                        self.btnPlaceOrder.isHidden = true
//                        self.lblTitle.text = "Your order is being processed."
//                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        displayAlert(vc: self, title: "", message: "Something went wrong. Please try after a while.")
                    }
                }
            }
            catch
            {
                print(error)
            }
        }.resume()
    }
    
    //MARK:- Socket Functions
    
    private func setSocketEvents(_ userId:String, _ orderId: String)
    {
        self.socket.on(clientEvent: .connect) { (data, ack) in
            print(data)
            print("Socket connected")
            self.socket.emit("active user", userId)
            self.socket.emit("active order", orderId)
            
            self.socket.on("order approved") { data, ack in
                
                print(data)//returns orderid
                
              
                
                DispatchQueue.main.async
                {
                    displayAlert(vc: self, title: "", message: "Order placed.")
                    self.btnPlaceOrder.isHidden = true
                    self.lblTitle.text = "Your order is being processed."
                }
            }
            
            self.socket.on("order location"){ data, ack in
                print(data)
            }
            
            self.socket.on("task accepted") { data, ack in
                print(data)//returns DP's ph. no.//not working
            }
        }

        self.socket.connect()
    }
    
    private func closeSocketConnection() {
        self.socket.disconnect()
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
