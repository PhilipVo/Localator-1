import UIKit

protocol MapViewControllerDelegate: class {
    
    func mapViewControllerDelegate(controller: UIViewController, didUpdateFriends friends: [Friend])
}