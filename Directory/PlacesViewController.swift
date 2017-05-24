//
//  PlacesViewController.swift
//  Directory
//
//  Created by Kevin on 5/3/17.
//  Copyright © 2017 com.adient. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import MapKit

class PlacesViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var defaultOptions = SwipeTableOptions()
    var isSwipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .circular
    
    //MARK: fetch request init
    var fetchRequest: NSFetchRequest<ResourceCategoryEntity> = ResourceCategoryEntity.fetchRequest()
    
    public let persistentContainer = NSPersistentContainer(name: "DirectoryStore")
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<ResourceCategoryEntity> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<ResourceCategoryEntity> = ResourceCategoryEntity.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ResourceCategoryEntity.name), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "type == 'plant' || type == 'building'")
//        fetchRequest.predicate = NSPredicate(format: "type == 'plant'")
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: #keyPath(ResourceCategoryEntity.name), cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
                
            } else {
                self.setupView()
                
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                
                self.updateView()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        
    }
    
    // MARK: - View Methods
    public func setupView() {
        
        updateView()
    }
    
    fileprivate func updateView() {
        var hasPlace = false
        
        if let places = fetchedResultsController.fetchedObjects {
            hasPlace = places.count > 0
        }
        
        tableView.isHidden = !hasPlace
    }
    
    // MARK: - Notification Handling
    
    func applicationDidEnterBackground(_ notification: Notification) {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PlacesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool
    {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var predicate:NSPredicate? = nil
        if searchBar.text?.characters.count != 0 {
            predicate = NSPredicate(format: "(name contains [cd] %@)", searchBar.text!)
        }
        
        self.fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        tableView.reloadData()
    }

    
}


extension PlacesViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? PlaceTableViewCell {
                configure(cell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break;
        }
    }
}

extension PlacesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as? PlaceTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        cell.delegate = self
        // Configure Cell
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func configure(_ cell: PlaceTableViewCell, at indexPath: IndexPath) {
        // Fetch Quote
        let place = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        cell.placeLbl.text = place.name!

        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
}

extension PlacesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //select action
        searchBar.resignFirstResponder()
        let currentPlace = fetchedResultsController.object(at: indexPath)
        
        if (currentPlace.type == "plant") {
            let lat = currentPlace.plant?.plantAddress?.gpsLatitude
            let long = currentPlace.plant?.plantAddress?.gpsLongitude
            let placeStr = (currentPlace.plant?.plantAddress?.city!)! + " " + (currentPlace.plant?.plantAddress?.streetName1)!
            openMapForPlace(lat: lat!, long: long!, placeName: placeStr)
        } else {
            let alert = UIAlertController(title: "Alert", message: "No GPS information current", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //open map function
    func openMapForPlace(lat: CLLocationDegrees, long: CLLocationDegrees, placeName: String) {
        
        let myTargetCLLocation:CLLocation = CLLocation(latitude: lat, longitude: long) as CLLocation
        let coordinate = CLLocationCoordinate2DMake(myTargetCLLocation.coordinate.latitude,myTargetCLLocation.coordinate.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = placeName

        mapItem.openInMaps(launchOptions: [MKLaunchOptionsMapTypeKey : MKMapType.satellite.rawValue])
//        mapItem.openInMaps(launchOptions: nil)
        //TODU: change map item image
    }

}

extension PlacesViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let place = fetchedResultsController.object(at: indexPath)
        
        if orientation == .left {
            return[]
        } else {
            let floorPlan = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                print("floorPlan")
            }
            floorPlan.hidesWhenSelected = true
            configure(action: floorPlan, with: .floorplane)
            
            let directions = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                print("directions")
            }
            directions.hidesWhenSelected = true
            configure(action: directions, with: .directions)
            return [directions, floorPlan]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle =  .selection
        options.transitionStyle = defaultOptions.transitionStyle
        
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 4
            options.backgroundColor = UIColor.init(red: 244/255.0, green: 140/255.0, blue: 140/255.0, alpha: 1.0)
        }
        
        return options
    }
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color
            action.font = .systemFont(ofSize: 9)
            action.transitionDelegate = ScaleTransition.default
        }
    }
}








