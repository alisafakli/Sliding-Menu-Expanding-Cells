//
//  MenuTableViewController.swift
//  SlidingMenuAccordionCells
//
//  Created by Ali Safakli on 23/11/2016.
//  Copyright © 2016 Wonderland. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    var menuItems: [MenuItem]!
    var selectedIndex = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        menuItems = [MenuItem(title: "Home", icon: #imageLiteral(resourceName: "home_icon")),
                     MenuItem(title: "TV", icon: #imageLiteral(resourceName: "home_icon")),
                     MenuItem(title: "Expandable", icon: #imageLiteral(resourceName: "home_icon"), isExpanded: false, subItems: [MenuItem(title: "One", icon: #imageLiteral(resourceName: "empty_icon")),
                                                                                                    MenuItem(title: "Twp", icon: #imageLiteral(resourceName: "empty_icon"))])]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(selectedIndex == indexPath.row){
            return 100
        }else{
            return 40
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "menu_cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! MenuCell
        
        let obj = menuItems[indexPath.row]
        cell.firstViewLabel.text = obj.title
        
        if(obj.subItems.count > 0)
        {
            cell.secondViewLabel.text = obj.subItems[0].title
        }
        
        return cell
       
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(selectedIndex == indexPath.row){
            selectedIndex = -1
        }else{
            selectedIndex = indexPath.row
        }
        
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        self.tableView.endUpdates()
    }

}
