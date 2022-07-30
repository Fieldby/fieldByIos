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
    
    private var isFetching = false
    private var isLastPage = false
    private let mediaSubject = BehaviorRelay<[IGMediaModel]>(value: [])
    private var indices = [Int]()
    
    var campaignModel: CampaignModel!
    static let storyId = "medialistVC"
    
    var indexes: [Int] = []
    
    override func viewWillAppear(_ animated: Bool) {
        if let tabBar = self.tabBarController as? MainTabBarController {
            tabBar.hide()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let tabBar = self.tabBarController as? MainTabBarController {
            tabBar.show()
        }
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
        
        InstagramManager.shared.getMediaList()
            .subscribe { [unowned self] mediaArrayModel in
                mediaSubject.accept(mediaArrayModel.data)
            } onError: { _ in
                
            }
            .disposed(by: rx.disposeBag)

        
        mediaSubject
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCell.reuseId, cellType: FeedCell.self)) { [unowned self] idx, mediaModel, cell in
                var num: Int? = nil
                if indices.contains(idx) {
                    num = indices.firstIndex(of: idx)! + 1
                }
                
                cell.bind(model: mediaModel, num)
            }
            .disposed(by: rx.disposeBag)

        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] index in
                guard let cell = collectionView.cellForItem(at: index) as? FeedCell else { return }
                
                if !indices.contains(index.row) {
                    if indices.count < campaignModel.leastFeed {
                        indices.append(index.row)
                        cell.select(idx: indices.count)
                    }
                } else {
                    let idx = indices.firstIndex(of: index.row)!
                    indices.remove(at: idx)
                    cell.deSelect()
                    
                    var newIndex = 1
                    for index in indices {
                        guard let selectedCell = collectionView.cellForItem(at: [0, index]) as? FeedCell else { return }
                        selectedCell.select(idx: newIndex)
                        newIndex += 1
                    }
                }
                doneButton.setTitle("선택 완료(\(indices.count)/\(campaignModel.leastFeed))", for: .normal)
            })
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.didScroll
            .subscribe(onNext: { [unowned self] in
                let height = collectionView.frame.size.height
                let contentYoffset = collectionView.contentOffset.y
                let distanceFromBottom = collectionView.contentSize.height - contentYoffset
                if distanceFromBottom < height {
                    fetchNextPage()
                }
            })
            .disposed(by: rx.disposeBag)
        
        doneButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                                
                if indices.count < campaignModel.leastFeed {
                    presentCustomAlert(content: "\(campaignModel.leastFeed)장을 선택해주세요.", afterDismiss: {})
                } else if indices.count == campaignModel.leastFeed {
                    var temp = [String]()
                    for index in indices {
                        let mediaModel = mediaSubject.value[index]
                        temp.append(mediaModel.id)
                    }
                    CampaignManager.shared.saveUploadIds(campaignUuid: campaignModel.uuid, ids: temp)
                        .subscribe { [unowned self] in
                            presentCustomAlert(content: "캠페인을 위한 \(campaignModel.leastFeed)개의 피드를 등록하였습니다.") {
                                self.navigationController?.popViewController(animated: true)
                            }
                        } onError: { err in
                            print(err)
                        }
                        .disposed(by: rx.disposeBag)


                }
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    private func fetchNextPage() {
        if !isFetching && !isLastPage {
            isFetching = true
            InstagramManager.shared.getNextPage()
                .subscribe { [unowned self] mediaArrayModel in
                    if let mediaArrayModel = mediaArrayModel {
                        mediaSubject.accept(mediaSubject.value + mediaArrayModel.data)
                    }
                    isFetching = false
                } onError: { [unowned self] err in
                    print(err)
                    isFetching = false
                    isLastPage = true
                }
                .disposed(by: rx.disposeBag)
        }
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
