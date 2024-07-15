//
//  TripView.swift
//  DriveLog
//
//  Created by Carl on 4/14/24.
//

import SwiftUI
import MapKit
import Foundation
import AlertToast

struct TripView: View {
    // define variables
    @State private var coordinatesCL : [CLLocationCoordinate2D] = []
    @State private var speedsCL : [CLLocationSpeed] = []
    @State private var tripLine : MKPolyline? = nil
    @State private var tripRegion : MKCoordinateRegion? = nil
    
    // define variables for speed and distance calculation
    @State private var avgSpeed : String = "--"
    @State private var distance : String = "--"
    @State private var topSpeed : String = "--"
    
    // trip name
    var trip : String
    
    // get units from app storage
    @AppStorage("selectedSpeed") var speedUnit = "mph"
    @AppStorage("selectedDist") var distanceUnit = "miles"
    
    // get current device theme
    @Environment(\.colorScheme) var colorScheme
    
    // error alert variable
    @State private var showErrorAlert = false
    
    var body: some View {
        ZStack{
            // display map view for trip
            if let tripRegion = tripRegion, !coordinatesCL.isEmpty {
                MapView(region: tripRegion, lineCoordinates: coordinatesCL, startCoordinate: coordinatesCL[0], endCoordinate: coordinatesCL[coordinatesCL.count - 1])
                    .edgesIgnoringSafeArea(.bottom)
            }
            
            VStack{
                Spacer()
                
                VStack{
                    // title text
                    HStack{
                        Spacer()
                        
                        Text("Top Speed")
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                        Text("Avg Speed")
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                        Text("Distance")
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                    
                    // actual values
                    HStack{
                        Spacer()
                        
                        Text(topSpeed)
                            .bold()
                            .font(.system(size: 32))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        
                        Text(avgSpeed)
                            .bold()
                            .font(.system(size: 32))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                        Text(distance)
                            .bold()
                            .font(.system(size: 32))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                    
                    // units
                    HStack{
                        Spacer()
                        
                        Text(speedUnit)
                            .italic()
                            .textCase(.uppercase)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                        Text(speedUnit)
                            .italic()
                            .textCase(.uppercase)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                        Text(distanceUnit)
                            .italic()
                            .textCase(.uppercase)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding()
                .background(colorScheme == .dark ? Color.black : Color.white)
                .opacity(0.8)
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .edgesIgnoringSafeArea(.all)
            .padding()
            
        }
        .navigationTitle("Trip detail")
        .onAppear{
            loadTrip()
            //print(coordinatesCL)
            
            // call set distance function
            setDistance()
            setAvgSpeed()
            setTopSpeed()
            
        }
        .toast(isPresenting: $showErrorAlert) {
            AlertToast(displayMode: .alert, type: .error(Color.red), title: "Trip details failed to load")
        }
    }
    
    func setTopSpeed() {
        guard let maxSpeed = speedsCL.max() else {
            return
        }
        
        topSpeed = String(Int(maxSpeed)) // convert to int then string
    }
    
    func loadTrip() {
        //print(trip)
        // Extract date and time from human-readable index
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dtString = trip.replacingOccurrences(of: "Trip on ", with: "") // Remove the prefix
        
        if let date = dateFormatter.date(from: dtString) {
            
            // Convert to file format
            let df = DateFormatter()
            df.dateFormat = "yyyyMMddHHmmss"
            
            let ds = df.string(from: date) // The final form
            
            let content = getFileContents(fileName: "trip" + ds) // Get actual file content
            
            do {
                // Since content is in JSON, parse JSON
                let decoder = JSONDecoder()
                
                guard let jsonData = content?.data(using: .utf8) else {
                    print("Error while converting to JSON")
                    return
                }
                
                // Parse JSON into array of dictionaries
                let tripData = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]]
                
                //print(tripData)
                
                // Extract coordinates and speeds
                coordinatesCL = [] // Clear array first
                speedsCL = []
                
                for dataPoint in tripData ?? [] {
                    //print("entering deciphering loop")
                    
                    if let latitude = dataPoint["latitude"] as? Double,
                       let longitude = dataPoint["longitude"] as? Double,
                       let speed = dataPoint["speed"] as? Double {
                        
                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        
                        //print("Latitude: \(latitude), Longitude: \(longitude), Speed: \(speed)")
                        
                        // append to array
                        coordinatesCL.append(coordinate)
                        speedsCL.append(speed)
                    }
                }
                
                //print(coordinatesCL)
                //print(coordinatesCL.count)
                
                // Set coordinate region
                DispatchQueue.main.async{
                    if let firstCoordinate = coordinatesCL.first {
                        tripRegion = MKCoordinateRegion(
                            center: firstCoordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                        )
                    }
                    
                    tripLine = MKPolyline(coordinates: coordinatesCL, count: coordinatesCL.count)
                }
                
            } catch {
                print("Error while decoding JSON \(error)")
                return
            }
        } else {
            print("Error occurred while converting human-readable index to file name for deletion")
        }
        
    }
    
    
    // function to read file
    func getFileContents(fileName: String) -> String? {
        let fileManager = FileManager.default
        guard let documentDirectoryUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Cannot get document directory url")
            return nil
        }
        
        // construct the file path
        let filePath = documentDirectoryUrl.appendingPathComponent(fileName).appendingPathExtension("json")
        
        // try and read file contents
        do {
            let content = try String(contentsOf: filePath, encoding: .utf8)
            return content
        } catch {
            print("Failed to read file contents \(error)")
            return nil //TODO: change this to some other type maybe
        }
    }
    
    // function to get avg speed
    func setAvgSpeed(){
        var total = 0.0;
        
        if(speedsCL.count <= 0){
            showErrorAlert = true
            return
        }
        
        for i in 0..<speedsCL.count - 1 {
            total += speedsCL[i]
        }
        
        // calculate avg
        total /= Double(speedsCL.count)
        
        // check for units
        if(speedUnit == "mph"){
            total *= 2.23694
        }
        else{
            total *= 3.6
        }
        
        avgSpeed = String(Int(total)) // round to int
    }
    
    // function to get distance
    func setDistance(){
        var total = 0.0;
        
        print(coordinatesCL)
        print(coordinatesCL.count)
        
        // check if is zero
        if(coordinatesCL.count <= 0){
            showErrorAlert = true
            return
        }
        
        for i in 0..<coordinatesCL.count - 1 {
            let currentLocation = coordinatesCL[i]
            let nextLocation = coordinatesCL[i + 1]
            
            total += distanceBetweenTwoPts(pt1: currentLocation, pt2: nextLocation)
        }
        
        // check for units
        if(distanceUnit == "miles"){
            total *= 0.621371
        }
        
        // round to two decimal places
        //        total = round(total * 100) / 100
        
        // set state variable
        // the calculated distance is in kilometers
        distance = String(Int(total));
    }
    
    func distanceBetweenTwoPts(pt1 : CLLocationCoordinate2D, pt2 : CLLocationCoordinate2D) -> Double{
        let earthRadius: Double = 6371
        
        let lat1 = degreesToRadians(pt1.latitude)
        let lon1 = degreesToRadians(pt1.longitude)
        let lat2 = degreesToRadians(pt2.latitude)
        let lon2 = degreesToRadians(pt2.longitude)
        
        let dLon = lon2 - lon1
        let dLat = lat2 - lat1
        
        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let distance = earthRadius * c // Distance in kilometers
        
        return distance
    }
    
    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180
    }
}

struct TripViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            TripView(trip: "")
        }
    }
}
