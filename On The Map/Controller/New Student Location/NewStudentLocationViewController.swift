//
//  NewStudentLocationViewController.swift
//  On The Map
//
//  Created by Isaac Iniongun on 06/02/2020.
//  Copyright © 2020 Isaac Iniongun. All rights reserved.
//

import UIKit
import MapKit

enum ViewType {
    case locationText, locationOnMap
}

class NewStudentLocationViewController: BaseViewController {

    @IBOutlet weak var locationTextParentView: UIView!
    @IBOutlet weak var locationTextView: TextViewWithBorderAttributes!
    @IBOutlet weak var mapParentView: UIView!
    @IBOutlet weak var linkTextView: TextViewWithBorderAttributes!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationCoordinates: CLLocationCoordinate2D?
    var mapString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleViewVisibility(viewType: .locationText)
    }
    
    fileprivate func toggleViewVisibility(viewType: ViewType) {
        switch viewType {
        case .locationText:
            locationTextParentView.alpha = 1
            mapParentView.alpha = 0
        case .locationOnMap:
            mapParentView.alpha = 1
            locationTextParentView.alpha = 0
        }
    }

    @IBAction func findOnTheMapButtonTapped(_ sender: Any) {
        if locationTextView.text.isEmpty {
            showAlert(with: "Please enter a location.", alertType: .failure) {}
        } else {
            getLocationCoordinatesFromLocationText()
        }
    }
    
    fileprivate func getLocationCoordinatesFromLocationText() {
        
        showLoading(loadingMessage: "Finding location, please wait...")
        
        CLGeocoder().geocodeAddressString(locationTextView.text) { (placemarks, error) in
            
            self.hideLoading()
            
            if let location = placemarks?.first?.location {
                self.locationCoordinates = location.coordinate
                self.mapString = self.locationTextView.text
                self.toggleViewVisibility(viewType: .locationOnMap)
                self.setupMap()
            } else {
                self.showAlert(with: "Could not find location from address, please try again.", alertType: .failure) {}
            }
        }
    }
    
    fileprivate func setupMap() {
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(StudentLocationAnnotation.self))
        let annotation = StudentLocationAnnotation(coordinate: locationCoordinates!, title: ApiClient.Auth.user!.fullName, subtitle: mapString)
        mapView.addAnnotation(annotation)
        mapView.setRegion(annotation.region, animated: true)
    }
    
    @IBAction func submitLocationButtonTapped(_ sender: Any) {
        
        if linkTextView.text.isEmpty {
            showAlert(with: "Please enter a link to share.", alertType: .failure) {}
        } else {
            showLoading(loadingMessage: "Adding new student location, please wait...")
            
            ApiClient.postStudentLocation(mapString: mapString, mediaURL: linkTextView.text!, latitude: locationCoordinates!.latitude, longitude: locationCoordinates!.longitude, completionHandler: handleNewStudentLocationAdditionResponse(success:error:))
        }
    }
    
    fileprivate func handleNewStudentLocationAdditionResponse(success: Bool, error: Error?){
        
        hideLoading()
        
        if success {
            showAlert(with: "New student location added successfully.", alertType: .success) {
                self.showStudentLocationsViewController()
            }
        } else {
            showAlert(with: error?.localizedDescription ?? "Student location could not be added, please try again.", alertType: .failure) {}
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        showStudentLocationsViewController()
    }
    
    fileprivate func showStudentLocationsViewController() {
        ApiClient.Auth.shouldRefreshData = true
        navigationController?.popViewController(animated: true)
    }
    
}


//MARK: - MKMapViewDelegate Methods

extension NewStudentLocationViewController: MKMapViewDelegate {
    
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
    
}
