//
//  FinalInfoViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/16.
//

import UIKit

class FinalInfoViewController: UIViewController {

    static let storyId = "finalinfoVC"
    
    private var status = Status.isPro
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    
    enum Status {
        case isPro
        case style
    }

}
