//
//  IsProViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/06/08.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class IsProViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var proTypeLabel: UILabel!
    @IBOutlet weak var proTypeTableView: UITableView!
    @IBOutlet weak var associationTableView: UITableView!
    @IBOutlet weak var associationLabel: UILabel!
    
    @IBOutlet weak var proTypeButton: UIButton!
    @IBOutlet weak var associationButton: UIButton!
    
    @IBOutlet weak var proTypeImage: UIImageView!
    @IBOutlet weak var associationImage: UIImageView!
    
    
    @IBOutlet weak var typeTableViewContainer: UIView!
    @IBOutlet weak var typeContainer: UIView!
    
    @IBOutlet weak var associationTableViewContainer: UIView!
    @IBOutlet weak var associationContainer: UIView!
    private let proTypes = ["티칭프로", "협회준회원", "협회정회원", "투어프로"]
    private var isTypeOpened = false
    
    private let associations = ["KLPGA", "LPGA", "KPGA", "PGA", "기타 / 없음"]
    private var isAssociationOpened = false
    
    private var proType: String?
    private var association: String?
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var preBottomView: UIView!
    @IBOutlet weak var proBottomView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var nonView: UIView!
    @IBOutlet weak var nonAssociationTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        proBottomView.isHidden = true
        associationContainer.isHidden = true
        typeContainer.isHidden = true
        
        yesButton.layer.cornerRadius = 13
        noButton.layer.cornerRadius = 13
        
        nonView.layer.cornerRadius = 13
        
        nonView.isHidden = true
        
        
        
        typeContainer.layer.cornerRadius = 13
        typeContainer.layer.borderColor = UIColor.main.cgColor
        typeContainer.layer.borderWidth = 1
        
        associationContainer.layer.cornerRadius = 13
        associationContainer.layer.borderColor = UIColor.main.cgColor
        associationContainer.layer.borderWidth = 1
        
        nextButton.layer.cornerRadius = 13
        nextButton.isEnabled = false
        nextButton.backgroundColor = .unabled
        
        typeTableViewContainer.isHidden = true
        associationTableViewContainer.isHidden = true
        
        
        proTypeTableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        associationTableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)

        Observable.just(proTypes)
            .bind(to: proTypeTableView.rx.items(cellIdentifier: OptionCell.reuseId, cellType: OptionCell.self)) { idx, type, cell in
                cell.mainLabel.text = type
            }
            .disposed(by: rx.disposeBag)
            
        
        Observable.just(associations)
            .bind(to: associationTableView.rx.items(cellIdentifier: OptionCell.reuseId, cellType: OptionCell.self)) { idx, type, cell in
                cell.mainLabel.text = type
            }
            .disposed(by: rx.disposeBag)
        
        
        proTypeButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                if isTypeOpened {
            
                    UIView.animate(withDuration: 0.2) { [unowned self] in
                        isTypeOpened = false
                        typeTableViewContainer.isHidden = true
                        
                        proTypeImage.image = UIImage(systemName: "chevron.down")
                    }

                } else {
                    
                    UIView.animate(withDuration: 0.2) { [unowned self] in
                        isTypeOpened = true
                        typeTableViewContainer.isHidden = false
                        
                        isAssociationOpened = false
                        associationTableViewContainer.isHidden = true
                        
                        associationImage.image = UIImage(systemName: "chevron.down")
                        proTypeImage.image = UIImage(systemName: "chevron.up")
                    }

                }
            })
            .disposed(by: rx.disposeBag)
        
        proTypeTableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                proType = proTypes[idx.row]
                if association != nil {
                    nextButton.isEnabled = true
                    nextButton.backgroundColor = .main
                }
                UIView.animate(withDuration: 0.2) { [unowned self] in
                    isAssociationOpened = true
                    associationTableViewContainer.isHidden = false
                    
                    isTypeOpened = false
                    typeTableViewContainer.isHidden = true
                    
                    proTypeImage.image = UIImage(systemName: "chevron.down")
                    
                    associationImage.image = UIImage(systemName: "chevron.up")
                    
                    proTypeLabel.text = proType
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        
        associationTableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                association = associations[idx.row]
                if idx.row == 4 {
                    nonView.isHidden = false
                    association = nil
                    associationLabel.text = associations[idx.row]
                    associationImage.image = UIImage(systemName: "chevron.down")
                    isAssociationOpened = false
                    associationTableViewContainer.isHidden = true
                } else {
                    if proType != nil {
                        nextButton.isEnabled = true
                        nextButton.backgroundColor = .main
                    }
                    
                    UIView.animate(withDuration: 0.2) { [unowned self] in
                        isAssociationOpened = false
                        associationTableViewContainer.isHidden = true
                        
                        associationImage.image = UIImage(systemName: "chevron.down")
                        
                        associationLabel.text = association
                    }
                    
                }
            })
            .disposed(by: rx.disposeBag)
        
        associationButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                if isAssociationOpened {
                    
                    UIView.animate(withDuration: 0.2) { [unowned self] in
                        isAssociationOpened = false
                        associationTableViewContainer.isHidden = true
                        
                        associationImage.image = UIImage(systemName: "chevron.down")
                    }
                    

                } else {
                    
                    UIView.animate(withDuration: 0.2) { [unowned self] in
                        isAssociationOpened = true
                        associationTableViewContainer.isHidden = false
                        
                        isTypeOpened = false
                        typeTableViewContainer.isHidden = true
                        
                        proTypeImage.image = UIImage(systemName: "chevron.down")
                        
                        associationImage.image = UIImage(systemName: "chevron.up")
                    }
                    
                }
            })
            .disposed(by: rx.disposeBag)
        
        nonAssociationTextfield.rx.text
            .subscribe(onNext: { [unowned self] str in
                if let str = str {
                    if str.count > 1 {
                        association = str
                        nextButton.isEnabled = true
                        nextButton.backgroundColor = .main
                    } else {
                        nextButton.isEnabled = false
                        nextButton.backgroundColor = .unabled
                    }
                }
            })
            .disposed(by: rx.disposeBag)
            
        
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                AuthManager.saveUserInfo(key: "isPro", value: true)
                AuthManager.saveUserInfo(key: "proType", value: proType!)
                AuthManager.saveUserInfo(key: "association", value: association!)
                
                let vc = storyboard?.instantiateViewController(withIdentifier: FinalInfoViewController.storyId) as! FinalInfoViewController
                navigationController?.pushViewController(vc, animated: true)

            })
            .disposed(by: rx.disposeBag)
        
        
    }
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardFrame.height

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.proBottomView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
        
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        proBottomView.transform = .identity

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func preYes(_ sender: Any) {
        preBottomView.isHidden = true
        proBottomView.isHidden = false
        
        typeContainer.isHidden = false
        associationContainer.isHidden = false
        
        
    }
    
    @IBAction func preNo(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: FinalInfoViewController.storyId) as! FinalInfoViewController
        AuthManager.saveUserInfo(key: "isPro", value: false)
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension IsProViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
}
