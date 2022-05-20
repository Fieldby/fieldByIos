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
    
    
    
    @IBOutlet var viewModel: ProgressViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.rx.setDelegate(self)
//            .disposed(by: rx.disposeBag)
        makeUI()
        bind()
    }
    
    private func makeUI() {
        topView.layer.cornerRadius = 27
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        topView.addGrayShadow(color: .lightGray, opacity: 0.3, radius: 3)
    }
    
    private func bind() {
        usernameLabel.text = "@\(AuthManager.shared.myUserModel.igModel?.username ?? "field_by")"
        
        
        appliedLabel.text = String(AuthManager.shared.myUserModel.appliedCount()) + "건"
        inProgressLabel.text = String(AuthManager.shared.myUserModel.inProgressCount()) + "건"
        
        doneLabel.text = String(AuthManager.shared.myUserModel.doneCount()) + "건"
        
        viewModel.tosShowArray
            .bind(to: tableView.rx.items(cellIdentifier: ProgressMainCell.reuseId, cellType: ProgressMainCell.self)) { idx, model, cell in
                
                cell.bind(campaignModel: model.0, status: model.1.status)
                
                
            }
            .disposed(by: rx.disposeBag)
    }

}

//extension ProgressViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return CGFloat(350)
//    }
//}
