//
//  FinalInfoViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/16.
//

import UIKit
import RxSwift
import NSObject_Rx
import RxCocoa

class FinalInfoViewController: UIViewController {

    static let storyId = "finalinfoVC"
    
    
    @IBOutlet weak var isProView: UILabel!
    @IBOutlet weak var styleView: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var isPro = false
    private var status = Status.isPro
    
    private var selectedCount = 0
    private var cellViewModel: [Bool] = [Bool](repeating: false, count: Style.allCases.count)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.isHidden = true
        styleView.isHidden = true
        yesButton.layer.cornerRadius = 13
        noButton.layer.cornerRadius = 13
        
        yesButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if status == .isPro {
                    isPro = true
                    status = .style
                    collectionView.isHidden = false
                    styleView.isHidden = false
                    isProView.isHidden = true
                } else if status == .style {
                    saveInfo()
                    navigationController?.dismiss(animated: true)
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        noButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if status == .isPro {
                    isPro = false
                    status = .style
                    collectionView.isHidden = false
                    styleView.isHidden = false
                    isProView.isHidden = true
                } else if status == .style {
                    saveInfo()
                }
            })
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        Observable.just(Style.allCases)
            .bind(to: collectionView.rx.items(cellIdentifier: RegionCell.reuseId, cellType: RegionCell.self)) { idx, style, cell in
                cell.mainLabel.text = "#\(style.rawValue)"
            }
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                if cellViewModel[idx.row] {
                    cellUnselect(idx: idx.row)
                    selectedCount -= 1
                    yesButton.setTitle("예(\(selectedCount)/3)", for: .normal)
                } else {
                    if selectedCount == 3 {
                        
                    } else {
                        cellSelect(idx: idx.row)
                        selectedCount += 1
                        yesButton.setTitle("예(\(selectedCount)/3)", for: .normal)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    private func cellUnselect(idx: Int) {
        let cell = collectionView.cellForItem(at: [0, idx]) as! RegionCell
        cell.unselected()
        cellViewModel[idx] = false
    }
    
    private func cellSelect(idx: Int) {
        let cell = collectionView.cellForItem(at: [0, idx]) as! RegionCell
        cell.selected()
        cellViewModel[idx] = true
    }
    
    private func saveInfo() {
        AuthManager.saveUserInfo(key: "isPro", value: isPro)
        var value: [String: String] = [:]
        var count = 0
        for i in 0..<cellViewModel.count {
            if cellViewModel[i] {
                value[String(count)] = Style.allCases[i].rawValue
                count += 1
            }
        }
        AuthManager.saveUserInfo(key: "styles", value: value)
    }

    
    enum Status {
        case isPro
        case style
    }

}

extension FinalInfoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2-12, height: 69)
    }
}
