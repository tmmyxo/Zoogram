//
//  RegistrationViewController.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 05.10.2022.
//

import UIKit

private enum RegistrationCards: CaseIterable {
    case emailView
    case usernameView
    case passwordView
    case profileGeneralInfoView
    case ageAndGenderView
}

class RegistrationViewController: UIViewController {

    private let viewModel: RegistrationViewModel
    private var activeViewType: RegistrationCards = .emailView
    private var actionToRunBeforeNavigationToNextCard: (() -> Void)?

    private var task: Task<Void, Error>?

    internal lazy var imagePicker = UIImagePickerController()
    private var hapticGenerator = UINotificationFeedbackGenerator()
    private var continueButtonYAnchorConstraint: NSLayoutConstraint!
    var shouldKeepKeyboardFromPreviousVC: Bool = false

    private var shouldEndEdditing: Bool = true
    private lazy var cardWidth: CGFloat = {
        return view.frame.width - 50
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 21, weight: .bold)
        let image = UIImage(systemName: "chevron.backward", withConfiguration: imageConfiguration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.tintColor = Colors.label
        button.contentVerticalAlignment = .fill
        button.sizeToFit()
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.clipsToBounds = false
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillProportionally
        stackView.spacing = 25
        return stackView
    }()

    private lazy var emailView: RegistrationForm = {
        let descriptionText = String(localized: "Enter your Email")
        let placeholder = String(localized: "Email")
        let view = RegistrationForm(descriptionText: descriptionText,
                                    textFieldPlaceholder: placeholder)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.naturalBackground
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        view.textFieldKeyboardType = .emailAddress
        view.contentType = .emailAddress
        view.delegate = self
        return view
    }()

    private lazy var usernameView: RegistrationForm = {
        let descriptionText = String(localized: "Create a username")
        let placeholder = String(localized: "Username")
        let view = RegistrationForm(descriptionText: descriptionText,
                                    textFieldPlaceholder: placeholder)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.naturalBackground
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        view.textFieldKeyboardType = .asciiCapable
        view.contentType = .username
        view.delegate = self
        return view
    }()

    private lazy var passwordView: RegistrationForm = {
        let descriptionText = String(localized: "Create a password")
        let placeholder = String(localized: "Password")
        let view = RegistrationForm(descriptionText: descriptionText,
                                    textFieldPlaceholder: placeholder,
                                    isPasswordForm: true)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.naturalBackground
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        view.textFieldKeyboardType = .asciiCapable
        view.contentType = .password
        view.delegate = self
        return view
    }()

    private lazy var generalProfileInfoCardView: GeneralProfileInfoCard = {
        let view = GeneralProfileInfoCard(profilePictureHeaderDelegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var continueButton: CustomButton = {
        let button = CustomButton()
        let title = String(localized: "Continue")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        return button
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.alpha = 0
        indicator.isHidden = true
        return indicator
    }()

    init(service: RegistrationServiceProtocol) {
        self.viewModel = RegistrationViewModel(service: service)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.naturalSecondaryBackground
        view.addSubviews(backButton, scrollView, continueButton, loadingIndicator)
        scrollView.addSubviews(stackView)
        stackView.addArrangedSubviews(emailView, usernameView, passwordView, generalProfileInfoCardView)
        setupConstraints()
        setupEdditingInteruptionGestures(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isMovingToParent && shouldKeepKeyboardFromPreviousVC {
            self.emailView.becomeResponder()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isMovingToParent && shouldKeepKeyboardFromPreviousVC == false {
            self.emailView.becomeResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.emailView.resignResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        task?.cancel()
    }

    private func setupConstraints() {
        self.continueButtonYAnchorConstraint = continueButton.topAnchor.constraint(equalTo: emailView.bottomAnchor, constant: 15)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            backButton.widthAnchor.constraint(equalToConstant: 35),
            backButton.heightAnchor.constraint(equalToConstant: 30),

            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            emailView.widthAnchor.constraint(equalToConstant: cardWidth),
            usernameView.widthAnchor.constraint(equalToConstant: cardWidth),
            passwordView.widthAnchor.constraint(equalToConstant: cardWidth),
            generalProfileInfoCardView.widthAnchor.constraint(equalToConstant: cardWidth),

            self.continueButtonYAnchorConstraint,
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -15),

            loadingIndicator.heightAnchor.constraint(equalTo: continueButton.heightAnchor),
            loadingIndicator.widthAnchor.constraint(equalTo: continueButton.heightAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor)
        ])
    }

    private func saveEmail(completion: @escaping () -> Void) {
        let email = emailView.getTextFieldData()

        guard viewModel.isValidEmail(email: email) else {
            self.hapticGenerator.notificationOccurred(.error)
            let error = String(localized: "Invalid email")
            emailView.showErrorNotification(error: error)
            return
        }
        task = Task {
            do {
                let isEmailAvailable = try await viewModel.checkIfEmailIsAvailable(email: email)

                if isEmailAvailable {
                    self.viewModel.email = email
                    self.emailView.removeErrorNotification()
                    completion()
                } else {
                    self.hapticGenerator.notificationOccurred(.error)
                    self.emailView.showErrorNotification(error: String(localized: "User with this email is already registered"))
                }
            } catch {
                showPopUp(issueText: error.localizedDescription)
            }
        }
    }

    private func saveUsername(completion: @escaping () -> Void) {
        let username = usernameView.getTextFieldData()

        task = Task {
            do {
                try viewModel.checkIfUsernameIsValid(username: username)
                let isUsernameAvailable = try await viewModel.checkIfUsernameIsAvailable(username: username)

                if isUsernameAvailable {
                    self.viewModel.username = username
                    self.usernameView.removeErrorNotification()
                    completion()
                } else {
                    self.hapticGenerator.notificationOccurred(.error)
                    self.usernameView.showErrorNotification(error: String(localized: "This username is already taken"))
                }
            } catch {
                self.showPopUp(issueText: error.localizedDescription)
            }
        }
    }

    private func savePassword(completion: @escaping () -> Void) {
        let password = passwordView.getTextFieldData()

        do {
            try viewModel.checkIfPasswordIsValid(password: password)
            self.viewModel.password = password
            self.passwordView.removeErrorNotification()
            completion()
        } catch {
            self.hapticGenerator.notificationOccurred(.error)
            self.passwordView.showErrorNotification(error: error.localizedDescription)
        }
    }

    private func saveNameAndBio(completion: @escaping () -> Void) {
        guard let name = generalProfileInfoCardView.getName(),
              name.isEmpty != true
        else {
            self.hapticGenerator.notificationOccurred(.error)
            generalProfileInfoCardView.showNameFieldIsEmptyError()
            return
        }
        let bio = generalProfileInfoCardView.getBio()
        viewModel.name = name
        viewModel.bio = bio
        generalProfileInfoCardView.removeEmptyErrorForName()
        completion()
    }

    private func saveGenderAndDateOfBirth(completion: @escaping () -> Void) {
        if let gender = generalProfileInfoCardView.getGender() {
            viewModel.gender = gender
        } else {
            generalProfileInfoCardView.showGenderNotSelectedError()
        }

        if let dateOfBirth = generalProfileInfoCardView.getDateOfBirth() {
            viewModel.dateOfBirth = dateOfBirth
        } else {
            generalProfileInfoCardView.showDateOfBirthNotSelectedError()
        }

        if viewModel.gender != nil && viewModel.dateOfBirth != nil {
            generalProfileInfoCardView.removeErrorStateForAgeAndGender()
            completion()
        } else {
            self.hapticGenerator.notificationOccurred(.error)
            return
        }
    }

    private func finishRegistration(completion: @escaping (ZoogramUser) -> Void) {
        task = Task {
            do {
                self.showRegistrationIndicator()
                self.continueButton.isUserInteractionEnabled = false
                self.backButton.isUserInteractionEnabled = false
                let registeredUser = try await viewModel.registerNewUser()
                completion(registeredUser)
            } catch {
                self.continueButton.isUserInteractionEnabled = true
                self.backButton.isUserInteractionEnabled = true
                self.showContinueButton()
                let errorText = String(localized: "\(error.localizedDescription). \nPlease try again later.")
                self.showPopUp(issueText: errorText)
            }
        }
    }

    private func showCardView<T: UIView & TextFieldResponder>(_ view: T, shouldBecomeFirstResponder: Bool = true) {
        self.continueButtonYAnchorConstraint.isActive = false
        self.continueButtonYAnchorConstraint = self.continueButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 15)
        self.continueButtonYAnchorConstraint.isActive = true
        if shouldBecomeFirstResponder {
            view.becomeResponder()
        }
        UIView.animate(withDuration: 0.5) {
            self.scrollView.setContentOffset(CGPoint(x: view.frame.minX, y: 0), animated: false)
            self.view.layoutIfNeeded()
        }
    }

    private func showMainScreen(for user: ZoogramUser) {
        UIView.animateKeyframes(withDuration: 1.6, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                self.loadingIndicator.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.8) {
                self.generalProfileInfoCardView.transform = CGAffineTransform(translationX: 0, y: -(self.view.frame.height - self.generalProfileInfoCardView.bounds.height))
                self.continueButton.transform = CGAffineTransform(translationX: 0, y: (self.view.frame.height - self.continueButton.bounds.minY))
                self.view.alpha = 0
                self.view.layoutIfNeeded()
            }
        } completion: { _ in
            NotificationCenter.default.post(name: .shouldListenToAuthenticationState, object: nil, userInfo: ["shouldListen": true])
            self.view.window?.rootViewController = TabBarController(for: user, showAppearAnimation: true)
            self.view.window?.makeKeyAndVisible()
        }
    }

    private func showRegistrationIndicator() {
        continueButton.shouldIgnoreOwnAnimations = true
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        loadingIndicator.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        continueButton.transform = .identity

        UIView.animateKeyframes(withDuration: 0.4, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.6) {
                self.continueButton.transform = CGAffineTransform(scaleX: 0.1, y: 1.0)
                self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2
            }
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3) {
                self.continueButton.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                self.loadingIndicator.alpha = 1
                self.loadingIndicator.transform = .identity
            }
        }
    }

    private func showContinueButton() {
        self.continueButton.isHidden = false
        self.continueButton.transform = CGAffineTransform(scaleX: 0.1, y: 1.0)
        UIView.animateKeyframes(withDuration: 0.4, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                self.loadingIndicator.alpha = 0
                self.loadingIndicator.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.4) {
                self.continueButton.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                self.continueButton.transform = .identity
                self.continueButton.layer.cornerRadius = 13
            }
        } completion: { _ in
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = true
        }
    }

    @objc func didTapBackButton() {
        switch activeViewType {
        case .emailView:
            navigationController?.popViewController(animated: true)
        case .usernameView:
            showCardView(emailView, shouldBecomeFirstResponder: false)
        case .passwordView:
            showCardView(usernameView, shouldBecomeFirstResponder: false)
        case .profileGeneralInfoView:
            showCardView(passwordView, shouldBecomeFirstResponder: false)
        case .ageAndGenderView:
            self.generalProfileInfoCardView.flipToGeneralProfileInfoView()
            self.continueButton.shouldIgnoreOwnAnimations = false
            self.continueButton.setTitle(String(localized: "Continue"), for: .normal)
        }
        self.activeViewType = activeViewType.previous()
    }

    @objc func didTapContinueButton() {
        switch activeViewType {
        case .emailView:
            saveEmail {
                self.showCardView(self.usernameView)
                self.activeViewType = .usernameView
            }
        case .usernameView:
            saveUsername {
                self.showCardView(self.passwordView)
                self.activeViewType = .passwordView
            }
        case .passwordView:
            savePassword {
                self.passwordView.resignResponder()
                self.showCardView(self.generalProfileInfoCardView, shouldBecomeFirstResponder: false)
                self.activeViewType = .profileGeneralInfoView
            }
        case .profileGeneralInfoView:
            saveNameAndBio {
                self.generalProfileInfoCardView.flipToAgeAndGenderView()
                self.continueButton.setTitle(String(localized: "Finish"), for: .normal)
                self.generalProfileInfoCardView.resignResponder()
                self.activeViewType = .ageAndGenderView
            }
        case .ageAndGenderView:
            saveGenderAndDateOfBirth {
                self.view.endEditing(true)
                self.finishRegistration { registeredUser in
                    self.showMainScreen(for: registeredUser)
                }
            }
        }
    }
}

extension RegistrationViewController: ProfilePictureViewDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.generalProfileInfoCardView.updateProfileHeaderPicture(with: selectedImage)
            self.viewModel.profilePicture = selectedImage
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapContinueButton()
        return true
    }
}

extension RegistrationViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.name == Gestures.touchEndEdditing.rawValue && touch.view == continueButton {
            return false
        } else {
            return true
        }
    }
}
