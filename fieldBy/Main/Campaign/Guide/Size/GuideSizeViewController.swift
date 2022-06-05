//
//  GuideSizeViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/25.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class GuideSizeViewController: CommonGuideViewController {

    static let storyId = "guidesizeVC"
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sizeContainer: UIView!
    
    @IBOutlet weak var sizeTableViewContainer: UIView!
    @IBOutlet weak var sizeTableView: UITableView!
    @IBOutlet weak var sizeImage: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var colorContainer: UIView!
    @IBOutlet weak var colorTableViewContainer: UIView!
    @IBOutlet weak var colorTableView: UITableView!
    @IBOutlet weak var colorImage: UIImageView!
    @IBOutlet weak var colorLabel: UILabel!
    
    @IBOutlet weak var sizeButton: UIButton!
    @IBOutlet weak var colorButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    private var isSizeOpened = false
    private var isColorOpened = false
    
    private var size: String!
    private var color: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        sizeContainer.layer.cornerRadius = 13
        sizeContainer.layer.borderColor = UIColor.main.cgColor
        sizeContainer.layer.borderWidth = 1
        
        colorContainer.layer.cornerRadius = 13
        colorContainer.layer.borderColor = UIColor.main.cgColor
        colorContainer.layer.borderWidth = 1
        
        nextButton.layer.cornerRadius = 13
        nextButton.isEnabled = false
        nextButton.backgroundColor = .unabled
        
        sizeTableViewContainer.isHidden = true
        colorTableViewContainer.isHidden = true
        
        
        sizeTableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        colorTableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        Observable.just(campaignModel.itemModel.option!.size)
            .bind(to: sizeTableView.rx.items(cellIdentifier: OptionCell.reuseId, cellType: OptionCell.self)) { idx, size, cell in
                cell.mainLabel.text = size
            }
            .disposed(by: rx.disposeBag)
        
        Observable.just(campaignModel.itemModel.option!.color)
            .bind(to: colorTableView.rx.items(cellIdentifier: OptionCell.reuseId, cellType: OptionCell.self)) { idx, color, cell in
                cell.mainLabel.text = color
            }
            .disposed(by: rx.disposeBag)
        
        
        sizeButton.rx.tap
            .throttle(0.5, latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                if isSizeOpened {
            
                    UIView.animate(withDuration: 0.2) { [unowned self] in
                        isSizeOpened = false
                        sizeTableViewContainer.isHidden = true
                        
                        sizeImage.image = UIImage(systemName: "chevron.down")
                    }

                } else {
                    
                    UIView.animate(withDuration: 0.2) { [unowned self] in
                        isSizeOpened = true
                        sizeTableViewContainer.isHidden = false
                        
                        isColorOpened = false
                        colorTableViewContainer.isHidden = true
                        
                        colorImage.image = UIImage(systemName: "chevron.down")
                        sizeImage.image = UIImage(systemName: "chevron.up")
                    }

                }
            })
            .disposed(by: rx.disposeBag)
        
        sizeTableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                size = campaignModel.itemModel.option!.size[idx.row]
                if color != nil {
                    nextButton.isEnabled = true
                    nextButton.backgroundColor = .main
                }
                UIView.animate(withDuration: 0.2) { [unowned self] in
                    isColorOpened = true
                    colorTableViewContainer.isHidden = false
                    
                    isSizeOpened = false
                    sizeTableViewContainer.isHidden = true
                    
                    sizeImage.image = UIImage(systemName: "chevron.down")
                    
                    colorImage.image = UIImage(systemName: "chevron.up")
                    
                    sizeLabel.text = "사이즈: \(size!)"
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        
        colorTableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                color = campaignModel.itemModel.option!.color[idx.row]
                if size != nil {
                    nextButton.isEnabled = true
                    nextButton.backgroundColor = .main
                }
                
                UIView.animate(withDuration: 0.2) { [unowned self] in
                    isColorOpened = false
                    colorTableViewContainer.isHidden = true
                    
                    colorImage.image = UIImage(systemName: "chevron.down")
                    
                    colorLabel.text = "색상: \(color!)"
                }
            })
            .disposed(by: rx.disposeBag)
        
        colorButton.rx.tap
            .throttle(0.5, latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                if isColorOpened {
                    
                    UIView.animate(withDuration: 0.2) { [unowned self] in
                        isColorOpened = false
                        colorTableViewContainer.isHidden = true
                        
                        colorImage.image = UIImage(systemName: "chevron.down")
                    }
                    

                } else {
                    
                    UIView.animate(withDuration: 0.2) { [unowned self] in
                        isColorOpened = true
                        colorTableViewContainer.isHidden = false
                        
                        isSizeOpened = false
                        sizeTableViewContainer.isHidden = true
                        
                        sizeImage.image = UIImage(systemName: "chevron.down")
                        
                        colorImage.image = UIImage(systemName: "chevron.up")
                    }
                    
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let vc = UIStoryboard(name: "GuideCampaign", bundle: nil).instantiateViewController(withIdentifier: GuideFinalViewController.storyId) as! GuideFinalViewController
                vc.campaignModel = campaignModel
                vc.size = size
                vc.color = color
                navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
}

extension GuideSizeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

class OptionCell: UITableViewCell {
    static let reuseId = "optionCell"
    
    @IBOutlet weak var mainLabel: UILabel!
    
}
