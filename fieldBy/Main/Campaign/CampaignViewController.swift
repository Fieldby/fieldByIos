//
//  CampaignViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/04.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class CampaignViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    let testSubject = BehaviorSubject<[Datum]>(value: [])
    private var showingIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bind()
    }
    
    private func makeUI() {
        topView.layer.cornerRadius = 27
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        topView.addGrayShadow(color: .lightGray, opacity: 0.2, radius: 3)
        
        mainCollectionView.backgroundColor = .none
    }
    
    private func bind() {
        mainCollectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        InstagramManager.test2()
            .subscribe { data in
                self.testSubject.onNext(data.data)
            } onError: { err in
                print(err)
            }
            .disposed(by: rx.disposeBag)
        
        testSubject
            .bind(to: mainCollectionView.rx.items(cellIdentifier: CampaignCollectionViewCell.reuseId, cellType: CampaignCollectionViewCell.self)) { idx, data, cell in
                let url = URL(string: data.mediaURL)
                cell.mainImage.kf.setImage(with: url)
                

            }
        
        
    }

}


extension CampaignViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width-70, height: collectionView.frame.height)
        
    }
}
