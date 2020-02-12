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
    
    @IBOutlet weak var lblReceived: UILabel!
    @IBOutlet weak var lblPrepared: UILabel!
    @IBOutlet weak var lblPicked: UILabel!
    
    var timer:Timer?
    
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
    
    //----------//
    
    let reuseId = "deliveryReuseId"
    
    var routeCoordinates = [CLLocationCoordinate2D]()
    
    var avgAnimationTime: Double {
        // to show delivery in 180 second, replace 180 with amount of seconds you'd like to show
        return 180 / Double(routeCoordinates.count)
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
    
    var deliveryAnnotation: MKPointAnnotation = {
        let annotation = MKPointAnnotation()
        annotation.title = "Delivery Person"
        return annotation
    }()

    var userAnnotation: MKPointAnnotation  {
        let annotation = MKPointAnnotation()
        annotation.title = "User"
        annotation.coordinate = clientLocation.coordinate
        //annotation.coordinate = CLLocationCoordinate2DMake(29.956694, 31.276854)
        return annotation
    }

    var startingPointAnnotation: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        //annotation.title = "Restaurant"
        annotation.title = defaults.string(forKey: "restaurantName")!
        annotation.coordinate = restaurantLocation.coordinate
        //annotation.coordinate = CLLocationCoordinate2DMake(29.959622, 31.270363)
        return annotation
    }
    
    //----------//
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView?.showsUserLocation = true
        mapView.delegate = self
        
        centerMapOnLocation()
        
        print("restaurantLocation:\(restaurantLocation)")
        //print("userLocation:\(userLocation)")
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(highlightTaskAccepted), userInfo: nil, repeats: false)
        
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
    
        mapView.addAnnotation(userAnnotation)
        mapView.addAnnotation(startingPointAnnotation)
        mapView.addAnnotation(deliveryAnnotation)
        
        //showDetailsOnMap(clientLocation, "User")
        //showDetailsOnMap(dpLocation, "Delivery Person")
        //showDetailsOnMap(restaurantLocation, defaults.string(forKey: "restaurantName")! )
        
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
        let clientLocation = CLLocation(latitude:12.96195220947266, longitude:77.64364876922691)
//        let clientlocation = CLLocation(latitude:12.96195220947266, longitude:77.64364876922691)
        
        //Substitute the below lines 
        //let sourceMapItem = MKMapItem.forCurrentLocation()//gives users current location too/
        let sourcePlacemark = MKPlacemark(coordinate: restaurantLocation.coordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let destPlacemark = MKPlacemark(coordinate: clientLocation.coordinate)
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
            guard let primaryRoute = response.routes.first else {
                print("response has no routes")
                return }
//            self.mapView.addOverlay(primaryRoute.polyline)
            
            self.mapView.addOverlay(primaryRoute.polyline, level: .aboveRoads)
            
            self.mapView.setRegion(MKCoordinateRegion(primaryRoute.polyline.boundingMapRect), animated: true)
            
            // initiate recursive animation
            self.routeCoordinates = primaryRoute.polyline.coordinates
            self.coordinateIndex = 0
            
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
            //case "restaurant":
            //    annotationView.image = UIImage(named: "restaurant")
            case "Delivery Person":
                annotationView.image = UIImage(named: "deliveryPerson")
            default: annotationView.image = UIImage(named: "restaurant")
            //default: break
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
