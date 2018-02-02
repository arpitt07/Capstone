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
import SwiftCharts

class MainScreen: UIViewController {
    
    var counter : String = ""
    var timer : Timer!
    var clockTimer : Timer!
    var const = 0
    var arr = ""
    //var text2 : String = ""
    var lines  =  [String]()
    var lines2  =  [String]()
    var minutes : Int =  0
    var seconds : Int = 0
    var fractions : Int = 0
    var clocktext : String = ""
    var chartView: LineChart!
    
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
                lines = text2.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                
            }
            catch {/* error handling here */}
        }
        
        lines2 = lines.filter({$0 != ""})
        
  
        
    }
    
    @IBAction func stopPressed(_ sender: AnyObject) {
        
        
        let dataDB = Database.database().reference().child("Data")
        const = 1
    
        timer.invalidate()
        clockTimer.invalidate()
        
        let dataDictionary : [String:Any] = ["Time": clocktext , "Field1": lines2]
        
        print(arr)
        dataDB.childByAutoId().setValue(dataDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Message sent")
                print(self.lines2)
                
                //graph
                var timeCount = 1.0
                var dataPoints = [(Double,Double)]()
                
                for v in self.lines2{
                    let newdouble = Double(v)
                    dataPoints.append((timeCount,newdouble!))
                    //dataPoints.append(newdouble!)
                    timeCount = timeCount + 1.0
                }
                
                let chartConfig = ChartConfigXY(xAxisConfig: ChartAxisConfig(from:0, to:500, by:50), yAxisConfig: ChartAxisConfig(from:-1, to: 100, by: 15))
                let frame = CGRect(x:0, y:500, width: self.view.frame.width, height:225)
                let chart = LineChart(
                    frame: frame,
                    chartConfig: chartConfig,
                    xTitle: "X axis",
                    yTitle: "Y axis",
                    lines: [
                        (chartPoints: (dataPoints), color: UIColor.green)]
                )
                self.view.addSubview(chart.view)
                self.chartView = chart

            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

