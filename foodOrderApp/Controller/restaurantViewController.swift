//
//  restaurantViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 21/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit

class restaurantViewController: UIViewController
{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblOtherDetails: UILabel!
    
    @IBOutlet weak var menuItemTableView: UITableView!
        
    var arrMenuItems = [MenuItem]()
    var cartItems = [String:CartItemDetail?]()

    var selectedRestaurant = Restaurant(id: nil, name: nil, description: nil, city: nil, location: nil) //Value passed from prev. View Controller
    
    var restIDFromCart = ""
    
    var arrImages = [
        UIImage(imageLiteralResourceName: "pongal"),
        UIImage(imageLiteralResourceName: "masalaDosa"),
        UIImage(imageLiteralResourceName: "ravaDosa"),
        UIImage(imageLiteralResourceName: "curdVada"),
        UIImage(imageLiteralResourceName: "bajji"),
        UIImage(imageLiteralResourceName: "onionDosa"),
        UIImage(imageLiteralResourceName: "idli"),
        UIImage(imageLiteralResourceName: "dosa"),
        UIImage(imageLiteralResourceName: "vada"),
        UIImage(imageLiteralResourceName: "tea")
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadRestaurantDetails()
        
        menuItemTableView.delegate = self
        menuItemTableView.dataSource = self
        
        if let restaurantId = selectedRestaurant.id
        {
            loadCartItemFromJSONDataGET()
            loadMenuItemFromJSONData(restaurantId)
        }
    }
    
    func loadRestaurantDetails()
    {
        lblTitle.text = selectedRestaurant.name
        lblAddress.text = selectedRestaurant.city
    }
    
    func loadMenuItemFromJSONData(_ restaurantId:String)
    {
        let url = URL(string: "https://tummypolice.iyangi.com/api/v1/menu?restaurantid=\(restaurantId)")
        
        if let url = url{
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                guard let data =  data else { print("URLSession not workig")
                    return }
                do
                {
                    self.arrMenuItems = try JSONDecoder().decode([MenuItem].self, from: data)
                    DispatchQueue.main.async
                    {
                        self.menuItemTableView.reloadData()
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
    
    func loadCartItemFromJSONDataGET()
    {
        let url = URL(string: "https://tummypolice.iyangi.com/api/v1/cart")
        
        if let url = url{
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                guard let data =  data else { print("URLSession not workig")
                    return }
                do
                {
                    let initialCart = try JSONDecoder().decode(Cart.self, from: data)
                    print(initialCart)
                    
                    if ((initialCart.restaurantId != "") || (initialCart.restaurantId != nil))
                    {
                        self.restIDFromCart = initialCart.restaurantId!
                        
                        if(initialCart.cartItems.count > 0)
                        {
                            self.cartItems = initialCart.cartItems
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
    
    func loadCartItemFromJSONDataPOST(_ restaurandId: String, _ itemId: String, _ name: String, _ price: Double, _ quantity: Int)
    {
        
        loadCartItemFromJSONDataGET()
        cartItems[itemId] = CartItemDetail(name: name, price: price, quantity: quantity)
        
        let searchURL = URL(string: "https://tummypolice.iyangi.com/api/v1/cart")
        var searchURLRequest = URLRequest(url: searchURL!)
        
        searchURLRequest.httpMethod = "POST"
        searchURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do
        {
//            let jsonBody = try JSONEncoder().encode(Cart(
//            restaurantId: restaurandId,
//            cartItems : [itemId: CartItemDetail(name: name, price: price, quantity: quantity)]
//            ))

            let jsonBody = try JSONEncoder().encode(Cart(
                restaurantId: restaurandId,
                cartItems : self.cartItems
            ))
            
            searchURLRequest.httpBody = jsonBody
            
            print("jsonBody:\(jsonBody)")
        }
        catch
        {
            print(error)
        }
        
        URLSession.shared.dataTask(with: searchURLRequest){data, response,error in
            guard let data =  data else { return }
            
//            let received = String(data: data, encoding: String.Encoding.utf8)
//            print("received: \(received)")
            
            do
            {
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode)
                    else
                    {
                        print(error as Any)
                        return
                    }

                let cartResponse = try JSONDecoder().decode(Cart.self, from: data)
                print(cartResponse)
                
//                DispatchQueue.main.async {
//                    self.menuItemTableView.reloadData()
//                }
                
            }
            catch
            {
                print(error)
            }
        }.resume()
    }
    
}

extension restaurantViewController:UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrMenuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItemTableViewCell", for: indexPath) as? itemTableViewCell
        
        if(arrMenuItems.count > 0)
        {
            var imageIndex = 0
            
            if(indexPath.row < arrImages.count)
            {
                imageIndex = indexPath.row
            }
            else
            {
                imageIndex = (indexPath.row % arrImages.count)
            }
            
            cell?.imgFoodItem.image = arrImages[imageIndex]
            cell?.lblItemTitle.text = arrMenuItems[indexPath.row].name
            cell?.txtViewIngredients.text = arrMenuItems[indexPath.row].ingredients
            cell?.lblCost.text = String(arrMenuItems[indexPath.row].price! as Double)
            
            for(key, value) in cartItems
            {
                if(key == arrMenuItems[indexPath.row].id)
                {
                    cell?.lblAdd.text = String(Int((value?.quantity)!))
                }
            }
        
            cell?.btnAddAction = { [unowned self] in
                var tempQuantity = 0
                if let quantity = Int((cell?.lblAdd.text)!)
                {
                    cell?.lblAdd.text = String(quantity + 1)
                    tempQuantity = quantity + 1
                }
                else
                {
                    cell?.lblAdd.text = "1"
                    tempQuantity = 1
                }
                self.loadCartItemFromJSONDataPOST(self.selectedRestaurant.id!, self.arrMenuItems[indexPath.row].id!, self.arrMenuItems[indexPath.row].name!, self.arrMenuItems[indexPath.row].price!, tempQuantity)
            }
            
            cell?.btnSubtractAction = { [unowned self] in
                var tempQuantity = 0
                if let quantity = Int((cell?.lblAdd.text)!)
                {
                    if(quantity > 0)
                    {
                        cell?.lblAdd.text = String(quantity - 1)
                        tempQuantity = quantity - 1
                    }
                    else if(quantity == 0)
                    {
                        cell?.lblAdd.text = "Add"
                        tempQuantity = 0
                        cell?.btnMinus.isHidden = true
                    }
                }
            self.loadCartItemFromJSONDataPOST(self.selectedRestaurant.id!, self.arrMenuItems[indexPath.row].id!, self.arrMenuItems[indexPath.row].name!, self.arrMenuItems[indexPath.row].price!, tempQuantity)
            }
            
        }
        return cell!
    }
    
}
