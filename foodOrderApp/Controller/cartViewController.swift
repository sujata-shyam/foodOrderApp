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
        //setButtonUI()
        
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
        setRestaurantDefaults()
        loadCheckOutJSONDataGET()
    }
    
//    func setButtonUI()
//    {
//        btnBrowse.layer.cornerRadius = 10
//        btnBrowse.layer.masksToBounds = true
//        btnBrowse.layer.borderWidth = 2
//        btnBrowse.layer.borderColor = #colorLiteral(red: 0.7058823529, green: 0.5215686275, blue: 0.168627451, alpha: 1)
//    }
    
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
        let url = URL(string: "https://tummypolice.iyangi.com/api/v1/checkout")
        
        if let url = url{
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                guard let data =  data else { print("URLSession not workig")
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

    @IBAction func btnBrowseTapped(_ sender: UIButton)
    {
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
            //retrieveCurrentLocation()
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
            //orderProcessVC.userLocation = userCoordinate
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

//extension cartViewController:CLLocationManagerDelegate
//{
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
//    {
//        retrieveCurrentLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
//    {
//        locationManager.stopUpdatingLocation()
//        locationManager.delegate = nil
//
//        if let location = locations.first
//        {
//            userCoordinate = location.coordinate
//
//            //Place order only after lat/longi. is received
//            placeOrderPOST("\(location.coordinate.latitude)", "\(location.coordinate.longitude)")
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
//    {
//        if let clErr = error as? CLError
//        {
//            switch clErr
//            {
//                case CLError.locationUnknown:
//                    print("Error Location Unknown")
//                case CLError.denied:
//                    self.displayAlertForSettings()
//                default:
//                    print("Other Core Location error")
//            }
//        }
//        else
//        {
//            print("other error:", error.localizedDescription)
//        }
//    }
//
//    func retrieveCurrentLocation()
//    {
//        let status = CLLocationManager.authorizationStatus()
//
//        if(status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled())
//        {
//            self.displayAlertForSettings()
//            return
//        }
//
//        if(status == .notDetermined)
//        {
//            locationManager.requestWhenInUseAuthorization()
//            return
//        }
//
//        locationManager.startUpdatingLocation()
//    }
//
//    func displayAlertForSettings()
//    {
//        let alertController = UIAlertController (title: "The app needs access to your location to function.", message: "Go to Settings?", preferredStyle: .alert)
//
//        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
//            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
//                return
//            }
//
//            if UIApplication.shared.canOpenURL(settingsUrl) {
//                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
//                    print("Settings opened: \(success)")
//                })
//            }
//        }
//        alertController.addAction(settingsAction)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//        alertController.addAction(cancelAction)
//
//        present(alertController, animated: true, completion: nil)
//    }
//}
