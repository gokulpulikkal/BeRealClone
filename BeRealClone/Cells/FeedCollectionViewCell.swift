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
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    
    var post: Post?
    var isLiked = false
    let filledHeartImage = UIImage(systemName: "heart.fill")
    let emptyHeartImage = UIImage(systemName: "heart")
    
    let blurView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()
    
    let nameInitialTextView = {
        let nameLabelInsideImage = UILabel(frame: .zero)
        nameLabelInsideImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabelInsideImage.textColor = UIColor.white
        nameLabelInsideImage.font = UIFont.systemFont(ofSize: 25)
        return nameLabelInsideImage
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addBlurView()
        configureLikeImageView()
    }
    
    func configureLikeImageView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        likeImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func addBlurView() {
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.addSubview(nameInitialTextView)
        NSLayoutConstraint.activate([
            nameInitialTextView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            nameInitialTextView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }

    func configure(with post: Post) {
        self.post = post
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
        
        if let user = post.user, let userName = user.username {
            profileNameLabel.text = userName
            nameInitialTextView.text = "\(userName.prefix(1))"
        }
        if let imageFile = post.imageFile, let imageUrl = imageFile.url {
            imageView.kf.setImage(with: imageUrl)
        }
        if let createdAt = post.createdAt, let timeString = timeAgo(from: createdAt) {
            timeLabel.text = timeString
        }
        if let likes = post.likes, let currentUser = User.current {
            let currentUserLiked = likes.contains { $0 == currentUser.username }
            isLiked = currentUserLiked
        } else {
            isLiked = false
        }
        setLikeButtonUI()
        descriptionLabel.text = post.caption
    }
    
    func timeAgo(from date: Date) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        formatter.maximumUnitCount = 1
        
        guard let timeString = formatter.string(from: date, to: Date()) else {
            return nil
        }
        if timeString == "in 1 second" || timeString == "1 second ago" {
            return "Just now"
        }
        return "\(timeString) ago"
    }
    @objc func imageViewTapped() {
        isLiked.toggle()
        setLikeButtonUI()
        updateLikeInPost()
    }
    
    func setLikeButtonUI() {
        let image = isLiked ? filledHeartImage : emptyHeartImage
        likeImageView.image = image
    }
    
    func updateLikeInPost() {
        guard var post = post, let currentUser = User.current else { return }
        var likes = post.likes ?? []
        if isLiked {
            if !likes.contains(where: { $0 == currentUser.username }) {
                // If the user hasn't already liked the post, add them to the list of likes
                likes.append(currentUser.username!)
            }
        } else {
            likes.removeAll { $0 == currentUser.username }
        }
        DispatchQueue.global().async { [weak self] in
            guard self != nil else { return }
            post.likes = likes
            post.save { result in
                switch result {
                case .success(let post):
                    print("✅ Post Like Saved! \(post)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
