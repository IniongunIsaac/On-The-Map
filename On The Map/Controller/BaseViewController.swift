//
//  BaseViewController.swift
//  On The Map
//
//  Created by Isaac Iniongun on 05/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import UIKit
import Alertift
import ProgressHUD

enum AlertType {
    case success
    case failure
}

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showLoading() {
        ProgressHUD.colorSpinner(appColor)
        ProgressHUD.colorStatus(appColor)
        ProgressHUD.show("Proccessing Request...")
    }
    
    func hideLoading() {
        ProgressHUD.dismiss()
    }
    
    func showAlert(with message: String, alertType: AlertType, dismissAction: @escaping () -> Void) {
        
        let alertImage: UIImage? = alertType == .success ? UIImage(named: "success") : UIImage(named: "error")

        Alertift.alert(message: message)
            .image(alertImage, imageTopMargin: .belowRoundCorner)
            .action(.cancel("Dismiss"))
            .finally({ action, index, textfield  in
                dismissAction()
            })
            .show(on: self)
    }

}
