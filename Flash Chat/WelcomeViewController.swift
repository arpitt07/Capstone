//
//  WelcomeViewController.swift
//  Flash Chat
//
//  This is the welcome view controller - the first thign the user sees
//

import UIKit
import Firebase



class WelcomeViewController: UIViewController {

   
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func autoLogin(){let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let remember = Database.database().reference().child("Logins")
        print(deviceID)
        remember.child("deviceID").observe(DataEventType.value, with: {snapshot in
            print(snapshot)
        })
        remember.child("username").observe(DataEventType.value, with: {snapshot in
           print(snapshot)
            })
            remember.child("password").observe(DataEventType.value, with: {snapshot in
                print(snapshot)
            })
        }
}
