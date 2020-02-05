//
//  ViewController.swift
//  On The Map
//
//  Created by Isaac Iniongun on 04/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var emailTextfield: TextFieldWithBorderAttributes!
    @IBOutlet weak var passwordTextfield: TextFieldWithBorderAttributes!
    @IBOutlet weak var faceBookLoginButton: FBLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (AccessToken.current != nil) {
            // navigate to next screen
        }
        
        faceBookLoginButton.permissions = ["public_profile", "email"]
        faceBookLoginButton.delegate = self
        
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        showLoading()
        Client.login(email: emailTextfield.text!, password: passwordTextfield.text!, completion: handleLoginResponse(success:error:))
    }
    
    fileprivate func handleLoginResponse(success: Bool, error: Error?) {
        hideLoading()
        if success {
            showAlert(with: "Login success", alertType: .success, dismissAction: {})
        } else {
            showAlert(with: error?.localizedDescription ?? "An error occurred logging in, please try again", alertType: .failure) {}
        }
    }
    
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let result =  result else {
            showAlert(with: "Unable to login with Facebook, please try again.", alertType: .success, dismissAction: {})
            return
            
        }
        if result.token != nil {
            //navigate to next screen
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) { }
}

