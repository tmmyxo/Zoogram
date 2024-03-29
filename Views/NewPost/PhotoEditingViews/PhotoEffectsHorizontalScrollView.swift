//
//  PhotoEditingHorizontalStackView.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 14.02.2022.
//

import UIKit

struct EditingButton {
    let effectName: String
    let effectIcon: UIImage
}

protocol PhotoEffectsHorizontalScrollViewDelegate: AnyObject {
    func showExposureSlider()
    func showBrightnessSlider()
    func showContrastSlider()
    func showSaturationSlider()
    func showWarmthSlider()
    func showTintSlider()
    func showHighlightsSlider()
    func showShadowsSlider()
    func showVignetteSlider()
}

class PhotoEffectsHorizontalScrollView: UIView {

    weak var delegate: PhotoEffectsHorizontalScrollViewDelegate?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stackview = UIStackView()
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.axis = .horizontal
        stackview.spacing = 10
        stackview.alignment = .center
        stackview.distribution = .equalSpacing
        return stackview
    }()

    private lazy var exposureButton: PhotoEffectButton = {
        let button = PhotoEffectButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(effectIcon: UIImage(systemName: "plusminus")!, effectName: "Exposure")
        button.addTarget(self, action: #selector(didSelectExposureSetting), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var brightnessButton: PhotoEffectButton = {
        let button = PhotoEffectButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(effectIcon: UIImage(systemName: "sun.max")!, effectName: "Brightness")
        button.addTarget(self, action: #selector(didSelectBrightnessSetting), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var contrastButton: PhotoEffectButton = {
        let button = PhotoEffectButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(effectIcon: UIImage(systemName: "circle.lefthalf.filled")!, effectName: "Contrast")
        button.addTarget(self, action: #selector(didSelectContrastSetting), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var saturationButton: PhotoEffectButton = {
        let button = PhotoEffectButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(effectIcon: UIImage(systemName: "drop")!, effectName: "Saturation")
        button.addTarget(self, action: #selector(didSelectSaturationSetting), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var warmthButton: PhotoEffectButton = {
        let button = PhotoEffectButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(effectIcon: UIImage(systemName: "thermometer.sun")!, effectName: "Warmth")
        button.addTarget(self, action: #selector(didSelectWarmthSetting), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var tintButton: PhotoEffectButton = {
        let button = PhotoEffectButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(effectIcon: UIImage(systemName: "eyedropper.halffull")!, effectName: "Tint")
        button.addTarget(self, action: #selector(didSelectTintSetting), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var highLightsButton: PhotoEffectButton = {
        let button = PhotoEffectButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(effectIcon: UIImage(systemName: "circle.fill")!, effectName: "Highlights")
        button.addTarget(self, action: #selector(didSelectHighlightsSetting), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var shadowsButton: PhotoEffectButton = {
        let button = PhotoEffectButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(effectIcon: UIImage(systemName: "circle.fill")!, effectName: "Shadows")
        button.addTarget(self, action: #selector(didSelectShadowsSetting), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var vignetteButton: PhotoEffectButton = {
        let button = PhotoEffectButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(effectIcon: UIImage(systemName: "smallcircle.filled.circle")!, effectName: "Vignette")
        button.addTarget(self, action: #selector(didSelectVignetteSetting), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()

    private let filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Filter", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = CustomFonts.boldFont(ofSize: 16)
        return button
    }()

    private let editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = CustomFonts.boldFont(ofSize: 16)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        addSubviews(scrollView, filterButton, editButton)
        scrollView.addSubview(stackView)
        setupConstraints()
        setupScrollViewButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setupScrollViewButtons() {
            let buttons = [exposureButton, brightnessButton, contrastButton, saturationButton, warmthButton, tintButton, highLightsButton, shadowsButton, vignetteButton]
            for button in buttons {
                button.heightAnchor.constraint(equalToConstant: 110).isActive = true
                button.widthAnchor.constraint(equalToConstant: 85).isActive = true
                stackView.addArrangedSubview(button)
            }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: filterButton.topAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),

            filterButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            filterButton.trailingAnchor.constraint(equalTo: self.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),

            editButton.leadingAnchor.constraint(equalTo: self.centerXAnchor),
            editButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            editButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            editButton.heightAnchor.constraint(equalTo: filterButton.heightAnchor),
        ])
    }

    @objc private func didSelectExposureSetting() {
        self.delegate?.showExposureSlider()
    }

    @objc private func didSelectBrightnessSetting() {
        self.delegate?.showBrightnessSlider()
    }

    @objc private func didSelectContrastSetting() {
        self.delegate?.showContrastSlider()
    }

    @objc private func didSelectSaturationSetting() {
        self.delegate?.showSaturationSlider()
    }

    @objc private func didSelectWarmthSetting() {
        self.delegate?.showWarmthSlider()
    }

    @objc private func didSelectTintSetting() {
        self.delegate?.showTintSlider()
    }

    @objc private func didSelectHighlightsSetting() {
        self.delegate?.showHighlightsSlider()
    }

    @objc private func didSelectShadowsSetting() {
        self.delegate?.showShadowsSlider()
    }

    @objc private func didSelectVignetteSetting() {
        self.delegate?.showVignetteSlider()
    }
}


