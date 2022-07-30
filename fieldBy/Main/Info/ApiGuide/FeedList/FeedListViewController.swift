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
    private var indices = [Int]()
    
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

        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        InstagramManager.shared.getMediaList()
            .subscribe { [unowned self] mediaArrayModel in
                mediaSubject.accept(mediaArrayModel.data)
            } onError: { _ in
                
            }
            .disposed(by: rx.disposeBag)

        
        mediaSubject
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCell.reuseId, cellType: FeedCell.self)) { [unowned self] idx, mediaModel, cell in
                indicator.isHidden = true
                indicator.stopAnimating()
                var num: Int? = nil
                if indices.contains(idx) {
                    num = indices.firstIndex(of: idx)! + 1
                }
                
                cell.bind(model: mediaModel, num)
            }
            .disposed(by: rx.disposeBag)

        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] index in
                guard let cell = collectionView.cellForItem(at: index) as? FeedCell else { return }
                
                if !indices.contains(index.row) {
                    if indices.count < 3 {
                        indices.append(index.row)
                        cell.select(idx: indices.count)
                    }
                } else {
                    let idx = indices.firstIndex(of: index.row)!
                    indices.remove(at: idx)
                    cell.deSelect()
                    
                    var newIndex = 1
                    for index in indices {
                        guard let selectedCell = collectionView.cellForItem(at: [0, index]) as? FeedCell else { return }
                        selectedCell.select(idx: newIndex)
                        newIndex += 1
                    }
                }
                button.setTitle("선택 완료(\(indices.count)/3)", for: .normal)
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
            .bind { [unowned self] in
                if indices.count < 3 {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupVC") as! PopupViewController
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.content = "3장을 선택해주세요."
                    vc.afterDismiss = {
                        
                    }
                    present(vc, animated: true)
                } else if indices.count == 3 {
                    var temp = [String]()
                    for index in indices {
                        let mediaModel = mediaSubject.value[index]
                        temp.append(mediaModel.id)
                    }
                    AuthManager.shared.bestImages(urls: temp)
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupVC") as! PopupViewController
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.content = "대표사진 3장을 등록하였습니다."
                    vc.afterDismiss = {
                        self.navigationController?.popViewController(animated: true)
                    }
                    present(vc, animated: true)
                }
            }
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
    
    func bind(model: IGMediaModel,_ idx: Int? = nil) {
        if let url = model.thumbnailURL {
            mainImageView.setImage(url: url)
        } else {
            mainImageView.setImage(url: model.mediaURL)
        }
        
        switch model.mediaType {
        case .image:
            mediaTypeImageView.image = nil
        case .album:
            mediaTypeImageView.image = UIImage(named: "album")
        case .video:
            mediaTypeImageView.image = UIImage(named: "video")
        }
        
        if let idx = idx {
            select(idx: idx)
        } else {
            deSelect()
        }
    }
}
