//
//  OBTableViewController.swift
//  HomeWork - Swift - 33-34. UITableView Navigation Part 1-2
//
//  Created by Oleksandr Bardashevskyi on 11/23/18.
//  Copyright © 2018 Oleksandr Bardashevskyi. All rights reserved.
//

import UIKit

class OBTableViewController: UITableViewController {
    
    var path = String()
    var pathArray = [String]()
    var addFolderButton = UIBarButtonItem()
    var editButton = UIBarButtonItem()
    var folderCount = Int()
    var folderArrayCount = Int()
    var infoButton = UIButton()
    
    func initWithFolderPath(path: String) -> OBTableViewController {
        self.path = path
        self.tableView = UITableView.init(frame: self.view.bounds, style: UITableView.Style.grouped)
        
        /*
        FileManager.VolumeEnumerationOptions.skipHiddenVolumes
        FileManager.DirectoryEnumerationOptions.skipsHiddenFiles
        */
        
        do {
            self.pathArray = try FileManager.default.contentsOfDirectory(atPath: self.path)
        } catch let error as NSError {
            print("Error = \(error)")
        }
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = (self.path as NSString).lastPathComponent
        
        self.addFolderButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                                                    target: self,
                                                    action: #selector(addFolderAction))
        self.editButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.edit,
                                                    target: self,
                                                    action: #selector(editAction))
        
        self.navigationItem.rightBarButtonItems = [addFolderButton, editButton]
        
        self.tableView.reloadData()
        
    }
    // MARK: - Functions for BarButton
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newArray = sortedFileManager(array: self.pathArray, path: self.path)
        self.pathArray = newArray
    }
    
    @objc func addFolderAction(sender: UIBarButtonItem) {
        let _ = sortedFileManager(array: self.pathArray, path: self.path)
        self.folderCount += 1
        let newFolderPath = (self.path as NSString).appendingPathComponent("New Folder \(self.folderArrayCount + 1)")
        do {
            try FileManager.default.createDirectory(atPath: newFolderPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error = \(error)")
        }
        let insertFolder = "New Folder \(self.folderArrayCount + 1)"
        
        let insertNumber = self.folderArrayCount
        
        self.pathArray.insert(insertFolder, at: insertNumber)
        
        self.tableView.beginUpdates()
        
        let newIndexPath = NSIndexPath.init(row: insertNumber, section: 0)
        
        self.tableView.insertRows(at: [newIndexPath as IndexPath], with: UITableView.RowAnimation.middle)
        
        self.tableView.endUpdates()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if UIApplication.shared.isIgnoringInteractionEvents{
            UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
        //self.tableView.reloadData()
    }
    
    @objc func editAction(sender: UIBarButtonItem) {
        let _ = sortedFileManager(array: self.pathArray, path: self.path)
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        var item = UIBarButtonItem.SystemItem.edit
        if self.tableView.isEditing {
            item = UIBarButtonItem.SystemItem.done
        }
        self.editButton = UIBarButtonItem.init(barButtonSystemItem: item,
                                               target: self,
                                               action: #selector(editAction))
        self.navigationItem.setRightBarButtonItems([self.addFolderButton, self.editButton], animated: true)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "File Manager"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.pathArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifire = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifire)
        
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifire)
        }
        //MARK: InfoButton
        let button = UIButton.init(type: UIButton.ButtonType.infoDark)
        button.frame = CGRect(x: (cell?.bounds.maxX)!/20*21, y: (cell?.bounds.height)!/10*2, width: (cell?.bounds.height)!/10*6, height: (cell?.bounds.height)!/10*6)
        button.addTarget(self, action: #selector(infoButtonAction), for: UIControl.Event.touchUpInside)
        cell?.addSubview(button)
        self.infoButton = button
        
        
        
        if isDirectoryAtIndexPath(indexPath: indexPath).boolValue {
            cell?.imageView?.image = UIImage.init(named: "Folder.png")
        } else {
            cell?.imageView?.image = UIImage.init(named: "File.png")
        }
        
        let str = self.pathArray[indexPath.row]
        
        cell?.textLabel?.text = formatLenghtString(string: str)
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            let fileManager = FileManager.default
            
            let remove = (self.path as NSString).appendingPathComponent(self.pathArray.remove(at: indexPath.row))
            
            do {
                try fileManager.removeItem(atPath: remove)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            
            
            self.tableView.beginUpdates()
            
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
            self.tableView.endUpdates()
        }
    }
    
    //MARK: - Selectors for custom button
    
    @objc func infoButtonAction(sender: UIButton) {
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRow(at: pointInTable)
        let fileName = self.pathArray[(cellIndexPath?.row)!]
        print(fileName)
        let path = (self.path as NSString).appendingPathComponent(fileName)
        var fileSize = UInt64()
        var fileDate = Date()
        
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            fileDate = attr[FileAttributeKey.modificationDate] as! Date
        } catch {
            print("Error: \(error)")
        }
        let alert = UIAlertController(title: stringSizeFormator(string: String(fileSize)), message: String(fileDate.description), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - MyFunction
    
    func formatLenghtString(string: String) -> String {
        var str = String()
        
        if string.count >= 20 {
            str = string.padding(toLength: 23, withPad: " ", startingAt: 0)
            str.append("...")
        } else {
            str = string
        }
        
        return str
    }
    
    func isDirectoryAtIndexPath(indexPath: IndexPath) -> ObjCBool {
        
        let fileName = self.pathArray[indexPath.row]
        let filePath = (self.path as NSString).appendingPathComponent(fileName)
        
        var isDirection : ObjCBool = false
        
        FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirection)
        
        return isDirection
    }
    
    func sortedFileManager(array: [String], path: String) -> [String]{
        
        var folderArray = [String]()
        var fileArray = [String]()
        
        for i in array {
            let filePath = (path as NSString).appendingPathComponent(i)
            var isDirection : ObjCBool = false
            FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirection)
            if isDirection.boolValue {
                folderArray.append(i)
            } else {
                fileArray.append(i)
            }
        }
        var newArray = [String]()
        self.folderArrayCount = folderArray.count
        newArray += folderArray.sorted()
        newArray += fileArray.sorted()
        return newArray
    }
    
    func stringSizeFormator(string: String) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var index = 0
        var fileSize = Double()
        if Double(string) != nil {
            fileSize = Double(string)!
        }
        
        while fileSize > 1024 && index < units.count {
            fileSize /= 1024
            index += 1
        }
        let formatNumber = String(format: "%05.2f", fileSize)
        return "\(formatNumber) \(units[index])"
        
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isDirectoryAtIndexPath(indexPath: indexPath).boolValue {
            let fileName = self.pathArray[indexPath.row]
            let path = (self.path as NSString).appendingPathComponent(fileName)
            let vc = OBTableViewController()
            self.navigationController?.pushViewController(vc.initWithFolderPath(path: path), animated: true)
        }
    }
}

