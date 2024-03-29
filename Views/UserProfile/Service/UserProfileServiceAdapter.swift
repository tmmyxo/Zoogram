//
//  UserProfileServiceAdapter.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 11.04.2023.
//

import Foundation

typealias HasHitTheEnd = Bool

class UserProfileServiceAPIAdapter: UserProfileService, ImageService {

    var numberOfPostsToGet: UInt = 12

    var userID: String

    let followService: FollowSystemService
    let userPostsService: UserPostsService
    let userService: UserService
    let likeSystemService: LikeSystemService
    let bookmarksService: BookmarksService

    var dispatchGroup: DispatchGroup
    var lastReceivedPostKey: String = ""
    var isAlreadyPaginating: Bool = false
    var isPaginationAllowed: Bool = true
    var hasHitTheEndOfPosts: HasHitTheEnd = false

    init(userID: String, followService: FollowSystemService, userPostsService: UserPostsService, userService: UserService, likeSystemService: LikeSystemService, bookmarksService: BookmarksService) {
        self.userID = userID
        self.followService = followService
        self.userPostsService = userPostsService
        self.userService = userService
        self.likeSystemService = likeSystemService
        self.bookmarksService = bookmarksService
        self.dispatchGroup = DispatchGroup()
    }

    func getFollowersCount(completion: @escaping (Int) -> Void) {
        followService.getFollowersNumber(for: userID) { followersCount in
            completion(followersCount)
        }
    }

    func getFollowingCount(completion: @escaping (Int) -> Void) {
        followService.getFollowingNumber(for: userID) { followingCount in
            completion(followingCount)
        }
    }

    func getPostsCount(completion: @escaping (Int) -> Void) {
        userPostsService.getPostCount(for: userID) { postsCount in
            completion(postsCount)
        }
    }

    func getUserData(completion: @escaping (ZoogramUser) -> Void) {
        userService.getUser(for: userID) { user in
            let url = URL(string: user.profilePhotoURL)
            self.getImage(for: user.profilePhotoURL) { profilePhoto in
                user.profilePhoto = profilePhoto
                completion(user)
            }
        }
    }

    func getPosts(completion: @escaping ([PostViewModel]) -> Void) {
        userPostsService.getPosts(quantity: numberOfPostsToGet, for: userID) { [weak self] posts, lastObtainedPostKey in
            self?.lastReceivedPostKey = lastObtainedPostKey
            print("got user profile posts")
            print(posts)
            self?.getAdditionalPostDataFor(postsOfSingleUser: posts) { postsWithAdditionalData in
                print("got additional data for profile posts")
                print("posts count: \(postsWithAdditionalData.count)")
                completion(postsWithAdditionalData.map { post in
                    PostViewModel(post: post)
                })
            }
            if posts.count < self!.numberOfPostsToGet {
                self?.hasHitTheEndOfPosts = true
                self?.isPaginationAllowed = false
            } else {
                self?.hasHitTheEndOfPosts = false
                self?.isPaginationAllowed = true
            }
        }
    }

    func getMorePosts(completion: @escaping ([PostViewModel]?) -> Void) {
        print("Last postKey: ", lastReceivedPostKey)
        guard isAlreadyPaginating == false, lastReceivedPostKey != "" else {
            print("isAlreadyPaginating: \(isAlreadyPaginating)")
            return
        }
        isAlreadyPaginating = true
        isPaginationAllowed = false
        userPostsService.getMorePosts(quantity: numberOfPostsToGet, after: lastReceivedPostKey, for: userID) { [weak self] posts, lastDownloadedPostKey in
            guard posts.isEmpty != true, lastDownloadedPostKey != self?.lastReceivedPostKey else {
                self?.hasHitTheEndOfPosts = true
                self?.isAlreadyPaginating = false
                self?.isPaginationAllowed = false
                print("has hit the end of user posts")
                completion(nil)
                return
            }
            print("Last received postKey: ", lastDownloadedPostKey)
            print("got more posts for user")
            self?.lastReceivedPostKey = lastDownloadedPostKey
            self?.getAdditionalPostDataFor(postsOfSingleUser: posts) { postsWithAdditionalData in
                print("got additional post data for single user")
                self?.isAlreadyPaginating = false
                let postsViewModels = postsWithAdditionalData.map({ post in
                    PostViewModel(post: post)
                })
                completion(postsViewModels)
            }
        }
    }

    func followUser(completion: @escaping (FollowStatus) -> Void) {
        followService.followUser(uid: userID) { followStatus in
            completion(followStatus)
        }
    }

    func unfollowUser(completion: @escaping (FollowStatus) -> Void) {
        followService.unfollowUser(uid: userID) { [userID] followStatus in
            ActivitySystemService.shared.removeFollowEventForUser(userID: userID)
            completion(followStatus)
        }
    }

    func likePost(postID: String, likeState: LikeState, postAuthorID: String, completion: @escaping (LikeState) -> Void) {
        switch likeState {
        case .liked:
            likeSystemService.removePostLike(postID: postID) { result in
                switch result {
                case .success(let description):
                    ActivitySystemService.shared.removeLikeEventForPost(postID: postID, postAuthorID: postAuthorID)
                    print(description)
                    completion(.notLiked)
                case .failure(let error):
                    print(error)
                    completion(.liked)
                }
            }
        case .notLiked:
            likeSystemService.likePost(postID: postID) { result in
                switch result {
                case .success(let description):

                    let activityEvent = ActivityEvent.createActivityEventFor(likedPostID: postID)

                    ActivitySystemService.shared.addEventToUserActivity(event: activityEvent, userID: postAuthorID)
                    print(description)
                    completion(.liked)

                case .failure(let error):
                    print(error)
                    completion(.notLiked)
                }
            }
        }
    }

    func deletePost(postModel: PostViewModel, completion: @escaping () -> Void) {
        print("inside service adapter delete post method")
        userPostsService.deletePost(postID: postModel.postID, postImageURL: postModel.postImageURL) {
            completion()
        }
    }

    func bookmarkPost(postID: String, authorID: String, bookmarkState: BookmarkState, completion: @escaping (BookmarkState) -> Void) {

        switch bookmarkState {
        case .bookmarked:
            bookmarksService.removeBookmark(postID: postID) { bookmarkState in
                completion(bookmarkState)
                print("Successfully removed a bookmark")
            }
        case .notBookmarked:
            bookmarksService.bookmarkPost(postID: postID, authorID: authorID) { bookmarkState in
                completion(bookmarkState)
                print("Successfully bookmarked a post")
            }
        }

    }
}

func createUserProfileDefaultServiceFor(userID: String) -> UserProfileServiceAPIAdapter {
    UserProfileServiceAPIAdapter(userID: userID,
                                 followService: FollowSystemService.shared,
                                 userPostsService: UserPostsService.shared,
                                 userService: UserService.shared,
                                 likeSystemService: LikeSystemService.shared,
                                 bookmarksService: BookmarksService.shared)
}
