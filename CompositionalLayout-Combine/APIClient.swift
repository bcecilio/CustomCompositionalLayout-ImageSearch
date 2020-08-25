//
//  APIClient.swift
//  CompositionalLayout-Combine
//
//  Created by Brendon Cecilio on 8/25/20.
//  Copyright © 2020 Brendon Cecilio. All rights reserved.
//

import Foundation
import Combine

struct PhotoResultsWrapper: Decodable {
  let hits: [Photo]
}

struct Photo: Decodable, Hashable {
  let id: Int
  let webformatURL: String
}

class APIClient {
    
    public func searchPhotos(for query: String) -> AnyPublisher<[Photo], Error> {
        
        let perPage = 200 // max is 200 photos
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "cookies"
        let endpoint = "https://pixabay.com/api/?key=\(Config.APIKey)&q=\(query)&per_page=\(perPage)&safesearch=true"
        
        let url = URL(string: endpoint)!
        
        // using combine for networking
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data) // data
            .decode(type: PhotoResultsWrapper.self, decoder: JSONDecoder())
            .map {$0.hits}
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
