//
//  FeedListViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/26.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class FeedListViewController: UIViewController {
    
    static let storyId = "feedlistVC"
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var button: UIButton!
    
    
    private var isFetching = false
    private var isLastPage = false
    private let mediaSubject = BehaviorRelay<[IGMediaModel]>(value: [])
    private var indexes = [Int]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabBar = self.tabBarController as? MainTabBarController {
            tabBar.hide()
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        if let tabBar = self.tabBarController as? MainTabBarController {
            tabBar.show()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        button.layer.cornerRadius = 13

        indicator.isHidden = false
        indicator.startAnimating()
        
        button.isEnabled = false
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        InstagramManager.shared.getMediaList()
            .asObservable()
            .map { $0.data }
            .bind(to: mediaSubject)
            .disposed(by: rx.disposeBag)
        
        mediaSubject
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCell.reuseId, cellType: FeedCell.self)) { [unowned self] idx, mediaModel, cell in
                indicator.isHidden = true
                indicator.stopAnimating()
                if let url = mediaModel.thumbnailURL {
                    cell.mainImageView.setImage(url: url)
                } else {
                    cell.mainImageView.setImage(url: mediaModel.mediaURL)
                }
                
                switch mediaModel.mediaType {
                case .image:
                    cell.mediaTypeImageView.image = nil
                case .album:
                    cell.mediaTypeImageView.image = UIImage(named: "album")
                case .video:
                    cell.mediaTypeImageView.image = UIImage(named: "video")
                }
                
            }
            .disposed(by: rx.disposeBag)

        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] index in
                let cell = collectionView.cellForItem(at: index) as! FeedCell

                if cell.isOn {
                    cell.deSelect()
                    let idx = indexes.firstIndex(of: index.row)!
                    indexes.remove(at: idx)
                    
                    button.setTitle("선택 완료(\(indexes.count)/3)", for: .normal)
                    button.isEnabled = false
                } else {
                    if indexes.count < 3{
                        cell.select(idx: indexes.count+1)
                        indexes.append(index.row)
                        button.setTitle("선택 완료(\(indexes.count)/3)", for: .normal)
                        
                        if indexes.count == 3 {
                            button.isEnabled = true
                        } else {
                            button.isEnabled = false
                        }
                    }
                }
                for i in 0..<indexes.count {
                    let cell = collectionView.cellForItem(at: [0, indexes[i]]) as! FeedCell
                    cell.select(idx: i+1)
                }
            })
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.didScroll
            .subscribe(onNext: { [unowned self] in
                let height = collectionView.frame.size.height
                let contentYoffset = collectionView.contentOffset.y
                let distanceFromBottom = collectionView.contentSize.height - contentYoffset
                if distanceFromBottom < height {
                    fetchNextPage()
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        button.rx.tap
            .subscribe(onNext: { [unowned self] in
        
                mediaSubject
                    .subscribe(onNext: { [unowned self] imageArray in
                        var temp: [String] = []
                        for idx in indexes {
                            temp.append(imageArray[idx].id)
                        }
                        NotiManager.shared.sendInstagram()
                        AuthManager.shared.bestImages(urls: temp)
                    })
                    .disposed(by: rx.disposeBag)
                
                
                navigationController?.dismiss(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func fetchNextPage() {
        if !isFetching && !isLastPage {
            isFetching = true
            InstagramManager.shared.getNextPage()
                .subscribe { [unowned self] mediaArrayModel in
                    if let mediaArrayModel = mediaArrayModel {
                        mediaSubject.accept(mediaSubject.value + mediaArrayModel.data)
                    }
                    isFetching = false
                } onError: { [unowned self] err in
                    print(err)
                    isFetching = false
                    isLastPage = true
                }
                .disposed(by: rx.disposeBag)
        }
    }

}

extension FeedListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let len = (collectionView.frame.width-38)/3
        
        return CGSize(width: len, height: len)
    }
}

class FeedCell: UICollectionViewCell {
    static let reuseId = "feedCell"
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var mediaTypeImageView: UIImageView!
    @IBOutlet weak var numberContainer: UIView!
    var isOn: Bool = false
    
    override func awakeFromNib() {
        contentView.layer.borderColor = UIColor.main.cgColor
        numberContainer.layer.cornerRadius = 10.5
        numberContainer.isHidden = true
    }
    
    func select(idx: Int) {
        isOn = true
        isSelected = true
        contentView.layer.borderWidth = 3
        
        numberContainer.isHidden = false
        numberLabel.text = "\(idx)"
        
    }
    
    func deSelect() {
        isOn = false
        isSelected = false
        contentView.layer.borderWidth = 0
        
        numberContainer.isHidden = true

    }
    
}
