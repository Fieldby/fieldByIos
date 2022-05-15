//
//  GolfInfoViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/15.
//

import UIKit

class GolfInfoViewController: UIViewController {

    @IBOutlet var viewModel: GolfInfoViewModel!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bind()
    }
    

    private func makeUI() {
        nextButton.layer.cornerRadius = 13
    }

    private func bind() {
        
    }

    
    enum Status {
        case stroke
        case career
        case rounding
    }
}
