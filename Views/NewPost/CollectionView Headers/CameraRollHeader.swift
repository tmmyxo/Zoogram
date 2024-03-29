//
//  CameraRollHeader.swift
//  Zoogram
//
//  Created by Artem Dolbiev on 09.02.2022.
//

import UIKit

protocol CameraRollHeaderDelegate: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AnyObject {
    func didTapCameraButton(_ header: CameraRollHeaderView)
}

class CameraRollHeaderView: UIView {

    weak var delegate: CameraRollHeaderDelegate?

    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .darkGray
        button.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        return button
    }()

    private let sortButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Recents", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = CustomFonts.boldFont(ofSize: 16)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .black
        setupViewsAndConstraints()
    }

    override func layoutSubviews() {
        cameraButton.layer.cornerRadius = (self.bounds.height - 15) / 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViewsAndConstraints() {
        addSubviews(sortButton, cameraButton)

        NSLayoutConstraint.activate([
            sortButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            sortButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            sortButton.heightAnchor.constraint(equalTo: self.heightAnchor),
            sortButton.trailingAnchor.constraint(lessThanOrEqualTo: cameraButton.leadingAnchor),

            cameraButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            cameraButton.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -15),
            cameraButton.widthAnchor.constraint(equalTo: self.heightAnchor, constant: -15)
        ])
    }

    @objc private func didTapCameraButton() {
        delegate?.didTapCameraButton(self)
    }

}
