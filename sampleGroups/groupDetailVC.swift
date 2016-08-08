//
//  groupDetailVC.swift
//  sampleGroups
//
//  Created by Dhawal Majithia on 04/08/16.
//  Copyright © 2016 Dhawal Majithia. All rights reserved.
//

import UIKit
import Firebase

class groupDetailVC : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var joinBut: UIButton!
    @IBOutlet weak var numBut: UIButton!
    @IBOutlet weak var memberTableView: UITableView!
    var groupName = "group name"
    var groupID = ""
    var members = [String]()
    var ref = FIRDatabase.database().reference()
    var isMember = false
    var memNum = 0
    
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = false
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self
    }
    
    @IBAction func joinLeaveToggle(sender: AnyObject) {
        if(self.isMember){
            self.setMembershipStatus(false)
            self.leaveGroup()
            self.joinBut.setTitle("Join Group", forState: UIControlState.Normal)
        } // leave the group and update button label
        else{
            self.setMembershipStatus(true)
            self.joinGroup()
            self.joinBut.setTitle("Leave Group", forState: UIControlState.Normal)
        } // join the group and update button label
        self.loadData()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func joinGroup()
    {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let t = Int(NSDate().timeIntervalSince1970)
        let key = self.groupID
        let num = self.memNum + 1
        
        self.ref.child("groups/\(key)/members/").setValue(num)
        self.ref.child("memberships/\(uid)/\(t)/").setValue(key)
        self.ref.child("members/\(key)/\(t)/").setValue(uid)
        self.loadData()
    } // joinGroup()
    
    func leaveGroup()
    {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let key = self.groupID
        let num = self.memNum - 1
        var t = ""
        
        for pair in  (UIApplication.sharedApplication().delegate as! AppDelegate).memberships
        {
            if(pair.1 == key)
            {
                t = pair.0
                break
            }
        }
        
        self.ref.child("groups/\(key)/members/").setValue(num)
        self.ref.child("memberships/\(uid)/\(t)/").setValue(nil)
        self.ref.child("members/\(key)/\(t)/").setValue(nil)
    } // leaveGroup
    
    override func viewWillAppear(animated: Bool) {
        self.loadData()
        self.navigationItem.title = self.groupName
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadData()
    }
    
    func updateMembers(mem: String){
        self.members.append(mem)
    }
    
    func setMembershipStatus(status: Bool)
    {
        self.isMember = status
    }
    
    func checkMembership(){
        if(self.members.contains((FIRAuth.auth()?.currentUser?.displayName)!))
        {
            self.setMembershipStatus(true)
        }
        else{
            self.setMembershipStatus(false)
        }
    }
    
    func updateView(){
        
        
        if(self.isMember){
            self.joinBut.setTitle("Leave Group", forState: UIControlState.Normal)
        }
        else{
            self.joinBut.setTitle("Join Group", forState: UIControlState.Normal)
        }
        //self.numBut.titleLabel?.text = "\(members.count) members"
        self.numBut.setTitle("\(members.count) members", forState: UIControlState.Normal)
    }
    
    func loadData(){
        //self.members = [String]()
        self.setMembershipStatus(false)
        ref.child("/members/\(groupID)/").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get groups
            //NSLog("\(snapshot)")
            let num = snapshot.childrenCount
            if(num > 0)
            {
                let values = (snapshot.value as? Dictionary<String, String>)!
                let memberIDs = [String](values.values)
                if memberIDs.contains((FIRAuth.auth()?.currentUser?.uid)!){
                    self.setMembershipStatus(true)
                }
                for userID in memberIDs
                {
                    self.ref.child("usernames").child(userID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        // Get user value
                        //NSLog("\(snapshot)")
                        let username = snapshot.value as! String
                        //self.members.append(username)
                        self.updateMembers(username)
                        // ...
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                }

            }
                        //self.members = userNames
        // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        self.checkMembership()
        self.updateView()
        self.memberTableView.reloadData()
        
    } // load member names
    
    //table view delegate and datasource methods
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memberCell")
        if(indexPath.item >= self.memNum)
        {
            return cell!
        }
        cell?.textLabel?.text = members[indexPath.item]
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.members.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
