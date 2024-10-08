//
//  SearchedUserTableViewCell.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 21.10.2022.
//

import UIKit

class SearchedUserTableViewCell: UITableViewCell {

    static let identifier = "SearchedUserTableViewCell"

    private let profileImageViewSize: CGFloat = 50

    var profileImageView: ProfilePictureImageView = {
        let imageView = ProfilePictureImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = CustomFonts.boldFont(ofSize: 14)
        label.textColor = Colors.label
        label.numberOfLines = 1
        return label
    }()

    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFonts.regularFont(ofSize: 14)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViewsAndConstraints()
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        usernameLabel.text = nil
        nameLabel.text = nil
        profileImageView.image = nil
    }

    private func setupViewsAndConstraints() {
        contentView.addSubviews(profileImageView, usernameLabel, nameLabel)

        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewSize),
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewSize),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: 15),
            usernameLabel.heightAnchor.constraint(equalToConstant: 15),
            usernameLabel.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -5),

            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 15),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])

        profileImageView.layer.cornerRadius = profileImageViewSize / 2
    }

    func configure(with user: ZoogramUser) {
        usernameLabel.text = user.username
        nameLabel.text = user.name
        profileImageView.image = user.getProfilePhoto() ?? UIImage.profilePicturePlaceholder
    }
}
