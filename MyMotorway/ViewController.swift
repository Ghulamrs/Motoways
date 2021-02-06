//
//  ViewController.swift
//  MyMotorway
//
//  Created by Home on 11/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController, GMSMapViewDelegate {
    var mapView: GMSMapView!
//    var Hafizabad: CLLocation = CLLocation(latitude: 31.90, longitude: 73.61)
    let Islamabad: CLLocation = CLLocation(latitude: 33.6938, longitude: 73.0652) // Zero Point
//    var Islamabad: CLLocation = CLLocation(latitude: 33.658824, longitude: 72.998717) // Peshawar Morr Interchange
    let myUrl = "http://3.92.12.25/"
    var loxi: LocationEx? // ground data location set
    var sending: Bool = false
    var button: UIButton?
    let pid: UInt = 10

    var train: [CLLocationCoordinate2D] = []
    var marker: GMSMarker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a GMSCameraPosition that tells the map to display the
        let camera = GMSCameraPosition.camera(withLatitude: Islamabad.coordinate.latitude, longitude: Islamabad.coordinate.longitude, zoom: 5.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.mapType = .normal
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        self.view = mapView

        let pakolor = UIColor(red:0, green:0.6, blue:0, alpha:1)
        let pakland = JsonFileLayer(mvc: self, color1: pakolor, color2: pakolor)
        pakland.loadMap(name: "pakistan1.js")
        pakland.drawCircle(latC: Islamabad.coordinate.latitude, longC: Islamabad.coordinate.longitude, radius: 300.0, width: 5, color: .red)
        NetworkStatus()
        train.append(Islamabad.coordinate)
        DrawMotorways()
        self.marker = nil
        AddButton()
        traverse(lox: train, color: .green)
    }
    
    @objc func Test() {
        if !self.sending {
            self.sending = true
            button!.setTitle("Stop", for: UIControl.State.normal)
        }
        else {
            self.sending = false
            button!.setTitle("Send", for: UIControl.State.normal)
        }
    }
    
    func AddButton() {
        button = UIButton(type: UIButton.ButtonType.roundedRect)
        button!.frame = CGRect(x: UIScreen.main.bounds.width/4, y: 0, width: UIScreen.main.bounds.width/2, height: 50)
        button!.setTitle("Send", for: UIControl.State.normal)
        button!.tintColor = .red

        button!.frame = button!.frame.offsetBy(dx: 0, dy: UIScreen.main.bounds.height-button!.intrinsicContentSize.height-20)

        self.mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0, bottom: button!.intrinsicContentSize.height, right: 0)
        self.mapView.addSubview(button!)
        
        button!.addTarget(self, action: #selector(Test), for: .touchDown)
    }

    func DrawMotorways() {
        let greenColor = UIColor(red:0, green:0.6, blue:0, alpha:1)
        let colors: [UIColor] = [.red, .blue, .green, .purple, .black]
    
    var i=0;draw(lox: lex[i], color: colors[i%5], wide: 3, farward: true, result: &train)  // Islamabad to Lahore
            draw(lox: lox[i], color: colors[i%5], wide: 3, farward: false, result: &train) // Lahore to Pindi Bhattian
        i=2;draw(lox: lox[i], color: greenColor,  wide: 2, farward: false, result: &train) // Pindi Bhattian to Multan
        i=6;draw(lox: lox[i], color: colors[i%5], wide: 3, farward: false, result: &train) // Multan to Lahore
        i=1;draw(lox: lex[i], color: greenColor,  wide: 2, farward: true, result: &train)  // Lahore to Islamabad   - GT Road
        i=3;draw(lox: lex[i], color: colors[i%5], wide: 3, farward: false, result: &train) // Islamabad to Mansehra and back to Islamabad
            draw(lox: lex[i], color: colors[i%5], wide: 3, farward: true, result: &train)  // Islamabad to Mansehra and back to Islamabad
        i=0;draw(lox: loxs[i], color: .green,  wide: 2, farward: true, result: &train) // Ghaor Ghashti to Katlang
        draw(lox: law1, color: .green,  wide: 2, farward: true, result: &train) // Lawari tunnel
    }

    func draw(lox: [[Double]], color: UIColor, wide: Float, farward: Bool, result: inout [CLLocationCoordinate2D]) {
        let path = GMSMutablePath()
        var loc:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lox[0][0], lox[0][1])
        if farward==false {
            let last = lox.count - 1
            loc = CLLocationCoordinate2DMake(lox[last][0], lox[last][1])
        }
        result.append(loc)
        path.add(loc)
        for i in 1..<lox.count {
            if farward==true {
                loc = CLLocationCoordinate2DMake(lox[i][0], lox[i][1])
            } else {
                loc = CLLocationCoordinate2DMake(lox[lox.count-i-1][0], lox[lox.count-i-1][1])
            }
            result.append(loc)
            path.add(loc)
        }
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = color
        polyline.strokeWidth = CGFloat(wide*2+1)
        polyline.map = self.mapView
        
        let polyline2 = GMSPolyline(path: path)
        polyline2.strokeColor = UIColor.red
        polyline2.strokeWidth = CGFloat(wide+1)
        polyline2.map = self.mapView
        
        if wide > 2 {
            let polyline1 = GMSPolyline(path: path)
            polyline1.strokeColor = UIColor.green
            polyline1.strokeWidth = CGFloat(1)
            polyline1.map = self.mapView
        }
    }
    
    func showMarker(loc: CLLocationCoordinate2D, id: UInt) {
        self.marker = GMSMarker();
        self.marker.position = CLLocationCoordinate2DMake(loc.latitude, loc.longitude)
        self.marker.snippet = "saeed (" + String(id) + ")"
        self.marker.map = mapView
    }
    
    func moveMarker(loc: CLLocationCoordinate2D) {
        self.marker.position = CLLocationCoordinate2DMake(loc.latitude, loc.longitude)
        self.marker.map = mapView
    }
    
    func traverse(lox: [CLLocationCoordinate2D], color: UIColor) {
        var loc = lox[0]
        let day = Date()
        if NetStatus.status.isConnected && self.sending {
            self.sendLocation(loc: CLLocation(coordinate: loc, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: day))
        }
        self.mapView.animate(toLocation: loc)
        if(self.marker == nil) { showMarker(loc: loc, id: self.pid) }
        var i = 0
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            if i >= lox.count { return }
            loc = lox[i]
            if NetStatus.status.isConnected && self.sending {
                self.sendLocation(loc: CLLocation(coordinate: loc, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: day))
            }
            self.moveMarker(loc: loc)
            self.mapView.animate(toLocation: loc)
            i = i + 1
        })
    }
    
    func sendLocation(loc: CLLocation) {
        let url = URL(string: myUrl + "setLocationii.php")
        var request = URLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        request.httpMethod = "POST"
           
        let postString = String("pid=") + String(pid) + String("&par=") +
            String(loc.coordinate.latitude) + "," +
            String(loc.coordinate.longitude) + "," +
            String(loc.altitude) + "," +
            String(loc.speed) + ",1"

        request.httpBody = postString.data(using: .utf8, allowLossyConversion: true)
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
    
            do {
                if data == nil { return }
                let decoder = JSONDecoder()
                self.loxi = try decoder.decode(LocationEx.self, from: data!)
                DispatchQueue.main.sync {
                }
            }
            catch let parsingError {
                print("Error: ", parsingError)
            }
        }).resume()
    }

    func NetworkStatus() {
        NetStatus.status.didStartMonitoringHandler = {
        }
        NetStatus.status.didStopMonitoringHandler = {
        }
        NetStatus.status.netStatusChangeHandler = {
            DispatchQueue.main.async {
                if NetStatus.status.isConnected {
                    self.button!.tintColor = .red
                }
                else {
                    self.button!.tintColor = .gray
                }
            }
        }
        NetStatus.status.startMonitoring()
    }
}
