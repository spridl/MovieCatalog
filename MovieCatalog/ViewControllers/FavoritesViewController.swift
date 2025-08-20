//
//  FavoritesViewController.swift
//  MovieCatalog
//
//  Created by Тимур on 18.08.2025.
//

import UIKit

class FavoritesViewController: UIViewController {

    private let tableView = UITableView()
    private let statsLabel = UILabel()
    private var movies: [FavoriteMovie] = []
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        view.backgroundColor = .systemBackground
        setupTableView()
        setupStatsLabel()
        loadFavorites()
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshFavorites), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Фон", style: .plain, target: self, action: #selector(changeBackgroundTrapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let custom = BackgroundManager.shared.loadBackground() {
            setupBackgroundImage(custom)
        } else {
            setupBackgroundImage(UIImage(named: "default_bg"))
        }
        updateStats()
        loadFavorites()
        
    }
    
    @objc private func refreshFavorites() {
        loadFavorites()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @objc private func changeBackgroundTrapped() {
        let alert = UIAlertController(title: "Фон", message: "Выберите источник изображения", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Камера", style: .default, handler: { _ in
                self.openImagePicker(source: .camera)
            }))
        }
        alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { _ in
            self.openImagePicker(source: .photoLibrary)
        }))
        
        if BackgroundManager.shared.loadBackground() != nil {
            alert.addAction(UIAlertAction(title: "Сбросить фон", style: .destructive, handler: { _ in
                BackgroundManager.shared.clearBackground()
                self.setupBackgroundImage(UIImage(named: "default_bg"))
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    private func openImagePicker(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    private func setupBackgroundImage(_ image: UIImage?) {
        guard let image = image else { return }
        
        let newBG = UIImageView(image: image)
        newBG.contentMode = .scaleAspectFill
        newBG.frame = tableView.bounds
        newBG.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        UIView.transition(with: tableView, duration: 0.45, animations: {
            self.tableView.backgroundView = newBG
        })
    }
    
    private func setupTableView() {
        tableView.register(MovieCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    private func setupStatsLabel() {
        statsLabel.font = .systemFont(ofSize: 16)
        statsLabel.textColor = .secondaryLabel
        statsLabel.textAlignment = .center
        statsLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 40)
        tableView.tableHeaderView = statsLabel
    }
    private func updateStats() {
        statsLabel.text = "Всего успешных поисков \(AppSettings.searchCount)"
    }
    
    private func loadFavorites() {
        movies = CoreDataManager.shared.fetchFavorites()
        tableView.reloadData()
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        cell.configure(title: movie.title ?? "", year: movie.year ?? "", poster: movie.poster ?? "")
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movieDelete = movies[indexPath.row]
            CoreDataManager.shared.removeFromFavorites(id: movieDelete.id ?? "")
            movies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension FavoritesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        if let image {
            BackgroundManager.shared.saveBackground(image)
            setupBackgroundImage(image)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
