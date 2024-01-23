//
//  ListView.swift
//  DriveLog
//
//  Created by Carl Wang on 1/14/24.
//

import SwiftUI

struct ListView: View {
    var body: some View {
        VStack {
            let logs  = getLogs() // get logs from filesystem
            
            // check empty
            if logs.isEmpty {
                Text("You have no drives so far") // empty message
            }
            else{
                List{
                    ForEach(formatLogs(logs: logs), id: \.self) { timestamp in
                        Text(timestamp)
                    } // display the list history from the formatLogs function
                    .onDelete(perform: delete)
                }
                .toolbar{
                    EditButton() // create a edit button for the list
                }
            }
        }
        .navigationBarTitle("Drives", displayMode: .inline)
    }
    
    // function to get list of drive logs in the phone filesystem
    func getLogs() -> [URL]{
        
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            // get all files in the directory
            do {
                let pathList = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [])
                
                // filter list, first four char in file name is trip and extension is json
                let filterList = pathList.filter{ url in
                    let fileName = url.lastPathComponent
                    return fileName.hasPrefix("trip") && url.pathExtension.lowercased() == "json"
                }
                
                return filterList
            } catch {
                print("Error: \(error)")
                return []
            }
        }
        return []
    }
    
    // format the logs to human readable form
    func formatLogs(logs: [URL]) -> [String] {
        var formattedList: [String] = [] // construct a array

        for url in logs {
            let fileName = url.lastPathComponent // get url

            // extract the timestamp part from the url
            if let range = fileName.range(of: "trip") {
                let startIndex = fileName.index(range.upperBound, offsetBy: 0)
                let endIndex = fileName.index(startIndex, offsetBy: 14) // length of yyyyMMddHHmmss
                let timestamp = String(fileName[startIndex..<endIndex])
                
                // format the timestamp to human readable form
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmss"
                
                guard let date = dateFormatter.date(from: timestamp) else {
                    print("Failed to convert timestamp to Date.")
                    return ["Error occurred"]
                }

                // format for displaying in the list
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let formattedDate = dateFormatter.string(from: date)
                let formatted = "Drive on " + formattedDate

                formattedList.append(formatted)
            }
        }

        return formattedList
    }
    
    // dummy delete function for list
    func delete(at offsets: IndexSet){
        //TODO: finish this function 
    }

}

#Preview {
    ListView()
}
