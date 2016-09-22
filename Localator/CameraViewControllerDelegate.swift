import UIKit

protocol CameraViewControllerDelegate: class {
    
    func cameraViewControllerDelegate(controller: UIViewController, didTakePhoto base64: String)
}