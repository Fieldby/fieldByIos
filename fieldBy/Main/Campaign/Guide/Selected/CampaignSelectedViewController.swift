//
//  CampaignSelectedViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/06/05.
//

import UIKit
import FirebaseStorage

class CampaignSelectedViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var guideButton: UIButton!
    
    @IBOutlet weak var campaignImageView: UIImageView!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var detailButton: UIButton!
    
    var campaignModel: CampaignModel!
    
    static let storyId = "campaignselectedVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        indicator.isHidden = true
        
        campaignImageView.layer.cornerRadius = 4
        guideButton.isEnabled = false
        
        Storage.storage().reference().child(campaignModel.mainImageUrl)
            .downloadURL { [unowned self] url, error in
                if let url = url {
                    campaignImageView.kf.setImage(with: url)
                    guideButton.isEnabled = true
                }
            }
        brandNameLabel.text = campaignModel.brandName
        itemNameLabel.text = campaignModel.itemModel.name
        
        guideButton.layer.cornerRadius = 13
        
        container.layer.cornerRadius = 13
        container.addGrayShadow()
        
        mainLabel.text = "축하합니다 @\(AuthManager.shared.myUserModel.igModel!.username)"
        
        guideButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                indicator.isHidden = false
                indicator.startAnimating()
                
                CampaignManager.shared.guideImages(campaignModel: campaignModel)
                    .subscribe(onNext: { [unowned self] images in
                        let vc = storyboard?.instantiateViewController(withIdentifier: "guidecampaignVC") as! GuideCampaignViewController
                        vc.guideImages = images
                        vc.campaignModel = campaignModel
                        indicator.stopAnimating()
                        indicator.isHidden = true
                        navigationController?.pushViewController(vc, animated: true)
                    })
                    .disposed(by: rx.disposeBag)
                
            })
            .disposed(by: rx.disposeBag)
        
        detailButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true) { [unowned self] in
                    presentDetailVC(campaignModel: campaignModel, image: campaignImageView.image!)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func pop(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func presentDetailVC(campaignModel: CampaignModel, image: UIImage) {
        
        let vc = UIStoryboard(name: "Campaign", bundle: nil).instantiateViewController(withIdentifier: DetailCampaignViewController.storyId) as! DetailCampaignViewController
        vc.campaignModel = campaignModel
        vc.mainImage = image
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .fullScreen
        AuthManager.shared.mainTabBar.present(nav, animated: true)

    }

}
