//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    var usr:String = ""
    var pwd:String = ""
    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        //new user on our Firebase database
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            
            if error != nil {
                print(error!)
            }
            else {
                
                let remember = Database.database().reference().child("Logins")
                self.usr = self.emailTextfield.text!.replacingOccurrences(of: ".", with: ",")
                remember.child(self.usr).setValue(["password":self.passwordTextfield.text!,"userType":"patient"])
                
                print("Registered Successfully")
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToMain", sender: self)
            }
        }
        
        

        
        
    } 
    
    
}
