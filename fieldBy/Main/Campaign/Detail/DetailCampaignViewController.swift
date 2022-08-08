//
//  DetailCampaignViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/12.
//

import UIKit
import Kingfisher
import FirebaseStorage
import RxSwift
import RxRelay

class DetailCampaignViewController: UIViewController {

    static let storyId = "detailcampaignVC"
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var mainImageButton: UIButton!
    
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var timeStickyContainer: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var isNewContainer: UIView!
    
    
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    
    @IBOutlet weak var itemUrlButton: UIButton!
    @IBOutlet weak var selectionDateLabel: UILabel!
    @IBOutlet weak var doneSelectionDateLabel: UILabel!
    
    @IBOutlet weak var itemDateLabel: UILabel!
    
    @IBOutlet weak var betweenDateLabel: UILabel!
    
    @IBOutlet weak var leastFeedLabel: UILabel!
    @IBOutlet weak var maintainLabel: UILabel!
    
    @IBOutlet weak var uploadDateLabel: UILabel!
    
    @IBOutlet weak var shadowView: UIView!
    
    
    @IBOutlet weak var bottomTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var helpButton: UIButton!
    
    @IBOutlet weak var doneBottomView: UIView!
    
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var notDoneView: UIView!
    @IBOutlet weak var notDoneInfoView: UIView!
    
    
    //DoneView
    @IBOutlet weak var doneInfoView: UIView!
    @IBOutlet weak var doneView: UIView!
    @IBOutlet weak var roadAddrLabel: UILabel!
    @IBOutlet weak var postNumLabel: UILabel!
    @IBOutlet weak var cancelInfoLabel: UILabel!
    @IBOutlet weak var addressButton: UIButton!
    
    
    @IBOutlet weak var imageGuideView: UIView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet var viewModel: DetailCampaignViewModel!
    
    private var timer: Timer?
    
    private let mainTabBar = AuthManager.shared.mainTabBar
    
    private var isSelected = false
    var mainImage: UIImage!
    var campaignModel: CampaignModel!
    var timeSubject = BehaviorSubject<String>(value: "")
    var animationTimer: Timer?
    
    var isDone = false
    
    override func viewWillAppear(_ animated: Bool) {

        if !isDone {
            calculateDate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [unowned self] _ in
                calculateDate()
            })
        }
        
        if let model = AuthManager.shared.myUserModel.campaigns.first(where: { $0.uuid == campaignModel.uuid }) {
            roadAddrLabel.text = model.juso?.roadAddr ?? AuthManager.shared.myUserModel.juso.roadAddr
            postNumLabel.text = model.juso?.zipNo ?? AuthManager.shared.myUserModel.juso.zipNo
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationTimer?.invalidate()
        timer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bind()
    }
    

    private func makeUI() {
        if AuthManager.shared.myUserModel.selectedCampaigns[campaignModel.uuid] == true { isSelected = true }
        
        mainImageView.image = mainImage
        imageGuideView.layer.cornerRadius = 16
        indicator.isHidden = true
        timeStickyContainer.layer.cornerRadius = 14.5
        isNewContainer.layer.cornerRadius = 9.5
        dateContainer.layer.cornerRadius = 21
        dateContainer.addGrayShadow(color: .gray, opacity: 0.15, radius: 3)
        
        infoContainer.layer.cornerRadius = 21
        infoContainer.addGrayShadow(color: .gray, opacity: 0.15, radius: 3)
        mainScrollView.contentInsetAdjustmentBehavior = .never
        
        applyButton.layer.cornerRadius = 13
        cancelButton.layer.cornerRadius = 13
        progressButton.layer.cornerRadius = 13
        
        bottomView.layer.cornerRadius = 21
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        doneBottomView.isHidden = true
        
        
        shadowView.layer.cornerRadius = 21
        
        timeStickyContainer.addGrayShadow()
        
        isDone = AuthManager.shared.myUserModel.campaignUuids[campaignModel.uuid] ?? false
        
        if isDone {
            timeStickyContainer.backgroundColor = .main
            timeLabel.text = "제안 완료!"
            notDoneView.isHidden = true
            doneView.isHidden = false
            notDoneInfoView.isHidden = true
            doneInfoView.isHidden = false
            
            doneBottomView.isHidden = false
            shadowView.isHidden = true
            bottomView.isHidden = true
            
            if isSelected {
                cancelButton.isHidden = true
                progressButton.setTitle("가이드 확인", for: .normal)
                cancelInfoLabel.isHidden = true
            }

        } else {
            notDoneView.isHidden = false
            doneView.isHidden = true
            
            notDoneInfoView.isHidden = false
            doneInfoView.isHidden = true
            
            doneBottomView.isHidden = true
            shadowView.isHidden = false
            bottomView.isHidden = false
            
            if campaignModel.status != .applied {
                applyButton.isEnabled = false
                applyButton.backgroundColor = .unabled
            }
        }
        
        var cnt = 0
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self] timer in

            if cnt < 100 {
                imageGuideView.alpha = CGFloat(100-cnt)/100
            } else if cnt < 200 {
                imageGuideView.alpha = CGFloat(cnt-100)/100
            } else if cnt < 300 {
                imageGuideView.alpha = CGFloat(300-cnt)/100
            } else if cnt < 400 {
                imageGuideView.alpha = CGFloat(cnt-300)/100
            } else if cnt == 400 {
                timer.invalidate()
            }
            cnt += 1
        })
        
        
    }
    
    private func bind() {
        
        brandNameLabel.text = campaignModel.brandName
        titleLabel.text = campaignModel.itemModel.name
        subTitleLabel.text = campaignModel.itemModel.description
        
        isNewContainer.isHidden = !campaignModel.isNew
        
        cancelInfoLabel.text = "신청 취소는 \(campaignModel.selectionDate.month)월 \(campaignModel.selectionDate.day)일 전까지만 가능합니다"
        
        if !isDone {
            timeSubject
                .observeOn(MainScheduler.asyncInstance)
                .bind(to: timeLabel.rx.text)
                .disposed(by: rx.disposeBag)
        }

        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        
        selectionDateLabel.text = campaignModel.selectionDate.parsedDate
        doneSelectionDateLabel.text = "\(campaignModel.selectionDate.month)월 \(campaignModel.selectionDate.day)일"
        itemDateLabel.text = "~\(campaignModel.itemDate.parsedDate)"
        betweenDateLabel.text = "\(campaignModel.itemDate.parsedDate)~\(campaignModel.uploadDate.parsedDate)"
        uploadDateLabel.text = campaignModel.uploadDate.parsedDate
        
        
        bottomTitleLabel.text = campaignModel.itemModel.name
        priceLabel.text = getComma(price: campaignModel.itemModel.price) + "원"
        
        maintainLabel.text = "\(campaignModel.maintain)일"
        leastFeedLabel.text = "\(campaignModel.leastFeed)회"
        
        applyButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                
                if AuthManager.shared.myUserModel.igModel == nil {
                    viewModel.presentPopup("캠페인에 지원하려면 인스타그램 채널 연결이 필요합니다. \n연결은 마이페이지에서 진행할 수 있습니다.")
                } else {
                    viewModel.pushGuideVC()
                }


            })
            .disposed(by: rx.disposeBag)
        
        itemUrlButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                openUrl(url: campaignModel.itemModel.url)
            })
            .disposed(by: rx.disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                viewModel.presentPopup("캠페인 신청이 취소되었습니다.")
            })
            .disposed(by: rx.disposeBag)
        
        progressButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if isSelected {
                    indicator.isHidden = false
                    indicator.startAnimating()
                    
                    CampaignManager.shared.guideImages(campaignModel: campaignModel)
                        .subscribe(onNext: { [unowned self] images in
                            let vc = UIStoryboard(name: "GuideCampaign", bundle: nil).instantiateViewController(withIdentifier: "guidecampaignVC") as! GuideCampaignViewController
                            vc.guideImages = images
                            vc.campaignModel = campaignModel
                            indicator.stopAnimating()
                            indicator.isHidden = true
                            navigationController?.pushViewController(vc, animated: true)
                        })
                        .disposed(by: rx.disposeBag)
                } else {
                    dismiss(animated: true) { [unowned self] in
                        mainTabBar!.selectedIndex = 1
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.pushGuideVC = { [unowned self] in
            if timeLabel.text == "마감" {
                viewModel.presentPopup("마감되었습니다")
            } else {
                indicator.isHidden = false
                indicator.startAnimating()
                pushGuideVC()
            }
        }
        
        viewModel.presentPopup = { [unowned self] str in
            
            let vc = storyboard?.instantiateViewController(withIdentifier: CommonPopupViewController.storyId) as! CommonPopupViewController
            vc.modalTransitionStyle = .crossDissolve
            vc.content = str
            vc.topVC = self
            vc.campaignModel = campaignModel
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: true)
        }
        
        mainScrollView.rx.didScroll
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] in
                if !isDone {
                    calculateDate()
                }
            })
            .disposed(by: rx.disposeBag)

        helpButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                viewModel.helpAction()
            })
            .disposed(by: rx.disposeBag)
        
        mainImageButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                presentImageVC()
            })
            .disposed(by: rx.disposeBag)
        
        addressButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let vc = UIStoryboard(name: "Address", bundle: nil).instantiateViewController(withIdentifier: "addressVC") as! AddressViewController
                vc.modalPresentationStyle = .fullScreen
                vc.isIndividual = true
                vc.campaignUuid = campaignModel.uuid
                self.present(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func presentImageVC() {
        indicator.isHidden = false
        indicator.startAnimating()
        
        CampaignManager.shared.mainImageUrl(campaignModel: campaignModel)
            .subscribe { [unowned self] urlArray in
                let vc = storyboard?.instantiateViewController(withIdentifier: MainImageViewController.storyId) as! MainImageViewController
                indicator.isHidden = true
                indicator.stopAnimating()
                
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.imageRelay.accept(urlArray)
                self.present(vc, animated: true)
            } onError: { [unowned self] err in
                indicator.isHidden = true
                indicator.stopAnimating()
                
                print(err)
            }
            .disposed(by: rx.disposeBag)

        

    }
    
    private func pushGuideVC() {
        let vc = UIStoryboard(name: "GuideCampaign", bundle: nil).instantiateViewController(withIdentifier: "guidecheckVC") as! GuideCheckViewController
        vc.campaignModel = campaignModel
        self.navigationController?.pushViewController(vc, animated: true)
        indicator.stopAnimating()
        indicator.isHidden = true
    }
    
    private func pushGuideImageVC() {
        let vc = UIStoryboard(name: "GuideCampaign", bundle: nil).instantiateViewController(withIdentifier: "guidecheckVC") as! GuideCheckViewController
        vc.campaignModel = campaignModel
        self.navigationController?.pushViewController(vc, animated: true)
        indicator.stopAnimating()
        indicator.isHidden = true
    }
    
    private func getComma(price : Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = NSLocale.current
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.usesGroupingSeparator = true
        return formatter.string(from: price as NSNumber) ?? ""
        
    }
    
    private func calculateDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
        
        let dueDate = dateFormatter.date(from: campaignModel.dueDate)!
        
        var diff = Int(dueDate.timeIntervalSince(Date()))
        
        if diff < 0 {
            timeSubject.onNext("마감")
        } else {
            let diffDay = diff/(3600*24)
            if diffDay > 0 {
                timeSubject.onNext("\(diffDay)일 후 마감")
            } else {
                
                let diffHour = diff/3600
                diff = diff - diffHour*3600
                
                let diffMin = diff/60
                diff = diff - diffMin*60
                
                timeSubject.onNext("\(diffHour):\(diffMin):\(diff) 후 마감")
            }
        }
    }

    
}

extension DetailCampaignViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

class MainImageCell: UICollectionViewCell {
    static let reuseId = "mainimageCell"
    @IBOutlet weak var mainImageView: UIImageView!
    
    
    
}
