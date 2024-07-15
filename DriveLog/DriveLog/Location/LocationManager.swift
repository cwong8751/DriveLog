//
//  LocationManager.swift
//  DriveLog
//
//  Created by Carl on 4/14/24.
//

import Foundation
import MapKit

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900, longitude: -122.009_020),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
        
    // published variable to make user coordinates accessible in content view
    @Published var userCoordinates: CLLocationCoordinate2D? = nil
    @Published var userSpeed: CLLocationSpeed? = 0.0
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
    }
    
    func setup() {
        switch locationManager.authorizationStatus {
        //If we are authorized then we request location just once, to center the map
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        //If we don´t, we request authorization
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
//        locationManager.startUpdatingLocation()
//        //locationManager.requestLocation()
//    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            guard manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways else { return }
            locationManager.startUpdatingLocation()
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        
//        // stops the map from recentering itself
//        //locationManager.stopUpdatingLocation()
//        
//        
//        DispatchQueue.main.async{
//            locations.last.map {
//                self.userCoordinates = $0.coordinate // update coordinates to published variable
//                self.userSpeed = $0.speed // update speed
//                self.region = MKCoordinateRegion(
//                    center: $0.coordinate,
//                    span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
//                )
//            }
//        }
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         guard let location = locations.last else { return }
         
         DispatchQueue.main.async {
             self.userCoordinates = location.coordinate
             self.userSpeed = location.speed
             self.region = MKCoordinateRegion(
                 center: location.coordinate,
                 span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
             )
         }
     }
}
