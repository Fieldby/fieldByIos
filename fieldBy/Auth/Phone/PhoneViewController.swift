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
import PanModal

class PhoneViewController: UIViewController {

    //Top view
    @IBOutlet weak var oneLabel: UILabel!
    @IBOutlet weak var twoLabel: UILabel!
    
    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var certificationButton: UIButton!
    
    @IBOutlet weak var nameContainer: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet var viewModel: PhoneViewModel!
    
    private let statusSubject = BehaviorSubject<EditingStatus>(value: .number)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func makeUI() {
        self.bottomView.isHidden = true
        phoneContainer.layer.cornerRadius = 13
        phoneContainer.layer.borderColor = UIColor.main.cgColor
        phoneContainer.layer.borderWidth = 1
        
        nameContainer.layer.cornerRadius = 13
        nameContainer.layer.borderColor = UIColor.main.cgColor
        nameContainer.layer.borderWidth = 1
        nameView.isHidden = true
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
                viewModel.presentCheckNumberVC()
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.presentCheckNumberVC = { [unowned self] in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "checknumberVC") as! CheckNumberViewController
            vc.topVC = self
            self.presentPanModal(vc)
        }
        
    }
    

    @objc func keyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardFrame.height
        CommmonView.shared.keyboardHeight = keyboardHeight
        
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

    func startWritingName() {
        phoneTextField.isUserInteractionEnabled = false
        nameView.isHidden = false
        nameTextField.becomeFirstResponder()
        statusSubject.onNext(.name)
        certificationButton.setTitle("입력 완료", for: .normal)
    }
    
    enum EditingStatus {
        case number
        case name
    }
    
}

extension PhoneViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

}
