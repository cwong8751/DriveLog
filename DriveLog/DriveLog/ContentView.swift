import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State var isSettingsSheetPresented = false
    @State var isLogging = false
    
    // current speed and distance
    @State var curSpeed: Double = 0.0
    @State var curDistance: Double = 0.0
    
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
                                Text(String(curSpeed))
                                
                                Spacer()
                                
                                Text(String(curDistance))
                                
                                Spacer()
                                
                                Text("--")
                            }
                            .padding()
                            
                            HStack{
                                Text("Speed")
                                    .italic()
                                    .textCase(.uppercase)
                                
                                Spacer()
                                
                                Text("Distance")
                                    .italic()
                                    .textCase(.uppercase)
                                
                                Spacer()
                                
                                Text("Time")
                                    .italic()
                                    .textCase(.uppercase)
                            }
                            .padding()
                        }
                        .background(.white)
                        .opacity(0.8)
                        .cornerRadius(5)
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
    }
    
    // function to log path of user
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
                    
                    //TODO: update live user speed, distance and time
                }
                
                // record location
                if let coord = locationManager.userCoordinates {
                    coordinates.append(coord)
                    //print("User Coordinates: \(coord.latitude), \(coord.longitude)")
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
        do{
            // map data coordinate2d
            let coordinateMap = coordinates.map{["latitude": $0.latitude, "longitude": $0.longitude]}
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
                
            }
        }
        catch{
            print("Error: \(error.localizedDescription)")
        }
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
