//
//  GolfInfoViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/15.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class GolfInfoViewController: UIViewController {


    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    
    
    @IBOutlet var viewModel: GolfInfoViewModel!
    
    private let toShowArray = BehaviorRelay<[Any]>(value: [])
    private let statusRelay = BehaviorRelay<Status>(value: .stroke)
    private var status = Status.stroke
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bind()
    }
    

    private func makeUI() {
        nextButton.layer.cornerRadius = 13
        
        tableView.isHidden = true
    }

    private func bind() {
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        Observable.just(RoundingCount.allCases)
            .bind(to: tableView.rx.items(cellIdentifier: RoundingCell.reuseId, cellType: RoundingCell.self)) { [unowned self] idx, rounding, cell in
                cell.mainLabel.text = rounding.rawValue
            }
            .disposed(by: rx.disposeBag)
        
        toShowArray
            .bind(to: collectionView.rx.items(cellIdentifier: RegionCell.reuseId, cellType: RegionCell.self)) { idx, someThing, cell in
                
                if let stroke = someThing as? StrokeAverage {
                    cell.mainLabel.text = stroke.rawValue
                }
                
                if let career = someThing as? Career {
                    cell.mainLabel.text = career.rawValue
                }
                
                cell.unselected()
            }
            .disposed(by: rx.disposeBag)
        
        statusRelay.subscribe(onNext: { [unowned self] status in
            switch status {
            case .stroke:
                setStroke()
                
            case .career:
                setCareer()
                
            case .rounding:
                setRounding()
    
            }
        })
        .disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                if status == .stroke {
                    if let idx = viewModel.strokeIndex {
                        let cell = collectionView.cellForItem(at: [0, idx]) as! RegionCell
                        cell.unselected()
                    }
                    viewModel.strokeIndex = idx.row
                } else if status == .career {
                    if let idx = viewModel.careerIndex {
                        let cell = collectionView.cellForItem(at: [0, idx]) as! RegionCell
                        cell.unselected()
                    }
                    viewModel.careerIndex = idx.row
                }
                let cell = collectionView.cellForItem(at: idx) as! RegionCell
                cell.selected()
            })
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                if let idx = viewModel.roundingIndex {
                    let cell = tableView.cellForRow(at: [0, idx]) as! RoundingCell
                    cell.deselect()
                }
                
                viewModel.roundingIndex = idx.row
                let cell = tableView.cellForRow(at: [0, idx.row]) as! RoundingCell
                cell.selected()
                
                tableView.deselectRow(at: [0, idx.row], animated: true)
                
                
            })
            .disposed(by: rx.disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                switch status {
                case .stroke:
                    if viewModel.strokeIndex != nil {
                        statusRelay.accept(.career)
                        status = .career
                    }
                case .career:
                    if viewModel.careerIndex != nil {
                        statusRelay.accept(.rounding)
                        status = .rounding
                    }
                case .rounding:
                    viewModel.saveInfo()
                    viewModel.pushFinalVC()
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.pushFinalVC = { [unowned self] in
            let vc = storyboard?.instantiateViewController(withIdentifier: FinalInfoViewController.storyId) as! FinalInfoViewController
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }

    private func setStroke() {
        toShowArray.accept(StrokeAverage.allCases)
        mainLabel.text = "평균 타수를 선택해주세요."
        numberLabel.text = "(1/3)"
        
    }
    
    private func setCareer() {
        toShowArray.accept(Career.allCases)
        mainLabel.text = "골프 경력을 선택해주세요."
        numberLabel.text = "(2/3)"
    }
    
    private func setRounding() {
        collectionView.isHidden = true
        tableView.isHidden = false
        mainLabel.text = "월 라운딩 횟수를 선택해주세요."
        numberLabel.text = "(3/3)"
    }
    
    enum Status {
        case stroke
        case career
        case rounding
    }
}

extension GolfInfoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2-12, height: 69)
    }
}

extension GolfInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(69)
    }
}
