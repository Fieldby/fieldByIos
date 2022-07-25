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
    
    @IBOutlet weak var topSpace: UIView!
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
    
    //Agreement
    
    @IBOutlet weak var spaceView: UIView!
    @IBOutlet weak var agreementFoldButton: UIButton!
    private var agreeAll = false
    @IBOutlet weak var agreeAllButton: UIButton!
    @IBOutlet weak var agreeAllImageView: UIImageView!
    
    private var usage = false
    @IBOutlet weak var usageView: UIView!
    @IBOutlet weak var usageButton: UIButton!
    @IBOutlet weak var usageImageView: UIImageView!
    
    private var privacy = false
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var privacyImageView: UIImageView!
    
    private var marketing = false
    @IBOutlet weak var marketingView: UIView!
    @IBOutlet weak var marketingButton: UIButton!
    @IBOutlet weak var marketingImageView: UIImageView!
    
    
    @IBOutlet weak var finalButton: UIButton!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    @IBOutlet var viewModel: PhoneViewModel!
    
    private var folded = false
    
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
        indicator.isHidden = true
        finalButton.isHidden = true
        finalButton.layer.cornerRadius = 13
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
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                switch editingStatus {
                case .number:
                    endEditingNumber()
                case .name:
                    startAgreement()
                case .agreement:
                    break
                }
            })
            .disposed(by: rx.disposeBag)
        
        agreeAllButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in

                viewModel.usageSubject.onNext(!agreeAll)
                usage = !agreeAll
                viewModel.privacySubject.onNext(!agreeAll)
                privacy = !agreeAll
                viewModel.marketingSubject.onNext(!agreeAll)
                marketing = !agreeAll
                
                viewModel.agreeAllSubject.onNext(!agreeAll)
                
                if agreeAll {
                    openAgreement()
                } else {
                    foldAgreement()
                }
                
                agreeAll = !agreeAll
                
            })
            .disposed(by: rx.disposeBag)
        
        usageButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                viewModel.usageSubject.onNext(!usage)
                usage = !usage
                if !usage == false {
                    agreeAll = false
                }
            })
            .disposed(by: rx.disposeBag)
        
        privacyButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                viewModel.privacySubject.onNext(!privacy)
                privacy = !privacy
                if !privacy == false {
                    agreeAll = false
                }
            })
            .disposed(by: rx.disposeBag)
        
        marketingButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                viewModel.marketingSubject.onNext(!marketing)
                marketing = !marketing
                if !privacy == false {
                    agreeAll = false
                }
            })
            .disposed(by: rx.disposeBag)

        viewModel.agreeAllSubject
            .map { $0 ? UIImage(named: "authCheckSelected") : UIImage(named: "authCheckUnselected") }
            .bind(to: agreeAllImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        viewModel.usageSubject
            .map { $0 ? UIImage(named: "authCheckSelected") : UIImage(named: "authCheckUnselected") }
            .bind(to: usageImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        viewModel.privacySubject
            .map { $0 ? UIImage(named: "authCheckSelected") : UIImage(named: "authCheckUnselected") }
            .bind(to: privacyImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        viewModel.marketingSubject
            .map { $0 ? UIImage(named: "authCheckSelected") : UIImage(named: "authCheckUnselected") }
            .bind(to: marketingImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        finalButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                indicator.isHidden = false
                indicator.startAnimating()
                
                viewModel.saveAgreement(bool: marketing)
                    .subscribe { [unowned self] in
                        let vc = UIStoryboard(name: "Address", bundle: nil).instantiateViewController(withIdentifier: "addressVC") as! AddressViewController
                        indicator.isHidden = true
                        indicator.stopAnimating()
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    } onError: { [unowned self] error in
                        indicator.isHidden = true
                        indicator.stopAnimating()
                        print(error)
                    }
                    .disposed(by: rx.disposeBag)
            })
            .disposed(by: rx.disposeBag)
        
        agreementFoldButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if !folded {

                    foldAgreement()
                } else {

                    openAgreement()
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        
        
        /*
         ViewModel functions
         */
        
        viewModel.presentCheckNumberVC = { [unowned self] in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "checknumberVC") as! CheckNumberViewController
            vc.topVC = self
            vc.phoneNumber = phoneTextField.text!
            self.presentPanModal(vc)
        }
        
        viewModel.pushFailedVC = { [unowned self] in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "certifailedVC") as! CertiFailedViewController
            self.navigationController?.pushViewController(vc, animated: true)
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
//        self.bottomView.isHidden = true
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
    
    private func endEditingNumber() {
        phoneTextField.resignFirstResponder()
        indicator.isHidden = false
        indicator.startAnimating()
        
        UIView.animate(withDuration: 0.3) { [unowned self] in
            oneLabel.text = "확인 중입니다."
            twoLabel.isHidden = true
            bottomView.isHidden = true
        }
        viewModel.checkNumber(number: phoneTextField.text ?? "")
            .subscribe(onNext: { [unowned self] bool in
                indicator.stopAnimating()
                indicator.isHidden = true
                if bool {
                    viewModel.presentCheckNumberVC()
                } else {
                    viewModel.pushFailedVC()
                }
            })
            .disposed(by: rx.disposeBag)
  

        viewModel.finalButtonValidSubject
            .bind(to: finalButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

    }
    
    private func startAgreement() {
        indicator.startAnimating()
        indicator.isHidden = false
        viewModel.saveName(name: nameTextField.text!)
            .subscribe { [unowned self] in
                
                indicator.stopAnimating()
                indicator.isHidden = true
                
                nameTextField.resignFirstResponder()
                UIView.animate(withDuration: 0.3) { [unowned self] in
                    bottomView.isHidden = true
                    agreeLabel.isHidden = false
                    agreementView.isHidden = false
                    topSpace.isHidden = true
                    finalButton.isHidden = false
                }
                
            } onError: { [unowned self] error in
                indicator.stopAnimating()
                indicator.isHidden = true
                print(error)
            }
            .disposed(by: rx.disposeBag)

        

    }

    func startWritingName(uuid: String) {
        indicator.isHidden = false
        indicator.startAnimating()
        
        AuthManager.shared.fetch(uuid: uuid)
            .subscribe { [unowned self] in
                indicator.isHidden = true
                indicator.stopAnimating()
                print("this")
                navigationController?.dismiss(animated: true, completion: {
                    AuthManager.shared.defaultVC.toMain()
                })
            } onError: { [unowned self] _ in
                phoneTextField.isUserInteractionEnabled = false

                indicator.isHidden = true
                indicator.stopAnimating()
                
                nameTextField.becomeFirstResponder()
                editingStatus = .name
                certificationButton.isEnabled = false
                UIView.animate(withDuration: 0.3) { [unowned self] in
                    nameView.isHidden = false
                    mainLabel.text = "본인인증"
                    oneLabel.isHidden = true
                    certificationButton.setTitle("입력 완료", for: .normal)
                    certificationButton.backgroundColor = defaultGrayColor
                }
            }
            .disposed(by: rx.disposeBag)
    }
    
    private func foldAgreement() {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            agreementFoldButton.setImage(UIImage(named: "chevron.down"), for: .normal)
            spaceView.isHidden = true
            usageView.isHidden = true
            privacyView.isHidden = true
            marketingView.isHidden = true
        } completion: { [unowned self] _ in
            folded = true
        }
    }
    
    private func openAgreement() {
        
        UIView.animate(withDuration: 0.3) { [unowned self] in
            agreementFoldButton.setImage(UIImage(named: "chevron.up"), for: .normal)
            spaceView.isHidden = false
            usageView.isHidden = false
            privacyView.isHidden = false
            marketingView.isHidden = false
        } completion: { [unowned self] _ in
            folded = false
        }

    }
    
    enum EditingStatus {
        case number
        case name
        case agreement
    }
    
    @IBAction func usageTap(_ sender: Any) {
        openUrl(url: "https://hyuwo.notion.site/f82dd55f687e42c9aa901206d6009800")
    }
    
    @IBAction func privacyTap(_ sender: Any) {
        openUrl(url: "https://hyuwo.notion.site/234d2a7b6aee4fc7b0146c707391e9f9")
    }
    
    @IBAction func marketingTap(_ sender: Any) {
        openUrl(url: "https://hyuwo.notion.site/d09a1e7a3f974b2ba1527ce576a33bcd")
    }
}

extension PhoneViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

}
