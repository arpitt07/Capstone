//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    let remember = Database.database().reference().child("Logins")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {

        SVProgressHUD.show()
        // Log in the user
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            
            if error != nil {
                print(error!)
            }
            else {
                
                print("Log in Successful")
                
                SVProgressHUD.dismiss()
                self.store()
                self.performSegue(withIdentifier: "goToMain", sender: self)
            }
        }
        
    }
    func store(){
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        remember.setValue(["deviceID":deviceID,"username":emailTextfield.text!,"password":passwordTextfield.text!])
    }
}
