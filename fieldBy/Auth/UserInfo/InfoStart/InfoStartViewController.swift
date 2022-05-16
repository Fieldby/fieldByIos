//
//  InfoStartViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/16.
//

import UIKit

class InfoStartViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nextButton.layer.cornerRadius = 13
    }
    
    @IBAction func next(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "userinfoVC") as! UserInfoViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
