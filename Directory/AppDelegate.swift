//
//  AppDelegate.swift
//  Directory
//
//  Created by Peter Michael Gits on 4/25/17.
//  Copyright © 2017 com.adient. All rights reserved.
//

import UIKit
import CoreData
//import Fabric
//import Crashlytics
//import DigitsKit
import CoreSpotlight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myCoreDataManager: CoreDataManager = CoreDataManager()
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        return urls[urls.count-1]
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //this copies the populated embedded database if it doesn't already exist
//        self.myCoreDataManager.preloadDBData()
        
        // Sets background to a blank/empty image
        //        Fabric.with([Crashlytics.self, Digits.self])
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
        
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes=[NSForegroundColorAttributeName:UIColor.white]
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                if let navigationController = window?.rootViewController as? UINavigationController {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    /*
                     let theDetailViewController = storyBoard.instantiateViewController(withIdentifier: "detailView") as! SQRAMFGDetailViewController
                     let programCode = uniqueIdentifier
                     if let programEntity = self.fetchThisProgram(code: programCode){
                     theDetailViewController.performDeepLink(deepLinkProgram: (programEntity))
                     navigationController.pushViewController(theDetailViewController, animated: true)
                     return true
                     }
                     */
                    // If you want to push to new ViewController then use this
                }
            }
        }
        return true
    }

    // MARK: - Core Data stack
    func fetchTheUserDetails() ->[PeopleEntity] {
        let moc = getManagedContext()
        let sitesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SiteEntity")
        sitesFetch.fetchLimit = 1
        var myFetchedSites:[PeopleEntity]
        do {
            myFetchedSites = try moc.fetch(sitesFetch) as! [PeopleEntity]
        } catch {
            fatalError("Failed to fetch any sites: \(error)")
        }
        return myFetchedSites
    }
    
    func fetchedResource() ->[ResourceEntity] {
        let moc = getManagedContext()
        let resourcesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ResourceEntity")
        var myFetchedResources:[ResourceEntity]
        do {
            myFetchedResources = try moc.fetch(resourcesFetch) as! [ResourceEntity]
        } catch {
            fatalError("Failed to fetch any resources: \(error)")
        }
        return myFetchedResources
    }
    
    func fetchAllResources(_ resourceCity:String, resourceState:String, resourceCountryCode:String)->[ResourceEntity]{
        let moc = getManagedContext()
        let resourcesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ResourceEntity")
        if resourceState == "" {
            resourcesFetchRequest.predicate = NSPredicate(format:"city = %@ stateOrProvince = %@ AND country = %@", resourceCity, resourceState, resourceCountryCode )
        } else {
            resourcesFetchRequest.predicate = NSPredicate(format:"city = %@ AND country = %@", resourceCity, resourceCountryCode )
        }
        var theLocatedEntity:[ResourceEntity]
        print(resourcesFetchRequest.predicate.debugDescription)
        do {
            theLocatedEntity = try moc.fetch(resourcesFetchRequest) as! [ResourceEntity]
        } catch {
            fatalError("Failed to fetch the resources named :\(resourceCity), error = \(error)")
        }
        return theLocatedEntity
    }
    
    func fetchThisPerson(lastName:String)->PeopleEntity? {
        let moc = self.getManagedContext()
        let personFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PeopleEntity")
        let predicateString:String = String(format:"lastname CONTAINS[cd] %@ OR firstname CONTAINS[cd] %@", lastName, lastName)
        print("predicate String = \(predicateString)")
        personFetchRequest.predicate = NSPredicate(format:predicateString)
        var theLocatedEntities:[PeopleEntity]
        let emptyProgramEntity:PeopleEntity? = nil
        do {
            theLocatedEntities = try moc.fetch(personFetchRequest) as! [PeopleEntity]
            
        } catch {
            fatalError("Failed to fetch the programEntity named :\(lastName), error = \(error)")
        }
        if(theLocatedEntities.count > 0){
            return theLocatedEntities[0]
        }
        return emptyProgramEntity
    }
    
    func getManagedContext() -> NSManagedObjectContext {
        return self.myCoreDataManager.persistentContainer.viewContext
    }
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = self.myCoreDataManager.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    public func createResources()->Void {
        let managedContext = self.getManagedContext()
        
        let companyEntity:CompanyEntity = NSEntityDescription.insertNewObject(forEntityName: "CompanyEntity", into: managedContext) as! CompanyEntity
        companyEntity.domain = "adient.com"
        //companyEntity.headquartersId
        companyEntity.name = "Adient"
        companyEntity.id   = 1
        companyEntity.imDomain = "adient.com"
        companyEntity.phoneNumber = "630 209 7542"
        companyEntity.url  = "adient.com"
        companyEntity.stockSymbol = "ADNT"
        
        let addressEntity1:AddressEntity = NSEntityDescription.insertNewObject(forEntityName: "AddressEntity", into: managedContext) as! AddressEntity
        addressEntity1.city = "Holland"
        addressEntity1.countryCode  = "US"
        addressEntity1.gpsAltitude  = 0.0
        addressEntity1.gpsLatitude  = 42.7663572
        addressEntity1.gpsLongitude = -86.0571885
        addressEntity1.gpsRadius    = 600.0
        addressEntity1.postalCode   = "49423"
        addressEntity1.stateOrProvince = "Michigan"
        addressEntity1.streetName1   = "727 South Waverly Road"
        
        let resourceCategory0:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory0.id = 1
        resourceCategory0.name = "Holland HQ"
        resourceCategory0.type = "building"
        
        let resourceCategory1:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory1.id = 2
        resourceCategory1.name = "conference room"
        resourceCategory1.type = "conference room"
        
        let resourceCategory2:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory2.id = 3
        resourceCategory2.name = "office"
        resourceCategory2.type = "office"
        
        let resourceCategory3:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory3.id = 4
        resourceCategory3.name = "desk"
        resourceCategory3.type = "desk"
        
        let resourceCategory4:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory4.id = 5
        resourceCategory4.name = "cafeteria"
        resourceCategory4.type = "cafeteria"
        
        let resourceCategory5:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory5.id = 6
        resourceCategory5.name = "bathroom"
        resourceCategory5.type = "bathroom"

        
        let resourceConferenceRoom1:ResourceEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceEntity", into: managedContext) as! ResourceEntity
        resourceConferenceRoom1.phoneNumber = "+16302097542"
        resourceConferenceRoom1.id = 1
        resourceConferenceRoom1.name = "IT-4-ASG_NA_Holland_COE"
        resourceConferenceRoom1.emailAddress = "IT41939@adient.com"
        resourceConferenceRoom1.projector  = true
        resourceConferenceRoom1.seatingCapacity = 12
        resourceConferenceRoom1.category   = resourceCategory1
        resourceConferenceRoom1.phoneNumber = "+16163946276"
        resourceConferenceRoom1.url = "https://ag.adient.com/mobile"
        let addressEntityRC1:AddressEntity = NSEntityDescription.insertNewObject(forEntityName: "AddressEntity", into: managedContext) as! AddressEntity
        addressEntityRC1.city = "Holland"
        addressEntityRC1.countryCode  = "US"
        addressEntityRC1.gpsAltitude  = 0.0
        addressEntityRC1.postalCode   = "49423"
        addressEntityRC1.stateOrProvince = "Michigan"
        addressEntityRC1.streetName1   = "727 South Waverly Road"
        resourceConferenceRoom1.location = addressEntityRC1
        resourceConferenceRoom1.location?.gpsLatitude = 42.771319
        resourceConferenceRoom1.location?.gpsLongitude = -86.071303
        resourceConferenceRoom1.location?.gpsRadius = 25 //meters
        
        let peopleEntity1:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let mikesBossEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let departmentEntity1:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
        peopleEntity1.globalUserId = "achabotm"
        peopleEntity1.employeeId   = 1
        peopleEntity1.lastname     = "Chabot"
        peopleEntity1.firstname    = "Mike"
        peopleEntity1.middlename   = "M"
        peopleEntity1.email        = "mike.chabot@adient.com"
        peopleEntity1.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "mike.chabot", ofType: "jpg")!)
        peopleEntity1.deskphone    = "+16163942516"
        peopleEntity1.mobilephone  = "+16162183730"
        peopleEntity1.imName       = "sip:mike.chabot@adient.com"
        peopleEntity1.title         = "Dir Solutions Delivery Srvcs"
        peopleEntity1.profileUrl    = "https://mysite.adient.com/person.aspx/?user=mike.chabot%40adient.com"
        departmentEntity1.departmentName = "IT Digital Office"
        departmentEntity1.departmentHeadId = 2 //"randall.j.urban"
        mikesBossEntity.employeeId   = 2
        mikesBossEntity.globalUserId = "aurbanr"
        peopleEntity1.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "randy.urban", ofType: "jpg")!)
        mikesBossEntity.email        = "randall.j.urban@adient.com"
        mikesBossEntity.firstname    = "Randall"
        mikesBossEntity.middlename   = "J"
        mikesBossEntity.lastname     = "Urban"
        mikesBossEntity.title        = "VP Digital Office"
        mikesBossEntity.deskphone    = "+17342546613"
        mikesBossEntity.mobilephone  = "+17344175548"
        mikesBossEntity.imName       = "sip:randall.j.urban@adient.com"
        
        peopleEntity1.myDepartment = departmentEntity1
        departmentEntity1.reportsToId  = 2
        //let mikesOfficeEntity:ResourceEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceEntity", into: managedContext) as! ResourceEntity
        //mikesOfficeEntity.

        self.saveContext()
        return
    }

}

