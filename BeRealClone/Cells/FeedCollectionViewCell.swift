//
//  FeedCollectionViewCell.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit
import Kingfisher

class FeedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with post: Post) {
        if let user = post.user {
            profileNameLabel.text = user.username
        }
        if let imageFile = post.imageFile, let imageUrl = imageFile.url {
            imageView.kf.setImage(with: imageUrl)
        }
        
        descriptionLabel.text = post.caption
    }
}
