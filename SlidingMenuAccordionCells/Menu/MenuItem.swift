//
//  MenuItems.swift
//  SlidingMenuAccordionCells
//
//  Created by Ali Safakli on 23/11/2016.
//  Copyright © 2016 Wonderland. All rights reserved.
//

import UIKit

class MenuItem {
    
    var title: String!
    var icon: UIImage!
    var isExpanded: Bool!
    var subItems: [MenuItem]!
    var segueIdentifier: String!
    
    init(title: String, icon: UIImage, isExpanded:Bool = false, subItems: [MenuItem] = [], segueIdentifier: String = "") {
        self.title = title
        self.icon = icon
        self.isExpanded = isExpanded
        self.subItems = subItems
        self.segueIdentifier = segueIdentifier
    }

}

