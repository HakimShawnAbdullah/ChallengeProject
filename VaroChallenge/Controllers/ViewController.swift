//
//  ViewController.swift
//  VaroChallenge
//
//  Created by AbdullahFamily on 2/7/20.
//  Copyright © 2020 HakimJoseph. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    final let NOW_PLAYING_SEGMENT_INDEX = 0
    
    private var currentPage = 1
    private var totalPages = Int.max
    private var selectedSegmentIndex = 0
    private let movieDataManager = MovieDataManager()
    private var viewModelData = [MovieViewModel]()
    
    @IBOutlet weak var moreMoviesButton: UIButton!
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        movieDataManager.delegate = self
        moviesPlayingTableView()
        setupNavBar()
    }
    
    private func moviesPlayingTableView() {
        movieTableView.register(UINib(nibName: MovieTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
        movieTableView.dataSource = self
        movieTableView.delegate = self
        moreMoviesButton.setTitle("Get More Movies", for: .normal)
        moreMoviesButton.isHidden = true
        getMoviesPlaying(page: currentPage)
    }
    
    private func setupNavBar() {
        navBar.delegate = self
        let segmentControl = UISegmentedControl(items: ["Movies Playing", "Favorite Movies"])
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        navBar.items = [UINavigationItem()]
        navBar.topItem?.titleView = segmentControl
        segmentControl.selectedSegmentIndex = NOW_PLAYING_SEGMENT_INDEX
        selectedSegmentIndex = NOW_PLAYING_SEGMENT_INDEX
    }
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        currentPage = 1
        if sender.selectedSegmentIndex == NOW_PLAYING_SEGMENT_INDEX {
            self.moreMoviesButton.isHidden = false
            getMoviesPlaying(page: currentPage)
        } else {
            self.moreMoviesButton.isHidden = true
            getFavorites()
        }
        selectedSegmentIndex = sender.selectedSegmentIndex
    }
    @IBAction func moreMoviesButtonTap(_ sender: UIButton) {
        guard currentPage != totalPages else {
            sender.isHidden = true
            return
        }
        currentPage += 1
        getMoviesPlaying(page: currentPage)
    }
    
    private func getMoviesPlaying(page: Int) {
        movieDataManager.getMoviesPlaying(page: page, completion: { [weak self] (movieModels, totalPages) in
            self?.totalPages = totalPages
            guard self?.selectedSegmentIndex == self?.NOW_PLAYING_SEGMENT_INDEX else{return}
            if let strongSelf = self {
                DispatchQueue.main.async {
                    if page != totalPages {
                        strongSelf.moreMoviesButton.isHidden = false
                    }
                    if page > 1 {
                        var newIndexPaths = [IndexPath]()
                        let totalNumberOfRows = strongSelf.viewModelData.count + movieModels.count
                        for i in strongSelf.viewModelData.count..<totalNumberOfRows {
                            newIndexPaths.append(IndexPath(item: i, section: 0))
                        }
                        strongSelf.viewModelData.append(contentsOf: movieModels)
                        strongSelf.movieTableView.insertRows(at: newIndexPaths, with: .none)
                    } else {
                        strongSelf.viewModelData = movieModels
                        strongSelf.movieTableView.reloadData()
                    }
                }
            }
        }) { [weak self] in
            guard self?.selectedSegmentIndex == self?.NOW_PLAYING_SEGMENT_INDEX else{return}
            let alertController = UIAlertController(title: "Network Error",
                                                    message: "Unable to get movies currently showing.",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close",
                                                    style: .cancel,
                                                    handler: nil))
            DispatchQueue.main.async {
                self?.present(alertController,
                             animated: true,
                             completion: nil)
            }
            
        }
    }
    
    private func getFavorites() {
        viewModelData = movieDataManager.getFavorites()
        movieTableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModelData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as! MovieTableViewCell
        cell.configure(with: viewModelData[indexPath.row], fromFavorites: selectedSegmentIndex != NOW_PLAYING_SEGMENT_INDEX)
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard selectedSegmentIndex != NOW_PLAYING_SEGMENT_INDEX else {return []}
        return [UITableViewRowAction(style: .default,
                                     title: "Remove From Favorites",
                                     handler: { [weak self] (action, indexPath) in
                                        if let strongSelf = self {
                                            do {
                                                try strongSelf.movieDataManager.update(
                                                    favorites: [strongSelf.viewModelData[indexPath.row]],
                                                    with: .delete)
                                            } catch {
                                                let alertController = UIAlertController(title: "Error",
                                                                                        message: "Unable to remove movie from favorites.",
                                                                                        preferredStyle: .alert)
                                                alertController.addAction(UIAlertAction(title: "Close",
                                                                                        style: .cancel,
                                                                                        handler: nil))
                                                strongSelf.present(alertController,
                                                             animated: true,
                                                             completion: nil)
                                            }
                                            
                                        }
        })]
    }
}

extension ViewController: MovieDataManagerDelegate {
    func addRow(at indexPath: IndexPath, with viewModel: MovieViewModel) {
        guard selectedSegmentIndex != NOW_PLAYING_SEGMENT_INDEX else {return}
        viewModelData.append(viewModel)
        movieTableView.insertRows(at: [indexPath], with: .none)
    }
    
    func removeRow(at indexPath: IndexPath) {
        guard selectedSegmentIndex != NOW_PLAYING_SEGMENT_INDEX else {return}
        viewModelData.remove(at: indexPath.row)
        movieTableView.deleteRows(at: [indexPath], with: .none)
    }
}
extension ViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
extension ViewController: MovieTableViewCellDelegate {
    func addToFavorites(viewModel: MovieViewModel) {
        do {
            try movieDataManager.update(favorites: [viewModel], with: .add)
            let alertController = UIAlertController(title: "Added to Favorites",
                                                    message: "\(viewModel.title) was added  to favorites.",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close",
                                                    style: .cancel,
                                                    handler: nil))
            present(alertController,
                         animated: true,
                         completion: nil)
        } catch {
            let alertController = UIAlertController(title: "Error",
                                                    message: "Unable to add movies to favorites.",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close",
                                                    style: .cancel,
                                                    handler: nil))
            present(alertController,
                         animated: true,
                         completion: nil)
        }
    }
}
