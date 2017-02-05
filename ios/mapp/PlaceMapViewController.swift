//
//  PlaceMapViewController.swift
//  mapp
//
//  Created by Dru Lang on 2/4/17.
//  Copyright © 2017 Dru Lang. All rights reserved.
//

import UIKit
import MapKit
import PureLayout


class PlaceMapViewController : UIViewController {
    
    fileprivate let mapView           = MKMapView(forAutoLayout: ())
    fileprivate let searchTextField   = UITextField(forAutoLayout: ())
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    fileprivate var constraintsAdded  = false
    fileprivate var places:[Place]    = [] {
        didSet {  refreshInterface() }
    }
    fileprivate var currentLocation:LocationCoordinate2D {
        get {  return mapView.centerCoordinate }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchTextField()
        
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        mapView.delegate = self
        
        view.addSubview(mapView)
        view.addSubview(searchTextField)
        view.addSubview(activityIndicator)
        
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if !constraintsAdded {
            constraintsAdded = true
            
            //Map view
            mapView.autoPinEdgesToSuperviewEdges()
            
            // Activity Indicator
            activityIndicator.autoCenterInSuperview()
            
            // Search textfield
            let insets = UIEdgeInsets(top: 35, left: 15, bottom: 15, right: 15)
            searchTextField.autoPinEdgesToSuperviewEdges(with: insets, excludingEdge: ALEdge.bottom)
            searchTextField.autoSetDimension(ALDimension.height, toSize: 50)
        }
        super.updateViewConstraints()
    }
}


//MARK: Target/Action
extension PlaceMapViewController {
    func refreshButtonTapped() {
        executePlaceSearch(withBuilder: buildLocationQuery)
    }
}

//MARK: Helpers
extension PlaceMapViewController {
    
    fileprivate func setupSearchTextField() {
        searchTextField.backgroundColor = UIColor.white
        searchTextField.font = UIFont.systemFont(ofSize: 25)
        searchTextField.delegate = self
        searchTextField.returnKeyType = UIReturnKeyType.search
        searchTextField.layer.cornerRadius = 3
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
        searchTextField.layer.borderWidth = 1
        searchTextField.placeholder = "Search for something!"
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(#imageLiteral(resourceName: "IconRefresh"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(refreshButtonTapped), for: UIControlEvents.touchUpInside)

        searchTextField.rightView = button
        searchTextField.rightViewMode = UITextFieldViewMode.always

    }
    
    fileprivate func refreshInterface() {
        refreshMapAnnotation()
    }
    
    fileprivate func refreshMapAnnotation() {
        mapView.removeAnnotations(places)
        mapView.addAnnotations(places)
        mapView.showAnnotations(places, animated: true)
    }
    
    fileprivate func buildLocationQuery() -> LocationQuery? {
        guard let text = searchTextField.text else {
            log.warning("Attempting to build query with an empty search textfield")
            return nil
        }

        return LocationQuery(coordinate: currentLocation, query: text, radius: 20, zoom: 10, count: 10)
    }

    fileprivate func executePlaceSearch(withBuilder queryBuilder:()->LocationQuery? ) {
        activityIndicator.startAnimating()

        guard let query = queryBuilder() else {
            log.warning("Query builder did not return a valid query.  Will cancel execution")
            return
        }
        
        defer {
            log.debug("Query execution failed")
            activityIndicator.stopAnimating()
        }
        
        log.debug("Starting to execute place search")
        CommandCenter.shared.placeSearch(query: query) { (places:[Place]?, error:LocationSearchError?) in
            guard error == nil else {
                log.error("Error performing search: \(error)")
                return
            }
            
            guard let places = places else {
                log.error("Performed query but places is nil")
                return
            }

            self.places = places
        }
    }
}


//MARK: Animation
extension PlaceMapViewController {
    
    func presentSearchTextField() {
        
    }
    
}

//MARK: TextFieldDelegate
extension PlaceMapViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        executePlaceSearch(withBuilder: buildLocationQuery)

        return true
    }
    
}

//MARK: MapView Delegate
extension PlaceMapViewController : MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        
        if let annotation = annotation as? Place {
            let label = UILabel()
            label.text = annotation.category.name
            view.canShowCallout = true
            view.detailCalloutAccessoryView = label
            
        }
        view.image = #imageLiteral(resourceName: "IconPlaceMark")

        return view
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        log.debug("Map view finished loading")
        
        presentSearchTextField()
    }
}

