//
//  MainMapVC.swift
//  SF Aware
//
//  Created by Akanki on 1/19/16.
//  Copyright © 2016 Akanki. All rights reserved.
//

import UIKit
import MapKit

enum JSONError : String, ErrorType{
    case NoData = "Data not found from Url."
    case ConversionFailed = "Data Conversion from JSON failed."
}

class MainMapVC: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var sfMapView: MKMapView!
    
    let initialLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
    let regionRadius: CLLocationDistance = 9500
    
    var resultArray = NSArray()
    var noOfCrimeInDistrict = [String : Int]()
    var districtLocation = [String : CLLocationCoordinate2D]()
    var sortedDistrictAscending = NSArray()
    var sortedDistrictColor = [String : UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Displaying Map.
        centerMapOnLocation(initialLocation)
        self.sfMapView.delegate = self
        
        self.dataFromUrl("https://data.sfgov.org/resource/ritf-b9ki.json", completion: { () -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.parsingAndSortingCrimeData(self.resultArray)
                
                //Creating and Adding Markers to Map.
                for (district, location) in self.districtLocation {
                    let numberOfCrime =  "# of Crimes: " + String(self.noOfCrimeInDistrict[district]!)
                    let districtAnnotation = DistrictAnnotation(title: district, coordinate: location, subtitle: numberOfCrime)
                    self.sfMapView.addAnnotation(districtAnnotation)
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Map loaction on initial load.
    func centerMapOnLocation(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2)
        sfMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func dataFromUrl(dataUrlString: String, completion: (Void) -> Void) {
        let dataURl = NSURL(string: dataUrlString)
        let task = NSURLSession.sharedSession().dataTaskWithURL(dataURl!) { (data, response, error) -> Void in
            do{
                guard let datafromJson = data else{
                    throw JSONError.NoData
                }
                guard let arrayFromData = try NSJSONSerialization.JSONObjectWithData(datafromJson, options: []) as? NSArray else{
                    throw JSONError.ConversionFailed
                }
                self.resultArray = arrayFromData
                completion()
            }
            catch let error as JSONError{
                print(error.rawValue)
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    
    
    func parsingAndSortingCrimeData(crimeDataArray: NSArray){
        
        //Extracting required information from the data.
        for crime in crimeDataArray{
            if let district = crime["pddistrict"] as? String{
                if (noOfCrimeInDistrict[district] != nil) {
                    noOfCrimeInDistrict[district] = noOfCrimeInDistrict[district]! + 1
                }else {
                    noOfCrimeInDistrict[district] = 1
                    let latitude = Double((crime["y"] as? String)!)
                    let longitude = Double((crime["x"] as? String)!)
                    districtLocation[district] = CLLocationCoordinate2DMake(latitude!, longitude!)
                }
            }
        }
        
        //Sorting District according to the number of crimes.
        sortedDistrictAscending = noOfCrimeInDistrict.keys.sort { (key1, key2) -> Bool in
            return noOfCrimeInDistrict[key1] < noOfCrimeInDistrict[key2]
        }
        
        //Assigning color scheme.
        for var i = 0; i < sortedDistrictAscending.count; i++ {
            var color = UIColor.greenColor()
            switch i {
            case 3:
                color = UIColor.yellowColor()
            case 4:
                color = UIColor.orangeColor()
            case 5:
                color = UIColor.purpleColor()
            case 6:
                color = UIColor.blueColor()
            case 7:
                color = UIColor.brownColor()
            case 8:
                color = UIColor.grayColor()
            case 9:
                color = UIColor.blackColor()
                
            default: break
            }
            sortedDistrictColor[sortedDistrictAscending[i] as! String] = color
        }
    }
    
//MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        //Creating Pin view for Markers and assigning colors.
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinTintColor = sortedDistrictColor[annotation.title!!]
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}

