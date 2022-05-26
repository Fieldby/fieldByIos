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

class DetailCampaignViewController: UIViewController {

    static let storyId = "detailcampaignVC"
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var timeStickyContainer: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var isNewContainer: UIView!
    
    
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    
    @IBOutlet weak var selectionDateLabel: UILabel!
    
    @IBOutlet weak var itemDateLabel: UILabel!
    
    @IBOutlet weak var betweenDateLabel: UILabel!
    
    @IBOutlet weak var leastFeedLabel: UILabel!
    @IBOutlet weak var maintainLabel: UILabel!
    
    @IBOutlet weak var uploadDateLabel: UILabel!
    
    @IBOutlet weak var shadowView: UIView!
    
    
    @IBOutlet weak var bottomTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet var viewModel: DetailCampaignViewModel!
    
    private var timer: Timer?
    
    var campaignModel: CampaignModel!
    var image: UIImage!
    
    var timeSubject = BehaviorSubject<String>(value: "")
    
    var isDone = false
    
    override func viewWillAppear(_ animated: Bool) {

        if !isDone {
            calculateDate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [unowned self] _ in
                calculateDate()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bind()
    }
    

    private func makeUI() {
        indicator.isHidden = true
        timeStickyContainer.layer.cornerRadius = 14.5
        isNewContainer.layer.cornerRadius = 9.5
        dateContainer.layer.cornerRadius = 21
        dateContainer.addGrayShadow(color: .gray, opacity: 0.15, radius: 3)
        
        infoContainer.layer.cornerRadius = 21
        infoContainer.addGrayShadow(color: .gray, opacity: 0.15, radius: 3)
        mainScrollView.contentInsetAdjustmentBehavior = .never
        
        applyButton.layer.cornerRadius = 13
        
        bottomView.layer.cornerRadius = 21
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        shadowView.layer.cornerRadius = 21
        
        if AuthManager.shared.myUserModel.campaignUuids[campaignModel.uuid] == true {
            applyButton.setTitle("캠페인 취소하기", for: .normal)
        }
    }
    
    private func bind() {
        isDone = AuthManager.shared.myUserModel.campaignUuids[campaignModel.uuid] ?? false
        
        if isDone {
            timeStickyContainer.backgroundColor = .main
            timeLabel.text = "신청 완료!"
        }
        
        mainImageView.image = image

        brandNameLabel.text = campaignModel.brandName
        titleLabel.text = campaignModel.itemModel.name
        subTitleLabel.text = campaignModel.itemModel.description
        
        isNewContainer.isHidden = !campaignModel.isNew
        
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
        
        Storage.storage().reference().child(campaignModel.mainImageUrl)
            .downloadURL { [unowned self] url, error in
                if let url = url {
                    mainImageView.kf.setImage(with: url)
                }
            }
        
        selectionDateLabel.text = campaignModel.selectionDate.parsedDate
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
                
                if AuthManager.shared.myUserModel.campaignUuids[campaignModel.uuid] == true {
                    viewModel.presentPopup("캠페인 신청이 취소되었습니다.")
                } else if AuthManager.shared.myUserModel.igModel == nil {
                    viewModel.presentPopup("캠페인에 지원하려면 인스타그램 채널 연결이 필요합니다. \n연결은 마이페이지에서 진행할 수 있습니다.")
                } else {
                    viewModel.pushGuideVC()
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
            vc.uuid = campaignModel.uuid
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
        
    }
    
    private func pushGuideVC() {
        CampaignManager.shared.guideImages(campaignModel: campaignModel)
            .subscribe(onNext: { [unowned self] guideImages in
                
                let vc = UIStoryboard(name: "GuideCampaign", bundle: nil).instantiateViewController(withIdentifier: "guidecampaignVC") as! GuideCampaignViewController
                vc.campaignModel = campaignModel
                vc.guideImages = guideImages
                self.navigationController?.pushViewController(vc, animated: true)
                indicator.stopAnimating()
                indicator.isHidden = true
            })
            .disposed(by: rx.disposeBag)
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
