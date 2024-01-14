import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State var isSettingsSheetPresented = false
    @State var isLogging = false
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $locationManager.region, interactionModes: [], showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                HStack{
                    Spacer()
                    Text("DriveLog")
                        .font(.title)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 40)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.3), Color.clear]), startPoint: .top, endPoint: .bottom)
                )
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                        .frame(width: 20)
                    
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
                            logPath { coordinates in
                                print(coordinates.description)
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
                    Spacer()
                }
                 
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
    
    // function to log path of user
    func logPath(completion: @escaping ([CLLocationCoordinate2D]) -> Void){
        print("Start logging path...")
        // run in background thread
        DispatchQueue.global().async{
            var coordinates: [CLLocationCoordinate2D] = []
            print("isLogging status : " + String(isLogging))
            while isLogging {
                
                if let coord = locationManager.userCoordinates {
                    coordinates.append(coord)
                    print("User Coordinates: \(coord.latitude), \(coord.longitude)")
                }
                sleep(3) // for test
            }
            
            // when the user presses the stop button
            DispatchQueue.main.async {
                            print("Stop logging")
                            // Call the completion handler with the logged coordinates
                            completion(coordinates)
                        }
        }
    }
}

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900, longitude: -122.009_020),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
        
    // published variable to make user coordinates accessible in content view
    @Published var userCoordinates: CLLocationCoordinate2D? = nil
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
    }
    
    func setup() {
        switch locationManager.authorizationStatus {
        //If we are authorized then we request location just once, to center the map
        case .authorizedWhenInUse:
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
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locations.last.map {
            userCoordinates = $0.coordinate // update coordinates to published variable
            region = MKCoordinateRegion(
                center: $0.coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
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
