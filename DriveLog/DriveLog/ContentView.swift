import SwiftUI
import MapKit
import AlertToast

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State var isSettingsSheetPresented = false
    @State var isLogging = false
    
    // current speed and distance
    @State var curSpeed: Double = 0.0
    @State var curDistance: Double = 0.0
    
    // get current device theming
    @Environment(\.colorScheme) var colorScheme
    
    // toast alert state variable
    @State private var showSavedAlert = false
    @State private var showSavingAlert = false
    
    // speed and distance unit app storage vars
    @AppStorage("selectedSpeed") var speedUnit = "mph"
    @AppStorage("selectedDist") var distanceUnit = "miles"
    
    var body: some View {
        NavigationView{
            ZStack {
                Map(coordinateRegion: $locationManager.region, interactionModes: .all
                    , showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)
                
                VStack{
                    HStack{
                        Spacer()
                        Text("DriveLog")
                            .font(.title)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.3), Color.clear]), startPoint: .top, endPoint: .bottom)
                    )
                    
                    Spacer()
                    
                    if isLogging {
                        VStack{
                            HStack{
                                Text(String(curDistance))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                
                                Spacer()
                                
                                Text(String(curSpeed))
                                    .multilineTextAlignment(.center)
                                    .font(.title)
                                    .frame(maxWidth: .infinity)
                                
                                Spacer()
                                
                                Text("--")
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding()
                            
                            HStack{
                                Text(distanceUnit)
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
                                
                                Text("Time")
                                    .italic()
                                    .textCase(.uppercase)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding()
                        }
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .opacity(0.8)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                    }
                    
                    HStack {
                        
                        Spacer()
                        
                        // settings button
                        Button(action: {
                            isSettingsSheetPresented.toggle()
                        }) {
                            Image(systemName: "gear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .padding(3)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .padding(.bottom, 20)
                        .shadow(radius: 3)
                        .sheet(isPresented: $isSettingsSheetPresented){
                            NavigationView {
                                SettingsView()
                                    .navigationBarTitle("Settings", displayMode: .inline)
                                
                                    .navigationBarItems(
                                        leading: Button("Exit") {
                                            isSettingsSheetPresented.toggle()
                                        }
                                    )
                            }
                            
                        }
                        
                        Spacer()
                        
                        // the "go" action button
                        Button(action: {
                            isLogging.toggle()
                            
                            // handle button press what to do
                            if isLogging {
                                // should start logging
                                logPath { coordinates, speeds in
                                    // handle logged coordinates
                                    
                                    // check empty
                                    if coordinates.count > 0 {
                                        savePath(coordinates: coordinates, speeds: speeds)
                                    }
                                }
                            }
                            
                        }) {
                            Text(isLogging ? "STOP" : "GO")
                                .font(isLogging ? .title : .largeTitle)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 100)
                                .background(isLogging ? Color.red : Color.green)
                                .clipShape(Circle())
                        }
                        .padding(.bottom, 20)
                        .shadow(radius: 5)
                        
                        Spacer()
                        
                        // show path button
                        NavigationLink(destination: ListView()){
                            Image(systemName: "figure.walk")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                        .padding(.bottom, 20)
                        .shadow(radius: 3)
                        .navigationBarTitle("Exit", displayMode: .inline)
                        
                        Spacer()
                    }
                    
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
        }
        .toast(isPresenting: $showSavedAlert, duration: 1.0){
            AlertToast(type: .systemImage("checkmark.circle", .green), title: "Trip saved")
        }
        .toast(isPresenting: $showSavingAlert){
            AlertToast(type: .loading, title: "Saving trip...")
        }
    }
    
    // function to log path of user
    // default distance is m, speed is m/s
    func logPath(completion: @escaping ([CLLocationCoordinate2D], [CLLocationSpeed]) -> Void){
        print("Start logging path...")
        // run in background thread
        DispatchQueue.global().async{
            
            // define coordinate and speed list variables
            var coordinates: [CLLocationCoordinate2D] = []
            var speeds: [CLLocationSpeed] = []
            
            // logging loop
            print("isLogging status : " + String(isLogging))
            while isLogging {
                
                // record speed
                if let speed = locationManager.userSpeed {
                    speeds.append(speed)
                    
                    // set user current speed
                    curSpeed = speed
                    
                    // speed convert
                    if(speedUnit == "mph"){
                        curSpeed *= 2.23694
                    }
                    else if(speedUnit == "kph"){
                        curSpeed *= 3.6
                    }
                    
                    // round speed
                    curSpeed = (curSpeed * 10).rounded() / 10
                    
                    //TODO: update live user time
                }
                
                // record location
                if let coord = locationManager.userCoordinates {
                    coordinates.append(coord)
                    //print("User Coordinates: \(coord.latitude), \(coord.longitude)")
                    
                    // set user current distance
                    curDistance = calculateTotalDistance(coordinates: coordinates)
                    
                    // distance convert
                    if(distanceUnit == "kilometers"){
                        curDistance /= 1000
                    }
                    else if(distanceUnit == "miles"){
                        curDistance *= 0.000621371
                    }
                    
                    // round distance
                    curDistance = (curDistance * 100).rounded() / 100
                }
                
                sleep(3) // for test
            }
            
            // when the user presses the stop button
            DispatchQueue.main.async {
                print("Stop logging")
                // Call the completion handler with the coordinates and speed
                completion(coordinates, speeds)
            }
        }
    }
    
    // function to save logged path
    func savePath(coordinates: [CLLocationCoordinate2D], speeds: [CLLocationSpeed]){
        showSavingAlert = true
        do{
            // check length of coordinates and speeds
            guard coordinates.count == speeds.count else {
                print("Error: coordinates and speeds are not the same length")
                showSavingAlert = false
                // TODO: add toast alert for users
                return
            }
            
            //TODO: test if this actually works
            // map data coordinate2d
            let coordinateMap = zip(coordinates, speeds).map { (coordinate, speed) -> [String: Any] in
                return [
                    "latitude": coordinate.latitude,
                    "longitude": coordinate.longitude,
                    "speed": speed
                ]
            }
            
            let data = try JSONSerialization.data(withJSONObject: coordinateMap, options: .prettyPrinted) // convert map to json to write to filesystem
            
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                // generate file name
                let cDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmss"
                let date = dateFormatter.string(from: cDate)
                let fileName = "trip" + date
                
                
                // Create the file URL
                let fileURL = documentDirectory.appendingPathComponent(fileName).appendingPathExtension("json")
                
                // Write JSON data to the file
                try data.write(to: fileURL, options: .atomic)
                print("File saved successfully at \(fileURL)")
                
                // update alert toast to user
                showSavingAlert = false
                showSavedAlert = true
            }
        }
        catch{
            print("Error: \(error.localizedDescription)")
            showSavingAlert = false
        }
    }
    
    // function to calculate total distance for display in trip
    func calculateTotalDistance(coordinates: [CLLocationCoordinate2D]) -> CLLocationDistance {
        guard coordinates.count > 1 else { return 0.0 }
        
        var totalDistance: CLLocationDistance = 0.0
        
        for i in 0..<coordinates.count - 1 {
            let start = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
            let end = CLLocation(latitude: coordinates[i + 1].latitude, longitude: coordinates[i + 1].longitude)
            totalDistance += start.distance(from: end)
        }
        
        return totalDistance
    }
}

struct HalfwayModalTransition: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity)
            .padding()
            .transition(.move(edge: .bottom))
    }
}

struct ContentViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
