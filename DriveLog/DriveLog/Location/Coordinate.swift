//
//  Coordinate.swift
//  DriveLog
//
//  Created by Carl on 4/15/24.
//

import Foundation
import MapKit

// custom coordinate class to decode for files

struct Coordinate: Decodable {
    let longitude: Double
    let latitude: Double

    // Convert Coordinate struct to CLLocationCoordinate2D
    var locationCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
