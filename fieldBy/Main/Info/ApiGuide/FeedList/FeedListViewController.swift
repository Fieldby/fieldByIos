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
    
    private var imageSubject = BehaviorSubject<[(UIImage?, ImageData)]>(value: [])
    private var indexes = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        button.layer.cornerRadius = 13

        indicator.isHidden = false
        indicator.startAnimating()
        
        button.isEnabled = false
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        InstagramManager.shared.fetchImages { [unowned self] imageArray in
            indicator.isHidden = true
            indicator.stopAnimating()

            imageSubject.onNext(imageArray)
        }
        
        imageSubject
            .map { $0.filter { $0.0 != nil }}
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCell.reuseId, cellType: FeedCell.self)) { [unowned self] idx, image, cell in
                
                cell.mainImageView.image = image.0
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
                        cell.select()
                        indexes.append(index.row)
                        button.setTitle("선택 완료(\(indexes.count)/3)", for: .normal)
                        
                        if indexes.count == 3 {
                            button.isEnabled = true
                        } else {
                            button.isEnabled = false
                        }
                        
                        
                    }

                }
                
            
            })
            .disposed(by: rx.disposeBag)
        
        
        button.rx.tap
            .subscribe(onNext: { [unowned self] in
                
                
                imageSubject
                    .map { $0.filter { $0.0 != nil }}
                    .subscribe(onNext: { [unowned self] imageArray in
                        
                        var temp: [String] = []
                        for idx in indexes {
                            temp.append(imageArray[idx].1.mediaURL)
                        }
                        
                        AuthManager.shared.bestImages(urls: temp)
                    })
                    .disposed(by: rx.disposeBag)
                
                
                navigationController?.dismiss(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        
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
    
    var isOn: Bool = false
    
    override func awakeFromNib() {
        contentView.layer.borderColor = UIColor.main.cgColor
    }
    
    func select() {
        isOn = true
        isSelected = true
        contentView.layer.borderWidth = 3
    }
    
    func deSelect() {
        isOn = false
        isSelected = false
        contentView.layer.borderWidth = 0
    }
    
}
