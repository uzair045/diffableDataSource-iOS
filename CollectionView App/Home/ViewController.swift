//
//  ViewController.swift
//  CollectionView App
//
//  Created by Uzair on 15/04/2022.
//

import UIKit
import PhotosUI
import Combine

class HomeVC: UIViewController {
    
    static let headerKind = "headerKind"
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Class Properties
    enum Section: Int, CaseIterable {
        case localImages
        case remoteImages
    }
    
    enum DataItem: Hashable {
        case localImages(UIImage)
        case remoteImages(Images)
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, DataItem>? = nil
    
    var localImagesArray = [UIImage]()
    var viewModel = HomeVM()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
    }
}

// MARK: - CLass Methods
extension HomeVC {
    
    fileprivate func initialSetup() {
        
        self.bindViewModelToView()
        
        // load local images
        self.localImagesArray = self.viewModel.localImages
        
        // Configure Collection view
        self.configureHierarchy()
        self.configureDataSource()
        
        // setup Title
        self.title = "Collection View"
        
        // fetch remote images
        self.viewModel.fetchImages()
    }
}

// MARK: - Bindings
extension HomeVC {
    
    fileprivate func bindViewModelToView() {
        
        self.viewModel.gotImages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                
                guard let self = self else { return }
                self.dataSource?.apply(self.snapshotForCurrentState(), animatingDifferences: false)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Collection view layout
extension HomeVC {
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8,
                                                     bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item, count: 3)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(30.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: HomeVC.headerKind,
                                                                 alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        
        return layout
    }
}

// MARK: - Configure heirarchy
extension HomeVC {
    
    private func configureHierarchy() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(UINib(nibName: TitleView.reuseIdentifier, bundle: nil),
                            forSupplementaryViewOfKind: HomeVC.headerKind,
                            withReuseIdentifier: TitleView.reuseIdentifier)
    }
}

// MARK: - Data source
extension HomeVC {
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, DataItem>(collectionView: self.collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, dataItem: DataItem) -> UICollectionViewCell? in

            // Get a cell of the desired kind.
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CollectionCell.reuseIdentifier,
                for: indexPath) as? CollectionCell else { fatalError("Cannot create new cell") }
            
            switch dataItem {
                case .localImages(let image):
                    cell.configureCell(image: image)
                case .remoteImages(let image):
                    cell.configureCell(with: image.thumbnailUrl ?? "")
            }
            
            // Return the cell.
            return cell
        }
        
        dataSource?.supplementaryViewProvider = {(
            collectionView: UICollectionView,
            kind: String,
            indexPath: IndexPath) -> UICollectionReusableView? in

            // Get a supplementary view of the desired kind.
            if let titleView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TitleView.reuseIdentifier,
                for: indexPath) as? TitleView {
                titleView.configureCell(at: indexPath)
                titleView.btnAddAction = {
                    self.presentPickerView()
                }
                return titleView
            } else {
                fatalError("Cannot create new supplementary")
            }
        }
        
        dataSource?.apply(snapshotForCurrentState(), animatingDifferences: false)
    }
    
    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, DataItem>{
        var snapshot = NSDiffableDataSourceSnapshot<Section, DataItem>()
        snapshot.appendSections(Section.allCases)

        let localItems = localImagesArray.map { DataItem.localImages($0) }
        snapshot.appendItems(localItems, toSection: Section.localImages)

        let remoteItems = self.viewModel.images.map { DataItem.remoteImages($0) }
        snapshot.appendItems(remoteItems, toSection: Section.remoteImages)
        return snapshot
    }

}

// MARK: - Configure Picker view
extension HomeVC {
    func presentPickerView() {
        var config : PHPickerConfiguration = PHPickerConfiguration()
        config.selectionLimit = 20
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        
        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }
}

// MARK: - Picker controller delegate
extension HomeVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        var count = 0
        for item in results {
            count += 1
            item.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.jpeg") { [unowned self] (url, error) in
                
                if let error = error {
                    print("printing error: \(error)")
                    return
                }
                
                guard let fileUrl = url else { return }
                loadImageAt(url: fileUrl) { [unowned self] image in
                    self.localImagesArray.append(image)
                    self.viewModel.saveImage(image)
                }
                
                if count == results.count {
                    self.dataSource?.apply(self.snapshotForCurrentState(), animatingDifferences: false)
                }
            }
        }
    }
}
