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
    
    
    let testSubject = BehaviorSubject<[Datum]>(value: [])
    
    var dataList: [Datum] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        pagerView.dataSource = self
        pagerView.delegate = self
        makeUI()
        bind()
    }
    
    private func makeUI() {
        topView.layer.cornerRadius = 27
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        topView.addGrayShadow(color: .lightGray, opacity: 0.2, radius: 3)
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
    
    
}

class pagerCell: FSPagerViewCell {
    static let reuseId = "pagerCell"
}

