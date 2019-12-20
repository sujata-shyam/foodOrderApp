//
//  homeViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 19/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit

class homeViewController: UIViewController  //,  UITableViewDelegate, UITableViewDataSource
{
    var arrPredictions = [Predictions]()
    
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
        loadJSONData()
        restaurantTableView.dataSource = self 
        restaurantTableView.delegate = self
    }
    
    func loadJSONData()
    {
        let urlString = "https://tummypolice.iyangi.com/api/v1/place/autocomplete/json?input=domi"
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
                        self.arrPredictions = Array(dictPlaces.predictions!)
                        print(self.arrPredictions)
                    }
                    
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
        if(arrPredictions.count > 0)
        {
            return arrPredictions.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resTableViewCell", for: indexPath) as? restaurantTableViewCell
        
        if(arrPredictions.count > 0)
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
            cell?.lblTitle.text = arrPredictions[indexPath.row].name
        }
        return cell!
    }
}

extension homeViewController : UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        
    }
}
