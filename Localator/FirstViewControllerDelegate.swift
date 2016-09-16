import Foundation
import UIKit

protocol FirstViewControllerDelegate: class {
    
    func firstViewControllerDelegate(controller: UIViewController, didFinishReceivingUpdate person: NSDictionary)
}