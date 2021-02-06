//
//  placesFile.swift
//  GooglePlacesSearchController
//
//  Created by Home on 12/1/19.
//

import Foundation

func DrawRoute() {
    // Google Controller usage
    //let controller = GooglePlacesSearchController(delegate: self as! GooglePlacesAutocompleteViewControllerDelegate, apiKey: GoogleSearchPlaceAPIKey)
    
    let sLat = String(Hafizabad.coordinate.latitude)
    let sLong = String(Hafizabad.coordinate.longitude)
    let a_coordinate_string = "\(sLat),\(sLong)"
    let b_coordinate_string = "\(Islamabad.coordinate.latitude),\(Islamabad.coordinate.longitude)"
    
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(a_coordinate_string)&destination=\(b_coordinate_string)&key=AIzaSyBQoDkkYyL0rA6E_gNH0nPYAtOYMiZcQjM"
    guard let url = URL(string: urlString) else {
        print("error: cannot create url!")
        return
    }
    let urlRequest = URLRequest(url: url)
    
    // setup session
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    
    // make the request
    _ = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
        do {
            guard let data = data else {
                throw JSONError.NoData
            }
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                throw JSONError.ConversionFailed
            }
            print(json)
            
            DispatchQueue.global(qos: .background).async {
                let array = json["routes"] as! NSArray
                let dic   = array[0] as! NSDictionary
                let dic1 = dic["overview_polyline"] as! NSDictionary
                let points  = dic1["points"] as! String
                print(points)
                
                // Go back to the main thread to update UI
                DispatchQueue.main.async { // show polyline
                    let path = GMSPath(fromEncodedPath: points)
                    self.rectangle.map = nil
                    self.rectangle = GMSPolyline(path: path)
                    self.rectangle.strokeWidth = 4
                    self.rectangle.strokeColor = UIColor.blue
                    self.rectangle.map = mapView
                }
            }
        } catch let error as JSONError {
            print(error.rawValue)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }).resume()
}
