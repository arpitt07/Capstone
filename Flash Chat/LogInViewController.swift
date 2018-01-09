//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {
    var posts:[String] = []
    var autoLogin: Bool = false
    
        let remember = Database.database().reference().child("Logins")
    
    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {

        SVProgressHUD.show()
        // Log in the user

        if(autoLogin){
            print(self.posts)
        Auth.auth().signIn(withEmail: self.posts[1], password: self.posts[0]) { (user, error) in
            
            if error != nil {
                print(error!)
            }
            else {
                
                print("Auto login")
                
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToMain", sender: self)
            }
        }
        }
        else{
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
    }
    func store(){
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        remember.child(deviceID).setValue(["username":emailTextfield.text!,"password":passwordTextfield.text!])
        
        remember.child(deviceID).observe(.value, with: {snapshot in
        })
        remember.child(deviceID).child("username").observe(.value, with: {snapshot in
            print(snapshot)
            self.posts.append(snapshot.value as! String)
        })
        remember.child(deviceID).child("password").observe(.value, with: {snapshot in
            print(snapshot)
            self.posts.append(snapshot.value as! String)
        })
        self.autoLogin = true
    }
    func checkLogin(){
        let deviceID = UIDevice.current.identifierForVendor!.uuidString

        remember.child(deviceID).observe(.value, with: {snapshot in
        })
        remember.child(deviceID).child("username").observe(.value, with: {snapshot in
            if((snapshot.value as! String) != ""){
                self.autoLogin = true
                self.posts.append(snapshot.value as! String)}})
            
        remember.child(deviceID).child("password").observe(.value, with: {snapshot in
            if((snapshot.value as! String) != ""){
            self.posts.append(snapshot.value as! String)}
        })
    }
}
