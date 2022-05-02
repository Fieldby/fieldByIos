//
//  CheckNumberViewController.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/02.
//

import UIKit

class CheckNumberViewController: UIViewController {

    @IBOutlet weak var fingerView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    private var originBeforeAnimation: CGRect = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        originBeforeAnimation = contentView.frame
    }
    
    private func makeUI() {
        fingerView.layer.cornerRadius = 2.5
    }
    
    private func bind() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture))
        contentView.addGestureRecognizer(gesture)
        gesture.delegate = self
    }

    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: view)
        
        if shouldDismissWithGesture(recognizer) {
            dismissViewController()
        } else {
            if point.y <= originBeforeAnimation.origin.y {
                recognizer.isEnabled = false
                recognizer.isEnabled = true
                return
            }
            contentView.frame = CGRect(x: 0, y: point.y, width: view.frame.width, height: view.frame.height)
        }
    }
    
    func dismissViewController() {
//            contentViewBottomConstraint.constant = -childViewController.view.frame.height
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.view.backgroundColor = .clear
            }, completion: { _ in
                self.dismiss(animated: false, completion: nil)
            })
        }
    
    private func shouldDismissWithGesture(_ recognizer: UIPanGestureRecognizer) -> Bool {
        return recognizer.state == .ended
    }
}

extension CheckNumberViewController: UIGestureRecognizerDelegate {
    
}
