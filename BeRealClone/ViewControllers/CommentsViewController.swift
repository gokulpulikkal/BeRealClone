//
//  CommentsViewController.swift
//  BeRealClone
//
//  Created by Gokul P on 18/03/24.
//

import UIKit
import ParseSwift

class CommentsViewController: BaseViewController {
    
    @IBOutlet weak var noCommentsLabel: UILabel!
    @IBOutlet weak var textInputView: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var textInputViewBottomConstraint: NSLayoutConstraint!
    
    let nameInitialTextView = {
        let nameLabelInsideImage = UILabel(frame: .zero)
        nameLabelInsideImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabelInsideImage.textColor = UIColor.white
        nameLabelInsideImage.font = UIFont.systemFont(ofSize: 20)
        return nameLabelInsideImage
    }()
    
    let post: Post
    let postPointer: Pointer<Post>
    var comments = [Comment]() {
        didSet {
            if comments.count > 0 {
                noCommentsLabel.isHidden = true
            } else {
                noCommentsLabel.isHidden = false
            }
        }
    }
    
    init(post: Post) {
        self.post = post
        self.postPointer = Pointer<Post>(objectId: post.id)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureProfilePicture()
        initializeHideKeyboard()
        startObservingKeyboard()
        addSpinningWheel()
        spinningWheel.startAnimating()
        fetchComments(forPost: postPointer) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let comments):
                DispatchQueue.main.async {
                    self.comments = comments
                    self.tableView.reloadData()
                    self.spinningWheel.stopAnimating()
                }
            case .failure(let error):
                print("Error fetching comments:", error)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorColor = .black
        tableView.rowHeight = 80
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
    }
    
    private func configureProfilePicture() {
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.addSubview(nameInitialTextView)
        NSLayoutConstraint.activate([
            nameInitialTextView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            nameInitialTextView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
        
        if let user = User.current, let userName = user.username {
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
        let lastVisibleCell = tableView.indexPathsForVisibleRows?.last
        UIView.animate( withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                self.textInputViewBottomConstraint.constant = keyboardFrame.height - safeAreaOffset + 8
                self.view.layoutIfNeeded()
                if let lastVisibleCell = lastVisibleCell {
                    self.tableView.scrollToRow(at: lastVisibleCell, at: .bottom, animated: false)
                }
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
    
    func createComment(text: String, userName: String, user: Pointer<User>, post: Pointer<Post>, completion: @escaping (Result<Comment, Error>) -> Void) {
        let comment = Comment(userName: userName, text: text, user: user, post: post)
        comment.save { result in
            switch result {
            case .success(let savedComment):
                completion(.success(savedComment))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchComments(forPost post: Pointer<Post>, completion: @escaping (Result<[Comment], Error>) -> Void) {
        let query = Comment.query()
            .include("user")
            .include("post")
            .where("post" == post)
            .order([.ascending("createdAt")])
            .limit(10) // Limit to the last 10 comments, adjust as needed
        
        query.find { result in
            switch result {
            case .success(let comments):
                completion(.success(comments))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    @IBAction func onSendButtonClick(_ sender: Any) {
        guard let commentText = textInputView.text, commentText != "", let user = User.current else { return }
        let userPointer = Pointer<User>(objectId: user.id)
        createComment(text: commentText, userName: user.username!, user: userPointer, post: postPointer) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let comment):
                    DispatchQueue.main.async {
                        self.comments.append(comment)
                        self.textInputView.text = ""
                        self.tableView.reloadData()
                        self.scrollToLastIndex()
                    }
                case .failure(let error):
                    print("Error creating comment:", error)
            }
        }
    }
    
    func scrollToLastIndex() {
        let lastSection = self.tableView.numberOfSections - 1
        let lastRow = self.tableView.numberOfRows(inSection: lastSection) - 1

        // Create an index path for the last row
        let indexPath = IndexPath(row: lastRow, section: lastSection)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell
        cell?.configure(with: comments[indexPath.item])
        return cell ?? UITableViewCell()
    }
    
    
}
