//
//  homeViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 19/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit

class homeViewController: UIViewController
{
    var arrRestaurants = [restaurant]()
    
    var arrImages = [UIImage(imageLiteralResourceName: "Baked"),
                     UIImage(imageLiteralResourceName: "American"),
                     UIImage(imageLiteralResourceName: "Pizza"),
                     UIImage(imageLiteralResourceName: "FrenchFries"),
                     UIImage(imageLiteralResourceName: "Burger"),
                     UIImage(imageLiteralResourceName: "Indian")
                     ]
    
    @IBOutlet weak var restaurantTableView: UITableView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadJSONDataWithCoordinates()
        
        restaurantTableView.dataSource = self
        restaurantTableView.delegate = self
    }
    
    func loadJSONDataWithSearchString(searchText:String)
    {
        var arrPredictions = [Predictions]()
        var urlString = "https://tummypolice.iyangi.com/api/v1/place/autocomplete/json?input="
        urlString.append(searchText)
        
        let url = URL(string: urlString)
        
        if let url = url{
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                guard let data =  data else { print("URLSession not workig")
                    return }
                do
                {
                    let dictPlaces = try JSONDecoder().decode(place.self, from: data)
                    
                    if(dictPlaces.predictions!.count > 0)
                    {
                        arrPredictions = Array(dictPlaces.predictions!)
                        
                        let latitude = arrPredictions[0].lat
                        let longitude = arrPredictions[0].lon
                        
                        self.loadJSONDataWithCoordinates(latitude!, longitude!)
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

    func loadJSONDataWithCoordinates(_ latitude:String = "12.9615402", _ longitude:String = "77.6441973")
    {
        let urlString = "https://tummypolice.iyangi.com/api/v1/restaurants?latitude=\(latitude)&longitude=\(longitude)"
        
        let url = URL(string: urlString)
            
        if let url = url{
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                guard let data =  data else { print("URLSession not workig")
                    return }
                do
                {
                    self.arrRestaurants = try JSONDecoder().decode([restaurant].self, from: data)
                    DispatchQueue.main.async
                    {
                            self.restaurantTableView.reloadData()
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

extension homeViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(arrRestaurants.count > 0)
        {
            return arrRestaurants.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resTableViewCell", for: indexPath) as? restaurantTableViewCell
        
        if(arrRestaurants.count > 0)
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
            
            cell?.imgFoodPic.image = arrImages[imageIndex]
            cell?.lblTitle.text = arrRestaurants[indexPath.row].name
        }
        return cell!
    }
}

extension homeViewController : UISearchBarDelegate
{
//    func createRequest(searchText:String)
//    {
//
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        print("CLICKED")
//        let result = createRequest(searchText:searchBar.text!)
//        loadCategories(with: result.0, predicate: result.1)
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
//        print(searchText)
//        if(searchText.count > 0)
//        {
//            loadCategories()
//            DispatchQueue.main.async
//            {
//                    searchBar.resignFirstResponder()
//            }
//        }
    }
}
