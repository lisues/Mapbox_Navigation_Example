//
//  ViewController.swift
//  myMyboxRoutes
//
//  Created by Lisue J She on 11/12/17.
//  Copyright © 2017 Robert Alavi. All rights reserved.
//

import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class ViewController: UIViewController, MGLMapViewDelegate {
    var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = NavigationMapView(frame: view.bounds, styleURL: MGLStyle.streetsStyleURL())
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setCenter(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), zoomLevel: 11, animated: false)
        
        let annotation = MyMapboxUtility.sharedInstance.getAnnotation(latitude: 37.7749, longitude: -122.4194)
        mapView.addAnnotation(annotation)
        
        view.addSubview(mapView)
    
    //    navigationMapboxExample()
    }
    
    @IBAction func mapBoxDemo(_ sender: Any) {
        navigationMapboxExample()
    }
    
    @IBAction func goMore(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "DemoMyNavigationViewController") as! DemoMyNavigationViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    func navigationMapboxExample() {
        let origin = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 37.828125, longitude: -122.422844), name: "Alcatraz Island, San Francisco")
        let destination = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 37.7631, longitude: -122.4575), name: "University Ca of San Francisco")
        
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        
        _ = Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first else { return }
            let viewController = NavigationViewController(for: route)
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4000, pitch: 0, heading: 0)
        mapView.fly(to: camera, completionHandler: nil)
    }
}

