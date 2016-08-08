//
//  newGroupVC.swift
//  sampleGroups
//
//  Created by Dhawal Majithia on 04/08/16.
//  Copyright © 2016 Dhawal Majithia. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class newGroupVC : UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var textField: UITextField!
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        createGroup()
        return true
    }
    
    @IBAction func done(sender: AnyObject) {
        self.textField.resignFirstResponder()
        createGroup()
    }
    
    func createGroup() {
        
        let groupName = self.textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.init(charactersInString: " "))
        if(groupName != "")
        {
            let uid = FIRAuth.auth()!.currentUser!.uid
            let t = Int(NSDate().timeIntervalSince1970)
            let key = ref.child("groups").childByAutoId().key
            let gPost = ["members" : 1, "name" : groupName!]
            let mPost = ["\(t)" : uid]
            //let MPost = ["\(t)" : key]
            let childUpdates = ["/groups/\(key)/" : gPost, "/members/\(key)/" : mPost]
            self.ref.updateChildValues(childUpdates)
            self.ref.child("memberships/\(uid)/\(t)/").setValue(key)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}