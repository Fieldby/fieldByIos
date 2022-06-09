//
//  SignoutViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/06/09.
//

import UIKit
import Firebase

class SignoutViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        button.layer.cornerRadius = 13
        textView.delegate = self
        // Do any additional setup after loading the view.
        
        textView.layer.cornerRadius = 13
        textView.layer.borderColor = UIColor.main.cgColor
        textView.layer.borderWidth = 1
        
        placeholderSetting()
        
        button.rx.tap
            .subscribe(onNext: { [unowned self] in
                let vc = storyboard?.instantiateViewController(withIdentifier: "logoutVC") as! LogoutViewController
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.titleText = "정말 탈퇴하시겠어요?"
                vc.isSigningOut = true
                vc.reason = textView.text!
                vc.topVC = self
                present(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    

}

extension SignoutViewController: UITextViewDelegate {
    func placeholderSetting() {
        textView.text = "탈퇴 사유를 작성해주세요."
        textView.textColor = .gray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray {
            textView.text = nil
            textView.textColor = UIColor(red: 48, green: 48, blue: 48)
        }

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "탈퇴 사유를 작성해주세요."
            textView.textColor = .gray
        }
    }
}
