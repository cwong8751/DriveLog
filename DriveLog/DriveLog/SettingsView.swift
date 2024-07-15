//
//  SettingsView.swift
//  DriveLog
//
//  Created by Carl on 11/20/23.
//

import SwiftUI

struct SettingsView: View {
    var units = ["imperial", "metric"]
    var mapStyles = ["default", "hybrid", "satellite"]
    
    // use user default for persistent app storage
    @AppStorage("selectedSpeed") var selectedSpeed = "mph"
    @AppStorage("selectedDist") var selectedDist = "miles"
    @AppStorage("unit") var selectedUnit = "imperial"
    @AppStorage("mapStyle") var selectedMapStyle = "default"

    
    var body: some View {
        Form{
            List{
                Section(header: Text("Units")){
                    Picker("Units", selection: $selectedUnit) {
                        ForEach(units, id: \.self){
                            Text($0)
                        }
                    }
                    .onChange(of: selectedUnit) { newValue in
                        switch newValue{
                        case "imperial":
                            selectedSpeed = "mph"
                            selectedDist = "miles"
                            break;
                        case "metric":
                            selectedSpeed = "km/h"
                            selectedDist = "km"
                            break;
                        default:
                            selectedSpeed = "mph"
                            selectedDist = "miles"
                            break;
                        }
                    }
                }
                
                Section(header: Text("Map")){
                    Picker("Map Style", selection: $selectedMapStyle) {
                        ForEach(mapStyles, id: \.self){
                            Text($0)
                        }
                    }
//                    .onChange(of: selectedMapStyle) { newValue in
//                        print("new map style: " + selectedMapStyle)
//                    }
                }
                
                if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    Section(header: Text("Version")){
                        Text(appVersion)
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
