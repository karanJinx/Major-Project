//
//  Cell.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 08/09/23.
//

import UIKit

class Cell: UITableViewCell {

    
    @IBOutlet var baseView: Cell!
    @IBOutlet var medicationLable: UILabel!
    @IBOutlet var frequencyLable: UILabel!
    @IBOutlet var quantityLable: UILabel!
    @IBOutlet var dateDayLable: UILabel!
    @IBOutlet var lastDayDateLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
