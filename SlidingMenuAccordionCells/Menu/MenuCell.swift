//
//  MenuCellV2.swift
//  SlidingMenuAccordionCells
//
//  Created by Ali Safakli on 23/11/2016.
//  Copyright © 2016 Wonderland. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var mainLogoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
