//
//  MediaListViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/23.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class MediaListViewController: UIViewController {
    
    @IBOutlet var viewModel: MediaListViewModel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    private var imageSubject = BehaviorSubject<[ImageData]>(value: [])
    private var imageArray: [ImageData] = []
    
    var campaignModel: CampaignModel!
    static let storyId = "medialistVC"
    
    var indexes: [Int] = []
    
    override func viewWillAppear(_ animated: Bool) {
        let tabVC = tabBarController as! MainTabBarController
        tabVC.bottomView.isHidden = true
        tabVC.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let tabVC = tabBarController as! MainTabBarController
        tabVC.bottomView.isHidden = false
        tabVC.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.layer.cornerRadius = 13
        
        doneButton.setTitle("선택 완료(0/\(campaignModel.leastFeed))", for: .normal)
        bind()
        
    }
    
    private func bind() {

                
        collectionView.rx.setDelegate(self)
            .disposed(by: rx.disposeBag)
        
        InstagramManager.shared.fetchImages { [unowned self] imageArray in
            
            imageSubject.onNext(imageArray.filter { $0.mediaType != .video})
            self.imageArray = imageArray.filter { $0.mediaType != .video}

        }
        
        imageSubject
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCell.reuseId, cellType: FeedCell.self)) { [unowned self] idx, image, cell in
                
                cell.mainImageView.setImage(url: image.mediaURL)
            }
            .disposed(by: rx.disposeBag)
        
        
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] index in
                let cell = collectionView.cellForItem(at: index) as! FeedCell
                
                if cell.isOn {
                    let idx = indexes.firstIndex(of: index.row)!
                    indexes.remove(at: idx)
                    
                    cell.deSelect()
                    doneButton.setTitle("선택 완료(\(indexes.count)/\(campaignModel.leastFeed))", for: .normal)
                } else {
                    if indexes.count < campaignModel.leastFeed {
                        indexes.append(index.row)
                        doneButton.setTitle("선택 완료(\(indexes.count)/\(campaignModel.leastFeed))", for: .normal)
                        cell.select(idx: indexes.count)
                    }
                }
                
                for i in 0..<indexes.count {
                    let cell = collectionView.cellForItem(at: [0, indexes[i]]) as! FeedCell
                    cell.select(idx: i+1)
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        doneButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                
                var count = Array(repeating: false, count: indexes.count)
                
                for i in 0..<indexes.count {
                    
                    let id = imageArray[indexes[i]].id
                    
                    InstagramManager.shared.fetchChildImages(id: id) { [unowned self] imageArray in
                        
                        let uuid = campaignModel.uuid
                        
                        CampaignManager.shared.saveUploadIds(campaignUuid: uuid, images: imageArray.sorted(by: {$0.timestamp > $1.timestamp}), index: i)
                            .subscribe { [unowned self] in
                                print("이미지 업로드 성공")
 
                                count[i] = true
                                if count == Array(repeating: true, count: indexes.count) {
                                    navigationController?.popViewController(animated: true)
                                }
                                
                            } onError: { [unowned self] err in

                                print(err)
                            }
                            .disposed(by: rx.disposeBag)
                        
                    }
                }
                
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension MediaListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let len = (collectionView.frame.width-38)/3
        
        return CGSize(width: len, height: len)
    }
}
