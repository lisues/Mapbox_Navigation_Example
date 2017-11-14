//
//  DemoMyNavigationViewController.swift
//  myMyboxRoutes
//
//  Created by Lisue J She on 11/13/17.
//  Copyright © 2017 Robert Alavi. All rights reserved.
//

import Mapbox
import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation
import UIKit

class DemoMyNavigationViewController: UIViewController, MGLMapViewDelegate, UITextFieldDelegate  {

    @IBOutlet weak var destination: UITextField!
    @IBOutlet weak var mapView: UIView!
    
    var myView:MGLMapView = MGLMapView()
    var directionsRoute: Route?
    var destinationCoordinate: CLLocationCoordinate2D? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()

        myView.delegate = self
        destination.delegate = self
       
        myView = MGLMapView(frame: mapView.bounds, styleURL: MGLStyle.satelliteStreetsStyleURL())
        myView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        myView.setCenter(CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), zoomLevel: 11, animated: false)
        
        myView.showsUserLocation = true
        
        let setDestination = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        myView.addGestureRecognizer(setDestination)
        
        let annotation = MyMapboxUtility.sharedInstance.getAnnotation(latitude: 37.7749, longitude: -122.4194)
        myView.addAnnotation(annotation)
        
        mapView.addSubview(myView)
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func showRoutes(_ sender: Any) {
        var to:String="2130 Fulton St, San Francisco, CA 94117" //UCSF
        if let toTemp = destination.text {
            to = toTemp
        }
       
        var originCoordinate: CLLocationCoordinate2D? = nil
        
        getLocationGeocode( address: to ) { (success) in
            if (success) {
                var originCoordinate: CLLocationCoordinate2D? = nil
                if let origin = self.myView.userLocation {
                    originCoordinate = origin.coordinate
                    self.calculateRoute(from: originCoordinate!, to: self.destinationCoordinate!) { [unowned self] (route, error) in
                            if error != nil {
                                // Print an error message
                                print("Error calculating route")
                            }
                        }
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
   
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4000, pitch: 0, heading: 0)
        mapView.fly(to: camera, completionHandler: nil)
    }
    
    func didLongPress(_ sender: UILongPressGestureRecognizer) {
       
        guard sender.state == .began else { return }

        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: mapView)
        let coordinate = myView.convert(point, toCoordinateFrom: myView)
        
        // Create a basic point annotation and add it to the map
        let annotation = MGLPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Start navigation"
        DispatchQueue.main.async {
            self.myView.addAnnotation(annotation)
        }
    }
    
    func getLocationGeocode( address: String, completionHandlerGeoSearch: @escaping (_ success: Bool) -> Void) {
        
       // let annotation = MGLPointAnnotation()
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address) { (placemark, error) in
            
            guard let placemark = placemark?[0] else {
                completionHandlerGeoSearch(false)
                return
            }
            
            self.destinationCoordinate = CLLocationCoordinate2D(latitude:placemark.location!.coordinate.latitude,
                                       longitude: placemark.location!.coordinate.longitude)
            completionHandlerGeoSearch(true)
        }
    }
    
    func calculateRoute(from origin: CLLocationCoordinate2D,
                        to destination: CLLocationCoordinate2D,
                        completion: @escaping (Route?, Error?) -> ()) {
        
        let originWaypoint = Waypoint(coordinate: origin, name: "Start")
        
        let destinationWaypoint = Waypoint(coordinate: destination, name: "Finish")
        
        let options = NavigationRouteOptions(waypoints: [originWaypoint, destinationWaypoint], profileIdentifier: .automobileAvoidingTraffic)
        
         _ = Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first else { return }
            self.directionsRoute = route
            self.drawRoute(route: self.directionsRoute!)
        }
    }
    
    func drawRoute(route: Route) {
        guard route.coordinateCount > 0 else { return }
        // Convert the route’s coordinates into a polyline.
        var routeCoordinates = route.coordinates!
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        // If there's already a route line on the map, reset its shape to the new route
        if let source = myView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            
            myView.style?.addSource(source)
            myView.style?.addLayer(lineStyle)
            self.presentNavigation(along: route)
        }
    }
    
    func presentNavigation(along route: Route) {
        let viewController = NavigationViewController(for: route)
        self.present(viewController, animated: true, completion: nil)
    }
}

