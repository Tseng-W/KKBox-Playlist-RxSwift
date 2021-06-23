//
//  Object.swift
//  TopicDL5_RxSwift
//
//  Created by 曾問 on 2021/5/5.
//

import UIKit
import Moya

protocol DecodableResponseTargetType: TargetType {
    associatedtype ResponseType: Decodable
}

protocol KKBoxApiTargetType: DecodableResponseTargetType { }

extension KKBoxApiTargetType {
    var baseURL: URL { return URL(string: "https://api.kkbox.com")!}
    var headers: [String : String]? { return ["Authorization": "Bearer IgsEJfFcDK5xQYKnlkONgA=="] }
    var sampleData: Data { return Data() }
}

protocol KKBoxAccountTargetType: DecodableResponseTargetType { }

extension KKBoxAccountTargetType {
    var baseURL: URL { return URL(string: "https://account.kkbox.com")!}
    var headers: [String : String]? { return nil }
    var sampleData: Data { return Data() }
}

enum KKBox {
    
    struct GetAccessToken: KKBoxAccountTargetType {
        
        typealias ResponseType = AccessTokenResponse
        
        var path: String { return "/oauth2/token" }
        
        var method: Moya.Method { return .post }
        
        var task: Task { return .requestParameters(parameters: data, encoding: URLEncoding.default) }
        
        private var data: [String: String] = [:]
        
        init(id: String, secret: String) {
            data["grant_type"] = "client_credentials"
            data["client_id"] = id
            data["client_secret"] = secret
        }
    }
    
    struct GetNewHits: KKBoxApiTargetType {

        typealias ResponseType = HitsResponse

        var path: String { return "/v1.1/new-hits-playlists/\(playListId)/tracks" }

        var method: Moya.Method { return .get }

        var task: Task { return .requestParameters(parameters: ["territory": "TW", "limit": limit, "offset": offset], encoding: URLEncoding.default) }

        var headers: [String : String]? { return ["Authorization": token] }
        
        var playListId: String = "DZrC8m29ciOFY2JAm3"
        
        var token: String
        
        var offset: Int = 0
        
        var limit: Int = 20

    }
}


// MARK: - KKBox account access token object

struct AccessTokenResponse: Decodable {
    var accessToken: String
    var tokenType: String
    var expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

// MARK: - KKBox API hots object

struct HitsResponse: Decodable {
    var data: [Song]
    var paging: Paging
    var summary: [String: Int]
}

struct Song: Decodable {
    var id: String
    var name: String
    var duration: Int
    var isrc: String
    var url: String
    var trackNumber: Int
    var explicitness: Bool
    var availableTerritories: [String]
    var album: Album
    
    enum CodingKeys: String, CodingKey {
        case id, name, duration, isrc, url, explicitness, album
        case trackNumber = "track_number"
        case availableTerritories = "available_territories"
    }
}

struct Album: Decodable {
    var id: String
    var name: String
    var url: String
    var explicitness: Bool
    var availableTerritories: [String]
    var releaseDate: String
    var images: [Image]
    var artist: Artist
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, explicitness, images, artist
        case availableTerritories = "available_territories"
        case releaseDate = "release_date"
    }
}

struct Artist: Decodable {
    var id: String
    var name: String
    var url: String
    var images: [Image]
}

struct Image: Decodable {
    var height: Int
    var width: Int
    var url: String
}

struct Owner: Decodable {
    var id: String
    var url: String
    var name: String
    var description: String
    var images: [Image]
}

struct Paging: Decodable {
    var offset: Int
    var limit: Int
    var previous: String?
    var next: String?
    
    enum CodingKeys: String, CodingKey {
        case offset, limit, previous, next
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offset = try container.decode(Int.self, forKey: .offset)
        limit = try container.decode(Int.self, forKey: .limit)
        
        do {
            previous = try container.decode(String.self, forKey: .previous)
        } catch {
            previous = nil
        }
        
        do {
            next = try container.decode(String.self, forKey: .next)
        } catch {
            next = nil
       }
    }
}
// MARK: - KKBox API search object


