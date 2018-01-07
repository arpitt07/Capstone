//
//  MainScreen.swift
//  Flash Chat
//
//  This is the main screen after logging in
//

import UIKit
import Firebase
import SwiftyTimer



class MainScreen: UIViewController {
    
    var counter : String = ""
    var timer : Timer!
    var const = 0
    var arr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @objc func updateEntry() {
        //while (const == 0) {
            arr.append(counter +  "a")
            print(counter)
            print(arr)
       // }
    }
    
    @IBOutlet weak var startPressed: UIButton!
    @IBOutlet weak var stopPressed: UIButton!
    
    @IBAction func startPressed(_ sender: AnyObject) {
        

        timer = Timer.scheduledTimer(timeInterval: 10.seconds, target: self, selector: #selector(updateEntry), userInfo: nil, repeats: true)
        
  
        
    }
    
    @IBAction func stopPressed(_ sender: AnyObject) {
        
        
        let dataDB = Database.database().reference().child("Data")
        const = 1
    
        timer.invalidate()
        
        let dataDictionary : [String:Any] = ["Time": arr , "Field1": "13.7"]
        
        print(arr)
        dataDB.childByAutoId().setValue(dataDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Message sent")
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

