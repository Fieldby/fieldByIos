//
//  GuideCautionViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/19.
//

import UIKit

class GuideCautionViewController: CommonGuideViewController {

    static let storyId = "guidecautionVC"
    
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonContainer.layer.cornerRadius = 21
        buttonContainer.layer.borderWidth = 1
        buttonContainer.layer.borderColor = UIColor.fieldByGray.cgColor
        
        nextButton.layer.cornerRadius = 13
    }
    

    @IBAction func next(_ sender: Any) {

    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
