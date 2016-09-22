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

    let socketId: String?
    let title: String?
    let locationName: String
    let location: CLLocation
    var coordinate: CLLocationCoordinate2D
    var color: UIColor
    var overlay: MKCircle?
    var imageView: UIImageView?
    
    var subtitle: String? {
        return locationName
    }
    
    init(socketId: String, title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.socketId = socketId
        self.title = title
        self.locationName = locationName
        self.location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.coordinate = coordinate
        self.color = MapViewController.generateRandomColor()
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
        return color
    }

    func clone() -> Friend {
        let clone = Friend(socketId: socketId!, title: title!, locationName: locationName, coordinate: coordinate)
        clone.color = color
        return clone
    }
}
