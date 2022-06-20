//
//  NotiViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/27.
//

import UIKit

class NotiViewController: UIViewController {

    @IBOutlet var viewModel: NotiViewModel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        makeUI()
        bind()
        
    }
    
    private func makeUI() {
        
    }
    
    private func bind() {
        
        viewModel.notiArray
            .bind(to: tableView.rx.items(cellIdentifier: NotiCell.reuseId, cellType: NotiCell.self)) { [unowned self] idx, notiModel, cell in
                cell.bind(notiModel: notiModel)
            }
            .disposed(by: rx.disposeBag)
        
        
    }
            
            
    @IBAction func pop(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    


}

extension NotiViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(140)
    }
}
