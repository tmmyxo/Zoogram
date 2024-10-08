//
//  ActivityEvent.swift
//  Zoogram
//
//  Created by Artem Dolbiiev on 22.02.2023.
//

import Foundation

enum ActivityEventType: String, Codable {
    case postLiked
    case followed
    case postCommented
}

struct ActivityEvent: Sendable, Codable, Hashable {

    let eventType: ActivityEventType
    let userID: String
    let postID: String?
    let eventID: String
    let timestamp: Date
    let text: String?
    let commentID: String?
    var seen: Bool

    // Used locally
    var user: ZoogramUser?
    var post: UserPost?

    init(eventType: ActivityEventType, userID: String, postID: String? = nil, eventID: String, timestamp: Date, text: String? = nil, seen: Bool = false, commentID: String? = nil) {
        self.eventType = eventType
        self.userID = userID
        self.postID = postID
        self.eventID = eventID
        self.timestamp = timestamp
        self.text = text
        self.commentID = commentID
        self.seen = seen
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventType = try container.decode(ActivityEventType.self, forKey: .eventType)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.postID = try container.decodeIfPresent(String.self, forKey: .postID)
        self.eventID = try container.decode(String.self, forKey: .eventID)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.commentID = try container.decodeIfPresent(String.self, forKey: .commentID)
        self.seen = try container.decode(Bool.self, forKey: .seen)
    }

    static func createActivityEventFor(comment: PostComment, postID: String) -> ActivityEvent {
        let eventID = ActivitySystemService.shared.createEventUID()

        return ActivityEvent(eventType: .postCommented,
                      userID: comment.authorID,
                      postID: postID,
                      eventID: eventID,
                      timestamp: Date(),
                      text: comment.commentText,
                      commentID: comment.commentID
        )
    }

    static func createActivityEventFor(likedPostID: String) -> ActivityEvent {
        let currentUserID = UserManager.shared.getUserID()
        let eventID = ActivitySystemService.shared.createEventUID()
        return ActivityEvent(
            eventType: .postLiked,
            userID: currentUserID,
            postID: likedPostID,
            eventID: eventID,
            timestamp: Date())
    }

    static func generateReferenceString(for event: ActivityEvent) -> String {
        let eventType = event.eventType.rawValue
        switch event.eventType {
        case .postLiked:
            return "\(eventType)_\(event.userID)_\(event.postID!)"
        case .postCommented:
            return "\(eventType)_\(event.userID)_\(event.commentID!)"
        case .followed:
            return "\(eventType)_\(event.userID)"
        }
    }

    typealias CommentID = String
    typealias PostID = String

    static func generateReferenceStringForComment(_ commentID: CommentID) -> String {
        let currentUserID = UserManager.shared.getUserID()
        let eventType = ActivityEventType.postCommented.rawValue
        return "\(eventType)_\(currentUserID)_\(commentID)"
    }

    static func generateReferenceStringForPost(_ postID: PostID) -> String {
        let currentUserID = UserManager.shared.getUserID()
        let eventType = ActivityEventType.postLiked.rawValue
        return "\(eventType)_\(currentUserID)_\(postID)"
    }

    static func generateReferenceStringForFollowEvent() -> String {
        let currentUserID = UserManager.shared.getUserID()
        let eventType = ActivityEventType.followed.rawValue
        return "\(eventType)_\(currentUserID)"
    }

    static func == (lhs: ActivityEvent, rhs: ActivityEvent) -> Bool {
        return lhs.eventID == rhs.eventID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(eventID)
    }

    enum CodingKeys: CodingKey {
        case eventType
        case userID
        case postID
        case eventID
        case timestamp
        case text
        case commentID
        case seen
    }
}
