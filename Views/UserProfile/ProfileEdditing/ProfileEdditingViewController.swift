//
//  ProfileEdditingViewController.swift
//  Zoogram
//
//  Created by Artem Dolbiev on 19.01.2022.
//
import UIKit

class ProfileEdditingViewController: UIViewController {

    let viewModel = ProfileEdditingViewModel()
    let profileImage: UIImage
    var imagePicker = UIImagePickerController()

    var profilePictureHeaderView: ProfilePictureHeader = {
        let header = ProfilePictureHeader()
        header.backgroundColor = .systemBackground
        return header
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        tableView.register(ProfileEdditingSectionHeader.self, forHeaderFooterViewReuseIdentifier: ProfileEdditingSectionHeader.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.sectionHeaderTopPadding = .leastNormalMagnitude
        return tableView
    }()

    init(userProfileViewModel: UserProfileViewModel) {
        self.profileImage = userProfileViewModel.user.profilePhoto ?? UIImage()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        profilePictureHeaderView.delegate = self
        view.addSubview(tableView)
        setupConstraints()
        tableView.dataSource = self
        tableView.delegate = self
        profilePictureHeaderView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 180)

        tableView.tableHeaderView = profilePictureHeaderView
        title = "Edit Profile"
        view.backgroundColor = .systemBackground
        configureNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        profilePictureHeaderView.configure(with: profileImage)
    }

    override func viewDidAppear(_ animated: Bool) {
        viewModel.getUserProfileData {
            self.tableView.reloadData()
        }
    }

    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSave))

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapCancel))

        navigationItem.leftBarButtonItem?.tintColor = .label
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc func didTapSave() {
        viewModel.saveChanges {
            print("saved changes")

            self.dismiss(animated: true)
        }
    }

    @objc func didTapCancel() {
        self.dismiss(animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.models.count
    }
}

extension ProfileEdditingViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.models[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.models[indexPath.section][indexPath.row]
        let cell: FormTableViewCell = tableView.dequeue(withIdentifier: FormTableViewCell.identifier, for: indexPath)
        cell.configure(with: model )
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else {
            return nil
        }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProfileEdditingSectionHeader.identifier) as? ProfileEdditingSectionHeader
        view?.title.text = "Private Info"
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 80
        } else {
            return 0
        }
    }
}

extension ProfileEdditingViewController: FormTableViewCellDelegate {

    func formTableViewCell(didUpdateModel model: EditProfileFormModel) {
        viewModel.hasEdditedUserProfile(data: model)
    }
}

extension ProfileEdditingViewController: ProfilePictureHeaderProtocol {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.viewModel.newProfilePicture = selectedImage
            self.profilePictureHeaderView.configure(with: selectedImage)
            self.viewModel.hasChangedProfilePic = true
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
