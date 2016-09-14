//
//  SchedulePickerTableViewCell.swift
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/23/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

import UIKit

class SchedulePickerTableViewCell: UITableViewCell {
    @IBOutlet weak var SchedulePicker: UIPickerView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
