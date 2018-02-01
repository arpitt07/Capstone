//: Playground - noun: a place where people can play

import UIKit

var lines  =  [String]()

let file = "file.txt"

if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
    
    print()
    let fileURL = dir.appendingPathComponent(file)
    
    do {
        
        let text2 = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
        lines = text2.components(separatedBy: NSCharacterSet.newlines)
        
    }
    catch {/* error handling here */}
}

print(lines)

