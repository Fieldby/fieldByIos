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
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var unOpenedLabel: UILabel!
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }
    
    private func makeUI() {
        infoView.isHidden = false
        barView.isHidden = false
        pagerView.isHidden = false
        
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

                if idx == showingIndex {
                    cell.mainView.backgroundColor = .white
                } else {
                    cell.mainView.backgroundColor = .none
                }

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
        if model.status == .unOpened {
            brandNameLabel.text = model.brandName
            titleLabel.text = model.itemModel.name
            priceLabel.text = "\(getComma(price: model.itemModel.price))원"
            
            timeLabel.text = "SOON"
            
            missionButton.backgroundColor = UIColor(red: 196, green: 243, blue: 238)
            missionButton.isEnabled = false
            missionButton.setTitle("오픈 전", for: .normal)
            unOpenedLabel.isHidden = false
        } else {
            unOpenedLabel.isHidden = true
            brandNameLabel.text = model.brandName
            titleLabel.text = model.itemModel.name
            priceLabel.text = "\(getComma(price: model.itemModel.price))원"
            
            timeLabel.text = calculateDate(campaignModel: model)
            
            let uuid = model.uuid
            
            if AuthManager.shared.myUserModel.campaignUuids[uuid] == true {
                missionButton.setTitle("신청 완료", for: .normal)
                missionButton.backgroundColor = UIColor(red: 48, green: 48, blue: 48)
            } else {
                missionButton.setTitle("신청하기", for: .normal)
                missionButton.backgroundColor = .main
            }
        }
        
    }

    private func presentDetailVC(campaignModel: CampaignModel, image: UIImage) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: DetailCampaignViewController.storyId) as! DetailCampaignViewController
        vc.campaignModel = campaignModel
        vc.mainImage = image
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
        
        let diff = Int(dueDate.timeIntervalSince(Date()))
        
        if diff < 0 {
            isNewContainer.backgroundColor = .unabled
            timeLabel.textColor = .main
            return "마감"
        }
        
        let diffDay = diff/(3600*24)
        
        if diffDay > 0 {

            isNewContainer.backgroundColor = .unabled
            timeLabel.textColor = .main
            return "D-\(diffDay)"
        } else {
            isNewContainer.backgroundColor = UIColor(red: 239, green: 77, blue: 77)
            timeLabel.textColor = .white
            
            return "D-1"
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
                    if model.status == .unOpened {
                        cell.imageView?.alpha = 0.5
                    }
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
        
        if campaignArray[index].status != .unOpened {
            presentDetailVC(campaignModel: campaignArray[index], image: pagerView.cellForItem(at: index)!.imageView!.image!)
        }
        pagerView.deselectItem(at: index, animated: true)

    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        showingIndexSubject.onNext(targetIndex)
        showingIndex = targetIndex
        
        barCollectionView.reloadData()
    }
    
}

extension CampaignViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == barCollectionView {
            return CGSize(width: collectionView.frame.width / CGFloat(campaignArray.count), height: collectionView.frame.height)
        }
        
        return CGSize(width: 0, height: 0)
    }
}

class pagerCell: FSPagerViewCell {
    static let reuseId = "pagerCell"
}

