//
//  MovieCell.swift
//  MovieCatalog
//
//  Created by Тимур on 14.08.2025.
//

import UIKit

final class MovieCell: UITableViewCell {
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private var imageLoadTask: Task<Void, Never>? // Хранит активную задачу
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(yearLabel)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageWidth: CGFloat = 60
        posterImageView.frame = CGRect(x: 15, y: 10, width: imageWidth, height: 90)
        
        let textX = posterImageView.frame.maxX + 10
        titleLabel.frame = CGRect(x: textX, y: 10, width: contentView.bounds.width - textX - 15, height: 40)
        yearLabel.frame = CGRect(x: textX, y: titleLabel.frame.maxY + 5, width: 100, height: 20)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        posterImageView.image = nil
    }
    func configure(title: String, year: String, poster: String) {
        titleLabel.text = title
        yearLabel.text = year
        loadImage(from: poster)
    }
    private func loadImage(from urlString: String) {
        posterImageView.image = nil
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let(data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async { [weak self] in
                        self?.posterImageView.image = image
                    }
                }
            } catch {
                print("Ошибка загрузки изображения: \(error)")
            }
        }
    }
}
