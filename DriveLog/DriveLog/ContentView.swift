import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State var isSettingsSheetPresented = false
    @State var isLogging = false
    
    
    var body: some View {
        ZStack {
            MapView()
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    locationManager.requestAuthorization()
                    
                }
            
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
                        isLogging.toggle() // switch statuses
                    }) {
                        Text(isLogging ? "PAUSE" : "GO")
                            .font(isLogging ? .title : .largeTitle)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(isLogging ? Color.orange : Color.green)
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
}

struct MapView: UIViewRepresentable {
    let mapView = MKMapView()
    @State var shouldRecenter = true
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if shouldRecenter { // only auto zoom on the first time
            if let userLocation = uiView.userLocation.location {
                uiView.centerCoordinate = userLocation.coordinate
                let coordinateRegion = MKCoordinateRegion(center: uiView.centerCoordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                uiView.showsCompass = true
                uiView.setRegion(coordinateRegion, animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            mapView.centerCoordinate = userLocation.coordinate
            let coordinateRegion = MKCoordinateRegion(center: mapView.centerCoordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.showsCompass = true
            mapView.setRegion(coordinateRegion, animated: true)
            
        }
    }
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    var authorizationStatusString: String {
        switch authorizationStatus {
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        case .authorizedAlways:
            return "Authorized Always"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Determined"
        @unknown default:
            fatalError("Unexpected case in authorizationStatus")
        }
    }
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        authorizationStatus = CLLocationManager.authorizationStatus()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = CLLocationManager.authorizationStatus()
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
    }
    
    func startUpdatingLocation(){
        locationManager.startUpdatingLocation()
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
