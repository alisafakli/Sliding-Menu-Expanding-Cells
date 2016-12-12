//
//  MenuTableVCTableViewController.swift
//  SlidingMenuAccordionCells
//
//  Created by Ali Safakli on 23/11/2016.
//  Copyright © 2016 Wonderland. All rights reserved.
//

import UIKit

class MenuTableVC: UITableViewController, SWRevealViewControllerDelegate {

    var numberOfVisibleRows: Int!
    var menuItems: [MenuItem]!
    var changedIndexes: [Int]! = []
    override func viewDidLoad() {
        super.viewDidLoad()
        menuItems = [MenuItem(title: "Home", icon: #imageLiteral(resourceName: "home_icon"), segueIdentifier: "testScreen"),
                     MenuItem(title: "TV", icon: #imageLiteral(resourceName: "home_icon"), segueIdentifier: "test2Screen"),
                     MenuItem(title: "Expandable", icon: #imageLiteral(resourceName: "home_icon"), isExpanded: false, subItems: [MenuItem(title: "One", icon: #imageLiteral(resourceName: "empty_icon")),
                                                                                                                                 MenuItem(title: "Two", icon: #imageLiteral(resourceName: "empty_icon"))], segueIdentifier: "test3Screen")]
        numberOfVisibleRows = menuItems.count
        print(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numberOfVisibleRows
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj: MenuItem!
        if (changedIndexes.count > 0){
            obj = menuItems[changedIndexes[0]-1]
        }else {
            obj = menuItems[indexPath.row]
        }
        
        var cellIdentifier: String!
        if (obj.isExpanded == true) {
            for i in 0 ..< changedIndexes.count {
                if indexPath.row == changedIndexes[i] {
                    cellIdentifier = "cell"
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
                    cell?.detailTextLabel?.text = obj.subItems[i].title
                    return cell!
                }
            }
        }
        cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        cell?.textLabel?.text = obj.title
        cell?.imageView?.image = obj.icon
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let obj = menuItems[indexPath.row]
        if !obj.isExpanded && obj.subItems.count > 0 {
            menuItems[indexPath.row].isExpanded = true
            for i in 0 ..< obj.subItems.count {
                numberOfVisibleRows = numberOfVisibleRows + 1
                changedIndexes.append(indexPath.row+i+1)
                insert(currentIndex: indexPath.row+i+1, indPath: indexPath)
            }
        }else if obj.isExpanded && obj.subItems.count > 0{
            menuItems[indexPath.row].isExpanded = false
            for i in 0 ..< obj.subItems.count {
                numberOfVisibleRows = numberOfVisibleRows - 1
//                delete(currentIndex: indexPath.row+i+1)
                
            }
        }
        
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        self.tableView.endUpdates()
        
        changeVC(segueIdentifier: obj.segueIdentifier)
    }
    
    func changeVC(segueIdentifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let frontViewController = storyboard.instantiateViewController(withIdentifier: segueIdentifier)
        
        
        let navController: UINavigationController = UINavigationController(rootViewController: frontViewController)
        
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "menuScreen") as! MenuTableVC
        
        
        let revealController: SWRevealViewController = SWRevealViewController(rearViewController: menuViewController, frontViewController: navController)
        revealController.delegate = self
        
        //        let rightViewController : MenuTableVC = MenuTableVC()
        //        rightViewController.view.backgroundColor = UIColor.purple
        //
        //        revealController.rightViewController = rightViewController
        
        
        self.revealViewController().present(revealController, animated: true, completion: nil)
    }

    func insert(currentIndex: Int, indPath: IndexPath) {
        
        let insertionIndexPath = IndexPath(row: currentIndex, section: indPath.section)
        
//        tableView.beginUpdates()
        
//        tableView.insertRows(at: indexPaths, with: .right)
//        tableView.insertRows(at: bottomHalfIndexPaths, with: .left)
        tableView.insertRows(at: [insertionIndexPath], with: .automatic)
        
//        tableView.endUpdates()
        

    }
    
    func deleteCell(_ cell: UITableViewCell) {
        if let deletionIndexPath = tableView.indexPath(for: cell) {
            tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }
    
}
