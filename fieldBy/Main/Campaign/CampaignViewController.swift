//
//  CampaignViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/04.
//

import UIKit

class CampaignViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
    }
    
    private func makeUI() {
        topView.layer.cornerRadius = 27
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        topView.addGrayShadow(color: .lightGray, opacity: 0.2, radius: 3)

    }

}
