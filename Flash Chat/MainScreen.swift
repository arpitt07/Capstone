//
//  MainScreen.swift
//  Flash Chat
//
//  This is the main screen after logging in
//

import UIKit
import Firebase
import SwiftyTimer
import BluetoothKit

class MainScreen: UIViewController {
    
    var counter : String = ""
    var timer : Timer!
    var clockTimer : Timer!
    var const = 0
    var arr = ""
    //var text2 : String = ""
    var lines  =  [String]()
    var minutes : Int =  0
    var seconds : Int = 0
    var fractions : Int = 0
    var clocktext : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @objc func updateEntry() {
        //while (const == 0) {
            arr.append(counter +  "-")
            print(counter)
            print(arr)
       // }
    }
    
    @IBOutlet weak var clock: UILabel!
    
    @objc func updateClock () {
        
        fractions += 1
        if fractions == 100 {
            
            seconds += 1
            fractions = 0
        }
        
        if seconds == 60 {
            
            minutes += 1
            seconds = 0
        }
        
        let fractionString = fractions > 9 ? "\(fractions)" : "0\(fractions)"
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        
        clocktext = "\(minutesString):\(secondsString):\(fractionString)"
        clock.text = clocktext
    }
    
    
    @IBOutlet weak var startPressed: UIButton!
    @IBOutlet weak var stopPressed: UIButton!
    
    @IBAction func startPressed(_ sender: AnyObject) {
        
        clockTimer = Timer.scheduledTimer(timeInterval: 0.01.seconds, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        
        timer = Timer.scheduledTimer(timeInterval: 10.seconds, target: self, selector: #selector(updateEntry), userInfo: nil, repeats: true)
        
        let file = "file.txt"
        
        if let dir = FileManager.default.urls(for: .documentDirectory , in: .userDomainMask).first {
            
            print()
            let fileURL = dir.appendingPathComponent(file)
            print(fileURL)
            
            do {
                let text2 = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
                lines = text2.components(separatedBy: NSCharacterSet.newlines)
                
            }
            catch {/* error handling here */}
        }
        
        
  
        
    }
    
    @IBAction func stopPressed(_ sender: AnyObject) {
        
        
        let dataDB = Database.database().reference().child("Data")
        const = 1
    
        timer.invalidate()
        clockTimer.invalidate()
        
        let dataDictionary : [String:Any] = ["Time": clocktext , "Field1": lines]
        
        print(arr)
        dataDB.childByAutoId().setValue(dataDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Message sent")
                print(self.lines)
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

