//
//  CheckNumberViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/02.
//

import UIKit
import PanModal
import RxSwift
import RxCocoa
import NSObject_Rx

class CheckNumberViewController: UIViewController {
    
    @IBOutlet weak var dragIndicator: UIView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var codeContainer: UIView!
    
    @IBOutlet weak var reRequestButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet var viewModel: CheckNumberViewModel!
    var topVC: PhoneViewController!
    
    private var isKeyboardLoaded = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        makeUI()
        bind()
        

    }

    private func makeUI() {
        dragIndicator.layer.cornerRadius = 2.5
        requestButton.layer.cornerRadius = 13
        
        codeView.isHidden = true
        
        reRequestButton.layer.cornerRadius = 13
        reRequestButton.layer.borderWidth = 1
        reRequestButton.layer.borderColor = UIColor.fieldByGray.cgColor
        
        codeContainer.layer.cornerRadius = 13
        codeContainer.layer.borderWidth = 1
        codeContainer.layer.borderColor = UIColor.main.cgColor
        
        bottomView.isHidden = true
    }
    
    private func bind() {
        requestButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                requestButton.isHidden = true
                codeView.isHidden = false
                codeTextField.becomeFirstResponder()
                
            })
            .disposed(by: rx.disposeBag)
        
        codeTextField.rx.text
            .orEmpty
            .bind(to: viewModel.codeSubject)
            .disposed(by: rx.disposeBag)
        
        viewModel.codeValidSubject
            .subscribe(onNext: { [unowned self] bool in
                if bool {
                    self.codeContainer.layer.borderWidth = 0
                    self.nextButton.backgroundColor = .main
                    nextButton.isEnabled = true
                } else {
                    self.codeContainer.layer.borderWidth = 1
                    self.nextButton.backgroundColor = UIColor(red: 147, green: 147, blue: 147)
                    nextButton.isEnabled = false
                }
            })
            .disposed(by: rx.disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true) {
                    self.topVC.startWritingName()
                }
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
        isKeyboardLoaded = true
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
        
        
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        bottomView.isHidden = true
        bottomView.transform = .identity
        isKeyboardLoaded = false
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }

}

extension CheckNumberViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(204)
    }
    
    var longFormHeight: PanModalHeight {
        return isKeyboardLoaded ? .contentHeight(260+CommmonView.shared.keyboardHeight) : .contentHeight(204)
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.6)
    }
}
