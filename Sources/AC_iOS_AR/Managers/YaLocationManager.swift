//
//  LocationManager.swift
//  myPlace
//
//  Created by Mac on 02/05/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import CoreLocation

@objc protocol YaLocationManagerDelegate {
    @objc optional func update(location: CLLocation)
    @objc optional func update(heading: CLHeading)
    @objc optional func update(error: Error)
    @objc optional func update(gpsEnabled: Bool)
}

class YaLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = YaLocationManager()
    
    private var hdopAccuracy: Double = 75.0
    
    var latestLocation: CLLocation? {
        willSet {
            if let location = newValue {
                delegate?.update?(location: location)
            }
        }
    }
    var latestHeading : CLHeading? {
        willSet {
            if let heading = newValue {
                delegate?.update?(heading: heading)
            }
        }
    }
    var latestError: Error? {
        willSet {
            if let error = newValue {
                delegate?.update?(error: error)
            }
        }
    }
    
    var gpsEnabled: Bool? {
        willSet {
            if let value = newValue {
                delegate?.update?(gpsEnabled: value)
            }
        }
    }

    let locationManager = CLLocationManager()
    
    var delegate: YaLocationManagerDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.distanceFilter = 1 // 1 meter
        locationManager.headingFilter = 1 // 1 degree
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    deinit {
        print("Deinit YaLocationManager")
    }
    
    func startUpdating() {
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Pick the location with best (= smallest value) horizontal accuracy
        if let location = (locations.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }.first), location.horizontalAccuracy <= hdopAccuracy {
            self.latestLocation = location
            self.latestError = nil
        } else {
            self.latestLocation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        latestHeading = newHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        gpsEnabled = (status == .authorizedAlways || status == .authorizedWhenInUse)
        if gpsEnabled ?? false {
            self.startUpdating()
        } else {
            self.stopUpdating()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.latestError = error
    }
    
    func set(hdop accuracy: Double) {
        self.hdopAccuracy = accuracy
    }
    
}
