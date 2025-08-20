//
//  MovieDetailViewController.swift
//  MovieCatalog
//
//  Created by Тимур on 15.08.2025.
//

import UIKit

class MovieDetailViewController: UIViewController {
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let plotLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    
    private let viewModel: MovieDetailViewModel
    
    init(movieId: String) {
        self.viewModel = MovieDetailViewModel(movieId: movieId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupBindings()
        
        Task {
            await viewModel.loadMovieDetails()
        }
    }
    
    private func setupUI() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
        
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.numberOfLines = 0
        
        infoLabel.font = .boldSystemFont(ofSize: 16)
        infoLabel.textColor = .secondaryLabel
        
        plotLabel.font = .systemFont(ofSize: 16)
        plotLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [posterImageView, titleLabel, infoLabel, plotLabel])
        stack.axis = .vertical
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        posterImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        favoriteButton.setTitle("⭐️ Add to Favorites", for: .normal)
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        
        view.addSubview(favoriteButton)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            favoriteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            favoriteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc private func toggleFavorite() {
        guard let movie = viewModel.movie else { return }
        
        if CoreDataManager.shared.isFavorite(id: movie.imdbID) {
            CoreDataManager.shared.removeFromFavorites(id: movie.imdbID)
            favoriteButton.setTitle("⭐️ Add to Favorites", for: .normal)
            animateFavoriteButton(isAdding: false)
        } else {
            CoreDataManager.shared.addToFavorites(movie: movie)
            favoriteButton.setTitle("✅ In Favorites", for: .normal)
            animateFavoriteButton(isAdding: true)
        }
        
    }
    
    private func animateFavoriteButton(isAdding: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.12, animations: {
                self.favoriteButton.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
            }, completion: { _ in
                UIView.animate(withDuration: 0.12) {
                    self.favoriteButton.transform = .identity
                }
            })
            if isAdding {
                self.flyStar(from: self.favoriteButton)
            }
        }
    }
    
    
    private func flyStar(from sourceView: UIView) {
        let star = UILabel()
        star.text = "⭐️"
        star.font = .systemFont(ofSize: 36)
        star.alpha = 0
        
        let frameInSelf = sourceView.superview?.convert(sourceView.frame, to: self.view) ?? sourceView.frame
        
        star.frame = CGRect(x: frameInSelf.midX - 18, y: frameInSelf.midY - 18, width: 36, height: 36)
        view.addSubview(star)
        
        UIView.animate(withDuration: 0.22, animations: {
            star.alpha = 1
        })
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseOut], animations: {
            star.transform = CGAffineTransform(translationX: 0, y: -120)
            star.alpha = 0
        }, completion: { _ in
            star.removeFromSuperview()
        })
        
    }
    
    private func setupBindings() {
        viewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let movie = self.viewModel.movie else { return }
                self.titleLabel.text = movie.title
                self.infoLabel.text = "\(movie.year) \(movie.genre) \(movie.director)"
                self.plotLabel.text = movie.plot
                
                Task {
                    if let image = try? await ImageLoader.shared.loadImage(from: movie.poster) {
                        self.posterImageView.image = image
                    }
                }
            }
            
            
        }
    }
    
}
