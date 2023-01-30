//
//  PostHeaderTableViewCell.swift
//  Zoogram
//
//  Created by Artem Dolbiev on 25.01.2022.
//

import SDWebImage
import UIKit

protocol PostHeaderDelegate {
    func menuButtonTappedFor(postID: String, index: Int)
    func didSelectUser(userID: String, atIndex: Int)
}

class PostHeaderTableViewCell: UITableViewCell {
    
    static let identifier = "PostHeaderTableViewCell"
    
    var postID = ""
    var userID = ""
    var postIndex = 0
    
    var delegate: PostHeaderDelegate?
    
    private let profilePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()
    
    private let menuButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 19)), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        setupViewsAndConstraints()
        addGestureRecognizers()
    }
    
    func addGestureRecognizers() {
        let userNameGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapUser))
        let profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapUser))
        
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(userNameGestureRecognizer)
        
        profilePhotoImageView.isUserInteractionEnabled = true
        profilePhotoImageView.addGestureRecognizer(profileImageGestureRecognizer)
        
    }
    
    public func configureWith(profilePictureURL: String, username: String, postID: String, userID: String, postIndex: Int) {
        profilePhotoImageView.sd_setImage(with: URL(string: profilePictureURL), completed: nil)
        self.postID = postID
        self.userID = userID
        self.postIndex = postIndex
        usernameLabel.text = username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViewsAndConstraints() {
        contentView.addSubviews(profilePhotoImageView, usernameLabel, menuButton)
        
        let profilePhotoHeightWidth = frame.height - 10
        
        NSLayoutConstraint.activate([
            profilePhotoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profilePhotoImageView.heightAnchor.constraint(equalToConstant: profilePhotoHeightWidth),
            profilePhotoImageView.widthAnchor.constraint(equalToConstant: profilePhotoHeightWidth),
            profilePhotoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            usernameLabel.centerYAnchor.constraint(equalTo: profilePhotoImageView.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: profilePhotoImageView.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: menuButton.leadingAnchor),
            usernameLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            
            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            menuButton.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: contentView.frame.height),
            menuButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
        profilePhotoImageView.layer.cornerRadius = profilePhotoHeightWidth / 2
    }
    
    @objc func didTapMenuButton() {
        delegate?.menuButtonTappedFor(postID: self.postID, index: postIndex)
    }
    
    @objc func didTapUser() {
        delegate?.didSelectUser(userID: self.userID, atIndex: self.postIndex)
    }
}
