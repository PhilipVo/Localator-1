import UIKit

class TabBarController: UITabBarController {
    
    var code: String?
    @IBOutlet weak var codeLabel: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let unwrappedCode = code {
            codeLabel.title = "Access Code: " + unwrappedCode
        }
    }
    
    @IBAction func onLeave(sender: UIBarButtonItem) {
//        Handle leave.
        print("TODO: TabBarController -> Handle Leave")
        dismissViewControllerAnimated(true, completion: nil)
    }
}