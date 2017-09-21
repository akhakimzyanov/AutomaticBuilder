//
//  ViewController.swift
//  AutomaticBuilder
//
//  Created by Aidar on 14.09.17.
//  Copyright © 2017 Aidar Khakimzyanov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet fileprivate weak var pathField: NSTextField!
    @IBOutlet fileprivate weak var projects: NSTableView!
    
    fileprivate var selectedRow = -1
    
    fileprivate var projectNames: [String] {
        get {
            return projectPaths.keys.sorted()
        }
    }
    
    fileprivate var _projectPaths: [String: String]?
    fileprivate var projectPaths: [String: String] {
        get {
            if _projectPaths == nil {
                _projectPaths = UserDefaults.standard.object(forKey: "projectPaths") as? [String: String]
                
                if _projectPaths != nil {
                    for (key, value) in _projectPaths! {
                        if !FileManager.default.fileExists(atPath: value) {
                            _projectPaths?.removeValue(forKey: key)
                        }
                    }
                }
            }
            
            if _projectPaths == nil {
                _projectPaths = [String: String]()
            }
            
            return _projectPaths!
        }
        set {
            _projectPaths = newValue
            
            projects.reloadData()
            
            UserDefaults.standard.set(_projectPaths, forKey: "projectPaths")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projects.backgroundColor = NSColor.clear
    }
    
    @IBAction fileprivate func browseFile(sender: AnyObject) {
        
        if pathField.stringValue.isEmpty {
            let dialog = NSOpenPanel()
            
            dialog.title = "Choose a .xcodeproj or .xcworkspace file"
            dialog.prompt = "Add"
            dialog.canCreateDirectories = false
            dialog.allowedFileTypes = ["xcodeproj", "xcworkspace"]
            
            if (dialog.runModal() == .OK) {
                addProject(path: dialog.url?.path)
            }
        } else {
            addProject(path: pathField.stringValue)
        }
    }
    
    @IBAction func betaPressed(sender: AnyObject) {
        callScriptForCurrent(releaseType: "beta")
    }
    
    @IBAction func releasePressed(sender: AnyObject) {
        callScriptForCurrent(releaseType: "release")
    }
    
    fileprivate func addProject(path: String?) {
        
        if let newPath = path, !newPath.isEmpty {
            var updatePath = newPath
            
            let lastPath = "/\((newPath as NSString).lastPathComponent)"
            if lastPath.contains("xcodeproj") || lastPath.contains("xcworkspace") {
                updatePath = updatePath.replacingOccurrences(of: lastPath, with: "")
            }
            
            let fastlanePath = (updatePath as NSString).appendingPathComponent("fastlane")
            if FileManager.default.fileExists(atPath: updatePath) && FileManager.default.fileExists(atPath: fastlanePath) {
                var newPaths = projectPaths
                
                let filename = (updatePath as NSString).lastPathComponent
                
                newPaths[filename] = updatePath
                
                projectPaths = newPaths;
            }
        }
    }
    
    fileprivate func callScriptForCurrent(releaseType: String) {
        
        if selectedRow != -1 {
            let projectName = projectNames[selectedRow]
            
            if let projectPath = projectPaths[projectName] {
                let script = "tell application \"Terminal\" \n"
                    + " set newTab to do script \"cd \(projectPath)\" \n"
                    + " set newWindow to first window of (every window whose tabs contains newTab) \n"
                    + " set output to do script \"fastlane \(releaseType)\" in newTab \n"
//                    + " repeat \n"
//                    + "  delay 3 \n"
//                    + "  if exists newTab \n"
//                    + "   if not busy of newTab then \n"
//                    + "    if output contains \"fastlane finished with errors\" \n"
//                    + "     close newWindow \n"
//                    + "    end if \n"
//                    + "    exit repeat \n"
//                    + "   end if \n"
//                    + "  else \n"
//                    + "   exit repeat \n"
//                    + "  end if \n"
//                    + " end repeat \n"
                    + "end tell"
                
                if let appleScript = NSAppleScript(source: script) {
                    var errorDict: NSDictionary?
                    appleScript.executeAndReturnError(&errorDict)
                    
                    if let error = errorDict {
                        print(error)
                    }
                }
            }
        }
    }
}


extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return projectNames.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var cellIdentifier: String = ""
        
        if tableColumn == tableView.tableColumns[0] {
            cellIdentifier = "NameID"
        } else if tableColumn == tableView.tableColumns[1] {
            cellIdentifier = "PathID"
        } else if tableColumn == tableView.tableColumns[2] {
            cellIdentifier = "SelectID"
        }
        
        let rowName = projectNames[row]
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            if tableColumn == tableView.tableColumns[0] {
                cell.textField?.stringValue = rowName.capitalized
            }
            
            if tableColumn == tableView.tableColumns[1], let path = projectPaths[rowName] {
                cell.textField?.stringValue = path
            }
            
            if (tableColumn == tableView.tableColumns[2]) {
                cell.imageView?.isHidden = selectedRow != row
            }
            
            return cell
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedRow = projects.selectedRow
        
        projects.reloadData()
    }
}


extension ViewController: NSTextFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            addProject(path: textView.string)
            
            return true
        }
        
        return false
    }
}


extension ViewController {
    
    static func controller() -> ViewController {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil) 
        
        let viewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "mainViewController")) as! ViewController
        
        return viewController
    }
}
