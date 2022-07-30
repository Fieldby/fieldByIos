//
//  OptionPopupViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/07/30.
//

import UIKit

class OptionPopupViewController: UIViewController {

    var content: String!
    var afterDismiss: (() -> Void)!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 14
        yesButton.layer.cornerRadius = 14
        backButton.layer.cornerRadius = 14
        contentLabel.text = content
        yesButton.rx.tap
            .bind { [unowned self] in
                self.dismiss(animated: true) { [unowned self] in
                    afterDismiss!()
                }
            }
            .disposed(by: rx.disposeBag)
        
        backButton.rx.tap
            .bind { [unowned self] in
                self.dismiss(animated: true)
            }
            .disposed(by: rx.disposeBag)
    }
    

}
