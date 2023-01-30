//
//  HomeFeedService.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 27.12.2022.
//

import Foundation
import FirebaseDatabase

class HomeFeedService {
    
    static let shared = HomeFeedService()
    
    private let databaseRef = Database.database(url: "https://catogram-58487-default-rtdb.europe-west1.firebasedatabase.app").reference()
    
    
    func getPostsForTimeline(completion: @escaping ([UserPost], String) -> Void) {
        
        let currentUserID = AuthenticationManager.shared.getCurrentUserUID()
        
        databaseRef.child("Timelines/\(currentUserID)").queryOrderedByKey().queryLimited(toLast: 12).observeSingleEvent(of: .value) { snapshot in
            
            var retrievedPosts = [UserPost]()
            var lastReceivedPost = ""
            let dispatchGroup = DispatchGroup()
            
            for snapshotChild in snapshot.children.reversed() {
                
                guard let postSnapshot = snapshotChild as? DataSnapshot,
                      let postDictionary = postSnapshot.value as? [String : Any]
                else {
                    print("Error while creating post dictionary from snapshot")
                    return
                }
                dispatchGroup.enter()
                lastReceivedPost = postSnapshot.key
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: postDictionary as Any)
                    let userPost = try JSONDecoder().decode(UserPost.self, from: jsonData)
                
                    UserService.shared.getUser(for: userPost.userID) { postAuthor in
                        userPost.author = postAuthor
                        retrievedPosts.append(userPost)
                        print("DECODED FEED POST:", userPost)
                        dispatchGroup.leave()
                    }
                } catch {
                    print("Couldn't create post object from dictionary")
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(retrievedPosts, lastReceivedPost)
            }
        }
    }
    
    func getMorePostsForTimeline(after lastSeenPostKey: String, completion: @escaping ([UserPost], String) -> Void) {
        
        let currentUserID = AuthenticationManager.shared.getCurrentUserUID()
        
        databaseRef.child("Timelines/\(currentUserID)").queryOrderedByKey().queryEnding(beforeValue: lastSeenPostKey).queryLimited(toLast: 12).observeSingleEvent(of: .value) { snapshot in
            
            var retrievedPosts = [UserPost]()
            var lastReceivedPost = ""
            let dispatchGroup = DispatchGroup()
            
            for snapshotChild in snapshot.children.reversed() {
                
                guard let postSnapshot = snapshotChild as? DataSnapshot,
                      let postDictionary = postSnapshot.value as? [String : Any]
                else {
                    print("Error while creating post dictionary from snapshot")
                    return
                }
                dispatchGroup.enter()
                lastReceivedPost = postSnapshot.key
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: postDictionary as Any)
                    let userPost = try JSONDecoder().decode(UserPost.self, from: jsonData)
                    
                    UserService.shared.getUser(for: userPost.userID) { postAuthor in
                        userPost.author = postAuthor
                        retrievedPosts.append(userPost)
                        dispatchGroup.leave()
                    }
                    
                } catch {
                    print("Couldn't create post object from dictionary")
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(retrievedPosts, lastReceivedPost)
            }
        }
    }
    
}
