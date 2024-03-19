//
//  CommentTableViewCell.swift
//  BeRealClone
//
//  Created by Gokul P on 18/03/24.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var labelView: UILabel!
    let nameInitialTextView = {
        let nameLabelInsideImage = UILabel(frame: .zero)
        nameLabelInsideImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabelInsideImage.textColor = UIColor.white
        nameLabelInsideImage.font = UIFont.systemFont(ofSize: 20)
        return nameLabelInsideImage
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
        configureProfilePicture()
    }
    
    private func configureProfilePicture() {
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.addSubview(nameInitialTextView)
        NSLayoutConstraint.activate([
            nameInitialTextView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            nameInitialTextView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with comment: Comment) {
        // Assuming `comment` has properties such as `text` and `user`
        labelView.text = comment.text
        self.nameInitialTextView.text = "\(comment.userName?.prefix(1) ?? "")"
    }
    
}
