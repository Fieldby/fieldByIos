//
//  InstagramViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/04.
//

import UIKit

class InstagramViewController: UIViewController {

    @IBOutlet weak var instagramTextField: UITextField!
    @IBOutlet weak var instagramContainer: UIView!
    @IBOutlet weak var instaResetButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
   
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bind()
    }
    
    private func makeUI() {
        instagramContainer.layer.cornerRadius = 13
        instagramContainer.layer.borderWidth = 1
        instagramContainer.layer.borderColor = UIColor.main.cgColor
        
        instaResetButton.isHidden = true
    }
    
    private func bind() {
        instaResetButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                instagramTextField.text = nil
            })
            .disposed(by: rx.disposeBag)
        
        instagramTextField.rx.text
            .map { text -> Bool in
                return text == nil
            }
            .bind(to: instaResetButton.rx.isHidden )
            .disposed(by: rx.disposeBag)
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

}
