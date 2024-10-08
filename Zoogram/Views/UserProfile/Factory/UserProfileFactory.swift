//
//  UserProfileFactory.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 19.07.2023.
//

import UIKit.UICollectionView

protocol UserProfileCollectionViewDelegate: ProfileHeaderDelegate, PaginationIndicatorCellDelegate {}

@MainActor class UserProfileFactory {

    weak var delegate: UserProfileCollectionViewDelegate?
    private let collectionView: UICollectionView
    private var sections = [CollectionSectionController]()
    private var headerSection: ProfileHeaderSection?
    private var postsSection: PostsSection?
    private var paginationIndicatorSection: PaginationIndicatorSection?
    private var paginationIndicatorController: PaginationIndicatorController?
    var postCellAction: ((IndexPath) -> Void)?

    init(for collectionView: UICollectionView) {
        self.collectionView = collectionView
    }

    func buildSections(profileViewModel: UserProfileViewModel) {
        self.sections.removeAll()
        let headerController = ProfileHeaderController(for: profileViewModel)
        headerController.delegate = delegate
        let headerSection = ProfileHeaderSection(bio: profileViewModel.bio, sectionHolder: collectionView, cellControllers: [headerController], sectionIndex: 0)
        self.headerSection = headerSection
        sections.append(headerSection)

        guard profileViewModel.posts.isEmpty != true else {
            let noPostsSection = NoPostsSection(sectionHolder: collectionView, cellControllers: [NoPostsCellController()], sectionIndex: 1)
            sections.append(noPostsSection)
            return
        }
        let postsSection = createPostsSection(with: profileViewModel.posts)
        self.postsSection = postsSection
        sections.append(postsSection)

        let paginationIndicatorSection = PaginationIndicatorSection(sectionHolder: collectionView, cellControllers: [], sectionIndex: 2)
        self.paginationIndicatorSection = paginationIndicatorSection
        sections.append(paginationIndicatorSection)
    }

    func refreshProfileHeader(with viewModel: UserProfileViewModel) {
        guard let headerSectionIndex = headerSection?.sectionIndex else { return }
        let headerController = ProfileHeaderController(for: viewModel)
        headerController.delegate = delegate
        self.headerSection?.cellControllers = [headerController]
        self.collectionView.reloadSections(IndexSet(integer: headerSectionIndex))
    }

    func getSections() -> [CollectionSectionController] {
        return self.sections
    }

    func refreshPostsSection(with posts: [PostViewModel]) {
        postsSection = createPostsSection(with: posts)
    }

    func updatePostsSection(with posts: [PostViewModel], completion: @escaping () -> Void) {
        guard let postsCountBeforeUpdate = postsSection?.numberOfCells() else { return }
        let cellControllers = posts.map { postViewModel in
            CollectionPostController(post: postViewModel) { indexPath in
                self.postCellAction?(indexPath)
            }
        }
        postsSection?.appendCellControllers(controllers: cellControllers)

        guard let postsCountAfterUpdate = self.postsSection?.numberOfCells() else { return }
        let indexPaths = (postsCountBeforeUpdate ..< postsCountAfterUpdate).map {
            IndexPath(row: $0, section: 1)
        }
        self.collectionView.performBatchUpdates {
            self.collectionView.insertItems(at: indexPaths)
        } completion: { _ in
            completion()
        }
    }

    func hideLoadingFooter() {
        guard paginationIndicatorController != nil,
        let sectionIndex = paginationIndicatorSection?.sectionIndex else {
            return
        }
        paginationIndicatorSection?.cellControllers.removeAll()
        paginationIndicatorController = nil
        collectionView.reloadSections(IndexSet(integer: sectionIndex))
    }

    func showLoadingIndicator() {
        guard paginationIndicatorController == nil else {
            if let paginationCell = paginationIndicatorController?.cell as? PaginationIndicatorCell {
                paginationCell.showLoadingIndicator()
            }
            return
        }
        paginationIndicatorSection?.cellControllers.removeAll()
        guard let sectionIndex = paginationIndicatorSection?.sectionIndex else { return }
        let paginationIndicatorController = PaginationIndicatorController()
        self.paginationIndicatorController = paginationIndicatorController
        paginationIndicatorSection?.cellControllers.append(paginationIndicatorController)
        collectionView.reloadSections(IndexSet(integer: sectionIndex))
    }

    func showPaginationRetryButton(error: Error) {
        guard let sectionIndex = paginationIndicatorSection?.sectionIndex else { return }
        guard let paginationCell = collectionView.cellForItem(at: IndexPath(row: 0, section: sectionIndex)) as? PaginationIndicatorCell
        else { return }
        paginationCell.delegate = self.delegate
        paginationCell.displayLoadingError(error)
    }

    private func createPostsSection(with posts: [PostViewModel]) -> PostsSection {
        let cellControllers = posts.map { postViewModel in
            CollectionPostController(post: postViewModel) { indexPath in
                self.postCellAction?(indexPath)
            }
        }
        return PostsSection(sectionHolder: collectionView, cellControllers: cellControllers, sectionIndex: 1)
    }

    func getPostsSectionIndex() -> SectionIndex? {
        return postsSection?.sectionIndex
    }

}
