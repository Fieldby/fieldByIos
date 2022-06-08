//
//  MainImageViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/06/08.
//

import UIKit
import RxRelay

class MainImageViewController: UIViewController {
    
    static let storyId = "mainimageVC"

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indexLabel: UILabel!
    
    let imageRelay = BehaviorRelay<[URL]>(value: [])
    private var totalCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        imageRelay.map { $0.count }
            .subscribe(onNext: { [unowned self] count in
                totalCount = count
                indexLabel.text = "1 / \(count)"
                
            })
            .disposed(by: rx.disposeBag)
        
        imageRelay
            .bind(to: collectionView.rx.items(cellIdentifier: MainImageCell.reuseId, cellType: MainImageCell.self)) { idx, url, cell in
                cell.mainImageView.setImage(url: url)
            }
            .disposed(by: rx.disposeBag)
        
        collectionView.decelerationRate = .fast
        
    }
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension MainImageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let cellWidthIncludingSpacing = collectionView.frame.width
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        var roundedIndex = round(index)
        if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            roundedIndex = floor(index)
        } else {
            roundedIndex = ceil(index)
        }
        let nextX = roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left
        offset = CGPoint(x: nextX,
                         y: -scrollView.contentInset.top)


        targetContentOffset.pointee = offset
        
        let idx = Int(nextX / cellWidthIncludingSpacing)
        indexLabel.text = "\(idx+1) / \(totalCount)"
    }
    
}
