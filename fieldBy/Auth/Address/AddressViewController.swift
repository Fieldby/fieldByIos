//
//  AddressViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/03.
//

import UIKit

class AddressViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        AuthManager.address(keyword: "수서동")
            .subscribe { response in
                print(response.results.juso)
            } onError: { err in
                print(err)
            }

    }
    


}
