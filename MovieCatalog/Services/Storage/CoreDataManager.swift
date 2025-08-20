//
//  CoreDataManager.swift
//  MovieCatalog
//
//  Created by Тимур on 18.08.2025.
//

import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MovieDataModel")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения: \(error.localizedDescription)")
            }
        }
    }
}

extension CoreDataManager {
    func addToFavorites(movie: MovieDetail) {
        let fav = FavoriteMovie(context: context)
        fav.id = movie.imdbID
        fav.title = movie.title
        fav.year = movie.year
        fav.poster = movie.poster
        saveContext()
    }
    
    func removeFromFavorites(id: String) {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        if let results = try? context.fetch(request), let movie = results.first {
            context.delete(movie)
            saveContext()
        }
    }
    
    func fetchFavorites() -> [FavoriteMovie] {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    func isFavorite(id: String) -> Bool {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }
}
