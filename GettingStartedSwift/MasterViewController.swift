//
//  MasterViewController.swift
//  GettingStartedSwift
//
//  Created by Dylan McKee on 18/11/2015.
//  Copyright © 2015 Moltin. All rights reserved.
//

import UIKit
import Moltin

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Moltin"
        
        let checkoutButton = UIBarButtonItem(title: "Checkout!", style: UIBarButtonItemStyle.Plain, target: self, action: "checkout")
        self.navigationItem.rightBarButtonItem = checkoutButton
        
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        Moltin.sharedInstance().setPublicId("umRG34nxZVGIuCSPfYf8biBSvtABgTR8GMUtflyE")
        
        Moltin.sharedInstance().product.listingWithParameters(nil, success: { (response) -> Void in
            // The array of products is at the "result" key
            self.objects = response["result"]! as! [AnyObject]
            
            // Reload the table view that'll be used to display the products...
            self.tableView.reloadData()
            
        }, failure: { (response, error) -> Void in
            print("Something went wrong! \(error)")
        })
        
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDictionary
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row] as! [String: AnyObject]
        
        cell.textLabel!.text = object["title"] as? String
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func checkout() {
        // Perform the checkout (with hardcoded user data for tutorial sake)
        // Define the order parameters (hardcoded in this example)
         // You'll likely always want to hardcode 'gateway' so that it matches your store's payment gateway slug too.
        let orderParameters = [
            "customer": ["first_name": "Jon",
                "last_name":  "Doe",
                "email":      "jon.doe@gmail.com"],
            "shipping": "free-shipping",
            "gateway": "dummy",
            "bill_to": ["first_name": "Jon",
                "last_name":  "Doe",
                "address_1":  "123 Sunny Street",
                "address_2":  "Sunnycreek",
                "city":       "Sunnyvale",
                "county":     "California",
                "country":    "US",
                "postcode":   "CA94040",
                "phone":     "6507123124"],
            "ship_to": "bill_to"
            ] as [NSObject: AnyObject]
        
        Moltin.sharedInstance().cart.orderWithParameters(orderParameters, success: { (response) -> Void in
            // Checkout order succeeded! Let's go on to payment too...
            print("Order succeeded: \(response)")
            
            // Extract the Order ID so that it can be used in payment too...
            let orderId = (response as NSDictionary).valueForKeyPath("result.id") as! String
            
            // These payment parameters would contain the card details entered by the user in the checkout UI flow...
            let paymentParameters = ["data": [
                "number":       "4242424242424242",
                "expiry_month": "02",
                "expiry_year":  "2017",
                "cvv":          "123"
                ]] as [NSObject: AnyObject]
            
            Moltin.sharedInstance().checkout.paymentWithMethod("purchase", order: orderId, parameters: paymentParameters, success: { (response) -> Void in
                // Payment successful...
                print("Payment successful: \(response)")
                
                // Payment success too!
                // We'll show a UIAlertController to tell the user they're done.
                let alert = UIAlertController(title: "Order complete!", message: "Order complete and your payment has been processed - thanks for shopping with us!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                // In a production store app, this would be a great time to show a receipt...

                
                }, failure: { (response, error) -> Void in
                    // Payment error
                    print("Payment error: \(error)")
            })
            
            }, failure: { (response, error) -> Void in
                // Order failed
                print("Order error: \(error)")
        })
    }


}

