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
    var dpCoordinate = CLLocationCoordinate2D()
    
    @IBOutlet weak var lblOrderNumber: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var lblReceived: UILabel!
    @IBOutlet weak var lblPrepared: UILabel!
    @IBOutlet weak var lblPicked: UILabel!
    
    var timer:Timer?
    
    let clientLocation = CLLocation(latitude:12.96195220947266, longitude:77.64364876922691) //For GeekSkool //For Simulator
    
    //let clientLocation = CLLocation(latitude:13.025232483644993, longitude:77.65087198473294) //For SPT //For Simulator
    
    
    let restaurantLocation = CLLocation(latitude: (Double((defaults.string(forKey: "restaurantLatitude"))!))! , longitude: (Double((defaults.string(forKey: "restaurantLongitude"))!))! )
    
    let reuseId = "deliveryReuseId"
    
    var routeCoordinates = [CLLocationCoordinate2D]()
    
    var avgAnimationTime: Double {
        // to show delivery in 180 second, replace 180 with amount of seconds you'd like to show
        return 120 / Double(routeCoordinates.count)
    }
    
    var coordinateIndex: Int! {
        didSet {
            guard coordinateIndex != routeCoordinates.count else {
                print("animated through all coordinates, stopping function")
                return
            }
            animateToNextCoordinate()
        }
    }
    
    
    var deliveryAnnotation: MKPointAnnotation {
        
        let annotation = MKPointAnnotation()
        annotation.title = "Delivery Person"
        dpCoordinate = CLLocationCoordinate2D(latitude: Double((deliveryPersonLocation?.latitude)!)!, longitude: Double((deliveryPersonLocation?.longitude)!)!)
        
        annotation.coordinate = dpCoordinate
        
//        annotation.coordinate = CLLocationCoordinate2D(latitude: Double((deliveryPersonLocation?.latitude)!)!, longitude: Double((deliveryPersonLocation?.longitude)!)!)
        
        return annotation
    }
    
    var userAnnotation: MKPointAnnotation  {
        let annotation = MKPointAnnotation()
        annotation.title = "User"
        annotation.coordinate = clientLocation.coordinate
        //DO NOT DELETE
        //annotation.coordinate = MKMapItem.forCurrentLocation().placemark.coordinate
        return annotation
    }

    var restaurantAnnotation: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = defaults.string(forKey: "restaurantName")!
        annotation.coordinate = restaurantLocation.coordinate
        return annotation
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView?.showsUserLocation = true
        mapView.delegate = self
        
        centerMapOnLocation()
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(highlightTaskAccepted), userInfo: nil, repeats: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDPLocation), name: NSNotification.Name("gotDPLocation"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrderPickedup), name: NSNotification.Name("gotOrderPickedup"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrderDelivered), name: NSNotification.Name("gotOrderDelivered"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        //To display only 6 char. from the orderID
        lblOrderNumber.text = "ORDER #\((orderID?.prefix(6))!)"
    }
    
    @objc func highlightTaskAccepted()
    {
        lblReceived.attributedText = NSAttributedString(string:lblReceived.text! , attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17)
            ])
        
        lblPrepared.attributedText = NSAttributedString(string:lblPrepared.text! , attributes: [
            .foregroundColor: UIColor(named: "Fire Brick")!,
            .font: UIFont.boldSystemFont(ofSize: 20)
            ])
        
        lblPicked.attributedText = NSAttributedString(string:lblPicked.text!, attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17)
            ])
    }
    
    @objc func handleDPLocation(notification: Notification)
    {
        let locationDetails = notification.object as! Location
        print("locationDetails:\(locationDetails)")
        
        let srcCoordinate = CLLocationCoordinate2D(latitude: Double((locationDetails.latitude)!)!, longitude: Double((locationDetails.longitude)!)!)
        
        getDirections(srcCoordinate)
    }
    
    @objc func handleOrderPickedup()
    {
        lblReceived.attributedText = NSAttributedString(string:lblReceived.text! , attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17)
            ])
        
        lblPrepared.attributedText = NSAttributedString(string:lblPrepared.text! , attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17)
            ])
        
        lblPicked.attributedText = NSAttributedString(string:lblPicked.text!, attributes: [
            .foregroundColor: UIColor(named: "Fire Brick")!,
            .font: UIFont.boldSystemFont(ofSize: 20)
            ])
    }
    
    @objc func handleOrderDelivered()
    {
        performSegue(withIdentifier: "goToCompletion", sender: self)
    }
    
    func centerMapOnLocation()
    {
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: reuseId)
    
        //let deliverycoordinate = CLLocationCoordinate2D(latitude: Double((deliveryPersonLocation?.latitude)!)!, longitude: Double((deliveryPersonLocation?.longitude)!)!)
        
//        let coordinateRegion = MKCoordinateRegion(center: deliverycoordinate,
//                                                  latitudinalMeters: 500, longitudinalMeters: 500)
        
        //let coordinateRegion = MKCoordinateRegion(center: clientLocation.coordinate,
//                                                  latitudinalMeters: 500, longitudinalMeters: 500)
//
        //mapView.setRegion(coordinateRegion, animated: true)
        
        mapView.addAnnotation(userAnnotation)
        mapView.addAnnotation(restaurantAnnotation)
        mapView.addAnnotation(deliveryAnnotation)
        
        //getDirections()
        getDirections(dpCoordinate)
    }
    
    func getDirections(_ sourceLocation: CLLocationCoordinate2D)
    {
        //let sourcePlacemark = MKPlacemark(coordinate: dpCoordinate)
        //let sourcePlacemark = MKPlacemark(coordinate: restaurantLocation.coordinate)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        //let destPlacemark = MKPlacemark(coordinate: clientLocation.coordinate)
        let destPlacemark = MKPlacemark(coordinate: restaurantLocation.coordinate)
        let destMapItem = MKMapItem(placemark: destPlacemark)
        
        //Substitute the below lines
        //let destMapItem = MKMapItem.forCurrentLocation()//gives users current location too/
        
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
            guard let primaryRoute = response.routes.first else {
                print("response has no routes")
                return }
            
            self.mapView.addOverlay(primaryRoute.polyline, level: .aboveRoads)
            
            self.mapView.setRegion(MKCoordinateRegion(primaryRoute.polyline.boundingMapRect), animated: true)
            
            // initiate recursive animation
            /* commented on 13th feb
            self.routeCoordinates = primaryRoute.polyline.coordinates
            self.coordinateIndex = 0
            */
            
            //below needed. DO NOT DELETE
            //primaryRoute.expectedTravelTime //use this to display the ETA
            /*
             self.steps = primaryRoute.steps
             for step in primaryRoute.steps
             {
             print(step.distance)
             print(step.instructions)
             print(step.polyline.coordinate)
             }
             */
        }
    }
    
//    func getDirections()
//    {
//        //let sourcePlacemark = MKPlacemark(coordinate: dpCoordinate)
//
//        let sourcePlacemark = MKPlacemark(coordinate: restaurantLocation.coordinate)
//        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//
//        let destPlacemark = MKPlacemark(coordinate: clientLocation.coordinate)
//        let destMapItem = MKMapItem(placemark: destPlacemark)
//
//        //Substitute the below lines
//        //let destMapItem = MKMapItem.forCurrentLocation()//gives users current location too/
//
//        let directionsRequest = MKDirections.Request()
//        directionsRequest.source = sourceMapItem
//        directionsRequest.destination = destMapItem
//        directionsRequest.transportType = .automobile
//
//        let directions = MKDirections(request: directionsRequest)
//        directions.calculate { (response, error) in
//            if let err = error
//            {
//                print(err.localizedDescription)
//                return
//            }
//
//            guard let response = response
//                else
//                {
//                    print("Empty Response!!")
//                    return
//                }
//            guard let primaryRoute = response.routes.first else {
//                print("response has no routes")
//                return }
//
//            self.mapView.addOverlay(primaryRoute.polyline, level: .aboveRoads)
//
//            self.mapView.setRegion(MKCoordinateRegion(primaryRoute.polyline.boundingMapRect), animated: true)
//
//            // initiate recursive animation
//            self.routeCoordinates = primaryRoute.polyline.coordinates
//            self.coordinateIndex = 0
//
//            //below needed. DO NOT DELETE
//            //primaryRoute.expectedTravelTime //use this to display the ETA
//            /*
//            self.steps = primaryRoute.steps
//            for step in primaryRoute.steps
//            {
//                print(step.distance)
//                print(step.instructions)
//                print(step.polyline.coordinate)
//            }
//            */
//        }
//    }
    
    func animateToNextCoordinate()
    {
        let coordinate = routeCoordinates[coordinateIndex]
        
        UIView.animate(withDuration: avgAnimationTime, animations: {
            self.deliveryAnnotation.coordinate = coordinate
        }, completion:  { _ in
            self.coordinateIndex += 1
        })
    }
}

extension orderProcessViewController:MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        switch annotation.title
        {
            case "User":
                annotationView.image = UIImage(named: "user")
            case "Delivery Person":
                annotationView.image = UIImage(named: "deliveryPerson")
            default: annotationView.image = UIImage(named: "restaurant")
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if overlay is MKPolyline
        {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            renderer.lineWidth  = 2
            renderer.lineJoin = .round
            return renderer
        }
        return MKOverlayRenderer()
    }
}

public extension MKMultiPoint
{
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)
        
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        
        return coords
    }
}
