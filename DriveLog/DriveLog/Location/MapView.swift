//
//  MapView.swift
//  DriveLog
//
//  Created by Carl on 4/15/24.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    let region: MKCoordinateRegion
    let lineCoordinates: [CLLocationCoordinate2D]
    let startCoordinate: CLLocationCoordinate2D?
    let endCoordinate: CLLocationCoordinate2D?
    
    
    // Create the MKMapView using UIKit.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .standard
        mapView.region = region
        
        // draw the line
        let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
        mapView.addOverlay(polyline)
        
        // draw start and end coordinates
        if let start = startCoordinate {
            let startPin = MKPointAnnotation()
            startPin.coordinate = start
            startPin.title = "Start"
            mapView.addAnnotation(startPin)
        }
        
        if let end = endCoordinate {
            let endPin = MKPointAnnotation()
            endPin.coordinate = end
            endPin.title = "End"
            mapView.addAnnotation(endPin)
        }
        
        return mapView
    }
    
    
    func updateUIView(_ view: MKMapView, context: Context) {}
    
    // Link it to the coordinator which is defined below.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    
    init(_ parent: MapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 5
            
            print("rendering polyline")
            return renderer
        }
        return MKOverlayRenderer()
    }
}
