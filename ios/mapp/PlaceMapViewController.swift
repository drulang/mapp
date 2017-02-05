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
    
    fileprivate let mapView          = MKMapView(forAutoLayout: ())
    fileprivate let searchTextField  = UITextField(forAutoLayout: ())
    fileprivate var constraintsAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.backgroundColor = UIColor.white
        searchTextField.font = UIFont.systemFont(ofSize: 25)

        view.addSubview(mapView)
        view.addSubview(searchTextField)
        
        view.setNeedsUpdateConstraints()

    }

    override func updateViewConstraints() {
        if !constraintsAdded {
            constraintsAdded = true
            
            mapView.autoPinEdgesToSuperviewEdges()
            
            let insets = UIEdgeInsets(top: 35, left: 15, bottom: 15, right: 15)
            searchTextField.autoPinEdgesToSuperviewEdges(with: insets, excludingEdge: ALEdge.bottom)
        }
        super.updateViewConstraints()
    }
}

