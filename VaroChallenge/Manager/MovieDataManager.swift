//
//  MovieDataManager.swift
//  VaroChallenge
//
//  Created by AbdullahFamily on 2/7/20.
//  Copyright © 2020 HakimJoseph. All rights reserved.
//

import Foundation
import CoreData

protocol MovieDataManagerDelegate: AnyObject {
    func addRow(at indexPath: IndexPath, with viewModel: MovieViewModel)
    func removeRow(at indexPath: IndexPath)
}

enum MovieDataManagerOperation {
    case add, delete
}

final class MovieDataManager: NSObject {
    private var fetchedResultsController:NSFetchedResultsController<Movie>
    weak var delegate: MovieDataManagerDelegate?
    override init() {
        fetchedResultsController = CoreDataManager.shared.fetchedResultsController()
        super.init()

        fetchedResultsController.delegate = self
    }
    public func getFavorites() -> [MovieViewModel] {
        try? fetchedResultsController.performFetch()
        guard let movies = fetchedResultsController.fetchedObjects else {
            return []
        }
        return convertModels(models: movies)
    }
    
    public func update(favorites: [MovieViewModel], with operation: MovieDataManagerOperation) throws {
        switch operation {
        case .add:
            try addFavorites(favorites: favorites)
        case .delete:
            try remove(favorites: favorites)
        }
    }
    
    private func addFavorites(favorites: [MovieViewModel]) throws {
        try CoreDataManager.shared.insert(viewModels: favorites)
    }
    
    private func remove(favorites: [MovieViewModel]) throws {
        try CoreDataManager.shared.delete(viewModels: favorites)
    }
    
    public func getMoviesPlaying(page: Int, completion: @escaping ([MovieViewModel], Int)-> Void,  failure: @escaping ()-> Void){
        NetworkManager.shared.getMoviesPlaying(page: page, completion: { [weak self] (moviesPlaying,totalpages)  in
            if let strongSelf = self {
                completion(strongSelf.convertModels(models: moviesPlaying), totalpages)
            }
        }) {
            failure()
        }
    }
    private func convertModels(models: [MovieModel]) -> [MovieViewModel] {
        var movieViewModels = [MovieViewModel]()
        for movie in models {
            movieViewModels.append(MovieViewModel(movieModel: movie))
        }
        return movieViewModels
    }
}

extension MovieDataManager: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else {
                return
            }
            delegate?.removeRow(at: indexPath)
        case .insert:
            guard let indexPath = newIndexPath, let movie = anObject as? Movie else {
                return
            }
            let viewModel = MovieViewModel(movieModel: movie)
            delegate?.addRow(at: indexPath, with: viewModel)
        default: break 
        }
    }
}
