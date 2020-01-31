//
//  tempViewController.swift
//  foodOrderApp
//
//  Created by Sujata on 31/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

//PLEASE DELETE THIS FILE

import UIKit
import MapKit

class tempViewController: UIViewController
{
    var mapView: MKMapView!
    
    // annotations for this demo, replace with your own annotations
    var deliveryAnnotation: MKPointAnnotation = {
        let annotation = MKPointAnnotation()
        annotation.title = deliveryTitle
        
        return annotation
    }()
    
    let userAnnotation: MKPointAnnotation = {
        let annotation = MKPointAnnotation()
        annotation.title = userTitle
        annotation.coordinate = CLLocationCoordinate2DMake(29.956694, 31.276854)
        return annotation
    }()
    
    let startingPointAnnotation: MKPointAnnotation = {
        let annotation = MKPointAnnotation()
        annotation.title = startingPointTitle
        annotation.coordinate = CLLocationCoordinate2DMake(29.959622, 31.270363)
        return annotation
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMapView()
        navigate()
    }
    
    func loadMapView() {
        // set map
        mapView = MKMapView()
        view = mapView
        mapView.delegate = self
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: reuseId)
        
        // add annotations
        mapView.addAnnotation(userAnnotation)
        mapView.addAnnotation(startingPointAnnotation)
        mapView.addAnnotation(deliveryAnnotation)
    }
    
    func navigate() {
        let sourcePlaceMark = MKPlacemark(coordinate: startingPointAnnotation.coordinate)
        let destPlaceMkark = MKPlacemark(coordinate: userAnnotation.coordinate)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destPlaceMkark)
        directionRequest.transportType = .any
        
        let direction = MKDirections(request: directionRequest)
        
        direction.calculate(completionHandler: { response, error in
            if let error = error {
                print(error.localizedDescription)
                
                return
            }
            
            guard let primaryRoute = response!.routes.first else {
                print("response has no routes")
                return
            }
            
            self.mapView.addOverlay(primaryRoute.polyline, level: .aboveRoads)
            self.mapView.setRegion(MKCoordinateRegion(primaryRoute.polyline.boundingMapRect), animated: true)
            
            // initiate recursive animation
            self.routeCoordinates = primaryRoute.polyline.coordinates
            self.coordinateIndex = 0
        })
    }
    
    var routeCoordinates = [CLLocationCoordinate2D]()
    
    var avgAnimationTime: Double {
        // to show delivery in 60 second, replace 60 with amount of seconds you'd like to show
        return 60 / Double(routeCoordinates.count)
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
    
    func animateToNextCoordinate() {
        let coordinate = routeCoordinates[coordinateIndex]
        
        UIView.animate(withDuration: avgAnimationTime, animations: {
            self.deliveryAnnotation.coordinate = coordinate
        }, completion:  { _ in
            self.coordinateIndex += 1
        })
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        // replace these images with your own
        switch annotation.title {
        case userTitle:
            annotationView.image = UIImage(named: "user")
        case startingPointTitle:
            annotationView.image = UIImage(named: "store")
        case deliveryTitle:
            annotationView.image = UIImage(named: "deliveryTruck")
        default: break
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard overlay is MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .black
        renderer.lineWidth = 5
        renderer.lineJoin = .round
        
        return renderer
    }
}

public extension MKMultiPoint {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)
        
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        
        return coords
    }
}
shareimprove this answer
edited Apr 25 '19 at 18:16
answered Apr 23 '19 at 23:31

