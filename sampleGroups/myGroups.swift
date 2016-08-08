//
//  myGroups.swift
//  sampleGroups
//
//  Created by Dhawal Majithia on 04/08/16.
//  Copyright © 2016 Dhawal Majithia. All rights reserved.
//

import UIKit
import Firebase

class myGroupsVC : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var numBut: UIButton!
    @IBOutlet weak var groupsTableView: UITableView!
    
    var ref = FIRDatabase.database().reference()
    var groupIDs = []
    var groupData = [Dictionary<String, AnyObject>]()
    var groupID = ""
    var groupName = ""
    var memNum = 0
    
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = false
        self.groupsTableView.delegate = self
        self.groupsTableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        self.loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadData()
        //self.groupsTableView.reloadData()
    }
    
    func updateGroupData(gData: Dictionary<String, AnyObject>)
    {
        self.groupData.append(gData)
    }
    
    func updateGroupIDs(gIDs: [String])
    {
        self.groupIDs = gIDs
    }
    
    func loadData(){
        ref.child("/memberships/\((FIRAuth.auth()?.currentUser?.uid)!)/").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get groups
            //NSLog("\(snapshot)")
            let num = snapshot.childrenCount
            if(num > 0)
            {
                let values = (snapshot.value as? Dictionary<String, String>)!
                self.groupIDs = [String](values.values)
                for gID in self.groupIDs
                {
                    self.ref.child("groups").child(gID as! String).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        // Get user value
                        NSLog("\(snapshot)")
                        let gData = snapshot.value as! Dictionary<String, AnyObject>
                        //self.members.append(username)
                        self.updateGroupData(gData)
                        // ...
                    }) { (error) in
                        print(error.localizedDescription)
                    } // error handling
                    
                } //for

            } //if
                        //self.members = userNames
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        self.numBut.setTitle("\(self.groupIDs.count) Groups", forState: UIControlState.Normal)
        self.groupsTableView.reloadData()
        (UIApplication.sharedApplication().delegate as! AppDelegate).updateMemberships()
        
    } // loadData()
    
    
    // table view delegate and data source methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupIDs.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.groupID = self.groupIDs[indexPath.item] as! String
        self.groupName = self.groupData[indexPath.item]["name"]! as! String
        self.memNum = self.groupData[indexPath.item]["members"] as! Int
        self.performSegueWithIdentifier("myGroupDetail", sender: self)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell")
        cell?.textLabel?.text = groupData[indexPath.item]["name"] as? String
        let num = groupData[indexPath.item]["members"]! as! Int
        cell?.detailTextLabel?.text = "\(num)"
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "myGroupDetail"){
            if let dVC = segue.destinationViewController as? groupDetailVC{
                dVC.groupID = self.groupID
                dVC.groupName = self.groupName
                dVC.memNum = self.memNum
            }
        }
    }
}
