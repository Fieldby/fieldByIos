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

    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mainLabel: UILabel!
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
    
    @IBOutlet weak var finalButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var finalView: UIView!
    
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
        
        finalButton.layer.cornerRadius = 13
        
        bottomView.isHidden = true
        
        regionCollectionView.isHidden = true
        finalView.isHidden = true
    }
    
    private func bind() {
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
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
                    
                    nextButton.isEnabled = true
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
                    
                    mainLabel.text = "닉네임을 입력해주세요."

                case .job:
                    jobView.isHidden = false
                    heightView.isHidden = true
                    birthDayView.isHidden = true
                    
                    numberLabel.text = "(2/5)"
                    
                    nextButton.setTitle("다음", for: .normal)
                    
                    mainLabel.text = "직업을 입력해주세요."
                    
                case .birthDay:
                    jobView.isHidden = false
                    birthDayView.isHidden = false
                    heightView.isHidden = true

                    
                    numberLabel.text = "(3/5)"
                    
                    
                    mainLabel.text = "생년월일을 입력해주세요."
                    
                case .height:
                    
                    jobView.isHidden = false
                    heightView.isHidden = false
                    birthDayView.isHidden = false
                    
                    numberLabel.text = "(4/5)"
                                        
                    mainLabel.text = "키를 입력해주세요."
                    
                case .simpleAddress:
                    bottomView.isHidden = true
                    finalView.isHidden = false
                    
                    numberLabel.text = "(5/5)"
                    
                    mainLabel.text = "지역을 선택해주세요."
                    
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
                    
                    nextButton.isEnabled = true
                    
                case .birthDay:
                    status = .height
                    statusRelay.accept(.height)
                    birthDayTextField.resignFirstResponder()
                    heightTextField.becomeFirstResponder()
                    
                    nextButton.isEnabled = false
                    
                case .height:
                    status = .simpleAddress
                    statusRelay.accept(.simpleAddress)
                    heightTextField.resignFirstResponder()
                    regionCollectionView.isHidden = false

                case .simpleAddress:
                    break
                    
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        regionCollectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] index in
                if let idx = viewModel.selectedIndex {
                    let cell = regionCollectionView.cellForItem(at: [0, idx]) as! RegionCell
                    cell.unselected()
                }
                
                let cell = regionCollectionView.cellForItem(at: index) as! RegionCell
                cell.selected()
                
                viewModel.selectedIndex = index.row
            })
            .disposed(by: rx.disposeBag)
        
        finalButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                if viewModel.selectedIndex != nil {
                    viewModel.saveInfo()
                    viewModel.pushGolfInfoVC()
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.pushGolfInfoVC = { [unowned self] in
            let vc = storyboard?.instantiateViewController(withIdentifier: "golfinfoVC") as! GolfInfoViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    enum Status {
        case nickName
        case job
        case birthDay
        case height
        case simpleAddress
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
        unselected()
    }
    
    func selected() {
        containerView.backgroundColor = .main
        mainLabel.textColor = .white
    }
    
    func unselected() {
        mainLabel.textColor = UIColor(red: 48, green: 48, blue: 48)
        containerView.backgroundColor = .fieldByGray
    }
}
