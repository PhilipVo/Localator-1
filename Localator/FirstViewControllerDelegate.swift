import UIKit

protocol FirstViewControllerDelegate: class {
    
    func firstViewControllerDelegate(controller: UIViewController, friendJoined friend: Friend)
    
    func firstViewControllerDelegate(controller: UIViewController, positionUpdated person: NSDictionary)
}