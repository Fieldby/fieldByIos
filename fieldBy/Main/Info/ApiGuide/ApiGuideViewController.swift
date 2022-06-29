//
//  ApiGuideViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/26.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import FBSDKLoginKit
import FirebaseAuth

class ApiGuideViewController: UIViewController {
    
    static let storyId = "apiguideVC"

    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var guideLabel: UILabel!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        collectionView.decelerationRate = .fast

        Observable.just(["0", "1", "2", "3", "4", "5", "6"])
            .bind(to: collectionView.rx.items(cellIdentifier: ApiCell.reuseId, cellType: ApiCell.self)) { idx, num, cell in
                cell.mainImageView.image = UIImage(named: "api\(num)")
            }
            .disposed(by: rx.disposeBag)
        
        mediaButton.layer.cornerRadius = 13
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func getMedia(_ sender: Any) {
        indicator.isHidden = false
        indicator.startAnimating()
        
        let manager = LoginManager()
        manager.logIn(permissions: ["public_profile", "instagram_basic", "pages_show_list", "pages_read_engagement"], from: self) { result, error in
            if let error = error {
                print("Process error: \(error)")
                return
            }
            guard let result = result else {
                print("No Result")
                return
            }
            if result.isCancelled {
                print("Login Cancelled")
                return
            }
                        
            InstagramManager.shared.igLogin(viewController: self, token: result.token!.tokenString) { [unowned self] in
                indicator.isHidden = true
                indicator.stopAnimating()
                let vc = storyboard?.instantiateViewController(withIdentifier: FeedListViewController.storyId) as! FeedListViewController
                navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
}

extension ApiGuideViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let cellWidthIncludingSpacing = collectionView.frame.width
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        var roundedIndex = round(index)
        if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            roundedIndex = floor(index)
        } else {
            roundedIndex = ceil(index)
        }
        let nextX = roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left
        
        offset = CGPoint(x: nextX,
                         y: -scrollView.contentInset.top)


        targetContentOffset.pointee = offset
        
        let idx = Int(nextX / cellWidthIncludingSpacing)
        handleIndex(idx: idx)
        
    }
    
    private func handleIndex(idx: Int) {
        if idx < 2 {
            guideLabel.text = "1. 인스타그램 앱의 설정 > 계정에서 프로페셔널 계정으로 전환해주세요."
        } else if idx < 5 {
            guideLabel.text = "2. 페이스북 로그인 > 페이지를 생성하여 인스타그램 계정과 연결해주세요."
        } else {
            guideLabel.text = "3. 인스타그램과 연결된 페이스북 페이지에서 필드바이 권한을 허용해주면 완료!"
        }
    }
}

class ApiCell: UICollectionViewCell {
    static let reuseId = "apiCell"
    @IBOutlet weak var mainImageView: UIImageView!
    
}
