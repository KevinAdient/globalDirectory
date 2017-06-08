//
//  PeopleViewController.swift
//  Directory
//
//  Created by Kevin on 5/3/17.
//  Copyright © 2017 com.adient. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import MapKit

class PeopleViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var defaultOptions = SwipeTableOptions()
    var isSwipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .circular
    
    //MARK: fetch request init
    var fetchRequest: NSFetchRequest<PeopleEntity> = PeopleEntity.fetchRequest()
    
    public let persistentContainer = NSPersistentContainer(name: "DirectoryStore")
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<PeopleEntity> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<PeopleEntity> = PeopleEntity.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(PeopleEntity.firstname), ascending: true)]
//        fetchRequest.predicate = NSPredicate(format: "id BEGINSWITH[cd] 'A'")
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: #keyPath(PeopleEntity.lastname), cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // init core data sources
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.createResources()

        
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
        var hasPeople = false
        
        if let people = fetchedResultsController.fetchedObjects {
            hasPeople = people.count > 0
        }
        
        tableView.isHidden = !hasPeople
    }
    
    //open map function
    func openMapForPlace(lat: CLLocationDegrees, long: CLLocationDegrees, placeName: String) {
        
        let myTargetCLLocation:CLLocation = CLLocation(latitude: lat, longitude: long) as CLLocation
        let coordinate = CLLocationCoordinate2DMake(myTargetCLLocation.coordinate.latitude,myTargetCLLocation.coordinate.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = placeName
//        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsMapTypeKey : MKMapType.satellite.rawValue])
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
        
        let mySingletonObj = statusObj.sharedInstance
        let statusBoolArray = mySingletonObj.statusBoolArray
        var myStatusArray = ["Available", "Busy", "Do not distrub", "Appear away"]
        for i in 0...3 {
            if (statusBoolArray[i]) {
                if let items = self.tabBarController?.tabBar.items {
                    
                    let tabBarItem = items[4] as! RAMAnimatedTabBarItem
                    let tabBarImage = UIImage(named: myStatusArray[i])!
                    
                    tabBarItem.image = tabBarImage.withRenderingMode(.alwaysOriginal)
                    
                    tabBarItem.selectedImage = tabBarImage
                    
                }
            }
        }
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

extension PeopleViewController: UISearchBarDelegate {
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
            predicate = NSPredicate(format: "(lastname contains [cd] %@) || (firstname contains[cd] %@)", searchBar.text!, searchBar.text!)
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

extension PeopleViewController: NSFetchedResultsControllerDelegate {
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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? PeopleTableViewCell {
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
//        case .delete:
//            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break;
        }
    }

    
    
}

extension PeopleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peopleCell", for: indexPath) as! PeopleTableViewCell
        cell.delegate = self
        
        // Configure Cell
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func configure(_ cell: PeopleTableViewCell, at indexPath: IndexPath) {
        // Fetch Quote
        let people = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        if people.middlename != "" && (people.middlename != nil) {
            cell.nameLbl.text = people.firstname! + " " + people.middlename! + " "  + people.lastname!
        } else {
            cell.nameLbl.text = people.firstname! + " " + people.lastname!
        }
        cell.positionLbl.text = people.title!
        cell.locationNameLbl.text = people.theirAddress?.city!
        if let peopleImg = people.picture {
            cell.profileImgView.image = UIImage(data: peopleImg as Data)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90;
    }
}

extension PeopleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //select action
        searchBar.resignFirstResponder()
        let selectedPeople = self.fetchedResultsController.object(at: indexPath) as PeopleEntity
        
        let PDVC = self.storyboard?.instantiateViewController(withIdentifier: "PeopleDetailViewController") as! PeopleDetailViewController
        PDVC.currentPerson = selectedPeople
        self.navigationController?.pushViewController(PDVC, animated: true)
    }
    
}

extension PeopleViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let currentPerson = fetchedResultsController.object(at: indexPath)
        
        if orientation == .left {
            return[]
        } else {
            let requestGPS = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                print("request gps")
                let lat = currentPerson.theirAddress?.gpsLatitude
                let long = currentPerson.theirAddress?.gpsLongitude
                let placeStr = (currentPerson.theirAddress?.city!)! + " " + (currentPerson.theirAddress?.streetName1)!
                self.openMapForPlace(lat: lat!, long: long!, placeName: placeStr)

            }
            requestGPS.hidesWhenSelected = true
            configure(action: requestGPS, with: .gps)
            return [requestGPS]
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
            options.backgroundColor = UIColor(red: 244/255.0, green: 140/255.0, blue: 140/255.0, alpha: 1.0)
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

enum ActionDescriptor {
    case gps, floorplane, directions
    
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .gps: return "Request GPS"
        case .floorplane: return "Floor plan"
        case .directions: return "Directions"
        }
    }
    
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .gps: name = "ShareGPS"
        case .floorplane: name = "Floorplan"
        case .directions: name = "Directions"
        }
        
        return UIImage(named: style == .backgroundColor ? name : name + "-circle")
    }
    
    var color: UIColor {
        switch self {
        case .gps: return UIColor.white
        case .floorplane: return UIColor.white
        case .directions: return UIColor.white
        }
    }
}

enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

enum ButtonStyle {
    case backgroundColor, circular
}




