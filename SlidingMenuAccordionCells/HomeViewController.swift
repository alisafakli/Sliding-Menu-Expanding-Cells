//
//  ViewController.swift
//  SlidingMenuAccordionCells
//
//  Created by Ali Safakli on 23/11/2016.
//  Copyright © 2016 Wonderland. All rights reserved.
//

import UIKit

class HomeViewController: BaseVC, SWRevealViewControllerDelegate {

    var swReveal: SWRevealViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let frontViewController = storyboard.instantiateViewController(withIdentifier: "testScreen") as! TestVC //SWRevealViewController
        
        
        let navController: UINavigationController = UINavigationController(rootViewController: frontViewController)
        
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "menuScreen") as! MenuTableVC
        
        
        let revealController: SWRevealViewController = SWRevealViewController(rearViewController: menuViewController, frontViewController: navController)
        revealController.delegate = self
        
//        let rightViewController : MenuTableVC = MenuTableVC()
//        rightViewController.view.backgroundColor = UIColor.purple
//        
//        revealController.rightViewController = rightViewController
        
        self.swReveal = revealController
        
        self.revealViewController().present(self.swReveal, animated: true, completion: nil)
        
        
    }

}
