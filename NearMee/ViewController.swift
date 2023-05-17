//
//  ViewController.swift
//  NearMee
//
//  Created by admin on 16/05/2023.
//

import UIKit
 import MapKit

class ViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    private var places: [PlaceAnnotation] = []
    
    lazy var mapView: MKMapView = {
       let map = MKMapView()
        map.delegate = self
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    lazy var searchTextField: UITextField = {
        let searchTextField  = UITextField()
        searchTextField.delegate = self
        searchTextField.layer.cornerRadius = 10
        searchTextField.clipsToBounds = true
        searchTextField.backgroundColor = .white
        searchTextField.placeholder = "Search"
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        searchTextField.leftViewMode = .always
        searchTextField.returnKeyType = .go
        searchTextField.translatesAutoresizingMaskIntoConstraints = false

        return searchTextField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestLocation()
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(searchTextField)
        view.addSubview(mapView)
        
        view.bringSubviewToFront(searchTextField)
        
        //add contraints to the search text field
        NSLayoutConstraint.activate([
            searchTextField.heightAnchor.constraint(equalToConstant: 44),
            searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width/1.2),
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 60)
        ])
        
        //add contraints to the mapView
        NSLayoutConstraint.activate([
            mapView.widthAnchor.constraint(equalTo: view.widthAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor),
            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager,
              let location = locationManager.location else { return }
        
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 760, longitudinalMeters: 760)
            mapView.setRegion(region, animated: true)
        case .denied:
            print("Location services has been denied")
        case .notDetermined, .restricted:
            print("Location cannot be determind or retricted")
        @unknown default:
            print("Unknown error. Unable to get location.")
        }
    }
    
    private func presentPlacesSheet(places: [PlaceAnnotation]) {
        
        guard let locationManager = locationManager,
              let userLocation = locationManager.location
        else { return }
        
        let placesTVC = PlacesTableViewController(userLocation: userLocation , places: places)
        placesTVC.modalPresentationStyle = .pageSheet
        
        if let sheet = placesTVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            present(placesTVC, animated: true)
        }
    }
    
    private func findNearByPlaces(by query: String) {
        
        //clear all annotation
        mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start {[weak self] response, error in
            guard let response = response, error == nil else { return }
            
            self?.places = response.mapItems.map { mapItem in
                PlaceAnnotation.init(mapItem: mapItem)
            }
            
            self?.places.forEach { place in
                self?.mapView.addAnnotation(place)
            }
            
            if let places = self?.places {
                self?.presentPlacesSheet(places: places)
            }
            print(response.mapItems)
        }
        
    }

}

// MARK: TextField Delegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if !text.isEmpty {
            textField.resignFirstResponder()
            findNearByPlaces(by: text)
        }
        return true
    }
}

// MARK: LocationManager Delegate
extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: MKMapView Delegate

extension ViewController: MKMapViewDelegate {
    
    private func clearAllSelections() {
        self.places = self.places.map({ place in
            place.isSelected = false
            return place
        })
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        
        // clear all selections
        clearAllSelections()
        
        guard let selectionAnnotation = annotation as? PlaceAnnotation else { return }
        let placeAnnotation = self.places.first(where: { $0.id == selectionAnnotation.id })
        placeAnnotation?.isSelected = true
        
        presentPlacesSheet(places: self.places)
    }
}
