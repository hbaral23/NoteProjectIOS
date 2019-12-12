//
//  NoteTableVIewCell.swift
//  Memo
//
//  Created by Ryan Bertrand on 03/12/2019.
//  Copyright © 2019 Hugo Baral. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func configure(note:Note?) {
        self.titleLabel.text = note?.title
        self.contentLabel.text = note?.content
        if(note?.pictures != nil && (note?.pictures?.count)! > 0) {
            self.noteImageView.image = UIImage(named: (note?.pictures![0])!)
        }
        else{
            self.noteImageView.isHidden = true;
        }
    
        let format = DateFormatter()
        format.dateFormat = "dd MMMM yyyy | HH:mm"
        format.locale = Locale(identifier: "FR-fr")
        
        self.dateLabel.text = format.string(from: (note?.date)!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
