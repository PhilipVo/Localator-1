import UIKit

protocol FirstViewControllerDelegate: class {
    
    func firstViewControllerDelegate(controller: UIViewController, friendJoined friend: Friend)
}