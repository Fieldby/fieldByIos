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
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var normalView: UIView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var campaignCounts: UILabel!
    @IBOutlet weak var totalRewardsLabel: UILabel!
    
    @IBOutlet weak var noMediaView: UIView!
    
    @IBOutlet weak var mediaButton: UIButton!
    
    @IBOutlet weak var newImageView: UIImageView!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        makeUI()
        bind()

    }
    
    private func makeUI() {
        topView.layer.cornerRadius = 27
        topView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        topView.addGrayShadow(color: .lightGray, opacity: 0.3, radius: 3)
        
        profileImageView.layer.cornerRadius = 35
        
        mediaButton.layer.cornerRadius = 13
        
        noMediaView.isHidden = true
        normalView.isHidden = true
        
        newImageView.isHidden = true
    }
    
    private func bind() {
        
        AuthManager.shared.igValidSubject
            .subscribe(onNext: { [unowned self] bool in
                if bool {
                    normalView.isHidden = false
                    noMediaView.isHidden = true
                    
                    bindIGInfo()
                    
                } else {
                    normalView.isHidden = true
                    noMediaView.isHidden = false
                    
                }
            })
            .disposed(by: rx.disposeBag)
        

        
        NotiManager.shared.notiArray
            .subscribe(onNext: { [unowned self] notiArray in
                if !notiArray.isEmpty && notiArray.first!.checked == false {
                    newImageView.isHidden = false
                } else {
                    newImageView.isHidden = true
                }
            })
            .disposed(by: rx.disposeBag)
        
        totalRewardsLabel.text = "\(AuthManager.shared.myUserModel.reward)원"
        
    }
    
    private func bindIGInfo() {
        if let igModel = AuthManager.shared.myUserModel.igModel {
            if let url = igModel.profileUrl {
                
                let url = try! URL(string: url)
                profileImageView.kf.setImage(with: url)
            }
            
            usernameLabel.text = "@\(igModel.username)"
            followersCountLabel.text = "팔로워 \(igModel.followers)"
            
            campaignCounts.text = "\(AuthManager.shared.myUserModel.campaigns.count)"
            
            if let urlStr = igModel.profileUrl {
                let url = (try! URL(string: urlStr))!
                let data = try! Data(contentsOf: url)
                let image = UIImage(data: data)!.resizeImageTo(size: CGSize(width: 25, height: 25))!.roundedImage.withRenderingMode(.alwaysOriginal)

                
                tabBarController!.tabBar.items![2].image = image
                tabBarController!.tabBar.items![2].selectedImage = image
            }
            
            
        }
    }
    
    @IBAction func editProfile(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: EditProfileViewController.storyId) as! EditProfileViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func kakaoChannel(_ sender: Any) {
        openUrl(url: "http://pf.kakao.com/_xdxeQzb")
    }
    
    
    private func apiGuide() {
        let vc = UIStoryboard(name: "ApiGuide", bundle: nil).instantiateViewController(withIdentifier: ApiGuideViewController.storyId) as! ApiGuideViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @IBAction func pushNoti(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Noti", bundle: nil).instantiateViewController(withIdentifier: "notiVC") as! NotiViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func qna(_ sender: Any) {
        openUrl(url: "https://fieldby.notion.site/FAQ-f57a2a1fab7d46dabc48d5fa69d77932")
    }
    
    @IBAction func opennotion(_ sender: Any) {
        openUrl(url: "https://fieldby.notion.site/b8e080bdb4704c74883b486e4c0610db")
    }
    
    @IBAction func test(_ sender: Any) {
        apiGuide()
    }
    
    @IBAction func alert(_ sender: Any) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func uploadBestImages(_ sender: Any) {
        let vc = UIStoryboard(name: "ApiGuide", bundle: nil).instantiateViewController(withIdentifier: FeedListViewController.storyId) as! FeedListViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
