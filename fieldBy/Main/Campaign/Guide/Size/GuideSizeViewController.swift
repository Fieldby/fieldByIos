//
//  GuideSizeViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/25.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class GuideSizeViewController: CommonGuideViewController {

    static let storyId = "guidesizeVC"
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var optionTextfield: UITextField!
    @IBOutlet weak var optionLabel: UILabel!
    
    private var option: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nextButton.layer.cornerRadius = 13
        nextButton.isEnabled = false
        nextButton.backgroundColor = .unabled
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        optionTextfield.rx.text
            .orEmpty
            .subscribe(onNext: { [unowned self] option in
                self.option = option
            })
            .disposed(by: rx.disposeBag)
        
        
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let vc = UIStoryboard(name: "GuideCampaign", bundle: nil).instantiateViewController(withIdentifier: GuideFinalViewController.storyId) as! GuideFinalViewController
                vc.campaignModel = campaignModel
                vc.option = option
                navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        optionTextfield.rx.text
            .orEmpty
            .map { $0.count > 2 }
            .subscribe(onNext: { [unowned self] in
                nextButton.isEnabled = true
                nextButton.backgroundColor = .main
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}

extension GuideSizeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

class OptionCell: UITableViewCell {
    static let reuseId = "optionCell"
    
    @IBOutlet weak var mainLabel: UILabel!
    
}
