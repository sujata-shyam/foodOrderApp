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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let restaurantId = selectedRestaurant.id
        {
            loadMenuItemFromJSONData(restaurantId)
        }
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
//                    DispatchQueue.main.async
//                    {
//                        self.restaurantTableView.reloadData()
//                    }
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
