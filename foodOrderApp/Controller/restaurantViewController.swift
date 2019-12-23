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
    
    var arrMenuItems = [menuItem]()
    var selectedRestaurant = restaurant(id: nil, name: nil, description: nil, city: nil, location: nil) //Value passed from prev. View Controller
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
        
        if let restaurantId = selectedRestaurant.id
        {
            loadMenuItemFromJSONData(restaurantId)
        }
        
        menuItemTableView.delegate = self
        menuItemTableView.dataSource = self
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
                    self.arrMenuItems = try JSONDecoder().decode([menuItem].self, from: data)
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
        }
        
        return cell!
    }
    
    
}
