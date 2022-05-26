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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var button: UIButton!
    
    private var imageSubject = BehaviorSubject<[UIImage?]>(value: [])
    private var indexes = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.layer.cornerRadius = 13

        indicator.isHidden = false
        indicator.startAnimating()
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        InstagramManager.shared.fetchImages { [unowned self] imageArray in
            indicator.isHidden = true
            indicator.stopAnimating()

            imageSubject.onNext(imageArray)
        }
        
        imageSubject
            .map { $0.filter { $0 != nil }}
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCell.reuseId, cellType: FeedCell.self)) { [unowned self] idx, image, cell in
                
                cell.mainImageView.image = image
            }
            .disposed(by: rx.disposeBag)
        
        
        
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                let cell = collectionView.cellForItem(at: idx) as! FeedCell

                if cell.isOn {
                    cell.deSelect()
                    let idx = indexes.firstIndex(of: idx.row)!
                    indexes.remove(at: idx)
                    
                    button.setTitle("선택 완료(\(indexes.count)/3)", for: .normal)

                } else {
                    if indexes.count < 3{
                        cell.select()
                        indexes.append(idx.row)
                        button.setTitle("선택 완료(\(indexes.count)/3)", for: .normal)

                    }

                }
                
            
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
