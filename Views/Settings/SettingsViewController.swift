//
//  SettingsViewController.swift
//  Zoogram
//
//  Created by Artem Dolbiev on 18.01.2022.
//

import UIKit
import FirebaseAuth

struct SettingsCellModel {
    let title: String
    let color: UIColor
    let handler: (() -> Void)
}

final class SettingsViewController: UIViewController {
    
    private var data = [[SettingsCellModel]]()
    
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureModels()
        tableView.delegate = self
        tableView.dataSource = self
        view = tableView
    }
    
    private func configureModels() {
        
        data.append([
            SettingsCellModel(title: "Edit Profile", color: .label) { [weak self] in
                self?.didTapEditProfile()
            },
            SettingsCellModel(title: "Bookmarks", color: .label, handler: {
                self.didTapBookmarks()
            }),
            SettingsCellModel(title: "Invite Friends", color: .label) { [weak self] in
                self?.didTapInviteFriends()
            },
            SettingsCellModel(title: "Download Original Posts", color: .label) { [weak self] in
                self?.didTapDownloadPosts()
            }
        ])
        
        data.append([
            SettingsCellModel(title: "Terms of Service", color: .label) { [weak self] in
                self?.didTapTermsofService()
            },
            SettingsCellModel(title: "Privacy Policy", color: .label) { [weak self] in
                self?.didTapPrivacyPolicy()
            },
            SettingsCellModel(title: "Help & Feedback", color: .label) { [weak self] in
                self?.didTapHelpandFeedback()
            }
        ])
        
        data.append([SettingsCellModel(title: "Log Out", color: .systemRed) { [weak self] in
            self?.didTapLogOut()
            }
        ])
    }
    
    private func didTapEditProfile() {
//        let navVC = UINavigationController(rootViewController: ProfileEdditingViewController())
//        navVC.modalPresentationStyle = .fullScreen
//        present(navVC, animated: true)
    }
    
    private func didTapBookmarks() {
        let bookmarksVC = BookmarkedTableViewController()
        navigationController?.pushViewController(bookmarksVC, animated: true)
    }
    
    private func didTapInviteFriends() {
        
    }
    
    private func didTapDownloadPosts() {
        
    }
    
    private func didTapTermsofService() {
        
    }
    
    private func didTapPrivacyPolicy() {
        
    }
    
    private func didTapHelpandFeedback() {
        
    }
    
    private func didTapLogOut() {
        let logoutAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            AuthenticationManager.shared.signOut { success in
                if success {
                    
                    UIView.animateKeyframes(withDuration: 0.5, delay: 0) {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                            self.view.alpha = 0
                            self.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        }
                        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                
                                sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
                            }
                        }
                    } completion: { _ in
                        
                    }
                } else {
                    fatalError("Could not log out user")
                    // error occured
                }
            }
        }
        logoutAlert.addAction(logOutAction)
        logoutAlert.addAction(cancelAction)
        present(logoutAlert, animated: true)
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsCell = data[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = settingsCell.title
        content.textProperties.color = settingsCell.color
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = data[indexPath.section][indexPath.row]
        model.handler()
    }
}
