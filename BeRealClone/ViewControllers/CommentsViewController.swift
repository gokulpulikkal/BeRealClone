//
//  CommentsViewController.swift
//  BeRealClone
//
//  Created by Gokul P on 18/03/24.
//

import UIKit

class CommentsViewController: BaseViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var textInputViewBottomConstraint: NSLayoutConstraint!
    let nameInitialTextView = {
        let nameLabelInsideImage = UILabel(frame: .zero)
        nameLabelInsideImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabelInsideImage.textColor = UIColor.white
        nameLabelInsideImage.font = UIFont.systemFont(ofSize: 20)
        return nameLabelInsideImage
    }()
    
    var post: Post
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureProfilePicture()
        initializeHideKeyboard()
        startObservingKeyboard()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureProfilePicture() {
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.addSubview(nameInitialTextView)
        NSLayoutConstraint.activate([
            nameInitialTextView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            nameInitialTextView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
        
        if let user = post.user, let userName = user.username {
            nameInitialTextView.text = "\(userName.prefix(1))"
        }
    }
    
    private func startObservingKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillAppear(_ notification: Notification) {
        let key = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardFrame = notification.userInfo?[key] as? CGRect else {
            return
        }
        let safeAreaBottom = view.safeAreaLayoutGuide.layoutFrame.maxY
        let viewHeight = view.bounds.height
        let safeAreaOffset = viewHeight - safeAreaBottom
//        let lastVisibleCell = tableView.indexPathsForVisibleRows?.last
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.textInputViewBottomConstraint.constant = keyboardFrame.height - safeAreaOffset + 8
                self.view.layoutIfNeeded()
//                if let lastVisibleCell = lastVisibleCell {
//                    self.tableView.scrollToRow(at: lastVisibleCell, at: .bottom, animated: false)
//                }
        })
    }
    
    @objc private func keyboardWillDisappear(_ notification: Notification) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
            self.textInputViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func onSendButtonClick(_ sender: Any) {
    }
}
