//
//  ViewController.swift
//  CurrentLocation
//
//  Created by Muhammad Rizwan Anjum on 10/7/15.
//  Copyright © 2015 Muhammad Rizwan Anjum. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

func DegreesToRadians (value:Double) -> Double {
    return value * M_PI / 180.0
}

func RadiansToDegrees (value:Double) -> Double {
    return value * 180.0 / M_PI
}

class ViewController: UIViewController , CLLocationManagerDelegate {

    var needleAngle : Double?
    
    @IBOutlet weak var composs: UIImageView!
    @IBOutlet weak var needle: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    var kabahLocation : CLLocation?
    var latitude  : Double?
    var longitude : Double?
    var distanceFromKabah : Double?
    
    let locationManger = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kabahLocation = CLLocation(latitude: 21.42 , longitude: 39.83)
        
        self.locationManger.delegate = self
        self.locationManger.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 8.0, *) {
            self.locationManger.requestAlwaysAuthorization()
        } else {
            // Fallback on earlier versions
        }
        
        self.locationManger.startUpdatingLocation()
        self.locationManger.startUpdatingHeading()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: - LocationManger Delegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
//        let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        print("current location latitude \((location?.coordinate.latitude)!) and longitude \((location?.coordinate.longitude)!)")
        
        self.latitude = location?.coordinate.latitude
        self.longitude = location?.coordinate.longitude
//
//        self.latitude = 31.5497
//        self.longitude = 74.3436
        self.locationManger.startUpdatingLocation()
        needleAngle     = self.setLatLonForDistanceAndAngle(location!)
        
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error " + error.localizedDescription)
    }
    
    func setLatLonForDistanceAndAngle(userlocation: CLLocation) -> Double
    {
        let lat1 = DegreesToRadians(userlocation.coordinate.latitude)
        let lon1 = DegreesToRadians(userlocation.coordinate.longitude)
        let lat2 = DegreesToRadians(kabahLocation!.coordinate.latitude)
        let lon2 = DegreesToRadians(kabahLocation!.coordinate.longitude)
        
        distanceFromKabah = userlocation.distanceFromLocation(kabahLocation!)
        let dLon = lon2 - lon1;
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var radiansBearing = atan2(y, x)
        if(radiansBearing < 0.0)
        {
            radiansBearing += 2*M_PI;
        }
//        print("Initial Bearing \(radiansBearing*180/M_PI)")
        let distanceFromKabahUnit  = 0.0
        
        
        
        return radiansBearing
    
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        let needleDirection   = -newHeading.trueHeading;
        let compassDirection  = -newHeading.magneticHeading;
        
        self.needle.transform = CGAffineTransformMakeRotation(CGFloat(((Double(needleDirection) * M_PI) / 180.0) + needleAngle!))
        print("Needle \(CGAffineTransformMakeRotation(CGFloat(((Double(needleDirection) * M_PI) / 180.0) + needleAngle!)))")
        self.composs.transform = CGAffineTransformMakeRotation(CGFloat((Double(compassDirection) * M_PI) / 180.0))
        print("composs \(CGAffineTransformMakeRotation(CGFloat((Double(compassDirection) * M_PI) / 180.0)))")
    }
    
    override func viewDidAppear(animated: Bool) {
        needleAngle = 0.0
        self.locationManger.startUpdatingHeading()
        kabahLocation = CLLocation(latitude: 21.42 , longitude: 39.83)
        self.locationManger.delegate = self
        
    }
    override func viewDidDisappear(animated: Bool) {
        self.locationManger.delegate = nil
    }
    
    
    

}

