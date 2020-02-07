//
//  ViewController.swift
//  On The Map
//
//  Created by Isaac Iniongun on 04/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var emailTextfield: TextFieldWithBorderAttributes!
    @IBOutlet weak var passwordTextfield: TextFieldWithBorderAttributes!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        showLoading(loadingMessage: "Loggin in...")
        ApiClient.login(email: emailTextfield.text!, password: passwordTextfield.text!, completion: handleLoginResponse(success:error:))
    }
    
    fileprivate func handleLoginResponse(success: Bool, error: Error?) {
        hideLoading()
        if success {
            showStudentLocations()
        } else {
            showAlert(with: error?.localizedDescription ?? "An error occurred logging in, please try again", alertType: .failure) {}
        }
    }
    
    fileprivate func showStudentLocations() {
        emailTextfield.text = ""
        passwordTextfield.text = ""
        performSegue(withIdentifier: "showStudentLocations", sender: self)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
}

