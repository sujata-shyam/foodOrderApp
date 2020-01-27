//
//  orderProcessViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 22/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit
import MapKit

class orderProcessViewController: UIViewController
{
    var userLocation : Location? //Passed thru. segue
    //var deliveryPersonLocation : Location? //Passed thru. segue
    var orderID : String? //Passed thru. segue
    
    @IBOutlet weak var lblOrderNumber: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 2000
    //var clientlocation = CLLocation()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        centerMapOnLocation()
//        showDetailsOnMap()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        lblOrderNumber.text = "ORDER #\((orderID?.prefix(6))!)"
        //print("deliveryPersonLocation:\(deliveryPersonLocation)")
    }
    
    
    func centerMapOnLocation()
    {
        //let clientlocation = CLLocation(latitude: (Double((userLocation?.latitude)!))! , longitude: (Double((userLocation?.longitude)!))! )
        
        let clientlocation = CLLocation(latitude:12.96195220947266, longitude:77.64364876922691)
        
        
        //let dplocation = CLLocation(latitude: (Double((deliveryPersonLocation?.latitude)!))! , longitude: (Double((deliveryPersonLocation?.longitude)!))! )
        
//        defaults.string(forKey: "restaurantLatitude")
//        defaults.string(forKey: "restaurantLongitude")
        
        let restaurantlocation = CLLocation(latitude: (Double((defaults.string(forKey: "restaurantLatitude"))!))! , longitude: (Double((defaults.string(forKey: "restaurantLongitude"))!))! )
        
        print("restaurantlocation:\(restaurantlocation)")
        
        let coordinateRegion = MKCoordinateRegion(center: clientlocation.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        showDetailsOnMap(clientlocation, "Your Location")
        //showDetailsOnMap(dplocation, "Delivery Person")
        showDetailsOnMap(restaurantlocation, defaults.string(forKey: "restaurantName")! )
        
        
//        let annotations = MKPointAnnotation()
//        annotations.title = title
//        annotations.coordinate = CLLocationCoordinate2D(latitude: clientlocation.coordinate.latitude, longitude: clientlocation.coordinate.longitude)
//        mapView.addAnnotation(annotations)
//
//        let annotations1 = MKPointAnnotation()
//        annotations1.title = title
//        annotations1.coordinate = CLLocationCoordinate2D(latitude: restaurantlocation.coordinate.latitude, longitude: restaurantlocation.coordinate.longitude)
//        mapView.addAnnotation(annotations1)
    }
    
    func showDetailsOnMap(_ location: CLLocation, _ title: String)
    {
        let annotations = MKPointAnnotation()
        annotations.title = title
        annotations.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        mapView.addAnnotation(annotations)
    }
    
//    func getDirections(_ loc1: CLLocationCoordinate2D, _ loc2: CLLocationCoordinate2D)
//    {
//        let source = MKMapItem(placemark: MKPlacemark(coordinate: loc1))
////        source.name = "Your Location"
//        let destination = MKMapItem(placemark: MKPlacemark(coordinate: loc2))
////        destination.name = "Destination"
//        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
//    }

}
