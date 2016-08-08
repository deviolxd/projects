//
//  ViewController.swift
//  sampleGroups
//
//  Created by Dhawal Majithia on 03/08/16.
//  Copyright © 2016 Dhawal Majithia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import Firebase
import FirebaseFacebookAuthUI

class ViewController: UIViewController, FIRAuthUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationItem.hidesBackButton = true
        let authUI = FIRAuthUI.authUI()
        authUI?.delegate = self
        //let facebookAuthUI = FIRFacebookAuthUI(appID: "1069402449811920")
        //authUI?.signInProviders = [facebookAuthUI!]
        let authViewController = authUI!.authViewController()
        self.navigationController?.presentViewController(authViewController, animated: true, completion: {})
        //self.performSegueWithIdentifier("home", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func application(app: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String
        return FIRAuthUI.authUI()?.handleOpenURL(url, sourceApplication: sourceApplication ?? "") ?? false
    }
    
    func authUI(authUI: FIRAuthUI, didSignInWithUser user: FIRUser?, error: NSError?) {
        NSLog("Hola!")
        self.dismissViewControllerAnimated(false, completion: {})
        self.performSegueWithIdentifier("home", sender: self)
    }
    
}

