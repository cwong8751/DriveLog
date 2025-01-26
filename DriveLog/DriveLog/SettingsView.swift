//
//  SettingsView.swift
//  DriveLog
//
//  Created by Carl on 11/20/23.
//

import SwiftUI
import AlertToast

struct SettingsView: View {
    var units = ["imperial", "metric"]
    
    // use user default for persistent app storage
    @AppStorage("selectedSpeed") var selectedSpeed = "mph"
    @AppStorage("selectedDist") var selectedDist = "miles"
    @AppStorage("unit") var selectedUnit = "imperial"
    
    // import file option state variables
    @State private var isImportingFile = false

    
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
                    Text("Coming soon")
                }
                
//                Section(header: Text("Sync")){
//                    
//                }
                
                Section(header: Text("Data")){
                    Button(action: {}, label: Text("Export trips"))
                    
                    Button(action: {}, label: Text("Export all"))
                    
                    Button(action: {isImportingFile = true}, label: Text("Import trip"))
                    
                    Button(action: {}, label: Text("Backup"))
                }
                
                if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    Section(header: Text("Version")){
                        Text(appVersion)
                    }
                }
                
            }
        }
        
        .fileImporter(isPresented: $isImportingFile, allowedContentTypes: [.json]) { result in
            do {
                let fileURL = try result.get()
                
                // read contents of file
                let raw = readFile(fileURL: fileURL.absoluteString)
                if(raw != nil){
                    // start importing the file
                    if(validateContent(contents: raw!)){
                        
                    }
                    else{
                        // show error
                        print("format not ok")
                    }
                }
                else{
                    print("content is null")
                }
                
            }
            catch {
                print(error)
            }
        }
    }
}

// Validate the content to see if format is ok
func validateContent(contents: String) -> Bool {
    // Convert the content string to Data
    guard let data = contents.data(using: .utf8) else {
        return false
    }
    
    // Parse the JSON data
    do {
        if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            // Check each dictionary in the array
            for item in jsonArray {
                // Ensure it contains "latitude", "longitude", and "speed" keys with appropriate types
                guard let latitude = item["latitude"] as? Double,
                      let longitude = item["longitude"] as? Double,
                      let speed = item["speed"] as? Double else {
                    return false
                }
                
                // Further checks can be added here if needed (e.g., valid range for coordinates and speed)
            }
            return true
        }
    } catch {
        // Handle JSON parsing error
        print("Error parsing JSON: \(error.localizedDescription)")
        return false
    }
    
    return false
}


// reads incoming files
func readFile(fileURL: String) -> String? {
    // url check
    guard let url = URL(string: fileURL) else {
        print("Invalid URL")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: url)
        let string = String(data: data, encoding: .utf8)
        print(string ?? "Unable to decode data")
        return string
    } catch {
        print("Error reading file: \(error)")
        return nil
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
