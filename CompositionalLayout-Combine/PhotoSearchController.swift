//
//  ViewController.swift
//  CompositionalLayout-Combine
//
//  Created by Brendon Cecilio on 8/25/20.
//  Copyright © 2020 Brendon Cecilio. All rights reserved.
//

import UIKit
import Combine

class PhotoSearchController: UIViewController {
    
    enum SectionKind: Int, CaseIterable {
        case main
    }
    
    private var collectionView: UICollectionView!
    private var searchController: UISearchController!
    // delcare search text property that will be a 'publisher'  that listens to changes in the search bar controller
    // in order to make any property a 'publisher' you need to append the '@Published'
    // to subscribe to the search text's publisher, a $ needs to be prefixed to searchText => $earchText
    @Published private var searchText = ""
    private var subscriptions: Set<AnyCancellable> = []
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind,Int>
    var dataSource: DataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Photo Search"
        configureSearchController()
        configureCollectionView()
        configureDataSource()
        // subscribe to the searchText
        $searchText
            .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { (text) in
                print(text)
                // where we call the API
        }
    .store(in: &subscriptions)
    }
    
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self // delegate
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let itemSpacing: CGFloat = 5
            item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)
            // group
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 2)
            let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 3)
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(1000))
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [leadingGroup, trailingGroup])
            // section
            let section = NSCollectionLayoutSection(group: nestedGroup)
            return section
        }
        // layout
        return layout
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else {
                fatalError("could not dequeue an ImageCell")
            }
            return cell
        })
        // setup initial snapshot
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(1...100))
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension PhotoSearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            return
        }
        searchText = text
        // upon assigning a new value to the searchText
    }
}
