//
//  ProfileEdditingViewModel.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 01.10.2022.
//

import Foundation
import SDWebImage

enum ProfileFormKind {
    case name, username, bio, phone, email, gender
}

struct EditProfileFormModel {
    let label: String
    let placeholder: String
    var value: String?
    let formKind: ProfileFormKind
}

class ProfileEdditingViewModel {

    var name: String = ""
    var username: String = ""
    var bio: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    var profilePictureURL: String = ""
    var gender: String = ""
    var newProfilePicture: UIImage?

    var hasChangedProfilePic: Bool = false
    var models = [[EditProfileFormModel]]()
    var changedValues = [String: Any]()

    func getUserProfileData(completion: @escaping () -> Void) {
        UserService.shared.observeUser(for: AuthenticationManager.shared.getCurrentUserUID()) { user in
            self.name = user.name
            self.username = user.username
            self.bio = user.bio ?? ""
            self.email = user.email
            self.phoneNumber = user.phoneNumber ?? ""
            self.profilePictureURL = user.profilePhotoURL
            self.gender = user.gender ?? "Not Specified"
            self.configureModels()
            completion()
        }
    }

    func configureModels() {
        models.removeAll()
        let section1 = [EditProfileFormModel(label: "Name", placeholder: "Name", value: name, formKind: .name),
                        EditProfileFormModel(label: "Username", placeholder: "Username", value: username, formKind: .username),
                        EditProfileFormModel(label: "Bio", placeholder: "Bio", value: bio, formKind: .bio)]
        models.append(section1)

        let section2 = [EditProfileFormModel(label: "Phone", placeholder: "Phone", value: phoneNumber, formKind: .phone),
                        EditProfileFormModel(label: "Email", placeholder: "Email", value: email, formKind: .email),
                        EditProfileFormModel(label: "Gender", placeholder: "Gender", value: gender, formKind: .gender)]
        models.append(section2)
    }

    func getProfilePicture(completion: @escaping (UIImage) -> Void) {
        print(name, username, bio, email)
        let url = URL(string: profilePictureURL)
        SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { image, data, error, cache, bool, url in
            if let image = image {
                completion(image)
            }
        }
    }

    func hasEdditedUserProfile(data: EditProfileFormModel) {
        switch data.formKind {
        case .name:
            changedValues["name"] = data.value
        case .username:
            changedValues["username"] = data.value
        case .bio:
            changedValues["bio"] = data.value
        case .email:
            changedValues["email"] = data.value
        case .phone:
            changedValues["phoneNumber"] = data.value
        case .gender:
            changedValues["gender"] = data.value
        }
    }

    func saveChanges(completion: @escaping () -> Void) {
        if hasChangedProfilePic {
            print("inside hasChangedProfilePic")
            UserService.shared.updateUserProfilePicture(newProfilePic: newProfilePicture!)

            UserService.shared.updateUserProfile(with: self.changedValues) {
                completion()
            }
        } else {
            print("Changed values", changedValues)
            print("inside updateUserProfile")
            UserService.shared.updateUserProfile(with: self.changedValues) {
                print("finished updating profile data")
                completion()
            }
        }
    }
}
