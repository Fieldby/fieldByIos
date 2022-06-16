//
//  AddressViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/03.
//

import UIKit
import RxSwift
import NSObject_Rx
import RxCocoa

class AddressViewController: UIViewController {

    @IBOutlet var viewModel: AddressViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addrContainerView: UIView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var addrResetButton: UIButton!
    
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var detailResetButton: UIButton!
    
    @IBOutlet weak var detailAddrContainer: UIView!
    @IBOutlet weak var detailTextField: UITextField!
    
    private var editingStatus = EditingStatus.addr
    
    private var juso: Juso!
    
    var campaignUuid: String?
    var isIndividual = false
    var isChanging: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
   
        AuthManager.shared.mainTabBar.hide()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        AuthManager.shared.mainTabBar.show()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        addressTextField.delegate = self
        
        makeUI()
        bind()
    }
    
    private func makeUI() {
        indicator.isHidden = true
        addrContainerView.layer.cornerRadius = 13
        addrContainerView.layer.borderWidth = 1
        addrContainerView.layer.borderColor = UIColor.main.cgColor
        
        detailAddrContainer.isHidden = true
        detailAddrContainer.layer.cornerRadius = 13
        detailAddrContainer.layer.borderWidth = 1
        detailAddrContainer.layer.borderColor = UIColor.main.cgColor
        
        bottomView.isHidden = true
        
        if isChanging || isIndividual {
            searchButton.setTitle("변경 완료", for: .normal)
        }
    }
    
    private func bind() {
        if let myUserModel = AuthManager.shared.myUserModel {
            juso = myUserModel.juso
            viewModel.search(keyword: juso.jibunAddr) {
                
            }
        }
        
        
        viewModel.jusoSubject
            .bind(to: tableView.rx.items(cellIdentifier: AddressCell.reuseId, cellType: AddressCell.self)) { idx, juso, cell in
                cell.bind(juso: juso)
            }
            .disposed(by: rx.disposeBag)
        
        searchButton.rx.tap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                switch editingStatus {
                case .addr:
                    indicator.isHidden = false
                    indicator.startAnimating()
                    addressTextField.resignFirstResponder()
                    viewModel.search(keyword: addressTextField.text ?? "") { [unowned self] in
                        indicator.stopAnimating()
                        indicator.isHidden = true
                    }
                case .detail:
                    if isChanging {
                        saveAndPop()
                    } else if isIndividual {
                        saveAndDismiss()
                    } else {
                        pushUserInfoVC()
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        Observable.combineLatest(tableView.rx.modelSelected(Juso.self), tableView.rx.itemSelected)
            .subscribe(onNext: { [unowned self] juso, idx in
                self.juso = juso
                tableView.deselectRow(at: idx, animated: true)
                addressTextField.text = juso.roadAddr
                detailAddr()
            })
            .disposed(by: rx.disposeBag)
        
        addrResetButton.rx.tap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                addressTextField.text = nil
            })
            .disposed(by: rx.disposeBag)
        
        detailResetButton.rx.tap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                detailTextField.text = nil
            })
            .disposed(by: rx.disposeBag)
        
        addressTextField.rx.text
            .orEmpty
            .subscribe(onNext: { [unowned self] str in
                if str.contains(" ") {
                    presentAlert(message: "띄어쓰기 없이 입력해주세요.")
                    
                    var array = Array(str).map{String($0)}
                    array.removeLast()
                    let newStr = array.joined()
                    addressTextField.rx.text.onNext(newStr)
                }
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    private func detailAddr() {
        addrResetButton.isHidden = true
        addrContainerView.layer.borderWidth = 0
        tableView.isHidden = true
        detailAddrContainer.isHidden = false
        detailTextField.becomeFirstResponder()
        editingStatus = .detail
    }
    
    private func reSearchAddr() {
        addrResetButton.isHidden = false
        tableView.isHidden = false
        addrContainerView.layer.borderWidth = 1
        detailAddrContainer.isHidden = true
        detailTextField.text = nil
        editingStatus = .addr
    }
    
    private func saveAndDismiss() {
        CampaignManager.shared.saveAddress(uid: campaignUuid!, juso: juso, detail: detailTextField.text!)
        dismiss(animated: true)
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
    
    private func saveAndPop() {
        AuthManager.saveAddressInfo(juso: juso, detail: detailTextField.text!)
        navigationController?.popViewController(animated: true)
    }

    private func pushUserInfoVC() {
        
        AuthManager.saveAddressInfo(juso: juso, detail: detailTextField.text!)
        
        let vc = UIStoryboard(name: "UserInfo", bundle: nil).instantiateViewController(withIdentifier: "infostartVC") as! InfoStartViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    enum EditingStatus {
        case addr
        case detail
    }

    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension AddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

extension AddressViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == addressTextField && editingStatus == .detail {
            reSearchAddr()
        }
    }
}
