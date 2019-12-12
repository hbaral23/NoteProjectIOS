//
//  ImageCollectionViewCell.swift
//  Memo
//
//  Created by Ryan Bertrand on 11/12/2019.
//  Copyright © 2019 Hugo Baral. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {


    @IBOutlet weak var imageView: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func configure(imageName: String) {
        /*print(imageView!)
        let uiImage = UIImage(systemName: imageName)
        self.imageView.image = uiImage*/
    }
}
