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
import FBSDKLoginKit

class CampaignViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var barCollectionView: UICollectionView!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var missionButton: UIButton!
    @IBOutlet weak var isNewContainer: UIView!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet var viewModel: CampaignViewModel!
    
    private var campaignArray: [CampaignModel] = CampaignManager.shared.campaignArray
    
    private var showingIndexSubject = BehaviorSubject<Int>(value: 0)
    private var showingIndex = 0
    
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        indicator.isHidden = true
        
        pagerView.dataSource = self
        pagerView.delegate = self
        
        barCollectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        makeUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.reload()
        showingIndexSubject.onNext(showingIndex)
    }
    
    private func makeUI() {
        infoView.isHidden = false
        barView.isHidden = false
        pagerView.isHidden = false
        
        timerView.layer.cornerRadius = 14.5
        topView.layer.cornerRadius = 27
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        topView.addGrayShadow(color: .lightGray, opacity: 0.3, radius: 3)
        
        barCollectionView.backgroundColor = .none
        
        infoView.layer.cornerRadius = 21
        infoView.addGrayShadow(color: .lightGray, opacity: 0.3, radius: 3)
        
        isNewContainer.layer.cornerRadius = 9.5
        
        missionButton.layer.cornerRadius = 10
    }
    
    private func bind() {

        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width-65, height: 450)
        pagerView.isInfinite = true

        pagerView.register(pagerCell.self, forCellWithReuseIdentifier: pagerCell.reuseId)
        
        viewModel.campaignRelay
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
        
        showingIndexSubject
            .subscribe(onNext: { [unowned self] idx in
                timer?.invalidate()
                timer = nil
                
                bindInfoView(model: campaignArray[idx])
                
                
            })
            .disposed(by: rx.disposeBag)

        missionButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let index = showingIndex
                presentDetailVC(campaignModel: campaignArray[index], image: pagerView.cellForItem(at: index)!.imageView!.image!)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func bindInfoView(model: CampaignModel) {
        timerLabel.text = calculateDate(campaignModel: model)
        brandNameLabel.text = model.brandName
        titleLabel.text = model.itemModel.name
        isNewContainer.isHidden = !model.isNew
        priceLabel.text = "\(getComma(price: model.itemModel.price))원"
        
        let uuid = model.uuid
        
        if AuthManager.shared.myUserModel.campaignUuids[uuid] == true {
            missionButton.setTitle("신청 완료", for: .normal)
            missionButton.backgroundColor = UIColor(red: 48, green: 48, blue: 48)
        } else {
            missionButton.setTitle("신청하기", for: .normal)
            missionButton.backgroundColor = .main
        }
        
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [unowned self] _ in
                timerLabel.text = calculateDate(campaignModel: model)
            })
        }
    }

    private func presentDetailVC(campaignModel: CampaignModel, image: UIImage) {
        let vc = storyboard?.instantiateViewController(withIdentifier: DetailCampaignViewController.storyId) as! DetailCampaignViewController
        vc.campaignModel = campaignModel
        vc.image = image
        
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
        
    }
    
    private func getComma(price : Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = NSLocale.current
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.usesGroupingSeparator = true
        return formatter.string(from: price as NSNumber) ?? ""
        
    }
    
    private func calculateDate(campaignModel: CampaignModel) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
        
        let dueDate = dateFormatter.date(from: campaignModel.dueDate)!
        
        var diff = Int(dueDate.timeIntervalSince(Date()))
        
        let diffDay = diff/(3600*24)
        
        if diffDay > 0 {
            return "\(diffDay)일 후 마감"
        } else {
            let diffHour = diff/3600
            diff = diff - diffHour*3600
            
            let diffMin = diff/60
            diff = diff - diffMin*60

            return "\(diffHour):\(diffMin):\(diff) 후 마감"
        }
    }
    
}


extension CampaignViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: pagerCell.reuseId, at: index) as! pagerCell

        let model = campaignArray[index]

        Storage.storage().reference().child(model.mainImageUrl)
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

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
        pagerView.deselectItem(at: index, animated: true)
        presentDetailVC(campaignModel: campaignArray[index], image: pagerView.cellForItem(at: index)!.imageView!.image!)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        showingIndexSubject.onNext(targetIndex)
        showingIndex = targetIndex
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

