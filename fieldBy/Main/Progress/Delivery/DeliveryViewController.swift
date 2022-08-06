//
//  DeliveryViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/07/30.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class DeliveryViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    var userCampaignModel: UserCampaignModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        button.layer.cornerRadius = 14
        bind()
    }
    
    private func bind() {
        if let shipmentName = userCampaignModel.shipmentName {
            nameLabel.text = "택배사: \(shipmentName)"
        }
        if let number = userCampaignModel.shipmentNumber {
            numberLabel.text = "송장번호: \(number)"
        }
        
        button.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            })
            .disposed(by: rx.disposeBag)
    }

    @IBAction func tap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
