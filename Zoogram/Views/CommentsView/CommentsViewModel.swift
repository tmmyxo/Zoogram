//
//  PostWithCommentsViewModel.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 17.05.2023.
//

import Foundation
import UIKit

@MainActor
class CommentsViewModel {

    private let service: CommentsServiceProtocol

    private var currentUser: ZoogramUser!
    var shouldShowRelatedPost: Bool
    var hasAlreadyFocusedOnComment: Bool = true
    var commentSectionIndex: Int = 0
    var indexPathOfCommentToToFocusOn: IndexPath?
    var postViewModel: PostViewModel
    var postCaption: PostComment?
    var comments = [PostComment]()
    var hasPendingComments: Bool = false
    private var commentIDToFocusOn: String?
    private var relatedPost: UserPost?

    init(post: UserPost, commentIDToFocusOn: String?, shouldShowRelatedPost: Bool, service: CommentsServiceProtocol) {
        self.service = service
        self.commentIDToFocusOn = commentIDToFocusOn
        self.shouldShowRelatedPost = shouldShowRelatedPost
        self.postViewModel = PostViewModel(post: post)
        self.relatedPost = post
    }

    init(postViewModel: PostViewModel, commentIDToFocusOn: String?, shouldShowRelatedPost: Bool, service: CommentsServiceProtocol) {
        self.service = service
        self.commentIDToFocusOn = commentIDToFocusOn
        self.shouldShowRelatedPost = shouldShowRelatedPost
        self.postViewModel = postViewModel
        self.postCaption = createPostCaptionForCommentArea(with: postViewModel)
    }

    func getCurrentUserModel() async {
        let currentUser = await UserManager.shared.getCurrentUser()
        self.currentUser = currentUser
    }

    func fetchData() async throws {
        if let post = self.relatedPost {
            let postWithAdditionalData = try await service.getAdditionalPostData(for: post)
            self.postViewModel = PostViewModel(post: postWithAdditionalData)
        }

        let comments = try await service.getComments()
        self.comments = comments.reversed().enumerated().map({ index, comment in
            var mappedComment = comment
            if mappedComment.commentID == self.commentIDToFocusOn {
                self.indexPathOfCommentToToFocusOn = IndexPath(row: index, section: 1)
                self.hasAlreadyFocusedOnComment = false
            }
            mappedComment.canBeEdited = self.checkIfCommentCanBeEdited(comment: mappedComment)
            return mappedComment
        })
    }

    func checkIfCommentCanBeEdited(comment: PostComment) -> Bool {
        if comment.authorID == currentUser.userID || postViewModel.author.userID == currentUser.userID {
            return true
        } else {
            return false
        }
    }

    func createPostCaptionForCommentArea(with postViewModel: PostViewModel?) -> PostComment? {
        guard let postViewModel = postViewModel, let caption = postViewModel.unAttributedPostCaption else {
            return nil
        }
        let postCaption = PostComment(
            commentID: "",
            authorID: postViewModel.author.userID,
            commentText: caption,
            datePosted: postViewModel.postedDate,
            author: postViewModel.author)

        return postCaption
    }

    func getCurrentUserProfilePicture() -> UIImage {
        return currentUser.getProfilePhoto() ?? UIImage.profilePicturePlaceholder
    }

    private func getPostCaption() -> PostComment? {
        if shouldShowRelatedPost {
            return nil
        } else {
            let postCaption = createPostCaptionForCommentArea(with: self.postViewModel)
            return postCaption
        }
    }

    func getPostViewModel() -> PostViewModel {
        return self.postViewModel
    }

    func insertNewComment(comment: PostComment) {
        var commentToInsert = comment
        self.comments.insert(commentToInsert, at: 0)
        self.indexPathOfCommentToToFocusOn = IndexPath(row: 0, section: commentSectionIndex)
    }

    func getIndexPathOfComment(_ comment: PostComment) -> IndexPath {
        let commentID = comment.commentID
        var commentIndex: Int?
        _ = comments.enumerated().map { (index, comment) in
            if comment.commentID == commentID {
                commentIndex = index
            }
        }
        if let commentIndex = commentIndex {
            return IndexPath(row: commentIndex, section: commentSectionIndex)
        } else {
            fatalError()
        }
    }

    func getComments() -> [PostComment] {
        return self.comments
    }

    func getComment(for indexPath: IndexPath) -> PostComment {
        return comments[indexPath.row]
    }

    func getLatestComment() -> PostComment? {
        return comments.first
    }

    func createPostComment(text: String) throws -> PostComment {
        let commentUID = CommentSystemService.shared.createCommentUID()
        let currentUserID = try AuthenticationService.shared.getCurrentUserUID()
        let formattedText = text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        var postComment = PostComment(commentID: commentUID,
                                     authorID: currentUserID,
                                     commentText: formattedText,
                                     datePosted: Date(),
                                     author: currentUser)
        postComment.canBeEdited = true
        postComment.shouldBeMarkedUnseen = true
        postComment.hasBeenPosted = false
        return postComment
    }

    func postComment(comment: PostComment) async throws {
        hasPendingComments = true
        try await service.postComment(comment: comment)
        hasPendingComments = false
    }

    func deleteComment(at indexPath: IndexPath) async throws {
        let comment = comments[indexPath.row]

        try await service.deleteComment(commentID: comment.commentID)
        self.comments.remove(at: indexPath.row)
    }

    func deleteThisPost() async throws {
        let postViewModel = self.postViewModel
        try await service.deletePost(postModel: postViewModel)
    }

    func likeThisPost() async throws {
        try await service.likePost(
            postID: postViewModel.postID,
            likeState: postViewModel.likeState,
            postAuthorID: postViewModel.author.userID)
        postViewModel.switchLikeState()
    }

    func bookmarkThisPost() async throws {
        var postViewModel = self.postViewModel
        try await service.bookmarkPost(
            postID: postViewModel.postID,
            authorID: postViewModel.author.userID,
            bookmarkState: postViewModel.bookmarkState)
        postViewModel.switchBookmarkState()
    }
}
