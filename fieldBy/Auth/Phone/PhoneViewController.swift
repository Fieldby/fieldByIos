//
//  PhoneViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/01.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class PhoneViewController: UIViewController {

    //Top view
    @IBOutlet weak var oneLabel: UILabel!
    @IBOutlet weak var twoLabel: UILabel!
    
    
    
    
    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var certificationButton: UIButton!
    @IBOutlet var viewModel: PhoneViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        makeUI()
        bind()
    }
    
    private func makeUI() {
        self.bottomView.isHidden = true
        phoneContainer.layer.cornerRadius = 13
        phoneContainer.layer.borderColor = UIColor.main.cgColor
        phoneContainer.layer.borderWidth = 1
        
        
    }
    
    private func bind() {
        phoneTextField.rx.text
            .orEmpty
            .bind(to: viewModel.numberSubject)
            .disposed(by: rx.disposeBag)
        
        viewModel.numberValidSubject
            .subscribe(onNext: { [unowned self] bool in
                bool ? makeCertificationValid() : makeCertificationInvalid()
            })
            .disposed(by: rx.disposeBag)
        
        certificationButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                oneLabel.text = "확인 중입니다."
                twoLabel.isHidden = true
                phoneTextField.resignFirstResponder()
                bottomView.isHidden = true
                
                let vc = storyboard?.instantiateViewController(withIdentifier: "checknumberVC")
                vc!.modalPresentationStyle = .overCurrentContext
                self.present(vc!, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    

    @objc func keyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        self.bottomView.isHidden = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.bottomView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
        
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        self.bottomView.isHidden = true
        self.bottomView.transform = .identity
    }
    
    private func makeCertificationValid() {
        phoneContainer.layer.borderWidth = 0
        certificationButton.backgroundColor = .main
    }
    
    private func makeCertificationInvalid() {
        phoneContainer.layer.borderWidth = 1
        certificationButton.backgroundColor = UIColor(red: 147, green: 147, blue: 147)
    }

}
