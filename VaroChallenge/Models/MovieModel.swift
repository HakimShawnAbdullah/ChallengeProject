//
//  MovieModel.swift
//  VaroChallenge
//
//  Created by AbdullahFamily on 2/7/20.
//  Copyright © 2020 HakimJoseph. All rights reserved.
//

import UIKit

protocol MovieModel {
    var title:String {get}
    var imageLocation:URL {get}
}

struct MoviesPlaying: Decodable {
    let results:[MoviePlaying]
}

struct MoviePlaying: Decodable, MovieModel {
    var imageLocation: URL
    var title:String
    
    enum CodingKeys: String, CodingKey {
        case imageLocation = "poster_path", title
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        let imageAppendingString = try container.decode(String.self, forKey: .imageLocation)
        guard let url = URL(string:"https://image.tmdb.org/t/p/w200\(imageAppendingString)") else  {
            let decodingErrorContext = DecodingError.Context(codingPath: [CodingKeys.imageLocation], debugDescription: "Image Not Available")
            throw DecodingError.dataCorrupted(decodingErrorContext)
        }
        self.imageLocation = url
    }
}

struct MovieViewModel {
    let movieModel: MovieModel
    var imageURL: URL {
        return movieModel.imageLocation
    }
    var title: String {
        return movieModel.title
    }
}



