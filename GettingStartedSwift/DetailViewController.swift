//
//  DetailViewController.swift
//  GettingStartedSwift
//
//  Created by Dylan McKee on 18/11/2015.
//  Copyright © 2015 Moltin. All rights reserved.
//

import UIKit
import Moltin

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem as? NSDictionary {
            // Set the item title from the detailItem dictionary's 'title' key
            titleLabel.text = detail["string"] as? String
            
            // Set the formatted price with tax by looking at the key path in the detailItem dictionary
            priceLabel.text = detail.valueForKeyPath("price.data.formatted.with_tax") as? String
            
            // Set the item description from the detailItem dictionary's 'description' key
            descriptionLabel.text = detail["description"] as? String
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addToCart(sender: AnyObject) {
        // Get the current product's ID string from the detailItem product info dictionary...
        let productId: String = self.detailItem?.valueForKey("id") as! String
        
        Moltin.sharedInstance().cart.insertItemWithId(productId, quantity: 1, andModifiersOrNil: nil, success: { (response) -> Void in
                // Added to cart!
                // We'll show a UIAlertController to tell the user what we've done...
                let alert = UIAlertController(title: "Added to cart!", message: "Added item to cart!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            
            }, failure: { (response, error) -> Void in
                print("Something went wrong! \(error)")
        })
        
    }

    

}

