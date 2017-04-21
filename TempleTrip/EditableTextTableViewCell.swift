//
//  EditableTextTableViewCell.swift
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/23/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

import UIKit

class EditableTextTableViewCell: UITableViewCell {
    @IBOutlet weak var editableText: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
