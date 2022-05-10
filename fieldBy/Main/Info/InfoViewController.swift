//
//  InfoViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/04.
//

import UIKit
import FBSDKLoginKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Kingfisher

class InfoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    let testSubject = BehaviorSubject<[Datum]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add a custom login button to your app
        let loginButton = UIButton(type: .custom)
        loginButton.backgroundColor = .darkGray
        loginButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
        loginButton.center = view.center
        loginButton.setTitle("My Login Button", for: .normal)

        // Handle clicks on the button
        loginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)

        view.addSubview(loginButton)
        
        
        
        testSubject
            .bind(to: collectionView.rx.items(cellIdentifier: testCell.id, cellType: testCell.self)) { idx, data, cell in
                let url = URL(string: data.mediaURL)

                cell.imageView.kf.setImage(with: url)
            }
            .disposed(by: rx.disposeBag)
        
        
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    // Once the button is clicked, show the login dialog
    @objc func loginButtonClicked() {
                
        InstagramManager.test2()
            .subscribe { data in
                self.testSubject.onNext(data.data)
            } onError: { err in
                print(err)
            }
            .disposed(by: rx.disposeBag)

            
    }
    
}

extension InfoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

class testCell: UICollectionViewCell {
    static let id = "testCell"
    @IBOutlet weak var imageView: UIImageView!
    
}
