//
//  CertiFailedViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/03.
//

import UIKit

class CertiFailedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
