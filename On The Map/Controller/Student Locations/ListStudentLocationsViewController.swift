//
//  ListStudentLocationsViewController.swift
//  On The Map
//
//  Created by Isaac Iniongun on 06/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import UIKit

class ListStudentLocationsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideTabBar(false)
        
        if ApiClient.Auth.user == nil && StudentLocationModel.studentLocations.isEmpty {
            getUserData()
        } else if ApiClient.Auth.shouldRefreshData {
            getStudentLocations()
            ApiClient.Auth.shouldRefreshData = false
        } else {
            tableView.reloadData()
        }
    }
    
    fileprivate func getUserData() {
        showLoading(loadingMessage: "Getting user data...")
        ApiClient.getUserData(completionHandler: handleUserDataResponse(success:error:))
    }
    
    fileprivate func handleUserDataResponse(success: Bool, error: Error?) {
        hideLoading()
        if success {
            getStudentLocations()
        } else {
            showAlert(with: error?.localizedDescription ?? "Unable to get student data, please try again.", alertType: .failure, dismissAction: {})
        }
    }
    
    fileprivate func getStudentLocations() {
        showLoading(loadingMessage: "Getting student locations...")
        ApiClient.getStudentLocations(completionHandler: handleStudentLocationsResponse(studentLocations:error:))
    }
    
    fileprivate func handleStudentLocationsResponse(studentLocations: [StudentLocation], error: Error?) {
        hideLoading()
        if !studentLocations.isEmpty {
            StudentLocationModel.studentLocations = studentLocations
            tableView.reloadData()
        } else {
            showAlert(with: error?.localizedDescription ?? "Unable to get student locations, please try again.", alertType: .failure, dismissAction: {})
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        showLoading(loadingMessage: "Logging off...")
        ApiClient.logout(completion: handleLogoutSessionResponse(success:error:))
    }
    
    fileprivate func handleLogoutSessionResponse(success: Bool, error: Error?){
        hideLoading()
        if success {
            dismiss(animated: true, completion: nil)
        } else {
            showAlert(with: error?.localizedDescription ?? "Unable to log off, please try again.", alertType: .failure) { }
        }
    }
    
    @IBAction func refreshLocationsButtonTapped(_ sender: UIBarButtonItem) {
        getStudentLocations()
    }
    
    @IBAction func addStudentLocationButtonTapped(_ sender: UIBarButtonItem) {
        if StudentLocationModel.studentLocations.first(where: { $0.uniqueKey == ApiClient.Auth.uniqueKey }) != nil {
            showAlert(with: "You already added a location, do you wish to overwrite it?", alertType: .success, yesActionText: "Overwrite", yesAction: {
                self.showNewStudentLocationViewController()
            }) {}
        } else {
            showNewStudentLocationViewController()
        }
    }
    
    fileprivate func showNewStudentLocationViewController() {
        hideTabBar(true)
        performSegue(withIdentifier: "addStudentLocationList", sender: self)
    }
    
    fileprivate func hideTabBar(_ shouldShow: Bool) {
        tabBarController?.tabBar.isHidden = shouldShow
    }
    
    //MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocationModel.studentLocations.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentLocationTableViewCell", for: indexPath)
        
        let studentLocation = StudentLocationModel.studentLocations[indexPath.row]
        
        cell.textLabel?.text = studentLocation.fullName
        cell.detailTextLabel?.text = studentLocation.mapString
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let url = URL(string: StudentLocationModel.studentLocations[indexPath.row].mediaURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            showInvalidURLAlert()
        }
        
    }
    
    fileprivate func showInvalidURLAlert() {
        showAlert(with: "Student location does not contain a valid URL that can be opened.", alertType: .failure, dismissAction: {})
    }
    
}
