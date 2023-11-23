//
//  SettingsView.swift
//  DriveLog
//
//  Created by Carl on 11/20/23.
//

import SwiftUI

struct SettingsView: View {
    var speedUnits = ["mph", "kph"]
    @State private var selectedSpeed = "mph"
    var distUnits = ["miles", "kilometers"]
    @State private var selectedDist = "miles"
    
    var body: some View {
        Form{
            List{
                Section(header: Text("Units")){
                    // speed and distance selections
                    Picker("Speed unit", selection: $selectedSpeed){
                        ForEach(speedUnits, id: \.self){
                            Text($0)
                        }
                    }
                    
                    Picker("Distance unit", selection: $selectedDist){
                        ForEach(distUnits, id: \.self){
                            Text($0)
                        }
                    }
                }
                
                // my information sections
                Section(header: Text("Author")){
                    Text("Carl")
                    Text("http://www.wqis.xyz")
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
