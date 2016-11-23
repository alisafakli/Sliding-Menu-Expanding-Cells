//
//  MenuCell.swift
//  SlidingMenuAccordionCells
//
//  Created by Ali Safakli on 23/11/2016.
//  Copyright © 2016 Wonderland. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var secondHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var secondViewLabel: UILabel!
    @IBOutlet weak var firstViewLabel: UILabel!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var firstView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var showDetails = false {
        didSet {
            secondHeightConstraints.priority = showDetails ? 250 : 999
        }
    }

}
