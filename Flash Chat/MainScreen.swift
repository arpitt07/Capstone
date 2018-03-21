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
import BlueCapKit
import CoreBluetooth

class MainScreen: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    //Data
    var centralManager : CBCentralManager!
    var RSSIs = NSNumber()
    var data = NSMutableData()
    var writeData: String = ""
    var peripherals: [CBPeripheral] = []
    var characteristicValue = [CBUUID: NSData]()
    var timer2 = Timer()
    var characteristics = [String : CBCharacteristic]()
    
    var counter : String = ""
    var timer : Timer!
    var clockTimer : Timer!
    var const = 0
    var arr = ""
    var lines  =  [String]()
    var lines2  =  [String]()
    var minutes : Int =  0
    var seconds : Int = 0
    var fractions : Int = 0
    var clocktext : String = ""
    var chartView: LineChart!

    var txCharacteristic : CBCharacteristic?
    var rxCharacteristic : CBCharacteristic?
    var blePeripheral : CBPeripheral?
    var characteristicASCIIValue = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*Our key player in this app will be our CBCentralManager. CBCentralManager objects are used to manage discovered or connected remote peripheral devices (represented by CBPeripheral objects), including scanning for, discovering, and connecting to advertising peripherals.
         */
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @objc func updateEntry() {
            arr.append(counter +  "-")
            print(counter)
            print(arr)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            // We will just handle it the easy way here: if Bluetooth is on, proceed...start scan!
            print("Bluetooth Enabled")
            startScan()
            
        } else {
            //If Bluetooth is off, display a UI alert message saying "Bluetooth is not enable" and "Make sure that your bluetooth is turned on"
            print("Bluetooth Disabled- Make sure your Bluetooth is turned on")
            
            let alertVC = UIAlertController(title: "Bluetooth is not enabled", message: "Make sure that your bluetooth is turned on", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        blePeripheral = peripheral
        self.peripherals.append(peripheral)
        self.RSSIs = RSSI
        peripheral.delegate = self
        if blePeripheral == nil {
            print("Found new pheripheral devices with services")
            print("Peripheral name: \(String(describing: peripheral.name))")
            print("**********************************")
            print ("Advertisement Data : \(advertisementData)")
        }
    }
    //-Connection
    func connectToDevice () {
        centralManager?.connect(blePeripheral!, options: nil)
    }
    
    /*
     Invoked when a connection is successfully created with a peripheral.
     This method is invoked when a call to connect(_:options:) is successful. You typically implement this method to set the peripheral’s delegate and to discover its services.
     */
    //-Connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("*****************************")
        print("Connection complete")
        print("Peripheral info: \(String(describing: blePeripheral))")
        
        //Stop Scan- We don't need to scan once we've connected to a peripheral. We got what we came for.
        centralManager?.stopScan()
        print("Scan Stopped")
        
        //Erase data that we might have
        data.length = 0
        
        //Discovery callback
        peripheral.delegate = self
        //Only look for services that matches transmit uuid
        //peripheral.discoverServices([BLEService_UUID])
        peripheral.discoverServices([CBUUID(string:"FFE0")])
    }
    
    /*
     Invoked when the central manager fails to create a connection with a peripheral.
     */
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("Failed to connect to peripheral")
            return
        }
    }
    
    func disconnectAllConnection() {
        centralManager.cancelPeripheralConnection(blePeripheral!)
    }
    
    /*
     Invoked when you discover the peripheral’s available services.
     This method is invoked when your app calls the discoverServices(_:) method. If the services of the peripheral are successfully discovered, you can access them through the peripheral’s services property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            
            peripheral.discoverCharacteristics(nil, for: service)
            // bleService = service
        }
        print("Discovered Services: \(services)")
    }
    
    /*
     Invoked when you discover the characteristics of a specified service.
     This method is invoked when your app calls the discoverCharacteristics(_:for:) method. If the characteristics of the specified service are successfully discovered, you can access them through the service's characteristics property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics!")
        
        for characteristic in characteristics {
            //looks for the right characteristic
            
            //if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
            if characteristic.uuid.isEqual(CBUUID(string:"FFE1")) {
                rxCharacteristic = characteristic
                
                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                // didUpdateNotificationStateForCharacteristic method will be called automatically
                peripheral.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }
            if characteristic.uuid.isEqual(CBUUID(string:"FFE1")){
                txCharacteristic = characteristic
                print("Tx Characteristic: \(characteristic.uuid)")
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    // Getting Values From Characteristic
    
    /*After you've found a characteristic of a service that you are interested in, you can read the characteristic's value by calling the peripheral "readValueForCharacteristic" method within the "didDiscoverCharacteristicsFor service" delegate.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic == rxCharacteristic {
            if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                characteristicASCIIValue = ASCIIstring
                print("Value Recieved: \((characteristicASCIIValue as String))")
                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: nil)
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        if ((characteristic.descriptors) != nil) {
            
            for x in characteristic.descriptors!{
                let descript = x as CBDescriptor!
                print("function name: DidDiscoverDescriptorForChar \(String(describing: descript?.description))")
                print("Rx Value \(String(describing: rxCharacteristic?.value))")
                print("Tx Value \(String(describing: txCharacteristic?.value))")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
            
        } else {
            print("Characteristic's value subscribed")
        }
        
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
        }
    }

    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Message sent")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("Succeeded!")
    }
    func startScan() {
        peripherals = []
        print("Now Scanning...")
        self.timer2.invalidate()
        //centralManager?.scanForPeripherals(withServices: [BLEService_UUID] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        centralManager?.scanForPeripherals(withServices: [] , options: nil)
        Timer.scheduledTimer(timeInterval: 17, target: self, selector: #selector(self.cancelScan), userInfo: nil, repeats: false)
    }
    
    @objc func cancelScan() {
        self.centralManager?.stopScan()
        print("Scan Stopped")
        print("Number of Peripherals Found: \(peripherals.count)")
        print(peripherals)
        for i in self.peripherals{
            print("device: " + i.identifier.uuidString)
            if ((i.name) == "BT05"){
                print(i.name as! String)
                blePeripheral = i
                connectToDevice()
            }
        }
    }
    
    @IBOutlet weak var clock: UILabel!
    
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
                var overlay = [(Double,Double)]()
                
                for v in self.lines2{
                    let newdouble = Double(v)
                    overlay.append((timeCount,newdouble!))
                    //dataPoints.append(newdouble!)
                    timeCount = timeCount + 1.0
                }
                self.graphoverlay(overlay: overlay)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
    
    func graphoverlay(overlay: [(Double,Double)]) -> Void {
        let chartConfig = ChartConfigXY(xAxisConfig: ChartAxisConfig(from:0, to:500, by:50), yAxisConfig: ChartAxisConfig(from:-1, to: 100, by: 15))
        let frame = CGRect(x:0, y:500, width: self.view.frame.width, height:225)
        let chart = LineChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "X axis",
            yTitle: "Y axis",
            lines: [(chartPoints: (overlay), color: UIColor.green)]
        )
        self.view.addSubview(chart.view)
        self.chartView = chart
    }
}
