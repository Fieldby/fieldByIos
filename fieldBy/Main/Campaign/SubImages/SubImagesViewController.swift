//
//  SubImagesViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/08/09.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SubImagesViewController: UIViewController {
    static let storyId = "subimagesVC"

    let imageRelay = BehaviorRelay<[URL]>(value: [])
    
    private var idx = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        
        
        imageRelay
            .bind(to: collectionView.rx.items(cellIdentifier: MainImageCell.reuseId, cellType: MainImageCell.self)) { idx, url, cell in
                cell.mainImageView.setImage(url: url)
            }
            .disposed(by: rx.disposeBag)
        
        collectionView.decelerationRate = .fast
        
    }
    
    func scrollNext() {
        if idx < imageRelay.value.count-1 {
            idx += 1
        } else {
            idx = 0
        }
        collectionView.scrollToItem(at: [0, idx], at: .right, animated: true)
    }
    
    func scrollBack() {
        if idx > 0 {
            idx -= 1
        } else {
            idx = imageRelay.value.count-1
        }
        collectionView.scrollToItem(at: [0, idx], at: .right, animated: true)
    }
    

}

extension SubImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
}
