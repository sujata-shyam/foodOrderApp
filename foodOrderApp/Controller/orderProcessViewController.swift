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
    var userLocation : CLLocationCoordinate2D? //Passed thru. segue                       
    var deliveryPersonLocation : Location? //Passed thru. segue
    var orderID : String? //Passed thru. segue
    
    @IBOutlet weak var lblOrderNumber: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 500
    var steps = [MKRoute.Step]()
   
    //uncomment for testing on Actual devices
    //let clientlocation = CLLocation(latitude: (Double((userLocation?.latitude)!))! , longitude: (Double((userLocation?.longitude)!))! )
    
     let clientLocation = CLLocation(latitude:12.96195220947266, longitude:77.64364876922691)
    
    //Uncomment after fixing DP App and for testing on Actual devices
    //  let dplocation = CLLocation(latitude: (Double((deliveryPersonLocation?.latitude)!))! , longitude: (Double((deliveryPersonLocation?.longitude)!))! )
    
    
    // Temp. Fix. We are taking the restaurant location as DP's location
    // for now.
    let dpLocation = CLLocation(latitude: (Double((defaults.string(forKey: "restaurantLatitude"))!))! , longitude: (Double((defaults.string(forKey: "restaurantLongitude"))!))! )
    
    let restaurantLocation = CLLocation(latitude: (Double((defaults.string(forKey: "restaurantLatitude"))!))! , longitude: (Double((defaults.string(forKey: "restaurantLongitude"))!))! )
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView?.showsUserLocation = true
        mapView.delegate = self
        centerMapOnLocation()
        print("restaurantLocation:\(restaurantLocation)")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        //To display only 6 char. from the orderID
        lblOrderNumber.text = "ORDER #\((orderID?.prefix(6))!)"
    }
    
    func centerMapOnLocation()
    {
        let coordinateRegion = MKCoordinateRegion(center: clientLocation.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)

        showDetailsOnMap(clientLocation, "Your Location")
        showDetailsOnMap(dpLocation, "Delivery Person")
        showDetailsOnMap(restaurantLocation, defaults.string(forKey: "restaurantName")! )
        getDirections()
    }
    
    func showDetailsOnMap(_ location: CLLocation, _ title: String)
    {
        let annotations = MKPointAnnotation()
        annotations.title = title
        annotations.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        mapView.addAnnotation(annotations)
    }
    
    func getDirections()
    {
        let clientlocation = CLLocation(latitude:12.96195220947266, longitude:77.64364876922691)
        
        //Substitute the below lines 
        //let sourceMapItem = MKMapItem.forCurrentLocation()//gives users current location too/
        let sourcePlacemark = MKPlacemark(coordinate: clientlocation.coordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let destPlacemark = MKPlacemark(coordinate: restaurantLocation.coordinate)
        let destMapItem = MKMapItem(placemark: destPlacemark)
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destMapItem
        directionsRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, error) in
            if let err = error
            {
                print(err.localizedDescription)
                return
            }
            
            guard let response = response
                else
                {
                    print("Empty Response!!")
                    return
                }
            guard let primaryRoute = response.routes.first else { return }
            print("primaryRoute:\(primaryRoute)")
            //primaryRoute.expectedTravelTime //use this to display the ETA
            
            self.mapView.addOverlay(primaryRoute.polyline)
            self.steps = primaryRoute.steps
            
            
            for step in primaryRoute.steps
            {
                print(step.distance)
                print(step.instructions)
                print(step.polyline.coordinate)
            }
        }
    }
}

extension orderProcessViewController:MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if overlay is MKPolyline
        {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
            renderer.lineWidth  = 2
            return renderer
        }
        return MKOverlayRenderer()
    }

}


