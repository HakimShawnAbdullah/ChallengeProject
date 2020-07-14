//
//  NetworkManager.swift
//  VaroChallenge
//
//  Created by AbdullahFamily on 2/7/20.
//  Copyright © 2020 HakimJoseph. All rights reserved.
//

import Foundation
final class NetworkManager {
    final let API_URL = "https://api.themoviedb.org/3/movie/now_playing?api_key=7bfe007798875393b05c5aa1ba26323e&language=en-US"
    static let shared = NetworkManager()
    private init(){}
    func getMoviesPlaying(page: Int, completion: @escaping ([MoviePlaying], Int)-> Void, failure: @escaping () -> Void){
        guard let endpointURL = URL(string: "\(API_URL)&page=\(page)") else {
            failure()
            return
        }
        
        URLSession.shared.dataTask(with: endpointURL) { (data, urlResponse, error) in       
            guard let data = data, error == nil && (urlResponse as? HTTPURLResponse)?.statusCode == 200 else {
                failure()
                return
            }
            guard let decodedData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                let decodedDict = decodedData as? [String: AnyObject] else {
                failure()
                return
            }
            
            guard let totalPages = decodedDict["total_pages"] as? Int else {
                failure()
                return
            }
            
            guard let playingMovies = try? JSONDecoder().decode(MoviesPlaying.self, from: data).results else {
                failure()
                return
            }
            completion(playingMovies, totalPages)
        }.resume()
    }
}
