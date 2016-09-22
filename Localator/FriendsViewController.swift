import UIKit
import CoreLocation

class FriendsViewController: UICollectionViewController, MapViewControllerDelegate {
    
    var friends = [Friend]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor(red: 113.0 / 255.0, green: 197.0 / 255.0, blue: 207.0 / 255.0, alpha: 1.0)
        
        if let rect = navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            collectionView?.contentInset = UIEdgeInsetsMake(y, 10, 50, 10)
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        collectionView!.collectionViewLayout = layout
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        cell.backgroundColor = UIColor.yellowColor()
        cell.nameLabel.text = friends[indexPath.row].title
        
        if let imageView = friends[indexPath.row].imageView {
            cell.backgroundView = imageView
        } else {
            cell.backgroundColor = friends[indexPath.row].color
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,withReuseIdentifier: "FriendHeader",forIndexPath: indexPath) as! FriendHeaderView
            headerView.label.text = "Active Friends"
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewImage" {
            dispatch_async(dispatch_get_main_queue(), {
                let controller = segue.destinationViewController as! ImageViewController
                
                if let imageView = controller.imageView {
                    imageView.image = (sender as? UIImageView)?.image!
                    imageView.setNeedsDisplay()
                    imageView.reloadInputViews()
                }
            })
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        if let backgroundView = cell?.backgroundView {
            performSegueWithIdentifier("viewImage", sender: backgroundView)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
    }
    
    func mapViewControllerDelegate(controller: UIViewController, didUpdateFriends friends: [Friend]) {
        self.friends = friends
        self.collectionView?.reloadData()
    }
    
    func mapViewControllerDelegate(controller: UIViewController, didUpdateLocation coordinate: CLLocationCoordinate2D) {}
}