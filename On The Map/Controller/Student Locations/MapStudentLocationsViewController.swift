//
//  MapStudentLocationsViewController.swift
//  On The Map
//
//  Created by Isaac Iniongun on 06/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import UIKit
import MapKit

class MapStudentLocationsViewController: BaseViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
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
            showStudentLocationsOnMap()
        }
    }
    
    fileprivate func setupMap() {
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(StudentLocationAnnotation.self))
    }
    
    fileprivate func getUserData() {
        showLoading(loadingMessage: "Getting user data...")
        ApiClient.getUserData(completionHandler: handleUserDataResponse(success:error:))
    }

    fileprivate func getStudentLocations() {
        showLoading(loadingMessage: "Getting student locations...")
        ApiClient.getStudentLocations(completionHandler: handleStudentLocationsResponse(studentLocations:error:))
    }
    
    fileprivate func handleStudentLocationsResponse(studentLocations: [StudentLocation], error: Error?) {
        hideLoading()
        if !studentLocations.isEmpty {
            StudentLocationModel.studentLocations = studentLocations
            showStudentLocationsOnMap()
        } else {
            showAlert(with: error?.localizedDescription ?? "Unable to get student locations, please try again.", alertType: .failure, dismissAction: {})
        }
    }
    
    fileprivate func handleUserDataResponse(success: Bool, error: Error?) {
        hideLoading()
        if success {
            getStudentLocations()
        } else {
            showAlert(with: error?.localizedDescription ?? "Unable to get student data, please try again.", alertType: .failure, dismissAction: {})
        }
    }
    
    fileprivate func showStudentLocationsOnMap() {
        
        var studentLocationAnnotation: StudentLocationAnnotation?
        
        for student in StudentLocationModel.studentLocations {
            let coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            let annotation = StudentLocationAnnotation(coordinate: coordinate, title: student.fullName, subtitle: student.mediaURL)
            mapView.addAnnotation(annotation)
            
            if student.uniqueKey == ApiClient.Auth.uniqueKey {
                studentLocationAnnotation = annotation
            }
            
        }
        
        if let studentLocationAnnotation = studentLocationAnnotation {
            mapView.setRegion(studentLocationAnnotation.region, animated: true)
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
        performSegue(withIdentifier: "addStudentLocationMap", sender: self)
    }
    
    fileprivate func hideTabBar(_ shouldShow: Bool) {
        tabBarController?.tabBar.isHidden = shouldShow
    }
    
}

//MARK: - MKMapViewDelegate Methods

extension MapStudentLocationsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKMarkerAnnotationView?
        
        if let annotation = annotation as? StudentLocationAnnotation {
            let reuseIdentifier = NSStringFromClass(StudentLocationAnnotation.self)
            annotationView = (mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation) as! MKMarkerAnnotationView)
            
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let url = URL(string: (view.annotation?.subtitle ?? "") ?? ""), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            showInvalidURLAlert()
        }
    }
    
    fileprivate func showInvalidURLAlert() {
        showAlert(with: "Student location does not contain a valid URL that can be opened.", alertType: .failure, dismissAction: {})
    }
}
