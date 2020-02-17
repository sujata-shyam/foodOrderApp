//
//  LocationManager.swift
//  foodOrderApp
//
//  Created by Sujata on 14/02/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate
{
    static let shared = LocationManager()
    let locationManager : CLLocationManager
    var currentLocation: CLLocation!
    
    override init()
    {
        locationManager = CLLocationManager()
        
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self //Calls didChangeAuthorization
    }
    
    func start()
    {
        //print("Location manager started.")
        retrieveCurrentLocation()
    }
    
    func stop()
    {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        retrieveCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.first
        {
            currentLocation = location
            NotificationCenter.default.post(name: NSNotification.Name("gotCurrentLocation"), object: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        if let clErr = error as? CLError
        {
            switch clErr
            {
            case CLError.locationUnknown:
                print("Error Location Unknown")
            case CLError.denied:
                displayAlertForSettings()
            default:
                print("Core Location error:\(clErr.localizedDescription)")
            }
        }
        else
        {
            print("Error: ", error.localizedDescription)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func retrieveCurrentLocation()
    {
        let status = CLLocationManager.authorizationStatus()
        
        switch status
        {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
                break
            case .restricted, .denied:
                displayAlertForSettings()
                break
            default:
                break
        }
    }
}
