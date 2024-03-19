//
//  HomeViewController.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit
import ParseSwift

class HomeViewController: BaseViewController {
    
    let postItButton = {
        let createPostButton = UIButton(type: .system)
        createPostButton.translatesAutoresizingMaskIntoConstraints = false
        createPostButton.backgroundColor = .blue
        return createPostButton
    }()
    
    var collectionView: UICollectionView!
    var posts = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
        makeRequestForAuthorizationNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeQueryForFeeds()
    }
    
    func makeQueryForFeeds() {
        // Get the date for yesterday. Adding (-1) day is equivalent to subtracting a day.
        // NOTE: `Date()` is the date and time of "right now".
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: (-1), to: Date())!
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .where("createdAt" >= yesterdayDate) // <- Only include results created yesterday onwards
            .limit(10) // <- Limit max number of returned posts to 10

        // Fetch objects (posts) defined in query (async)
        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                // Update local posts property with fetched posts
                self?.posts = posts
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setUpUi() {
        setupCollectionView()
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30)
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.title = "BeReal"
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutUser))
        self.navigationItem.rightBarButtonItem = logoutButton
        
        postItButton.setTitle("BeReal", for: .normal)
        postItButton.setTitleColor(.white, for: .normal)
        postItButton.backgroundColor = .systemBlue
        postItButton.layer.cornerRadius = 35
        postItButton.addTarget(self, action: #selector(createPostButtonTapped), for: .touchUpInside)
        view.addSubview(postItButton)
        NSLayoutConstraint.activate([
            postItButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            postItButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            postItButton.widthAnchor.constraint(equalToConstant: 70),
            postItButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        
    }
    
    func setupCollectionView() {
        // Create a layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        // Create a collection view
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "FeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedCollectionViewCell")
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
        
    }
    
    @objc func logoutUser() {
        User.logout { [weak self] result in
            switch result {
                case .success:
                    self?.removeAllPendingNotifications()
                    let launchViewController = LaunchScreenVC()
                    self?.setRootViewController(launchViewController)
                case .failure(let error):
                    print("Failed to log out: \(error.message)")
            }
        }
    }
    
    @objc func createPostButtonTapped() {
        let postPhotoVC = PostPhotoViewController()
        self.navigationController?.pushViewController(postPhotoVC, animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items you want to display
        return posts.count
    }
            
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCollectionViewCell", for: indexPath) as! FeedCollectionViewCell
        // Configure the cell
        cell.configure(with: posts[indexPath.item])
        cell.delegate = self
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate cell size based on collection view width and aspect ratio
        let width = collectionView.bounds.width - 1 // Divide by number of columns, subtract 1 for spacing
        return CGSize(width: width, height: width)
    }
}

extension HomeViewController: FeedCollectionViewCellDelegate {
    func didTapCommentButton(_ post: Post) {
        let commentsViewController = CommentsViewController(post: post)
        commentsViewController.modalPresentationStyle = .popover
        present(commentsViewController, animated: true, completion: nil)
    }
}
