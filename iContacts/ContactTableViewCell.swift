//
//  ContactTableViewCell.swift
//  iContacts
//
//  Created by Мухаммед Каипов on 19/5/24.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet var contactsTextLabel: UILabel!
    static let identifier: String = "ContactTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        contactsTextLabel.text = nil
    }
    
}
