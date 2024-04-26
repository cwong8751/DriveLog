//
//  TripView.swift
//  DriveLog
//
//  Created by Carl on 4/14/24.
//

import SwiftUI
import MapKit
import Foundation

//TODO: either use mapview for both contentview and tripview or use Map()
struct TripView: View {
    // define variables
    @State private var coordinatesCL : [CLLocationCoordinate2D] = []
    @State private var tripLine : MKPolyline? = nil
    @State private var tripRegion : MKCoordinateRegion? = nil
    
    // define variables for speed and distance calculation
    @State private var avgSpeed : String = "--"
    @State private var distance : String = "--"
    
    // trip name
    var trip : String
    
    // get units from app storage
    @AppStorage("selectedSpeed") var speedUnit = "mph"
    @AppStorage("selectedDist") var distanceUnit = "miles"
    
    var body: some View {
        ZStack{
            // display map view for trip
            if let tripRegion = tripRegion, !coordinatesCL.isEmpty {
                MapView(region: tripRegion, lineCoordinates: coordinatesCL)
                    .edgesIgnoringSafeArea(.bottom)
            }
            
            VStack{
                Spacer()
                
                VStack{
                    Text(trip)
                        .multilineTextAlignment(.leading)
                    
                    // title text
                    HStack{
                        Spacer()
                        
                        Text("Avg speed")
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        Text("Distance")
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    
                    // actual values
                    HStack{
                        Spacer()
                        
                        Text(avgSpeed)
                            .bold()
                            .font(.system(size: 32))
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        Text(distance)
                            .bold()
                            .font(.system(size: 32))
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    
                    // units
                    HStack{
                        Spacer()
                        
                        Text(speedUnit)
                            .italic()
                            .textCase(.uppercase)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        Text(distanceUnit)
                            .italic()
                            .textCase(.uppercase)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding()
                .background(.white)
                .opacity(0.8)
                .cornerRadius(5)
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
        }
    }
    
    func loadTrip() {
        print(trip)
        
        // extract date and time from human readable index
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dtString = trip.replacingOccurrences(of: "Trip on ", with: "") // remove the prefix
        
        if let date = dateFormatter.date(from: dtString) {
            
            // convert to file format
            let df = DateFormatter()
            df.dateFormat = "yyyyMMddHHmmss"
            
            let ds = df.string(from: date) // the final form
            
            let content = getFileContents(fileName: "trip" + ds) // get actual file content
            
            do{
                // since content is in json, parse json
                let decoder = JSONDecoder()
                
                guard let jsonData = content?.data(using: .utf8) else {
                    print("Error while converting to json")
                    return
                }
                
                let coordinates = try decoder.decode([Coordinate].self, from: jsonData) // get coordinates
                
                // plot trip on map
                coordinatesCL = [] // clear array first
                
                for i in coordinates {
                    coordinatesCL.append(i.locationCoordinate)
                }
                
                // set coordinate region
                if let firstCoordinate = coordinatesCL.first {
                    tripRegion = MKCoordinateRegion(
                        center: firstCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                    )
                }
                
                tripLine = MKPolyline(coordinates: coordinatesCL, count: coordinatesCL.count)
            } catch {
                print("Error while decoding json \(error)")
                return
            }
        }
        else{
            print("Error occured while converting human readable index to file name for deletion")
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
        
    }
    
    // function to get distance
    func setDistance(){
        var total = 0.0;
        
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
        total = round(total * 100) / 100
        
        // set state variable
        // the calculated distance is in kilometers
        distance = String(total);
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
