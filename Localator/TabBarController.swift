import UIKit

class TabBarController: UITabBarController {
    
    var code: String?

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