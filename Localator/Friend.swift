//
//  Friend.swift
//  MapKitTutorial
//
//  Created by Philip on 9/15/16.
//  Copyright © 2016 Philip Vo. All rights reserved.
//

import MapKit
import Contacts

class Friend: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let location: CLLocation
    let coordinate: CLLocationCoordinate2D
    let color: String
    
    var subtitle: String? {
        return locationName
    }
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.coordinate = coordinate
        self.color = "Normal"
        
        super.init()
    }
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): self.subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
    func pinColor() -> UIColor  {
        switch color {
        case "Close":
            return UIColor.orangeColor()
        case "Far":
            return UIColor.blueColor()
        default:
            return UIColor.redColor()
        }
    }
}
