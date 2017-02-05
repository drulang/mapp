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

fileprivate struct Config {
    struct Layout {
        static let StatusLabelHeight = CGFloat(30)
    }
}


class PlaceMapViewController : UIViewController {
    
    fileprivate let mapView           = MKMapView(forAutoLayout: ())
    fileprivate let searchTextField   = UITextField(forAutoLayout: ())
    fileprivate let statusLabel       = UILabel(forAutoLayout: ())
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    fileprivate var constraintsAdded  = false
    fileprivate var searchTextFieldTopConstraint:NSLayoutConstraint?
    fileprivate var statusLabelTopConstraint:NSLayoutConstraint?
    fileprivate var places:[Place]    = [] {
        didSet {  refreshInterface() }
    }
    fileprivate var currentLocation:LocationCoordinate2D {
        get {  return mapView.centerCoordinate }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchTextField()
        
        statusLabel.font = UIFont.systemFont(ofSize: 15)
        statusLabel.backgroundColor = UIColor.white
        statusLabel.textAlignment = NSTextAlignment.center
        statusLabel.text = "No results 😯"
        statusLabel.layer.cornerRadius = 3
        statusLabel.layer.borderColor = UIColor.lightGray.cgColor
        statusLabel.layer.borderWidth = 1
        statusLabel.layer.masksToBounds = true
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        mapView.delegate = self
        

        view.addSubview(mapView)
        view.addSubview(statusLabel)
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
            searchTextFieldTopConstraint = searchTextField.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: -50)
            searchTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: 10)
            searchTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: 10)
            
            searchTextField.autoSetDimension(ALDimension.height, toSize: 50)
            
            // Status Label
            statusLabelTopConstraint = statusLabel.autoPinEdge(ALEdge.top, to: ALEdge.top, of: searchTextField, withOffset: 0)
            statusLabel.autoSetDimension(ALDimension.height, toSize: Config.Layout.StatusLabelHeight)
            statusLabel.autoAlignAxis(ALAxis.vertical, toSameAxisOf: self.view)
            statusLabel.autoConstrainAttribute(ALAttribute.width, to: ALAttribute.width, of: searchTextField, withMultiplier: 0.5)
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
        searchTextField.layer.borderWidth = 2
        searchTextField.placeholder = "Search for something!"
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(#imageLiteral(resourceName: "IconRefresh"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(refreshButtonTapped), for: UIControlEvents.touchUpInside)

        searchTextField.rightView = button
        searchTextField.rightViewMode = UITextFieldViewMode.always

        let padView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
        searchTextField.leftView = padView
        searchTextField.leftViewMode = UITextFieldViewMode.always
    }
    
    fileprivate func refreshInterface() {
        refreshMapAnnotation()
        
        if places.count == 0 {
            showStatusLabel()
        } else {
            hideStatusLabel()
        }
        
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
    
    func hideStatusLabel() {
        guard let constraint = statusLabelTopConstraint else {
            return
        }

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            constraint.constant = 0
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func showStatusLabel() {
        guard let constraint = statusLabelTopConstraint else {
            return
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            constraint.constant = 70
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func presentSearchTextField() {
        let topOffset = CGFloat(35)

        guard let constraint = searchTextFieldTopConstraint else {
            return
        }

        guard constraint.constant != topOffset else {
            log.warning("Search textfield is already in view")
            return
        }

        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            constraint.constant = topOffset

            self.view.layoutIfNeeded()
            
        }, completion: nil)
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

