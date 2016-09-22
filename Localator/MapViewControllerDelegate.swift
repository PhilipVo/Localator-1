import UIKit
import CoreLocation

protocol MapViewControllerDelegate: class {
    
    func mapViewControllerDelegate(controller: UIViewController, didUpdateFriends friends: [Friend])
    
    func mapViewControllerDelegate(controller: UIViewController, didUpdateLocation coordinate: CLLocationCoordinate2D)
}