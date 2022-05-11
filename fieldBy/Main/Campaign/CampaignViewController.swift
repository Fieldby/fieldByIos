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
import FSPagerView

class CampaignViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var barCollectionView: UICollectionView!
    
    private var showingIndexSubject = BehaviorSubject<Int>(value: 0)
    
    let testSubject = BehaviorSubject<[Datum]>(value: [])
    
    var dataList: [Datum] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        pagerView.dataSource = self
        pagerView.delegate = self
        
        barCollectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        makeUI()
        bind()
    }
    
    private func makeUI() {
        topView.layer.cornerRadius = 27
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        topView.addGrayShadow(color: .lightGray, opacity: 0.2, radius: 3)
        
        barCollectionView.backgroundColor = .none
    }
    
    private func bind() {
        
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        pagerView.itemSize = CGSize(width: 300, height: 450)
        pagerView.isInfinite = true

        
        InstagramManager.test2()
            .subscribe { data in
                self.testSubject.onNext(data.data)
            } onError: { err in
                print(err)
            }
            .disposed(by: rx.disposeBag)

        pagerView.register(pagerCell.self, forCellWithReuseIdentifier: pagerCell.reuseId)
        
        testSubject
            .subscribe(onNext: { [unowned self] array in
                dataList = array
                pagerView.reloadData()
            })
            .disposed(by: rx.disposeBag)
        
        
        testSubject
            .bind(to: barCollectionView.rx.items(cellIdentifier: "barCell", cellType: BarCell.self)) { [unowned self] idx, data, cell in
                
                cell.contentView.backgroundColor = .none

                showingIndexSubject
                    .subscribe(onNext: { [unowned cell] index in
                        if index == idx {
                            cell.mainView.backgroundColor = .white
                        } else {
                            cell.mainView.backgroundColor = .none
                        }
                        
                    })
                    .disposed(by: self.rx.disposeBag)
                
            }
            .disposed(by: rx.disposeBag)

        
    }

}

extension CampaignViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: pagerCell.reuseId, at: index) as! pagerCell

        let url = URL(string: dataList[index].mediaURL)
        
        cell.imageView?.kf.setImage(with: url)
        
        return cell
        
        
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        
        return dataList.count
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        showingIndexSubject.onNext(index)
        
    }
    
}

extension CampaignViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width/CGFloat(dataList.count), height: collectionView.frame.height)
    }
}

class pagerCell: FSPagerViewCell {
    static let reuseId = "pagerCell"
}

