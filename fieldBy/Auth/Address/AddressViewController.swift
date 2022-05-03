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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        makeUI()
        bind()
    }
    
    private func makeUI() {
        addrContainerView.layer.cornerRadius = 13
        addrContainerView.layer.borderWidth = 1
        addrContainerView.layer.borderColor = UIColor.main.cgColor
    }
    
    private func bind() {
        
        AuthManager.address(keyword: "수서동")
            .asObservable()
            .map { return $0.results.juso }
            .bind(to: tableView.rx.items(cellIdentifier: AddressCell.reuseId, cellType: AddressCell.self)) { idx, juso, cell in
                cell.bind(juso: juso)
            }
            .disposed(by: rx.disposeBag)
        
        
        
        
        
    }


}

extension AddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
