//
//  main.swift
//  SSIDChecker - Jamf 400 Challange 1
//
//  Created by Thomas Holbrook on 07/12/2017.
//  Copyright © 2017 Thomas Holbrook. All rights reserved.
//

import Cocoa
import CoreWLAN
import Foundation

// Method to write our Logs - Needs checking, seems messy!

func tjhLogger(logEntry:String) {
        // Where do we want to log to?
        let path = "/Library/Logs/J24/rogue-wifi.log"
        // That should probably be a URL as well.
        let logurl = NSURL(string: path)
        // Setup our entry with a date stamp and new line.
        let string = "\(NSDate()) - " + logEntry + " \n"
        // We need UTF8 character encoding for our entry, get that from String.
        let data = string.data(using: .utf8, allowLossyConversion: false)!
        // Check we have a log file to write to, if not we should create one TODO! Its in package so ok for now.
        if FileManager.default.fileExists(atPath: path) {
            //Debug Line
            print("File Exists carry on")
            //We use a try so we can catch a error, but we havent coded that yet.
            if let fileHandle = try? FileHandle(forUpdating: logurl as URL!) {
                print("Attempting Write")
                //Go to the end of file
                fileHandle.seekToEndOfFile()
                //Write Data
                fileHandle.write(data)
                //Close File
                fileHandle.closeFile()
            }
        }
    }

// Run a command in Swift stolen from:
// https://stackoverflow.com/questions/25726436/how-to-execute-external-program-from-swift
//

func execCommand(command: String, args: [String]) -> String {
    if !command.hasPrefix("/") {
        let commandFull = execCommand(command: "/usr/bin/which", args: [command]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return execCommand(command: commandFull, args: args)
    } else {
        let proc = Process()
        proc.launchPath = command
        proc.arguments = args
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: String.Encoding.utf8)!
    }
}


// Find out wifi interface

let iface = CWWiFiClient.shared().interface()?.interfaceName

// Setup our delay

// Argument parsing Errors.

let arguments = CommandLine.arguments
var delay:UInt32 = 0
//Find our current SSID
let currentSSID = CWWiFiClient.shared().interface()?.ssid()
// This Apps name for the help.
let executableName = NSString(string: CommandLine.arguments.first!).pathComponents.last!

// Usage for our users.
func usage() {
    
    print("")
    print("Usage:")
    print("\t\(executableName) <allowed_ssid> <wait_time>")
    print("")
    print("\t\(executableName) checks the current SSID against allowed SSID")
    print("")
    print("wait_time defines the amount of time we wait for WiFi to settle before executing the check")
    print("")
    print("Where a match is not found the client is disassociated and the SSID removed from Prefered Networks")
    print("")
    print("Example - \t\(executableName) \"Tom Tom\" 30")
    print("")
    print("Thomas Holbrook - The software is provided \"as is\", without warranty of any kind")
    print("")
}

//Check our arguments.

if arguments.count == 3 {
    
    //Wait for Wireless to settle.
    delay = UInt32(arguments[2])!
    sleep(delay)
    
}

if arguments.contains("-help") || arguments.contains("-h") {
    usage()
    exit(0)
}
    
else if arguments.count == 1 {
    usage()
    exit(0)
}
    
else if arguments.count == 2 {
    usage()
    exit(0)
}
    
    
else if arguments.count > 3 {
    usage()
    exit(0)
}
    
else if currentSSID == nil {
    print("Wifi Not Connected to a SSID")
    exit(0)
}

// Define our allowed SSID.

let allowedSSID = arguments[1]

// Debug Lines

print("Current SSID is " + currentSSID!)

print("Allowed SSID is " + allowedSSID)


//Check if our current SSID is allowed?
if currentSSID! == allowedSSID {
    
    print("Nothing to do here")
    
    }

else {
    
    //We are not allowed on this SSID diconnect the client
    
    print("Disconnecting from Rogue SSID")
    CWWiFiClient.shared().interface()!.disassociate()
    
    //Use networksetup to remove the prefered network entry
    
    print("Removing from Preferred Networks")
    
    let removePreferred = execCommand(command: "networksetup", args: ["-removepreferredwirelessnetwork", iface!, currentSSID!])
    
    print(removePreferred)
    
    tjhLogger(logEntry: "Removed from " + currentSSID!)
    
    sleep(delay)

    let reconResult = execCommand(command: "jamf", args: ["recon"])
    
    print(reconResult)
}


//The End

exit(0)



