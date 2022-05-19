//
//  CampaignAddressViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/19.
//

import UIKit

class CampaignAddressViewController: CommonGuideViewController {
    static let storyId = "campaignaddressVC"
    
    @IBOutlet weak var roadAddrLabel: UILabel!
    @IBOutlet weak var roadContainer: UIView!
    
    @IBOutlet weak var detailContainer: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var buttonContainer: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet var viewModel: CampaignAddressViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bind()
    }
    
    private func makeUI() {
        [roadContainer, detailContainer]
            .forEach { $0!.layer.cornerRadius = 13 }
        
        buttonContainer.layer.cornerRadius = 21
        buttonContainer.layer.borderWidth = 1
        buttonContainer.layer.borderColor = UIColor.fieldByGray.cgColor
        nextButton.layer.cornerRadius = 13

        
    }
    
    private func bind() {
        roadAddrLabel.text = AuthManager.shared.myUserModel.juso.roadAddr
        detailLabel.text = AuthManager.shared.myUserModel.juso.detail
    }

    @IBAction func next(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: GuideCheckViewController.storyId) as! GuideCheckViewController
        vc.campaignModel = campaignModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
