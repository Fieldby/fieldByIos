//
//  CommonPopupViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/24.
//

import UIKit

class CommonPopupViewController: UIViewController {
    
    static let storyId = "popupVC"
    
    var content: String!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentLabel.text = content
        containerView.layer.cornerRadius = 13
        
    }

    @IBAction func click(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
