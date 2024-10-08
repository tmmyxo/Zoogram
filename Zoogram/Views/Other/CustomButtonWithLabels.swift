//
//  CustomButtonWithLabels.swift
//  Zoogram
//
//  Created by Artem Dolbiev on 04.02.2022.
//

import UIKit

class CustomButtonWithLabels: UIButton {

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = CustomFonts.regularFont(ofSize: 14)
        label.textColor = Colors.label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = CustomFonts.boldFont(ofSize: 17)
        label.textColor = Colors.label
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewsAndConstraints()
    }

    public func configureWith(labelText: String, number: Int?) {
        label.text = labelText
        if let unwrappedNumber = number {
            numberLabel.text = "\(unwrappedNumber)"
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViewsAndConstraints() {
        self.addSubviews(label, numberLabel)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.widthAnchor.constraint(equalTo: self.widthAnchor),
            label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5),

            numberLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            numberLabel.topAnchor.constraint(equalTo: self.topAnchor),
            numberLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            numberLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
        ])
    }
}
