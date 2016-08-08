//
//  homeVC.swift
//  sampleGroups
//
//  Created by Dhawal Majithia on 04/08/16.
//  Copyright © 2016 Dhawal Majithia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class homeVC : ViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var groupsTableView: UITableView!
    var ref = FIRDatabase.database().reference()
    var groupIDs = []
    var groupData = []
    var groupID = ""
    var groupName = ""
    var memNum = 0
    
    override func viewDidLoad() {
        groupsTableView.dataSource = self
        groupsTableView.delegate = self
        self.updateUserName()
        self.loadData()
        self.navigationController?.navigationBarHidden = true
    }
    
    func updateUserName(){
        let userObj = FIRAuth.auth()?.currentUser
        let uid = (userObj?.uid)! as String
        self.ref.child("usernames/\(uid)/").setValue(userObj?.displayName)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadData()
        self.navigationController?.navigationBarHidden = true
        self.groupsTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadData()
        self.groupsTableView.reloadData()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.updateMemberships()
    }
    
    func loadData()
    {
        ref.child("/groups/").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get groups
            //NSLog("\(snapshot)")
            let num = snapshot.childrenCount
            if(num > 0)
            {
                let values = (snapshot.value as? Dictionary<String, Dictionary<String, AnyObject>>)!
                self.groupIDs = [String](values.keys)
                self.groupData = [Dictionary<String, AnyObject>](values.values)
                //NSLog("\(values)")
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // table view delegate and datasource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupIDs.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.groupID = groupIDs[indexPath.item] as! String
        self.groupName = self.groupData[indexPath.item]["name"] as! String
        self.memNum = self.groupData[indexPath.item]["members"] as! Int
        self.performSegueWithIdentifier("groupDetail", sender: self)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell")
        let num = groupData[indexPath.item]["members"] as! Int
        let name = groupData[indexPath.item]["name"] as! String
        cell?.detailTextLabel?.text = "\(num)"
        cell?.textLabel?.text = "\(name)"
        return cell!
    }
    
    // prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "groupDetail")
        {
            if let destinationVC = segue.destinationViewController as? groupDetailVC{
                destinationVC.groupID = self.groupID
                destinationVC.groupName = self.groupName
                destinationVC.memNum = self.memNum
            }
        }
    }
}
