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
    
    let blurView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
    }

    func configure(with post: Post) {
        if let currentUser = User.current,

            // Get the date the user last shared a post (cast to Date).
           let lastPostedDate = currentUser.lastPostedDate,

            // Get the date the given post was created.
           let postCreatedDate = post.createdAt,

            // Get the difference in hours between when the given post was created and the current user last posted.
           let diffHours = Calendar.current.dateComponents([.hour], from: postCreatedDate, to: lastPostedDate).hour {

            // Hide the blur view if the given post was created within 24 hours of the current user's last post. (before or after)
            blurView.isHidden = abs(diffHours) < 24
        } else {
            // Default to blur if we can't get or compute the date's above for some reason.
            blurView.isHidden = false
        }
        
        if let locationName = post.locationName {
            locationLabel.text = locationName
        }
        
        if let user = post.user {
            profileNameLabel.text = user.username
        }
        if let imageFile = post.imageFile, let imageUrl = imageFile.url {
            imageView.kf.setImage(with: imageUrl)
        }
        descriptionLabel.text = post.caption
    }
}
