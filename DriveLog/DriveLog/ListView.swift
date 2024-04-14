//
//  ListView.swift
//  DriveLog
//
//  Created by Carl Wang on 1/14/24.
//

import SwiftUI

//TODO: optimize this
struct ListView: View {
    // state variables
    @State private var showEmptyText = false
    
    @State private var trips: [String] = [] // stores the actual human readable titles
    
    var body: some View {
        VStack {
            
            if(showEmptyText){
                Spacer()
                Text("You have no trips so far")
            }
                
            List{
                ForEach(trips, id: \.self) { timestamp in
                    // wrap with navigation link to make each item clickable
                    NavigationLink(destination: TripView(trip: timestamp)){
                        Text(timestamp)
                    }
                } // display the list history from the formatLogs function
                    .onDelete(perform: delete)
                }
                .toolbar{
                    EditButton() // create a edit button for the list
                }
        }
        .onAppear{
            let logs = getLogs()
            
            // check empty
            if logs.isEmpty {
                showEmptyText = true
            }
            else{
                // display all trips
                trips = formatLogs(logs: logs)
            }
        }
        .navigationBarTitle("Trips", displayMode: .inline)
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
                
                // print out everything in filterlist
                print(filterList)
                
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
                let formatted = "Trip on " + formattedDate

                formattedList.append(formatted)
            }
        }

        return formattedList
    }
    
    // dummy delete function for list
    func delete(at offsets: IndexSet){
        //TODO: finish this function
        
        // offsets is usually an array
        for index in offsets {
            print("index: ", index)
            print("item: ", trips[index])
            
            let itemToDelete = trips[index]
            // extract date and time from human readable index
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let dtString = itemToDelete.replacingOccurrences(of: "Trip on ", with: "") // remove the prefix
            
            if let date = dateFormatter.date(from: dtString) {
                
                // convert to file format
                let df = DateFormatter()
                df.dateFormat = "yyyyMMddHHmmss"
                
                let ds = df.string(from: date) // the final form
                
                
                let fileManager = FileManager.default
                guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else{
                    print("Failed to get the documents directory.")
                    return
                }
                
                // delete the trip file
                let furl = documentsDirectory.appendingPathComponent("trip" + ds).appendingPathExtension("json")
                print(dateFormatter.string(from: date))
                print("File to be deleted: ", furl)
                
                
                do{
                    try fileManager.removeItem(at: furl)
                    print("File deleted: \(furl.lastPathComponent)")
                } catch {
                    print("Failed to delete file: \(error)")
                }
                
                               
                // remove item from trips
                trips.remove(at: index)
                
                // update ui
                if trips.count == 0 {
                    showEmptyText = true
                }
            }
            else{
                print("Error occured while converting human readable index to file name for deletion")
            }
        }
    }

}


struct ListViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            ListView()
        }
    }
}
