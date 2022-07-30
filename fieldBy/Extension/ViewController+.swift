//
//  ViewController+.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/11.
//

import Foundation
import UIKit

extension UIViewController {
    func presentAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openUrl(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    func presentErrorAlert(message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            self.openUrl(url: "https://fieldby.notion.site/3c12b2262bb444c0a73895bf4eaa4ef2")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentCustomAlert(content: String, afterDismiss: @escaping (() -> Void)) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupVC") as? PopupViewController else { return }
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.content = content
        vc.afterDismiss = afterDismiss
        present(vc, animated: true)
    }
    
    func presentCustomOptionAlert(content: String, afterDismiss: @escaping (() -> Void)) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "optionpopupVC") as? OptionPopupViewController else { return }
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.content = content
        vc.afterDismiss = afterDismiss
        present(vc, animated: true)
    }
}
