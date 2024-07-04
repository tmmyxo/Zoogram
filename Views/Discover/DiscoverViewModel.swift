//
//  DiscoverViewModel.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 21.10.2022.
//

import Foundation

@MainActor
class DiscoverViewModel {

    private var service: any DiscoverServiceProtocol

    var foundUsers = Observable([ZoogramUser]())
    var posts = Observable([PostViewModel]())

    init(service: any DiscoverServiceProtocol) {
        self.service = service
    }

    func isPaginationAllowed() async -> Bool {
        let isPaginating = await service.paginationManager.isPaginating()
        let hasHitTheEndOfPosts = await service.checkIfHasHitEndOfItems()
        return hasHitTheEndOfPosts == false && isPaginating == false
    }

    func getPostsToDiscover() async throws -> [PostViewModel] {
        let retrievedPosts = try await service.getItems()
        if let retrievedPosts = retrievedPosts {
            posts.value = retrievedPosts.map({ post in
                return PostViewModel(post: post)
            })
        }
        return posts.value
    }

    func getMorePostsToDiscover() async throws -> [PostViewModel]? {
        let paginatedPosts = try await service.getMoreItems()
        if let paginatedPosts = paginatedPosts {
            let viewModels = paginatedPosts.map({ post in
                return PostViewModel(post: post)
            })
            posts.value.append(contentsOf: viewModels)
            return viewModels
        } else {
            return nil
        }
    }

    func searchUser(for input: String) async throws {
        guard input.isEmpty == false else {
            foundUsers.value = []
            return
        }
        foundUsers.value = try await service.searchUserWith(username: input)
    }

    func hasHitTheEndOfPosts() async -> Bool {
        return await service.checkIfHasHitEndOfItems()
    }

    func hasLoadedData() async -> Bool {
        let numberOfRetrievedItems = await service.paginationManager.getNumberOfRetrievedItems()
        let numberOfAllItems = await service.paginationManager.getNumberOfAllItems()
        let numberOfItemsToGet = service.paginationManager.numberOfItemsToGetPerPagination
        let hasntRetrievedPosts = numberOfRetrievedItems == 0
        let numberOfReceivedItemsIsLessThanRequired = numberOfRetrievedItems < numberOfItemsToGet
        let hasntRetrievedAllPosts = numberOfRetrievedItems < numberOfAllItems
        let retrievedLessPostsThanRequired = numberOfReceivedItemsIsLessThanRequired && hasntRetrievedAllPosts

        if hasntRetrievedPosts || retrievedLessPostsThanRequired {
            return false
        } else {
            return true
        }
    }
}