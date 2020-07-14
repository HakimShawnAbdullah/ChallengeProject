//
//  CoreDataManager.swift
//  VaroChallenge
//
//  Created by AbdullahFamily on 2/7/20.
//  Copyright © 2020 HakimJoseph. All rights reserved.
//

import UIKit
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    private let persistentContainer:NSPersistentContainer
    private let mainContext:NSManagedObjectContext
    private init(){
        persistentContainer = NSPersistentContainer(name: "Movie")
        persistentContainer.loadPersistentStores { (_, error) in
            if error != nil {
                fatalError()
            }
        }
        mainContext = persistentContainer.viewContext
        mainContext.automaticallyMergesChangesFromParent = true
    }
    private func saveContext() throws {
        if mainContext.hasChanges {
            try mainContext.save()
        }
    }
    
    public func cleanUp() {
        do {
            try saveContext()
        } catch{}
    }

    public func insert(viewModels: [MovieViewModel]) throws {
        persistentContainer.performBackgroundTask {(backgroundContext) in
            for viewModel in viewModels {
                let movie = Movie(context: backgroundContext)
                movie.imageLocation = viewModel.imageURL
                movie.title = viewModel.title
                backgroundContext.insert(movie)
            }
            try? backgroundContext.save()
        }
    }
    public func delete(viewModels: [MovieViewModel]) throws {
        var predicates = [NSPredicate]()
        for viewModel in viewModels {
            predicates.append(NSPredicate(format: "title == %@", viewModel.title))
        }
        guard let movies = fetchMovies(withPredicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates)) else {
            return
        }
        var movieIDs = [NSManagedObjectID]()
        for movie in movies {
            movieIDs.append(movie.objectID)
        }
        persistentContainer.performBackgroundTask {(backgroundContext) in
            for movieID in movieIDs {
                backgroundContext.delete(backgroundContext.object(with: movieID))
            }
            try? backgroundContext.save()
        }
    }
    
    private func fetchMovies(withPredicate pred: NSPredicate?) -> [Movie]? {
        let fetchRequest = NSFetchRequest<Movie>(entityName: "Movie")
        fetchRequest.predicate = pred
        return try? mainContext.fetch(fetchRequest)
    }
    public func fetchedResultsController() -> NSFetchedResultsController<Movie> {
        let fetchRequest = NSFetchRequest<Movie>(entityName: "Movie")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let fetchedRC = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                   managedObjectContext: mainContext,
                                                   sectionNameKeyPath: nil,
                                                   cacheName: nil)
        return fetchedRC
    }
}
