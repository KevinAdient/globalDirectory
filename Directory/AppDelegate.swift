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
        if self.fetchedResource().count > 0 {
            return;
        }
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

        
        let plymouthAddressEntity1:AddressEntity = NSEntityDescription.insertNewObject(forEntityName: "AddressEntity", into: managedContext) as! AddressEntity
        plymouthAddressEntity1.city = "Plymouth"
        plymouthAddressEntity1.countryCode  = "US"
        plymouthAddressEntity1.gpsAltitude  = 0.0
        plymouthAddressEntity1.gpsLatitude  = 42.3853165
        plymouthAddressEntity1.gpsLongitude = -83.5293167
        plymouthAddressEntity1.gpsRadius    = 400.0
        plymouthAddressEntity1.postalCode   = "48170"
        plymouthAddressEntity1.stateOrProvince = "Michigan"
        plymouthAddressEntity1.streetName1   = "49200 Halyard Drive"//734-254-5000 site general number

        let helmAddressEntity1:AddressEntity = NSEntityDescription.insertNewObject(forEntityName: "AddressEntity", into: managedContext) as! AddressEntity
        helmAddressEntity1.city = "Plymouth"
        helmAddressEntity1.countryCode  = "US"
        helmAddressEntity1.gpsAltitude  = 0.0
        helmAddressEntity1.gpsLatitude  = 42.3926075
        helmAddressEntity1.gpsLongitude = -83.4905251
        helmAddressEntity1.gpsRadius    = 200.0
        helmAddressEntity1.postalCode   = "48170"
        helmAddressEntity1.stateOrProvince = "Michigan"
        helmAddressEntity1.streetName1   = "45000 Helm St"//734-254-5000 site general number

        let milwaukeeAddressEntity1:AddressEntity = NSEntityDescription.insertNewObject(forEntityName: "AddressEntity", into: managedContext) as! AddressEntity
        milwaukeeAddressEntity1.city = "Milwaukee"
        milwaukeeAddressEntity1.countryCode  = "US"
        milwaukeeAddressEntity1.gpsAltitude  = 0.0
        milwaukeeAddressEntity1.gpsLatitude  = 43.037536
        milwaukeeAddressEntity1.gpsLongitude = -87.9029545
        milwaukeeAddressEntity1.gpsRadius    = 400.0
        milwaukeeAddressEntity1.postalCode   = "53202"
        milwaukeeAddressEntity1.stateOrProvince = "Wisconsin"
        milwaukeeAddressEntity1.streetName1   = "833 E Michigan Street"//734-254-5000 site general number
        
        let resourceCategory0:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory0.id = 1050
        resourceCategory0.name = "Holland Customer Center"
        resourceCategory0.type = "building"
        
        let plymouthCategory:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        plymouthCategory.id = 1000
        plymouthCategory.name = "Central Tech Unit Plymouth MI"
        plymouthCategory.type = "building"

        let wisconsinCategory:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        wisconsinCategory.id = 2000
        wisconsinCategory.name = "Wisconsin Adient HQ"
        wisconsinCategory.type = "building"

        
        let resourceCategory1:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory1.id = 1
        resourceCategory1.name = "conference room"
        resourceCategory1.type = "conference room"
        
        let resourceCategory2:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory2.id = 2
        resourceCategory2.name = "office"
        resourceCategory2.type = "office"
        
        let resourceCategory3:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory3.id = 3
        resourceCategory3.name = "desk"
        resourceCategory3.type = "desk"
        
        let resourceCategory4:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory4.id = 4
        resourceCategory4.name = "cafeteria"
        resourceCategory4.type = "cafeteria"
        
        let resourceCategory5:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory5.id = 5
        resourceCategory5.name = "bathroom"
        resourceCategory5.type = "bathroom"

        let lobbyResource:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        lobbyResource.id = 6
        lobbyResource.name = "lobby"
        lobbyResource.type = "lobby"
        
        let addressEntityRC1:AddressEntity = NSEntityDescription.insertNewObject(forEntityName: "AddressEntity", into: managedContext) as! AddressEntity
        addressEntityRC1.city = "Holland"
        addressEntityRC1.countryCode  = "US"
        addressEntityRC1.gpsAltitude  = 0.0
        addressEntityRC1.postalCode   = "49423"
        addressEntityRC1.stateOrProvince = "Michigan"
        addressEntityRC1.streetName1   = "727 South Waverly Road"
        
        let resourceConferenceRoom2:ResourceEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceEntity", into: managedContext) as! ResourceEntity
        resourceConferenceRoom2.phoneNumber = "+16302097542"
        resourceConferenceRoom2.id = 2
        resourceConferenceRoom2.name = "IT-4-ASG_NA_Holland_COE"
        resourceConferenceRoom2.emailAddress = "IT3278@adient.com"
        resourceConferenceRoom2.projector  = true
        resourceConferenceRoom2.seatingCapacity = 12
        resourceConferenceRoom2.category   = resourceCategory1
        resourceConferenceRoom2.phoneNumber = "+16163946276"
        resourceConferenceRoom2.iAttendUrl = "https://ag.adient.com/mobile/iAttend?conf=IT3278"
        resourceConferenceRoom2.location = addressEntityRC1
        resourceConferenceRoom2.location?.gpsLatitude = 42.771192
        resourceConferenceRoom2.location?.gpsLongitude = -86.071312
        resourceConferenceRoom2.location?.gpsRadius = 25 //meters
        resourceConferenceRoom2.company = companyEntity

        let resourceConferenceRoom3:ResourceEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceEntity", into: managedContext) as! ResourceEntity
        resourceConferenceRoom3.phoneNumber = "+16302097542"
        resourceConferenceRoom3.id = 3
        resourceConferenceRoom3.name = "IT-4-ASG_NA_Holland_COE"
        resourceConferenceRoom3.emailAddress = "IT3278@adient.com"
        resourceConferenceRoom3.projector  = true
        resourceConferenceRoom3.seatingCapacity = 12
        resourceConferenceRoom3.category   = resourceCategory1
        resourceConferenceRoom3.phoneNumber = "+16163946276"
        resourceConferenceRoom3.iAttendUrl = "https://ag.adient.com/mobile/iAttend?conf=IT3278"
        resourceConferenceRoom3.location = addressEntityRC1
        resourceConferenceRoom3.location?.gpsLatitude = 42.771192
        resourceConferenceRoom3.location?.gpsLongitude = -86.071312
        resourceConferenceRoom3.location?.gpsRadius = 25 //meters
        resourceConferenceRoom3.company = companyEntity

        let resourceConferenceRoom4:ResourceEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceEntity", into: managedContext) as! ResourceEntity
        resourceConferenceRoom4.phoneNumber = "+16302097542"
        resourceConferenceRoom4.id = 4
        resourceConferenceRoom4.name = "IT-4-ASG_NA_Holland_COE"
        resourceConferenceRoom4.emailAddress = "IT41939@adient.com"
        resourceConferenceRoom4.projector  = true
        resourceConferenceRoom4.seatingCapacity = 12
        resourceConferenceRoom4.category   = resourceCategory1
        resourceConferenceRoom4.phoneNumber = "+16163946276"
        resourceConferenceRoom4.iAttendUrl = "https://ag.adient.com/mobile/iAttend?conf=IT4193"
        resourceConferenceRoom4.location = addressEntityRC1
        resourceConferenceRoom4.location?.gpsLatitude = 42.771319
        resourceConferenceRoom4.location?.gpsLongitude = -86.071423
        resourceConferenceRoom4.location?.gpsRadius = 25 //meters
        resourceConferenceRoom4.company = companyEntity

        let resourceConferenceRoom5:ResourceEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceEntity", into: managedContext) as! ResourceEntity
        resourceConferenceRoom5.phoneNumber = "+17342543800; 40331174"
        resourceConferenceRoom5.id = 5
        resourceConferenceRoom5.name = "IT-5-ASG_NA_Holland_COE"
        resourceConferenceRoom5.emailAddress = "IT51110@adient.com"
        resourceConferenceRoom5.projector  = false
        resourceConferenceRoom5.seatingCapacity = 4
        resourceConferenceRoom5.category   = resourceCategory1
        resourceConferenceRoom5.phoneNumber = "+16163946276"
        resourceConferenceRoom5.iAttendUrl = "https://ag.adient.com/mobile/iAttend?conf=IT51110"
        resourceConferenceRoom5.location = addressEntityRC1
        resourceConferenceRoom5.location?.gpsLatitude = 42.771273
        resourceConferenceRoom5.location?.gpsLongitude = -86.071442
        resourceConferenceRoom5.location?.gpsRadius = 5 //meters
        resourceConferenceRoom5.company = companyEntity

        let resourceConferenceRoom6:ResourceEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceEntity", into: managedContext) as! ResourceEntity
        resourceConferenceRoom6.phoneNumber = "+17342543800; 40331174"
        resourceConferenceRoom6.id = 6
        resourceConferenceRoom6.name = "IT-6-ASG_NA_holland_COE"
        resourceConferenceRoom6.emailAddress = "IT-6-ASG_NA_holland_COE@adient.com"
        resourceConferenceRoom6.projector  = true
        resourceConferenceRoom6.seatingCapacity = 8
        resourceConferenceRoom6.category   = resourceCategory1
        resourceConferenceRoom6.phoneNumber = "+16163946276"
        resourceConferenceRoom6.iAttendUrl = "https://ag.adient.com/mobile/iAttend?conf=IT-6-ASG_NA_holland_COE"
        resourceConferenceRoom6.location = addressEntityRC1
        resourceConferenceRoom6.location?.gpsLatitude = 42.771250
        resourceConferenceRoom6.location?.gpsLongitude = -86.071128
        resourceConferenceRoom6.location?.gpsRadius = 20 //meters
        resourceConferenceRoom6.company = companyEntity

        let lobby1:ResourceEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceEntity", into: managedContext) as! ResourceEntity
        lobby1.phoneNumber = ""
        lobby1.id = 20000
        lobby1.name = "North East Lobby"
        lobby1.emailAddress = ""
        lobby1.projector  = false
        lobby1.seatingCapacity = 0
        lobby1.category   = lobbyResource
        lobby1.phoneNumber = "+16163946276"//should be home admin
        lobby1.iAttendUrl = "https://ag.adient.com/mobile/iAttend?conf=20000"
        lobby1.location = addressEntityRC1
        lobby1.location?.gpsLatitude = 42.771444
        lobby1.location?.gpsLongitude = -86.070802
        lobby1.location?.gpsRadius = 30 //meters

        let peopleEntity1:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let mikesBossEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let departmentEntity1:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
        let departmentEntity2:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
        departmentEntity2.departmentName = "AP-Supp-CTU-Ply-IT App Mgmt"
        let sarahEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
    /*
        let kevinEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let harshaEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let sangaEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let peteEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
    */
        let shobitaEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let julieEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let sherylEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let bruceEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        
        bruceEntity.globalUserId = "amcdonaldb"
        bruceEntity.employeeId   = 1
        bruceEntity.firstname    = "Bruce"
        bruceEntity.lastname     = "McDonald"
        bruceEntity.middlename   = ""
        bruceEntity.email        = "bruce.mcdonald@adient.com"
        bruceEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "bruce.mcdonald", ofType: "jpg")!)
        bruceEntity.deskphone    = "+14142208988"
        bruceEntity.mobilephone  = "+14142233501"
        bruceEntity.imName       = "sip:bruce.mcdonald@adient.com"
        bruceEntity.title         = "Chairman and CEO"
        bruceEntity.profileUrl    = "https://mysite.adient.com/person.aspx/?user=bruce.mcdonald%40adient.com"
        let departmentEntity6:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
        departmentEntity6.departmentName = "Adient Office of the CEO"
        bruceEntity.theirDepartment = departmentEntity6
        bruceEntity.company       = companyEntity
        bruceEntity.theirAddress  = milwaukeeAddressEntity1
        departmentEntity6.reportsToId = 0
        departmentEntity6.departmentHeadId = 1
        departmentEntity6.departmentId = 6
        
        sherylEntity.globalUserId = "ahaislets"
        sherylEntity.employeeId   = 2
        sherylEntity.lastname     = "Haislet"
        sherylEntity.firstname    = "Sheryl"
        sherylEntity.middlename   = "L"
        sherylEntity.email        = "sheryl.l.haislet@adient.com"
        sherylEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "sheryl.haislet", ofType: "jpg")!)
        sherylEntity.deskphone    = "+173425431176"
        sherylEntity.mobilephone  = "+16162831888"
        sherylEntity.imName       = "sip:sheryl.l.haislet@adient.com"
        sherylEntity.title         = "VP IT"
        sherylEntity.profileUrl    = "https://mysite.adient.com/person.aspx/?user=sheryl.l.haislet%40adient.com"
        let departmentEntity3:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
        departmentEntity3.departmentName = "Adient Mgt Glen"
        sherylEntity.theirDepartment = departmentEntity3
        departmentEntity3.reportsToId = 1
        departmentEntity3.departmentHeadId = 2
        departmentEntity3.departmentId = 2
        
        sherylEntity.company       = companyEntity
        sherylEntity.theirAddress  = plymouthAddressEntity1

        julieEntity.globalUserId = "araglandj"
        julieEntity.employeeId   = 3
        julieEntity.lastname     = "Ragland"
        julieEntity.firstname    = "Julie"
        julieEntity.middlename   = ""
        julieEntity.email        = " julie.ragland@adient.com"
        julieEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "julie.ragland", ofType: "jpg")!)
        julieEntity.deskphone    = "+14142208986"
        julieEntity.mobilephone  = "+14145261426"
        julieEntity.imName       = "sip:julie.ragland@adient.com"
        julieEntity.title         = "VP Corporate Applications"
        julieEntity.profileUrl    = "https://mysite.adient.com/person.aspx/?user=julie.ragland%40adient.com"
        let departmentEntity4:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
        departmentEntity4.departmentName = "Adient - Office of CIO"
        departmentEntity4.reportsToId = 2
        departmentEntity4.departmentHeadId = 3
        departmentEntity4.departmentId = 4
        julieEntity.theirDepartment = departmentEntity4
        julieEntity.company       = companyEntity
        julieEntity.theirAddress  = milwaukeeAddressEntity1
        
        shobitaEntity.globalUserId = "ashobitas"
        shobitaEntity.employeeId   = 4
        shobitaEntity.lastname     = "Saxena"
        shobitaEntity.firstname    = "Shobhita"
        shobitaEntity.middlename   = ""
        shobitaEntity.email        = "shobhita.saxena@adient.com"
        shobitaEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "shobita.saxena", ofType: "jpg")!)
        shobitaEntity.deskphone    = "+17342546752"
        shobitaEntity.mobilephone  = "+12482078910"
        shobitaEntity.imName       = "sip:shobhita.saxena@adient.com"
        shobitaEntity.title         = "Exec Dir Project Delivery Srvcs"
        shobitaEntity.profileUrl    = "https://mysite.adient.com/person.aspx/?user=sheryl.l.haislet%40adient.com"
        let departmentEntity5:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
        departmentEntity5.departmentName = "AP-Adient-IT-CTU 08"
        departmentEntity5.reportsToId = 3
        departmentEntity5.departmentHeadId = 4
        departmentEntity5.departmentId = 5
        shobitaEntity.theirDepartment = departmentEntity5
        shobitaEntity.company       = companyEntity
        shobitaEntity.theirAddress  = helmAddressEntity1

        sarahEntity.globalUserId = "ahendrixsons"
        sarahEntity.employeeId   = 40
        sarahEntity.firstname    = "Sarah"
        sarahEntity.lastname     = "Hendrixson"
        sarahEntity.middlename   = "A"
        sarahEntity.email        = "sarah.a.hendrixson@adient.com"
        sarahEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "sarah.hendrixson", ofType: "jpg")!)
        sarahEntity.deskphone    = "+16163948819"
        sarahEntity.mobilephone  = "+16163401320"
        sarahEntity.imName       = "sip:sarah.a.hendrixson@adient.com"
        sarahEntity.title         = "Mgr E2P Bus Rel Process & Modeling"
        sarahEntity.profileUrl    = "hhttps://mysite.adient.com/person.aspx/?user=sarah.a.hendrixson%40adient.com"
        let departmentEntity7:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
        departmentEntity7.departmentName = "AP-Supp-CTU-Ply-IT App Mgmt"
        departmentEntity7.reportsToId = 4
        departmentEntity7.departmentHeadId = 40
        departmentEntity7.departmentId = 7
        sarahEntity.theirDepartment = departmentEntity7
        sarahEntity.company       = companyEntity
        sarahEntity.theirAddress  = addressEntity1

        peopleEntity1.globalUserId = "achabotm"
        peopleEntity1.employeeId   = 21
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
        peopleEntity1.company       = companyEntity

        departmentEntity1.departmentName = "IT Digital Office"
        departmentEntity1.departmentHeadId = 20 //"randall.j.urban"
        departmentEntity1.reportsToId = 2  //randy reports to sheryl
        departmentEntity1.departmentId = 1
        mikesBossEntity.employeeId   = 20
        mikesBossEntity.globalUserId = "aurbanr"
        mikesBossEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "randy.urban", ofType: "jpg")!)
        mikesBossEntity.email        = "randall.j.urban@adient.com"
        mikesBossEntity.firstname    = "Randall"
        mikesBossEntity.middlename   = "J"
        mikesBossEntity.lastname     = "Urban"
        mikesBossEntity.title        = "VP Digital Office"
        mikesBossEntity.deskphone    = "+17342546613"
        mikesBossEntity.mobilephone  = "+17344175548"
        mikesBossEntity.imName       = "sip:randall.j.urban@adient.com"
        mikesBossEntity.profileUrl   = "https://mysite.adient.com/person.aspx/?user=randall.j.urban%40adient.com"
        mikesBossEntity.company      = companyEntity
        mikesBossEntity.theirAddress = helmAddressEntity1
        peopleEntity1.theirDepartment = departmentEntity1
        peopleEntity1.theirAddress    = addressEntity1
        departmentEntity1.reportsToId  = 2

        self.saveContext()
        return
    }

}

