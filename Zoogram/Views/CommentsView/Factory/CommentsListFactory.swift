//
//  CommentsListFactory.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 24.05.2023.
//

import UIKit

@MainActor class CommentListFactory {

    private var tableView: UITableView

    var sections = [TableSectionController]()

    private var postSection: PostSection?
    private var captionSection: CaptionSection?
    private var commentsSection: CommentSection!

    private let delegate: CommentsTableViewDelegateProtocol
    private let shouldShowRelatedPost: Bool

    init(for tableView: UITableView, shouldShowRelatedPost: Bool, delegate: CommentsTableViewDelegateProtocol) {
        self.tableView = tableView
        self.delegate = delegate
        self.shouldShowRelatedPost = shouldShowRelatedPost
    }

    func buildSections(for viewModel: CommentsViewModel) {

        if shouldShowRelatedPost {
            let postController = createPostController(postViewModel: viewModel.postViewModel)
            postSection = PostSection(sectionHolder: tableView, cellControllers: [postController], sectionIndex: 0)
            sections.append(postSection!)
        } else {
            if let caption = viewModel.postCaption {
                let captionController = CommentCellController(comment: caption, isAPostCaption: true, delegate: self.delegate)
                captionSection = CaptionSection(sectionHolder: tableView, cellControllers: [captionController], sectionIndex: 0)
                sections.append(captionSection!)
            }
        }

        let commentsControllers = viewModel.comments.map { comment in
            CommentCellController(comment: comment, delegate: self.delegate)
        }
        let commentSectionIndex = (postSection != nil || captionSection != nil) ? 1 : 0
        commentsSection = CommentSection(sectionHolder: tableView, cellControllers: commentsControllers, sectionIndex: commentSectionIndex)
        sections.append(commentsSection!)
    }

    func createPostController(postViewModel: PostViewModel) -> PostCellController {
        return PostCellController(viewModel: postViewModel, delegate: self.delegate)
    }

    func getCommentSectionIndex() -> SectionIndex {
        return commentsSection.sectionIndex
    }

    func insertComment(with comment: PostComment, at indexPath: IndexPath, completion: @escaping () -> Void) {
        let cellController = CommentCellController(comment: comment, delegate: self.delegate)
        commentsSection.insertCell(with: cellController, at: indexPath.row)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion()
        }
    }

    func deleteComment(at indexPath: IndexPath) {
        commentsSection.removeCellController(at: indexPath)
        tableView.performBatchUpdates {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func markCommentAsSeen(at indexPath: IndexPath) {
        guard let commentController = commentsSection.cellController(at: indexPath) as? CommentCellController else { return }
        commentController.markAsSeen()
    }

    func focusOnComment(at indexPath: IndexPath) {
        guard let commentController = commentsSection.cellController(at: indexPath) as? CommentCellController else { return }
        commentController.focus()
    }

    func markCommentasPublished(at indexPath: IndexPath) {
        guard let commentController = commentsSection.cellController(at: indexPath) as? CommentCellController else { return }
        commentController.markAsPublished()
    }
}
