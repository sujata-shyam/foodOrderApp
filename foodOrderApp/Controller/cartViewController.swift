//
//  cartViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 09/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit
import MapKit

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
    
    @IBOutlet weak var emptyCartView: UIView!
    @IBOutlet weak var btnBrowse: UIButton!
    
    
    var currencySymbol = ""
    var arrCartItemDetail = [CartItemDetail]()
    lazy var checkoutLocal = Checkout(restaurantId:nil, cartItems:nil, bill:nil)
    
    //Below 2 lines to be passes thru. segue
    var deliveryPersonLocation: Location?
    var orderID: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        checkoutTableView.delegate = self
        checkoutTableView.dataSource = self
        
        currencySymbol = getSymbolForCurrencyCode(code: "INR")!
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrderApproved), name: NSNotification.Name("gotOrderApproved"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDPLocation), name: NSNotification.Name("gotDPLocation"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTaskAccepted), name: NSNotification.Name("gotTaskAccepted"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        loadCheckOutJSONDataGET()
        setRestaurantDefaults()
    }
    
    @objc func handleOrderApproved()
    {
        self.btnPlaceOrder.isHidden = true
        self.lblTitle.text = "Your order is being processed."
    }
    
    @objc func handleDPLocation(notification: Notification)
    {
        let locationDetails = notification.object as! Location
        self.deliveryPersonLocation = locationDetails
    }
    
    @objc func handleTaskAccepted()
    {
        self.performSegue(withIdentifier: "goToOrderProcess", sender: self)
    }
    
    func setRestaurantDefaults()
    {
        txtViewRestaurantName.text = defaults.string(forKey: "restaurantName")
        txtViewRestaurantAddr.text = defaults.string(forKey: "restaurantCity")
    }
    
    func loadCheckOutJSONDataGET()
    {
        let url = URL(string: "\(urlMainString)/checkout")
        
        if let url = url{
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                guard let data =  data else { print("URLSession not working")
                    return }
                do
                {
                    let checkOutDetails = try JSONDecoder().decode(Checkout.self, from: data)

                    if ((checkOutDetails.restaurantId != "") || (checkOutDetails.restaurantId != nil))
                    {
                        self.checkoutLocal = checkOutDetails
                        
                        if(checkOutDetails.cartItems!.count > 0)
                        {
                            self.arrCartItemDetail = Array(checkOutDetails.cartItems!.values) as! [CartItemDetail]
                            
                            let arrItemZeroCount = self.arrCartItemDetail.filter{$0.quantity == 0}
                            if arrItemZeroCount.count == self.arrCartItemDetail.count
                            {
                                DispatchQueue.main.async
                                {
                                    self.emptyCartView.isHidden = false
                                }
                            }
                            else
                            {
                                if(defaults.string(forKey: "restaurantName") == nil)
                                {
                                    self.getRestaurantDetails(checkOutDetails.restaurantId!)
                                }
                                
                                if arrItemZeroCount.count > 0 && arrItemZeroCount.count < self.arrCartItemDetail.count
                                {
                                    self.arrCartItemDetail = arrItemZeroCount
                                }
                                
                                let itemTotal = self.calculateItemTotal()
                            
                                DispatchQueue.main.async
                                {
                                    self.emptyCartView.isHidden = true
                                    self.lblItemTotalAmt.text = self.currencySymbol + " " + String(itemTotal)
                                    self.lblDeliveryFeeAmt.text = self.currencySymbol + " " + String((checkOutDetails.bill?.deliveryfee)!)
                                    self.lblRestaurantChargesAmt.text = self.currencySymbol + " " + "50"
                                    
                                    self.lblFinalBillAmt.text = self.currencySymbol + " " + String(itemTotal + (checkOutDetails.bill?.deliveryfee)! + 50)
                                
                                    self.checkoutTableView.reloadData()
                                }
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

    func getRestaurantDetails(_ restaurantId: String)
    {
        let url = URL(string: "\(urlMainString)/restaurant/info?id=\(restaurantId)")
        
        if let url = url{
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                guard let data =  data else { print("URLSession not workig")
                    return }
                do
                {
                    let restDetail = try JSONDecoder().decode(Restaurant.self, from: data)
                    
                    if restDetail.name != nil || restDetail.name == ""
                    {
                        DispatchQueue.main.async
                        {
                            defaults.set(restDetail.name, forKey: "restaurantName")
                            defaults.set(restDetail.city, forKey: "restaurantCity")
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
    
    @IBAction func btnBrowseTapped(_ sender: UIButton)
    {
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    @IBAction func btnPlaceOrderTapped(_ sender: UIButton)
    {
        if(defaults.string(forKey: "userId") == nil)
        {
            displayAlert(vc: self, title: "", message: "Please sign in to checkout.")
            return
        }
        else
        {
            if let templocation = LocationManager.shared.currentLocation
            {
                placeOrderPOST("\(templocation.coordinate.latitude)", "\(templocation.coordinate.longitude)")
            }
            else
            {
                 placeOrderPOST("12.96195220947266", "77.64364876922691")//For GeekSkool
            }
        }
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
    
    func placeOrderPOST(_ latitudeDesc:String, _ longitudeDesc:String)
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
            latitude: latitudeDesc,
            longitude: longitudeDesc
        )
        
        let searchURL = URL(string: "\(urlMainString)/order")
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
                
                if (orderResponse.orderid != nil)
                {
                    self.orderID = orderResponse.orderid?.id
                
                    SocketIOManager.sharedInstance.emitActiveUser(loginResponseLocal.id!)
                    SocketIOManager.sharedInstance.emitActiveOrder((orderResponse.orderid?.id)!)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let orderProcessVC = segue.destination as? orderProcessViewController
        {
            orderProcessVC.deliveryPersonLocation = deliveryPersonLocation
            orderProcessVC.orderID = orderID
        }
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

