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
        
        usernameLabel.text = "@\(AuthManager.shared.myUserModel.igModel?.username ?? "field_by")"
        
        indicator.isHidden = false
        indicator.startAnimating()
        
        viewModel.fetch()
            .subscribe { [unowned self] in
                tableView.reloadData()
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
        navigationController?.navigationBar.isHidden = true
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

        
        viewModel.toShowArray
            .map { array -> String in
                return "\(array.filter { $0.0.status == .applied }.count)건"
            }
            .bind(to: appliedLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.toShowArray
            .map { array -> String in
                return "\(array.filter { $0.0.status == .done }.count)건"
            }
            .bind(to: doneLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.toShowArray
            .map { array -> String in
                return "\(array.filter { $0.0.status != .done && $0.0.status != .applied }.count)건"
            }
            .bind(to: inProgressLabel.rx.text)
            .disposed(by: rx.disposeBag)

        
        viewModel.toShowArray
            .bind(to: tableView.rx.items(cellIdentifier: ProgressMainCell.reuseId, cellType: ProgressMainCell.self)) { [unowned self] idx, model, cell in
                
                cell.buttonHandler = { [unowned self] in
                    let vc = UIStoryboard(name: "Upload", bundle: nil).instantiateViewController(withIdentifier: "medialistVC") as! MediaListViewController
                    vc.modalPresentationStyle = .fullScreen
                    vc.campaignModel = model.0
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                cell.bind(campaignModel: model.0, userModel: model.1)
            }
            .disposed(by: rx.disposeBag)
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        tableView.rx.modelSelected((CampaignModel, UserCampaignModel).self)
            .subscribe(onNext: { [unowned self] model in
                if model.0.status == .applied {
                    indicator.isHidden = false
                    indicator.startAnimating()
                    
                    CampaignManager.shared.isSelected(uuid: model.0.uuid)
                        .subscribe { [unowned self] bool in
                            
                            viewModel.showStatus(bool, model.0)
                            indicator.isHidden = true
                            indicator.stopAnimating()
                        } onError: { [unowned self] _ in
                            indicator.isHidden = true
                            indicator.stopAnimating()
                        }
                        .disposed(by: rx.disposeBag)
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.showStatus = { [unowned self] bool, model in
            guard let bool = bool else {
                pushGuideFinalVC(model: model)
                return
            }
            
            bool ? pushSelectedVC() : pushUnselectedVC()
            
        }
        
        
    }

    @objc func pullToRefresh(_ sender: Any) {
        viewModel.fetch()
            .subscribe { [unowned self] in
                tableView.refreshControl?.endRefreshing()
                
            } onError: { [unowned self] error in
                print(error)
                tableView.refreshControl?.endRefreshing()
            }
            .disposed(by: rx.disposeBag)

    }
    
    func pushGuideFinalVC(model: CampaignModel) {
        let vc = UIStoryboard(name: "GuideCampaign", bundle: nil).instantiateViewController(withIdentifier: "guidefinalVC") as! GuideFinalViewController
        vc.campaignModel = model
        vc.isAppling = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushSelectedVC() {
        let vc = UIStoryboard(name: "GuideCampaign", bundle: nil).instantiateViewController(withIdentifier: CampaignSelectedViewController.storyId) as! CampaignSelectedViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushUnselectedVC() {
        let vc = UIStoryboard(name: "GuideCampaign", bundle: nil).instantiateViewController(withIdentifier: CampaignUnSelectedViewController.storyId) as! CampaignUnSelectedViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
