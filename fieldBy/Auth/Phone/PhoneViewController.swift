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
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var oneLabel: UILabel!
    @IBOutlet weak var twoLabel: UILabel!
    @IBOutlet weak var agreeLabel: UILabel!
    
    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var certificationButton: UIButton!
    
    @IBOutlet weak var nameContainer: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var agreementView: UIView!
    
    @IBOutlet var viewModel: PhoneViewModel!
    
    private var editingStatus = EditingStatus.number
    private let defaultGrayColor = UIColor(red: 147, green: 147, blue: 147)
    
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
        
        agreeLabel.isHidden = true
        agreementView.isHidden = true
    }
    
    private func bind() {
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        phoneTextField.rx.text
            .orEmpty
            .bind(to: viewModel.numberSubject)
            .disposed(by: rx.disposeBag)
        
        viewModel.numberValidSubject
            .subscribe(onNext: { [unowned self] bool in
                bool ? makeCertificationValid() : makeCertificationInvalid()
            })
            .disposed(by: rx.disposeBag)
        
        nameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.nameSubject)
            .disposed(by: rx.disposeBag)
        
        viewModel.nameValidSubject
            .subscribe(onNext: { [unowned self] bool in
                bool ? nameValid() : nameInvalid()
            })
            .disposed(by: rx.disposeBag)
        
        certificationButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                switch editingStatus {
                case .number:
                    oneLabel.text = "확인 중입니다."
                    twoLabel.isHidden = true
                    phoneTextField.resignFirstResponder()
                    bottomView.isHidden = true
                    viewModel.presentCheckNumberVC()
                case .name:
                    startAgreement()
                case .agreement:
                    break
                }

            })
            .disposed(by: rx.disposeBag)
        
        
        
        
        /*
         ViewModel functions
         */
        
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
        certificationButton.isEnabled = true
    }
    
    private func makeCertificationInvalid() {
        phoneContainer.layer.borderWidth = 1
        certificationButton.backgroundColor = defaultGrayColor
        certificationButton.isEnabled = false
    }
    
    private func nameValid() {
        nameContainer.layer.borderWidth = 0
        certificationButton.backgroundColor = .main
        certificationButton.isEnabled = true
    }
    
    private func nameInvalid() {
        nameContainer.layer.borderWidth = 1
        certificationButton.backgroundColor = defaultGrayColor
        certificationButton.isEnabled = false
    }
    
    private func startAgreement() {
        bottomView.isHidden = true
        agreeLabel.isHidden = false
        agreementView.isHidden = false
        nameTextField.resignFirstResponder()
        nameTextField.isUserInteractionEnabled = false

    }

    func startWritingName() {
        phoneTextField.isUserInteractionEnabled = false
        nameView.isHidden = false
        mainLabel.text = "본인인증"
        oneLabel.isHidden = true
        nameTextField.becomeFirstResponder()
        editingStatus = .name
        certificationButton.isEnabled = false
        certificationButton.setTitle("입력 완료", for: .normal)

        certificationButton.backgroundColor = defaultGrayColor
    }
    
    enum EditingStatus {
        case number
        case name
        case agreement
    }
    
}

extension PhoneViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

}
