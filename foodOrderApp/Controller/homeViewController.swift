//
//  homeViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 19/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit
import CoreLocation



class homeViewController: UIViewController
{
    let locationManager = CLLocationManager()
    var arrRestaurants = [Restaurant]()
    
    var arrImages = [UIImage(named: "Baked"),
                     UIImage(named: "American"),
                     UIImage(named: "Pizza"),
                     UIImage(named: "FrenchFries"),
                     UIImage(named: "Burger"),
                     UIImage(named: "Indian")
                     ]
    
    @IBOutlet weak var restaurantTableView: UITableView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadJSONDataWithCoordinates()
        
        restaurantTableView.dataSource = self
        restaurantTableView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
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
                
                            let received = String(data: data, encoding: String.Encoding.utf8)
                            print("received: \(received)")
                
                do
                {
                    let dictPlaces = try JSONDecoder().decode(Place.self, from: data)
                    
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

    //For Kalyan Nagar
    //func loadJSONDataWithCoordinates(_ latitude:String = "13.0251913", _ longitude:String = "77.6509358")
    
    //For GeekSkool
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
                    self.arrRestaurants = try JSONDecoder().decode([Restaurant].self, from: data)
                    //let received = String(data: data, encoding: String.Encoding.utf8)
                    //print("received: \(received)")
                    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "goToRestaurantDetail", sender: tableView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let restaurantVC = segue.destination as? restaurantViewController
        {
            if let indexPath = restaurantTableView.indexPathForSelectedRow
            {
                restaurantVC.selectedRestaurant = arrRestaurants[indexPath.row]
            }
        }
    }
}

extension homeViewController : UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if(searchBar.text!.count > 0)
        {
            loadJSONDataWithSearchString(searchText: searchBar.text!.lowercased())
        }
        else
        {
            loadJSONDataWithCoordinates()
        }
        
        DispatchQueue.main.async
        {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        //print(searchText)
//        if(searchText.count > 0)
//        {
            //loadCategories()
//            DispatchQueue.main.async
//            {
//                searchBar.resignFirstResponder()
//            }
        //}
    }
}
