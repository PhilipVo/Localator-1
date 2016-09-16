import Foundation
import CoreLocation
import UIKit

protocol MapViewControllerDelegate: class {
    
    func mapViewControllerDelegate(controller: UIViewController, coordinate: CLLocationCoordinate2D)
}