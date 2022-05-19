//
//  GuideFinalViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/19.
//

import UIKit

class GuideFinalViewController: UIViewController {
    
    static let storyId = "guidefinalVC"

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var viewMyCampaignsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dismissButton.layer.cornerRadius = 13
        viewMyCampaignsButton.layer.cornerRadius = 13
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func viewOthers(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
}
