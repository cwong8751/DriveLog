//
//  TripView.swift
//  DriveLog
//
//  Created by Carl on 4/14/24.
//

import SwiftUI
import MapKit

struct TripView: View {
    // define variables
    @StateObject var locationManager = LocationManager()
    var trip : String
    
    var body: some View {
        VStack{
            // display map view for trip 
            Map(coordinateRegion: $locationManager.region, interactionModes: .all
                , showsUserLocation: false)
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationTitle("Trip detail")
    }
}
