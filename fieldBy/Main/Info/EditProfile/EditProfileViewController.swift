//
//  EditProfileViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/26.
//

import UIKit

class EditProfileViewController: UIViewController {

    static let storyId = "editprofileVC"
    @IBOutlet weak var roadAddrLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        roadAddrLabel.text = AuthManager.shared.myUserModel.juso.roadAddr
        nameLabel.text = AuthManager.shared.myUserModel.name
        phoneNumberLabel.text = AuthManager.shared.myUserModel.phoneNumber
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func addrChange(_ sender: Any) {
        let vc = UIStoryboard(name: "Address", bundle: nil).instantiateViewController(withIdentifier: "addressVC") as! AddressViewController
        vc.isChanging = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func logout(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "logoutVC") as! LogoutViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    @IBAction func signout(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "signoutVC") as! SignoutViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
