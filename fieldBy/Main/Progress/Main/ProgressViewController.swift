//
//  ProgressViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/04.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class ProgressViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var appliedLabel: UILabel!
    
    @IBOutlet weak var inProgressLabel: UILabel!
    
    @IBOutlet weak var doneLabel: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    
    @IBOutlet var viewModel: ProgressViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        indicator.isHidden = false
        indicator.startAnimating()
        
        viewModel.fetch()
            .subscribe { [unowned self] in
                indicator.isHidden = true
                indicator.stopAnimating()
                
            } onError: { [unowned self] err in
                print(err)
                indicator.isHidden = true
                indicator.stopAnimating()
            }
            .disposed(by: rx.disposeBag)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bind()
    }
    
    private func makeUI() {
        indicator.isHidden = true
        topView.layer.cornerRadius = 27
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        topView.addGrayShadow(color: .lightGray, opacity: 0.3, radius: 3)
    }
    
    private func bind() {
        usernameLabel.text = "@\(AuthManager.shared.myUserModel.igModel?.username ?? "field_by")"
        
        
//        appliedLabel.text = String(AuthManager.shared.myUserModel.appliedCount()) + "건"
//        inProgressLabel.text = String(AuthManager.shared.myUserModel.inProgressCount()) + "건"
//
//        doneLabel.text = String(AuthManager.shared.myUserModel.doneCount()) + "건"
        
        viewModel.tosShowArray
            .bind(to: tableView.rx.items(cellIdentifier: ProgressMainCell.reuseId, cellType: ProgressMainCell.self)) { idx, model, cell in
                
                cell.bind(campaignModel: model.0, status: model.0.status)
                
                
            }
            .disposed(by: rx.disposeBag)
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
    }

    @objc func pullToRefresh(_ sender: Any) {
        viewModel.fetch()
            .subscribe { [unowned self] in
                tableView.refreshControl?.endRefreshing()
                
            } onError: { [unowned self] error in
                print(error)
                tableView.refreshControl?.endRefreshing()
            }

    }
}
