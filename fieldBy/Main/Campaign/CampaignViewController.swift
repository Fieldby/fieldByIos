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
import FirebaseStorage

class CampaignViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var barCollectionView: UICollectionView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var missionButton: UIButton!
    
    @IBOutlet var viewModel: CampaignViewModel!
    
    private var campaignArray: [CampaignModel] = []
    
    private var showingIndexSubject = BehaviorSubject<Int>(value: 0)

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
        
        infoView.layer.cornerRadius = 21
        infoView.addGrayShadow(color: .lightGray, opacity: 0.15, radius: 3)
        
        missionButton.layer.cornerRadius = 10
    }
    
    private func bind() {
        
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width-65, height: 450)
        pagerView.isInfinite = true

        pagerView.register(pagerCell.self, forCellWithReuseIdentifier: pagerCell.reuseId)
        
        CampaignManager.shared.campaignArrayRelay
            .subscribe(onNext: { [unowned self] array in
                campaignArray = array
                pagerView.reloadData()
            })
            .disposed(by: rx.disposeBag)
        
        
        CampaignManager.shared.campaignArrayRelay
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

    private func presentDetailVC(campaignModel: CampaignModel) {
        let vc = storyboard?.instantiateViewController(withIdentifier: DetailCampaignViewController.storyId) as! DetailCampaignViewController
        vc.campaignModel = campaignModel
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        
    }
}

extension CampaignViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: pagerCell.reuseId, at: index) as! pagerCell

        let model = campaignArray[index]

        Storage.storage().reference().child(model.imageUrl)
            .downloadURL { url, error in
                if let url = url {
                    cell.imageView?.kf.setImage(with: url)
                }
            }

        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 21
        cell.imageView?.contentMode = .scaleToFill
        cell.imageView?.addGrayShadow(color: .lightGray, opacity: 0.15, radius: 3)
        
        return cell
        
        
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        
        return campaignArray.count
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        showingIndexSubject.onNext(index)
        
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
        presentDetailVC(campaignModel: campaignArray[index])
    }
    
}

extension CampaignViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: collectionView.frame.height)
    }
}

class pagerCell: FSPagerViewCell {
    static let reuseId = "pagerCell"
}

