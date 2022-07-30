//
//  PopupViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/07/30.
//

import UIKit

class PopupViewController: UIViewController {

    var content: String!
    var afterDismiss: (() -> Void)!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 14
        contentLabel.text = content
        button.rx.tap
            .bind { [unowned self] in
                self.dismiss(animated: true) { [unowned self] in
                    afterDismiss!()
                }
            }
            .disposed(by: rx.disposeBag)
    }
    

}
