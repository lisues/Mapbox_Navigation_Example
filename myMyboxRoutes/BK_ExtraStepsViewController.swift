//
//  ExtraStepsViewController.swift
//  myMyboxRoutes
//
//  Created by Robert Alavi on 11/12/17.
//  Copyright © 2017 Robert Alavi. All rights reserved.
//

import Mapbox
import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation
import UIKit

class ExtraStepsViewController: UIViewController, MGLMapViewDelegate {
    
    var mapView: MGLMapView!
    var directionsRoute: Route?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = NavigationMapView(frame: view.bounds, styleURL: MGLStyle.streetsStyleURL())
        mapView.setCenter(CLLocationCoordinate2D(latitude: 30.265, longitude: -97.741), zoomLevel: 11, animated: false)
        view.addSubview(mapView)
        // Set the map view's delegate
        mapView.delegate = self
        // Allow the map view to display the user's location
        mapView.showsUserLocation = true
        let setDestination = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        mapView.addGestureRecognizer(setDestination)
    }
    
    // Always allow callouts to appear when annotations are tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        // Create a basic point annotation and add it to the map
        let annotation = MGLPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Start navigation"
        mapView.addAnnotation(annotation)
        
        calculateRoute(from: (mapView.userLocation!.coordinate), to: annotation.coordinate) { [unowned self] (route, error) in
            if error != nil {
                // Print an error message
                print("Error calculating route")
            }
        }
    }
    
    // Calculate route to be used for navigation
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
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            //lineStyle.lineColor = MGLStyleValue(rawValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
            lineStyle.lineWidth = MGLStyleValue(rawValue: 3)
            
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
        }
    }
    
    func presentNavigation(along route: Route) {
        class CustomStyle: DayStyle {
            
            public required init() {
                super.init()
                mapStyleURL = URL(string: "mapbox://styles/mapbox/light-v9")!
            }
            
            override func apply() {
                super.apply()
                // ManeuverView.appearance().backgroundColor = #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1)
                //  RouteTableViewHeaderView.appearance().backgroundColor = #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1)
                Button.appearance().textColor = .white
                WayNameLabel.appearance().textColor = .white
                DistanceLabel.appearance().textColor = .white
                DestinationLabel.appearance().textColor = .white
                ArrivalTimeLabel.appearance().textColor = .white
                TimeRemainingLabel.appearance().textColor = .white
                DistanceRemainingLabel.appearance().textColor = .white
                TurnArrowView.appearance().primaryColor = .white
                TurnArrowView.appearance().secondaryColor = .white
                LanesView.appearance().backgroundColor = .white
                LaneArrowView.appearance().primaryColor = .white
                CancelButton.appearance().tintColor = .white
            }
        }
        
    }
}

