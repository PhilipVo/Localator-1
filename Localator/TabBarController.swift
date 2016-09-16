import UIKit

class TabBarController: UITabBarController {
    
    var code: String?
    
    
    var mapDelegate: MapViewControllerDelegate?
    var firstDelegate: FirstViewControllerDelegate?

    @IBOutlet weak var codeLabel: UINavigationItem!
    
    @IBAction func onCancelButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let unwrappedCode = code {
            codeLabel.title = "Map Access Code: \(unwrappedCode)"
        }
    }
}