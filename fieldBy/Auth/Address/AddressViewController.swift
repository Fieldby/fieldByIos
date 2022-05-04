//
//  AddressViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/03.
//

import UIKit

class AddressViewController: UIViewController {

    @IBOutlet var viewModel: AddressViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addrContainerView: UIView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
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

        
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        makeUI()
        bind()
    }
    
    private func makeUI() {
        indicator.isHidden = true
        addrContainerView.layer.cornerRadius = 13
        addrContainerView.layer.borderWidth = 1
        addrContainerView.layer.borderColor = UIColor.main.cgColor
    }
    
    private func bind() {
        
        
        
        viewModel.jusoSubject
            .bind(to: tableView.rx.items(cellIdentifier: AddressCell.reuseId, cellType: AddressCell.self)) { idx, juso, cell in
                cell.bind(juso: juso)
            }
            .disposed(by: rx.disposeBag)
        
        searchButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                indicator.isHidden = false
                indicator.startAnimating()
                addressTextField.resignFirstResponder()
                viewModel.search(keyword: addressTextField.text ?? "") { [unowned  self] in
                    indicator.stopAnimating()
                    indicator.isHidden = true
                }
            })
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

extension AddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
