//
//  UserInfoViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/14.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class UserInfoViewController: UIViewController {

    
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var heightView: UIView!
    @IBOutlet weak var heightContainer: UIView!
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var birthDayView: UIView!
    @IBOutlet weak var birthDayContainer: UIView!
    @IBOutlet weak var birthDayTextField: UITextField!
    
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var jobContainer: UIView!
    @IBOutlet weak var jobTextField: UITextField!
    
    @IBOutlet weak var nickNameContainer: UIView!
    @IBOutlet weak var nickNameTextField: UITextField!
    
    @IBOutlet weak var regionCollectionView: UICollectionView!
    
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet var viewModel: UserInfoViewModel!
    
    private let statusRelay = BehaviorRelay<Status>(value: .nickName)
    private var status = Status.nickName
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        makeUI()
        bind()
        
    }
    
    private func makeUI() {
        nickNameContainer.layer.cornerRadius = 13
        nickNameContainer.layer.borderWidth = 1
        nickNameContainer.layer.borderColor = UIColor.main.cgColor
        
        jobContainer.layer.cornerRadius = 13
        jobContainer.layer.borderWidth = 1
        jobContainer.layer.borderColor = UIColor.main.cgColor
        
        birthDayContainer.layer.cornerRadius = 13
        birthDayContainer.layer.borderWidth = 1
        birthDayContainer.layer.borderColor = UIColor.main.cgColor
        
        heightContainer.layer.cornerRadius = 13
        heightContainer.layer.borderWidth = 1
        heightContainer.layer.borderColor = UIColor.main.cgColor
        
        bottomView.isHidden = true
        
        regionCollectionView.isHidden = true
    }
    
    private func bind() {
        
        nickNameTextField.rx.text.orEmpty
            .bind(to: viewModel.nickNameSubject)
            .disposed(by: rx.disposeBag)
        
        jobTextField.rx.text.orEmpty
            .bind(to: viewModel.jobSubject)
            .disposed(by: rx.disposeBag)
        
        birthDayTextField.rx.text.orEmpty
            .bind(to: viewModel.birthDaySubject)
            .disposed(by: rx.disposeBag)
        
        heightTextField.rx.text.orEmpty
            .bind(to: viewModel.heightSubject)
            .disposed(by: rx.disposeBag)
        
        viewModel.nickNameValidSubject
            .subscribe(onNext: { [unowned self] bool in
                if bool {
                    nickNameContainer.layer.borderWidth = 0
                    
                    nextButton.isEnabled = true
                } else {
                    nickNameContainer.layer.borderWidth = 1
                    
                    nextButton.isEnabled = false
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.jobValidSubject
            .subscribe(onNext: { [unowned self] bool in
                if bool {
                    jobContainer.layer.borderWidth = 0
                    
                    nextButton.isEnabled = true
                } else {
                    jobContainer.layer.borderWidth = 1
                    
                    nextButton.isEnabled = false
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.birthDayValidSubject
            .subscribe(onNext: { [unowned self] bool in
                if bool {
                    birthDayContainer.layer.borderWidth = 0
                    
                    nextButton.isEnabled = true
                } else {
                    birthDayContainer.layer.borderWidth = 1
                    
                    nextButton.isEnabled = false
                }
            })
            .disposed(by: rx.disposeBag)
            
        viewModel.heightValidSubject
            .subscribe(onNext: { [unowned self] bool in
                if bool {
                    heightContainer.layer.borderWidth = 0
                    
                    nextButton.isEnabled = true
                } else {
                    heightContainer.layer.borderWidth = 1
                    
                    nextButton.isEnabled = false
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        statusRelay
            .subscribe(onNext: { [unowned self] status in
                switch status {
                case .nickName:
                    heightView.isHidden = true
                    birthDayView.isHidden = true
                    jobView.isHidden = true
                    
                    numberLabel.text = "(1/5)"
                    
                    nextButton.setTitle("중복 확인", for: .normal)
                    
                    nickNameTextField.isUserInteractionEnabled = true

                case .job:
                    jobView.isHidden = false
                    heightView.isHidden = true
                    birthDayView.isHidden = true
                    
                    numberLabel.text = "(2/5)"
                    
                    nextButton.setTitle("다음", for: .normal)
                    
                    nickNameTextField.isUserInteractionEnabled = false
                    
                case .birthDay:
                    jobView.isHidden = false
                    birthDayView.isHidden = false
                    heightView.isHidden = true

                    
                    numberLabel.text = "(3/5)"
                    
                    jobTextField.isUserInteractionEnabled = false
                    
                case .height:
                    
                    jobView.isHidden = false
                    heightView.isHidden = false
                    birthDayView.isHidden = false
                    
                    numberLabel.text = "(4/5)"
                    
                    birthDayTextField.isUserInteractionEnabled = false
                    
                }
            })
            .disposed(by: rx.disposeBag)
        
        Observable.just(viewModel.regions)
            .bind(to: regionCollectionView.rx.items(cellIdentifier: RegionCell.reuseId, cellType: RegionCell.self)) { idx, region, cell in
                
                cell.mainLabel.text = region
            }
            .disposed(by: rx.disposeBag)
        
        regionCollectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        
        nextButton.rx.tap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                

                switch status {
                case .nickName:
                    status = .job
                    statusRelay.accept(.job)
                    nickNameTextField.resignFirstResponder()
                    jobTextField.becomeFirstResponder()
                    
                    nextButton.isEnabled = false
                case .job:
                    status = .birthDay
                    statusRelay.accept(.birthDay)
                    jobTextField.resignFirstResponder()
                    birthDayTextField.becomeFirstResponder()
                    
                    nextButton.isEnabled = false
                    
                case .birthDay:
                    status = .height
                    statusRelay.accept(.height)
                    birthDayTextField.resignFirstResponder()
                    heightTextField.becomeFirstResponder()
                    
                    nextButton.isEnabled = false
                    
                case .height:
                    
                    heightTextField.resignFirstResponder()
                    regionCollectionView.isHidden = false
                    
                }
                
            })
            .disposed(by: rx.disposeBag)
    }
    
    enum Status {
        case nickName
        case job
        case birthDay
        case height
    }
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        self.bottomView.isHidden = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.bottomView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }

    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        bottomView.isHidden = true
        bottomView.transform = .identity
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension UserInfoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2-12, height: 69)
    }
}

class RegionCell: UICollectionViewCell {
    static let reuseId = "regionCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mainLabel: UILabel!
    
    override func awakeFromNib() {
        containerView.layer.cornerRadius = 13
    }
    
}
