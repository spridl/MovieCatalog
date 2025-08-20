//
//  MovieSearchViewController.swift
//  MovieCatalog
//
//  Created by Тимур on 14.08.2025.
//

import UIKit

class MovieSearchViewController: UIViewController {
    private let viewModel = MovieSearchViewModel()
    
    private let searchbar = UISearchBar()
    private let tableView = UITableView()
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    private var lastAnimatedRow = -1
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Поиск фильмов"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        setupUI()
        bindViewModel()
        setupBindings()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshMovies), for: .valueChanged)
        
        if let lastQuery = viewModel.lastQuery {
            searchbar.text = lastQuery
            viewModel.searchMovies(query: lastQuery)
        }
    }
    
    @objc private func refreshMovies() {
        guard let query = searchbar.text, !query.isEmpty else {
            refreshControl.endRefreshing()
            return
        }
        viewModel.searchMovies(query: query)
        
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func setupBindings() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.lastAnimatedRow = -1
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupUI() {
        searchbar.placeholder = "Введите название фильма"
        searchbar.delegate = self
        
        tableView.dataSource = self
        tableView.register(MovieCustomCell.self, forCellReuseIdentifier: MovieCustomCell.identifier)
        
        
        activityIndicatorView.hidesWhenStopped = true
        
        view.addSubview(searchbar)
        view.addSubview(tableView)
        view.addSubview(activityIndicatorView)
        
        searchbar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchbar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            
            if self.viewModel.isLoading {
                self.activityIndicatorView.startAnimating()
            } else {
                self.activityIndicatorView.stopAnimating()
            }
            
            if let error = self.viewModel.errorMessage {
                self.showAlert(messege: error)
            }
            
            self.tableView.reloadData()
        }
    }
    
    private func showAlert(messege: String) {
        let alertController = UIAlertController(title: "Ошибка", message: messege, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movies = viewModel.movies[indexPath.row]
        let detailVC = MovieDetailViewController(movieId: movies.imdbID)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MovieSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.searchMovies(query: searchBar.text ?? "")
    }
}

extension MovieSearchViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCustomCell.identifier, for: indexPath) as? MovieCustomCell else {
            return UITableViewCell()
        }
        let movie = viewModel.movies[indexPath.row]
        cell.configure(title: movie.title ?? "", year: movie.year ?? "", poster: movie.poster)
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row > lastAnimatedRow else { return }
        lastAnimatedRow = indexPath.row
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 24)
        
        UIView.animate(withDuration: 0.35, delay: 0.04 * Double(indexPath.row), usingSpringWithDamping: 0.86, initialSpringVelocity: 0.3, options: [.curveEaseInOut], animations: {
            cell.alpha = 1
            cell.transform = .identity
        })
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height / 10
    }
}
