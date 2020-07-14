//
//  MovieTableViewCell.swift
//  VaroChallenge
//
//  Created by Hakim Joseph on 2/10/20.
//  Copyright © 2020 HakimJoseph. All rights reserved.
//

import UIKit
import SDWebImage

protocol MovieTableViewCellDelegate: NSObject {
    func addToFavorites(viewModel: MovieViewModel)
}

class MovieTableViewCell: UITableViewCell {
    @IBOutlet weak private var movieTitle: UILabel!
    @IBOutlet weak private var movieImageView: UIImageView!
    @IBOutlet weak private var favoritesButton: UIButton!
    public weak var delegate: MovieTableViewCellDelegate?
    private var viewModel: MovieViewModel?
    static var reuseIdentifier: String {
        return String(describing: MovieTableViewCell.self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    public func configure(with viewModel: MovieViewModel, fromFavorites: Bool) {
        self.viewModel = viewModel
        self.movieTitle.text = viewModel.title
        self.movieImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
        self.favoritesButton.isHidden = fromFavorites
    }
    @IBAction func didTapFavoritesButton(_ sender: Any) {
        guard let viewModel = viewModel else {return}
        delegate?.addToFavorites(viewModel: viewModel)
    }
    override func prepareForReuse() {
        viewModel = nil
        movieTitle.text = nil
        movieImageView.image = nil
        super.prepareForReuse()
    }
}
