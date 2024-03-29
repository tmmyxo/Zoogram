//
//  LikeSystemServicce.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 27.12.2022.
//

import Foundation
import FirebaseDatabase

class LikeSystemService {
    
    static let shared = LikeSystemService()
    
    private let databaseRef = Database.database(url: "https://catogram-58487-default-rtdb.europe-west1.firebasedatabase.app").reference()
    
    typealias LikesCount = Int
    
    typealias ResultBlock = (Result<String, Error>) -> Void
    
    func checkIfPostIsLiked(postID: String, completion: @escaping (LikeState) -> Void) {
        let userID = AuthenticationManager.shared.getCurrentUserUID()
        
        let databaseKey = "PostsLikes/\(postID)/"
        
        let query = databaseRef.child(databaseKey).queryOrdered(byChild: "userID").queryEqual(toValue: userID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(.liked)
            } else {
                completion(.notLiked)
            }
        }
    }
    
    func getLikesCountForPost(id: String, completion: @escaping (LikesCount) -> Void) {
        
        let databaseKey = "PostsLikes/\(id)"
        
        databaseRef.child(databaseKey).observeSingleEvent(of: .value) { snapshot in
            completion(Int(snapshot.childrenCount))
        }
    }
    
    func getUsersLikedForPost(id: String, completion: @escaping () -> Void) {
        
    }
    
    func likePost(postID: String, completion: @escaping ResultBlock) {
        let userID = AuthenticationManager.shared.getCurrentUserUID()
        
        let databaseKey = "PostsLikes/\(postID)/\(userID)"
        print("inside post like method", databaseKey)
        print(databaseKey)
        databaseRef.child(databaseKey).setValue(["userID" : userID]) { error, _ in
            if error == nil {
                completion(.success("liked post \(postID)"))
            } else {
                completion(.failure(error!))
            }
        }
    }
    
    func removePostLike(postID: String, completion: @escaping ResultBlock) {
        let userID = AuthenticationManager.shared.getCurrentUserUID()
        
        let databaseKey = "PostsLikes/\(postID)/\(userID)"
        
        databaseRef.child(databaseKey).removeValue { error, _ in
            if error == nil {
                completion(.success("remove like from \(postID)"))
            } else {
                completion(.failure(error!))
            }
        }
    }
    
}
