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
        
        UINavigationBar.appearance().tintColor = UIColor.white
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
    
    func fetchTheCompany() ->[CompanyEntity] {
        let moc = getManagedContext()
        let companyFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CompanyEntity")
        companyFetch.fetchLimit = 1
        var myFetchedCompany:[CompanyEntity]
        do {
            myFetchedCompany = try moc.fetch(companyFetch) as! [CompanyEntity]
        } catch {
            fatalError("Failed to fetch any companies: \(error)")
        }
        return myFetchedCompany
    }

    
    //if we already have one with this name
    func fetchedResourceCategory(_ resourceName:String) ->[ResourceCategoryEntity] {
        let moc = getManagedContext()
        let resourceCategoryFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ResourceCategoryEntity")
        var myFetchedResourceCategory:[ResourceCategoryEntity]
        do {
            resourceCategoryFetch.predicate = NSPredicate(format:"name = %@",resourceName )
            myFetchedResourceCategory = try moc.fetch(resourceCategoryFetch) as! [ResourceCategoryEntity]
        } catch {
            fatalError("Failed to fetch any category resources: \(error)")
        }
        return myFetchedResourceCategory
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
    
    func fetchEmployeeId(employeeId:String)->PeopleEntity? {
        let moc = self.getManagedContext()
        let personFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PeopleEntity")
        let predicateString:String = String(format:"employeeId CONTAINS[cd] \"%@\"", employeeId)
        print("predicate String = \(predicateString)")
        personFetchRequest.predicate = NSPredicate(format:predicateString)
        var theLocatedEntities:[PeopleEntity]
        let emptyProgramEntity:PeopleEntity? = nil
        do {
            theLocatedEntities = try moc.fetch(personFetchRequest) as! [PeopleEntity]
            
        } catch {
            fatalError("Failed to fetch the programEntity named :\(employeeId), error = \(error)")
        }
        if(theLocatedEntities.count > 0){
            return theLocatedEntities[0]
        }
        return emptyProgramEntity
    }

    func fetchThisPerson(lastName:String)->PeopleEntity? {
        let moc = self.getManagedContext()
        let personFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PeopleEntity")
        let predicateString:String = String(format:"lastname CONTAINS[cd] \"%@\"", lastName)
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
    
    func fetchManagerUsing(displayName:String)->PeopleEntity? {
        let moc = self.getManagedContext()
        let personFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PeopleEntity")
        let predicateString:String = String(format:"displayName CONTAINS[cd] \"%@\"", displayName)
        print("predicate String = \(predicateString)")
        personFetchRequest.predicate = NSPredicate(format:predicateString)
        var theLocatedEntities:[PeopleEntity]
        let emptyProgramEntity:PeopleEntity? = nil
        do {
            theLocatedEntities = try moc.fetch(personFetchRequest) as! [PeopleEntity]
            
        } catch {
            fatalError("Failed to fetch the programEntity named :\(displayName), error = \(error)")
        }
        if(theLocatedEntities.count > 0){
            return theLocatedEntities[0]
        }
        return emptyProgramEntity
    }

    func fetchManagersDepartment(managersName:String)->DepartmentEntity? {
        let moc = self.getManagedContext()
        let departmentFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DepartmentEntity")
        let predicateString = String(format:"departmentHeadId contains[cd] \"%@\"", managersName)
        print("predicate String = \(predicateString)")
        departmentFetchRequest.predicate = NSPredicate(format:predicateString)
        var theLocatedEntities:[DepartmentEntity]
        let emptyDepartmentEntity:DepartmentEntity? = nil
        do {
            theLocatedEntities = try moc.fetch(departmentFetchRequest) as! [DepartmentEntity]
            
        } catch {
            fatalError("Failed to fetch the managersDepartmentEntity named :\(managersName), error = \(error)")
        }
        if(theLocatedEntities.count > 0){
            return theLocatedEntities[0]
        }
        return emptyDepartmentEntity
    }

    func fetchDepartment(departmentName:String)->DepartmentEntity? {
        let moc = self.getManagedContext()
        let departmentFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DepartmentEntity")
        //check for the dash
//        let preparseDepartmentName = departmentName.replacingOccurrences(of: "Adient - ", with: "", options: .literal, range: nil)
//      let predicateString = String(format:"departmentName contains[cd] \"%@\"", preparseDepartmentName)
        let predicateString = String(format:"departmentName contains[cd] \"%@\"", departmentName)
        print("predicate String = \(predicateString)")
        departmentFetchRequest.predicate = NSPredicate(format:predicateString)
        var theLocatedEntities:[DepartmentEntity]
        let emptyDepartmentEntity:DepartmentEntity? = nil
        do {
            theLocatedEntities = try moc.fetch(departmentFetchRequest) as! [DepartmentEntity]
            
        } catch {
            fatalError("Failed to fetch the programEntity named :\(departmentName), error = \(error)")
        }
        if(theLocatedEntities.count > 0){
            return theLocatedEntities[0]
        }
        return emptyDepartmentEntity
    }

    //only checking street and city keys
    func fetchAddress(streetAddress:String, cityAddress:String)->AddressEntity? {
        let moc = self.getManagedContext()
        let addressFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AddressEntity")
        let predicateString = String(format:"streetName1 contains[cd] \"%@\" AND city contains[cd] \"%@\" ", streetAddress, cityAddress)
        print("predicate String = \(predicateString)")
        addressFetchRequest.predicate = NSPredicate(format:predicateString)
        var theLocatedEntities:[AddressEntity]
        let emptyAddressEntity:AddressEntity? = nil
        do {
            theLocatedEntities = try moc.fetch(addressFetchRequest) as! [AddressEntity]
            
        } catch {
            fatalError("Failed to fetch the addressEntity named :\(streetAddress), \(cityAddress), error = \(error)")
        }
        if(theLocatedEntities.count > 0){
            return theLocatedEntities[0]
        }
        return emptyAddressEntity
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
    
    public func importJuliesReports()->Void {
        var iCounterResources : Int64 = 3000
        var iDepartmentIdCounter : Int16 = 100
        let julieReportsName:String = String("directReports")
        let jsonPeoplePath: String = Bundle.main.path(forResource: julieReportsName, ofType: "json")! as String
        
        let readData : Data = try! Data(contentsOf: URL(fileURLWithPath: jsonPeoplePath), options:  NSData.ReadingOptions.dataReadingMapped)
    
        let companyEntity:CompanyEntity = NSEntityDescription.insertNewObject(forEntityName: "CompanyEntity", into: getManagedContext()) as! CompanyEntity
        companyEntity.domain = "adient.com"
        //companyEntity.headquartersId
        companyEntity.name = "Adient"
        companyEntity.id   = 1
        companyEntity.imDomain = "adient.com"
        companyEntity.phoneNumber = "+1 734 254 5000"
        companyEntity.url  = "adient.com"
        companyEntity.stockSymbol = "ADNT"
    
        do {
            let peopleDictionary = try JSONSerialization.jsonObject(with: readData, options: [])
                as! [String : AnyObject]
            
            //print(peopleDictionary)
            //iterate over the dictionary
            for(juliesReports,theArray) in peopleDictionary {
                var myAddressEntity: AddressEntity? = nil
                var myResourceCategoryEntity: ResourceCategoryEntity
                var myDepartmentEntity: DepartmentEntity?
                var myPeopleEntity: PeopleEntity?
                    print("juliesReports = \(theArray)\n")
                    let largeArray = theArray as! NSArray
                    for arrayElement in largeArray {
                        let myReportsDictionary = arrayElement as! Dictionary<String, AnyObject>
                        let displayName :String = myReportsDictionary["displayname"] as! String
                        print("displayname = \(displayName)\n")
                        let GivenName = myReportsDictionary["GivenName"]
                        print ("GivenName = \(GivenName!)\n")
                        let Surname = myReportsDictionary["Surname"]
                        print ("Surname = \(Surname!)\n")
                        let SamAccountName = myReportsDictionary["SamAccountName"]
                        print ("SamAccountName = \(SamAccountName!)\n")
                        let EmailAddress = myReportsDictionary["EmailAddress"]
                        print ("EmailAddress = \(EmailAddress!)\n")
                        let employeeId = EmailAddress
                        print("replacing employeeId with email address\n")
                        
                        let manager : String = myReportsDictionary["manager"] as! String
                        print ("manager = \(manager)\n")
                        let Department :String? = myReportsDictionary["Department"] as? String
                        print ("Department = \(String(describing: Department))\n")
                        let StreetAddress = myReportsDictionary["StreetAddress"]
                        print ("StreetAddress = \(StreetAddress!)\n")
                        let city = myReportsDictionary["city"]
                        print ("city = \(city!)\n")
                        let State = myReportsDictionary["State"]
                        print ("State = \(State!)\n")
                        let co : String = myReportsDictionary["co"] as! String
                        print ("co = \(co)\n")
                        var myPostalCode : String?
                        //var myPostalCodeNumber : NSNumber?
                        if let myPostalCodeNumber = myReportsDictionary["PostalCode"] as? NSNumber {
                            myPostalCode = myPostalCodeNumber.stringValue
                        }
                         //let myPostalCodeNumber : NSNumber = myReportsDictionary["PostalCode"] as! NSNumber
                       // let myPostalCode : String = myPostalCodeNumber.stringValue
                        if myPostalCode != nil {
                            print ("PostalCode = \(myPostalCode)\n")
                        }else {
                            print ("PostalCode is empty\n")
                        }
                        let physicalDeliveryOfficeName = myReportsDictionary["physicalDeliveryOfficeName"]
                        print ("physicalDeliveryOfficeName = \(physicalDeliveryOfficeName!)\n")
                        let fetchedResourceCategoryArray = self.fetchedResourceCategory(physicalDeliveryOfficeName as! String)
                        if fetchedResourceCategoryArray.count <= 0 {
                            let newResourceCategory:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: getManagedContext()) as! ResourceCategoryEntity
                            newResourceCategory.id = iCounterResources
                            iCounterResources = iCounterResources + 1
                            newResourceCategory.name = physicalDeliveryOfficeName as! String
                            newResourceCategory.type = "building"
                            myResourceCategoryEntity = newResourceCategory
                            
                            //add the address because it is new
                            if let addressEntityExists = fetchAddress(streetAddress:StreetAddress as! String, cityAddress:city as! String){
                                myAddressEntity = addressEntityExists
                            }else {
                                let addressEntity:AddressEntity = NSEntityDescription.insertNewObject(forEntityName: "AddressEntity", into: self.getManagedContext()) as! AddressEntity
                                addressEntity.city = city as! String
                                addressEntity.streetName1 = StreetAddress as! String
                                //if State
                                addressEntity.stateOrProvince = State as? String
                                
                                if co == "United States of America" {
                                    addressEntity.countryCode = "US"
                                }else {
                                    addressEntity.countryCode = co 
                                }
                                if myPostalCode != nil {
                                    addressEntity.postalCode = myPostalCode
                                }
                                myAddressEntity = addressEntity
                            }
                            myResourceCategoryEntity.locations = myAddressEntity
                        }else {//didn't find any resourceCategory that matched name
                            myResourceCategoryEntity = fetchedResourceCategoryArray[0]
                            if myResourceCategoryEntity.locations != nil {
                                myAddressEntity = myResourceCategoryEntity.locations!
                            }
                        }
                        
                        if let existingPeopleEntity = fetchEmployeeId(employeeId:EmailAddress as! String) {
                            myPeopleEntity = existingPeopleEntity
                        }else {
                            let peopleEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: getManagedContext()) as! PeopleEntity
                            let telephoneNumber = myReportsDictionary["telephoneNumber"]
                            print ("telephoneNumber = \(telephoneNumber!)\n")
                            let mobile = myReportsDictionary["mobile"]
                            print ("mobile = \(mobile!)\n")
                            let title = myReportsDictionary["title"]
                            print ("title = \(title!)\n")
                            peopleEntity.displayName = displayName
                            peopleEntity.employeeId = employeeId as! String
                            peopleEntity.deskphone = telephoneNumber as? String
                            peopleEntity.mobilephone = mobile as! String
                            peopleEntity.title = title as! String
                            peopleEntity.firstname = GivenName as! String
                            peopleEntity.lastname = Surname as! String
                            peopleEntity.globalUserId = SamAccountName as! String
                            peopleEntity.email = EmailAddress as! String
                            
                            //passes in the fullname of the manager to get the email of manager
                            if let managersPeopleEntity : PeopleEntity = fetchManagerUsing(displayName:manager as! String) {
                            peopleEntity.reportsToId = managersPeopleEntity.email
                            }else {
                                peopleEntity.reportsToId = manager as! String
                            }
                            peopleEntity.theirAddress = myAddressEntity
                            peopleEntity.company = companyEntity
                            
                            myPeopleEntity = peopleEntity
                        }
                        
                        
                        //this tests this employee's department
                        if Department == ""  || Department == nil {
                            //fetch the manager's department
                            let managersDepartmentEntity = fetchManagersDepartment(managersName: manager as! String)
                            if managersDepartmentEntity != nil {
                                myDepartmentEntity = managersDepartmentEntity!
                            }
                        } else {
                            let existingDepartmentEntity = fetchDepartment(departmentName: Department!)
                            if existingDepartmentEntity != nil {
                                myDepartmentEntity = existingDepartmentEntity
                            }else {
                            //add departmentEntity
                                let newDepartmentEntity:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: getManagedContext()) as! DepartmentEntity
                                newDepartmentEntity.departmentName = Department!
                                newDepartmentEntity.departmentId = iDepartmentIdCounter
                                iDepartmentIdCounter += 1
                                newDepartmentEntity.headReportsToId = manager as! String
                                newDepartmentEntity.departmentHeadId = manager as! String
                                myDepartmentEntity = newDepartmentEntity
                            }
                        }
                        if myDepartmentEntity != nil {
                            myPeopleEntity?.theirDepartment = myDepartmentEntity
                        }
                        
//HERE PETE
                }
            }

        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        self.saveContext()


    }
    
    public func importPlants()->Void {
        let companyFetch = self.fetchTheCompany()
        var parentCompany : CompanyEntity? = nil
        if companyFetch.count > 0 {
            parentCompany = companyFetch[0]
        }

        let jsonPlantsName:String = String("prmgeo")
        let jsonPlantsPath: String = Bundle.main.path(forResource: jsonPlantsName, ofType: "json")! as String

        let readData : Data = try! Data(contentsOf: URL(fileURLWithPath: jsonPlantsPath), options:  NSData.ReadingOptions.dataReadingMapped)
        //let myString = readData.string
        //let removedSpecialCharactersString = removeSpecialCharsFromString(text:myString)
        //let newFilteredData = removedSpecialCharactersString.data
        do {
            let plantDictionary = try JSONSerialization.jsonObject(with: readData, options: [])
                as! [String : AnyObject]
            var plantStartingId:Int64 = 50000
            print(plantDictionary)
            //iterate over the dictionary
            for(theType,theProperties) in plantDictionary {
                print("type = \(theType)\n")
                if theType == "features" {
                    print("properties = \(theProperties)\n")
                    let largeArray = theProperties as! NSArray
                    for arrayElement in largeArray {
                        let plantEntity:PlantEntity = NSEntityDescription.insertNewObject(forEntityName: "PlantEntity", into: self.getManagedContext()) as! PlantEntity
                        
                        let addressEntity:AddressEntity = NSEntityDescription.insertNewObject(forEntityName: "AddressEntity", into: self.getManagedContext()) as! AddressEntity
                        
                        plantEntity.plantAddress = addressEntity
                        addressEntity.plant = plantEntity
                        let resourceCategoryEntity:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: self.getManagedContext()) as! ResourceCategoryEntity
                        resourceCategoryEntity.id = plantStartingId
                        plantStartingId += 1
                        resourceCategoryEntity.type = "plant"
                        resourceCategoryEntity.plants = plantEntity
                        if parentCompany != nil {
                            plantEntity.parentCompany = parentCompany
                        }

                        let myHeadDictionary = arrayElement as! Dictionary<String, AnyObject>
                        /*
                        let coords = myHeadDictionary["geometry"]
                        let coordinates = coords?["coordinates"] as! NSArray
                        let longitude = coordinates[0]
                        let latitude  = coordinates[1]
                        */
                        
                        let props = myHeadDictionary["properties"]
                        
                        let longitude = props?["Longitude"] as? Double
                        let latitude  = props?["Latitude"] as? Double
                        if latitude != nil && longitude != nil {
                            print("latitude = \(latitude!), longitude = \(longitude!)\n")
                            addressEntity.gpsLatitude  = latitude!
                            addressEntity.gpsLongitude = longitude!
                            addressEntity.gpsRadius    = 2000.0
                        }
                        if let phoneNumber = props?["Phone"] as? String {
                            print("phoneNumber: \(phoneNumber)")
                            plantEntity.phone = phoneNumber
                        }
                        let plantName = props?["Plant"] as! String
                        print("plantName:\(plantName)")
                        plantEntity.name = plantName
                        resourceCategoryEntity.name = plantName

                        let region = props?["Region"] as! String
                        print("region:\(region)")
                        plantEntity.region = region
                        let multipleBuildings = props?["Multiple Buildings?"] as! String
                        print("multipleBuildings: \(multipleBuildings)")
                        if multipleBuildings == "0" {
                            plantEntity.multipleBuildings = false
                        }else {
                            plantEntity.multipleBuildings = true
                        }
                        let viewMap = props?["ViewMap"] as! String
                        print("viewMap: \(viewMap)")
                        plantEntity.viewMapGeo = viewMap
                        if let iTManagedBy = props?["IT Managed By"] as? String {
                            print("iTManagedBy: \(iTManagedBy)")
                            plantEntity.iTManagedBy = iTManagedBy
                        }
                        let isActive = props?["Active?"] as! String
                        print("isActive: \(isActive)")
                        if isActive == "0" {
                            plantEntity.active = false
                        }else {
                            plantEntity.active = true
                        }
                        
                        if let city = props?["City"] as? String {
                            print("city: \(city)")
                            addressEntity.city = city
                        }
                        if let leadIT = props?["Lead IT"] as? String {
                            print("leadIT: \(leadIT)")
                            plantEntity.leadIT = leadIT
                        }
                        let state = props?["State"] as! String
                        print("state: \(state)")
                        addressEntity.stateOrProvince = state
                        let zipCode = props?["Zipcode"] as! String
                        print("zipCode: \(zipCode)")
                        addressEntity.postalCode   = zipCode
                        if let customerGroup = props?["Customer Group"] as? String {
                            print("customerGroup: \(customerGroup)")
                            plantEntity.customerGroup = customerGroup
                        }
                        let country = props?["Country"] as! String
                        print("country: \(country)")
                        addressEntity.countryCode  = country
                        let streetAddress = props?["Street Address"] as! String
                        print("streetAddress: \(streetAddress)")
                        addressEntity.streetName1 = streetAddress
                        let productGroupOrg = props?["Product Group Org"] as! String
                        print("productGroupOrg: \(productGroupOrg)")
                        plantEntity.productGroupOrg = productGroupOrg
                        if let additionalAddresses = props?["Additional addresses"] as? String {
                            print(additionalAddresses)
                            plantEntity.additionalAddresses = additionalAddresses
                        }
                        if let telecomId = props?["Telecom ID"] as? String {
                            print("telecomId: \(telecomId)")                        
                            plantEntity.telecomId = Int64(telecomId)!//Int64(string:telecomId)
                        }
                        if let pgItManager = props?["PG IT Manager"] as? String {
                            print("pgItManager: \(pgItManager)")
                            plantEntity.pgItManager = pgItManager
                        }
                        if let regionItManager = props?["Region IT Manager"] as? String {
                            print("regionItManager: \(regionItManager)")
                            plantEntity.regionITManager = regionItManager
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        print("finished")
        self.saveContext()
    }

/*
    func removeSpecialCharsFromString(text: String) -> String {
        let replace0 = text.replacingOccurrences(of: "\\\"", with: "\"")
        let replace = replace0.replacingOccurrences(of: "\\", with: "")
         //\"\t
        print(replace)
        return replace
        
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_{}[]\"".characters)
        return String(text.characters.filter {okayChars.contains($0) })
        
    }
    
    - (NSString *)stringByRemovingControlCharacters: (NSString *)inputString
    {
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    NSRange range = [inputString rangeOfCharacterFromSet:controlChars];
    if (range.location != NSNotFound) {
    NSMutableString *mutable = [NSMutableString stringWithString:inputString];
    while (range.location != NSNotFound) {
    [mutable deleteCharactersInRange:range];
    range = [mutable rangeOfCharacterFromSet:controlChars];
    }
    return mutable;
    }
    return inputString;
    }
*/
    public func createResources()->Void {
        if self.fetchedResource().count > 0 {
            return;
        }
        let managedContext = self.getManagedContext()
        self.importJuliesReports()
        
        //fetchCompanyEntity
        let theCompanyEntity :[CompanyEntity] = fetchTheCompany()
        var myCompanyEntity : CompanyEntity?
        if theCompanyEntity.count > 0 {
            myCompanyEntity = theCompanyEntity[0]
        }
        /*
        let companyEntity:CompanyEntity = NSEntityDescription.insertNewObject(forEntityName: "CompanyEntity", into: managedContext) as! CompanyEntity
        companyEntity.domain = "adient.com"
        //companyEntity.headquartersId
        companyEntity.name = "Adient"
        companyEntity.id   = 1
        companyEntity.imDomain = "adient.com"
        companyEntity.phoneNumber = "630 209 7542"
        companyEntity.url  = "adient.com"
        companyEntity.stockSymbol = "ADNT"
        */
        var myAddressEntity1 : AddressEntity?
        var myPlymouthAddressEntity1 : AddressEntity?
        var myHelmAddressEntity1 : AddressEntity?
        var myMilwaukeeAddressEntity1 : AddressEntity?
        var myDigitalOfficeDepartment : DepartmentEntity?

        
        if let existingAddressEntity = fetchAddress(streetAddress: "727 South Waverly Road", cityAddress: "Holland") {
            myAddressEntity1 = existingAddressEntity
            myAddressEntity1?.gpsLatitude  = 42.7663572
            myAddressEntity1?.gpsLongitude = -86.0571885
            myAddressEntity1?.gpsRadius    = 600.0
            myAddressEntity1?.postalCode   = "49423"
        }else {
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
            myAddressEntity1 = addressEntity1
        }
        
        if let existingAddressEntity = fetchAddress(streetAddress: "49200 Halyard Drive", cityAddress: "Plymouth") {
            myPlymouthAddressEntity1 = existingAddressEntity
            myPlymouthAddressEntity1?.gpsLatitude  = 42.3853165
            myPlymouthAddressEntity1?.gpsLongitude = -83.5293167
            myPlymouthAddressEntity1?.gpsRadius    = 400.0
            myPlymouthAddressEntity1?.postalCode   = "48170"
        }else {
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
            myPlymouthAddressEntity1 = plymouthAddressEntity1
        }

        if let existingAddressEntity = fetchAddress(streetAddress: "45000 Helm St", cityAddress: "Plymouth") {
            myHelmAddressEntity1 = existingAddressEntity
            myHelmAddressEntity1?.gpsLatitude  = 42.3926075
            myHelmAddressEntity1?.gpsLongitude = -83.4905251
            myHelmAddressEntity1?.gpsRadius    = 200.0
            myHelmAddressEntity1?.postalCode   = "48170"
        }else {
            let helmAddressEntity1:AddressEntity = NSEntityDescription.insertNewObject(forEntityName: "AddressEntity", into: managedContext) as! AddressEntity
            helmAddressEntity1.city = "Plymouth"
            helmAddressEntity1.countryCode  = "US"
            helmAddressEntity1.gpsAltitude  = 0.0
            helmAddressEntity1.gpsLatitude  = 42.3926075
            helmAddressEntity1.gpsLongitude = -83.4905251
            helmAddressEntity1.gpsRadius    = 200.0
            helmAddressEntity1.postalCode   = "48170"
            helmAddressEntity1.stateOrProvince = "MI"
            helmAddressEntity1.streetName1   = "45000 Helm St"//734-254-5000 site general number
            myHelmAddressEntity1 = helmAddressEntity1
        }
        
        if let existingAddressEntity = fetchAddress(streetAddress: "833 E Michigan Street", cityAddress: "Milwaukee") {
            myMilwaukeeAddressEntity1 = existingAddressEntity
            myMilwaukeeAddressEntity1?.gpsLatitude  = 43.037536
            myMilwaukeeAddressEntity1?.gpsLongitude = -87.9029545
            myMilwaukeeAddressEntity1?.gpsRadius    = 400.0
            myMilwaukeeAddressEntity1?.postalCode   = "53202"

        }else {
            let milwaukeeAddressEntity1:AddressEntity = NSEntityDescription.insertNewObject(forEntityName: "AddressEntity", into: managedContext) as! AddressEntity
            milwaukeeAddressEntity1.city = "Milwaukee"
            milwaukeeAddressEntity1.countryCode  = "US"
            milwaukeeAddressEntity1.gpsAltitude  = 0.0
            milwaukeeAddressEntity1.gpsLatitude  = 43.037536
            milwaukeeAddressEntity1.gpsLongitude = -87.9029545
            milwaukeeAddressEntity1.gpsRadius    = 400.0
            milwaukeeAddressEntity1.postalCode   = "53202"
            milwaukeeAddressEntity1.stateOrProvince = "WI"
            milwaukeeAddressEntity1.streetName1   = "833 E Michigan Street"//734-254-5000 site general number
            myMilwaukeeAddressEntity1 = milwaukeeAddressEntity1
        }
        
        let resourceCategory0:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        resourceCategory0.id = 1050
        resourceCategory0.name = "Holland Customer Center"
        resourceCategory0.type = "building"
        resourceCategory0.locations = myAddressEntity1
        
        let plymouthCategory:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        plymouthCategory.id = 1000
        plymouthCategory.name = "Central Tech Unit Plymouth MI"
        plymouthCategory.type = "building"
        plymouthCategory.locations = myPlymouthAddressEntity1

        let wisconsinCategory:ResourceCategoryEntity = NSEntityDescription.insertNewObject(forEntityName: "ResourceCategoryEntity", into: managedContext) as! ResourceCategoryEntity
        wisconsinCategory.id = 2000
        wisconsinCategory.name = "Adient Milwaukee Corp Office"
        wisconsinCategory.type = "building"
        wisconsinCategory.locations = myMilwaukeeAddressEntity1

        
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
        
        let addressEntityRC1 = myAddressEntity1
    /*
        let addressEntityRC1:AddressEntity = NSEntityDescription.insertNewObject(forEntityName: "AddressEntity", into: managedContext) as! AddressEntity
        addressEntityRC1.city = "Holland"
        addressEntityRC1.countryCode  = "US"
        addressEntityRC1.gpsAltitude  = 0.0
        addressEntityRC1.postalCode   = "49423"
        addressEntityRC1.stateOrProvince = "Michigan"
        addressEntityRC1.streetName1   = "727 South Waverly Road"
    */
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
        //for some reason this isn't getting populated below....
        resourceConferenceRoom2.location = addressEntityRC1
        resourceConferenceRoom2.location?.gpsLatitude = 42.771192
        resourceConferenceRoom2.location?.gpsLongitude = -86.071312
        resourceConferenceRoom2.location?.gpsRadius = 25 //meters
        resourceConferenceRoom2.company = myCompanyEntity

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
        resourceConferenceRoom3.company = myCompanyEntity

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
        resourceConferenceRoom4.company = myCompanyEntity

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
        resourceConferenceRoom5.company = myCompanyEntity

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
        resourceConferenceRoom6.company = myCompanyEntity

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

    /*
        let kevinEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let harshaEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let sangaEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
        let peteEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
    */

        var myBruceEntity : PeopleEntity?
        if let theBruceEntity = fetchEmployeeId(employeeId: "bruce.mcdonald@adient.com") {
            theBruceEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "bruce.mcdonald", ofType: "jpg")!)
            theBruceEntity.imName       = "sip:bruce.mcdonald@adient.com"
            theBruceEntity.profileUrl   = "https://mysite.adient.com/person.aspx/?user=bruce.mcdonald%40adient.com"
            myBruceEntity = theBruceEntity
            theBruceEntity.reportsToId  = "boardOfDirectors@adient.com"
        }else {
            let bruceEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
            
            bruceEntity.globalUserId = "amcdonaldb"
            bruceEntity.employeeId   = "bruce.mcdonald@adient.com"
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
            bruceEntity.company       = myCompanyEntity
            bruceEntity.theirAddress  = myMilwaukeeAddressEntity1
            bruceEntity.reportsToId  = "boardOfDirectors@adient.com"
            myBruceEntity = bruceEntity
        }
        if let bruceDepartment = fetchDepartment(departmentName: "Adient Office of the CEO"){
            bruceDepartment.headReportsToId = "0"
            bruceDepartment.departmentHeadId = "bruce.mcdonald@adient.com"
            myBruceEntity?.theirDepartment = bruceDepartment

        }else {
            let departmentEntity:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
            departmentEntity.departmentName = "Adient Office of the CEO"
            departmentEntity.headReportsToId = "0"
            departmentEntity.departmentHeadId = "bruce.mcdonald@adient.com"
            departmentEntity.departmentId = 6
            myBruceEntity?.theirDepartment = departmentEntity
        }

        var mySherylEntity : PeopleEntity?
        if let theSherylEntity = fetchEmployeeId(employeeId: "sheryl.l.haislet@adient.com") {
            theSherylEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "sheryl.haislet", ofType: "jpg")!)
            theSherylEntity.imName       = "sip:sheryl.l.haislet@adient.com"
            theSherylEntity.profileUrl    = "https://mysite.adient.com/person.aspx/?user=sheryl.l.haislet%40adient.com"
            theSherylEntity.reportsToId   = "bruce.mcdonald@adient.com"
            mySherylEntity = theSherylEntity
        }else {
            let sherylEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
            sherylEntity.globalUserId = "ahaislets"
            sherylEntity.employeeId   = "sheryl.l.haislet@adient.com"
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
            sherylEntity.company       = myCompanyEntity
            sherylEntity.theirAddress  = myPlymouthAddressEntity1
            sherylEntity.reportsToId   = "bruce.mcdonald@adient.com"
            mySherylEntity = sherylEntity
        }
        if let sherylDepartment = fetchDepartment(departmentName: "Adient - Office of CIO"){
            sherylDepartment.headReportsToId = "bruce.mcdonald@adient.com"
            sherylDepartment.departmentHeadId = "sheryl.l.haislet@adient.com"
            mySherylEntity?.theirDepartment = sherylDepartment
            
        }else {
            let departmentEntity:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
            departmentEntity.departmentName = "Adient - Office of CIO"
            departmentEntity.headReportsToId = "bruce.mcdonald@adient.com"
            departmentEntity.departmentHeadId = "sheryl.l.haislet@adient.com"
            departmentEntity.departmentId = 6
            mySherylEntity?.theirDepartment = departmentEntity
        }

        
        var myJulieEntity : PeopleEntity?
        if let theJulieEntity = fetchEmployeeId(employeeId: "julie.ragland@adient.com") {
            theJulieEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "julie.ragland", ofType: "jpg")!)
            theJulieEntity.imName       = "sip:julie.ragland@adient.com"
            theJulieEntity.profileUrl    = "https://mysite.adient.com/person.aspx/?user=julie.ragland%40adient.com"
            theJulieEntity.company       = myCompanyEntity
            theJulieEntity.theirAddress  = myMilwaukeeAddressEntity1
            theJulieEntity.reportsToId   = "sheryl.l.haislet@adient.com"
            myJulieEntity = theJulieEntity
        }else {
            let julieEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
            julieEntity.globalUserId = "araglandj"
            julieEntity.employeeId   = "julie.ragland@adient.com"
            julieEntity.lastname     = "Ragland"
            julieEntity.firstname    = "Julie"
            julieEntity.middlename   = ""
            julieEntity.email        = "julie.ragland@adient.com"
            julieEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "julie.ragland", ofType: "jpg")!)
            julieEntity.deskphone    = "+14142208986"
            julieEntity.mobilephone  = "+14145261426"
            julieEntity.imName       = "sip:julie.ragland@adient.com"
            julieEntity.title         = "VP Corporate Applications"
            julieEntity.profileUrl    = "https://mysite.adient.com/person.aspx/?user=julie.ragland%40adient.com"
            julieEntity.reportsToId   = "sheryl.l.haislet@adient.com"
            julieEntity.company       = myCompanyEntity
            julieEntity.theirAddress  = myMilwaukeeAddressEntity1
            myJulieEntity = julieEntity
        }
        if let julieDepartment = fetchDepartment(departmentName: "Adient Mgt Glen"){
            julieDepartment.headReportsToId = "sheryl.l.haislet@adient.com"
            julieDepartment.departmentHeadId = "julie.ragland@adient.com"
            myJulieEntity?.theirDepartment = julieDepartment
            
        }else {
            let departmentEntity:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
            departmentEntity.departmentName = "Adient Mgt Glen"
            departmentEntity.headReportsToId = "sheryl.l.haislet@adient.com"
            departmentEntity.departmentHeadId = "julie.ragland@adient.com"
            departmentEntity.departmentId = 6
            myJulieEntity?.theirDepartment = departmentEntity
        }

        var myShobitaEntity : PeopleEntity?
        if let theShobitaEntity = fetchEmployeeId(employeeId: "shobhita.saxena@adient.com") {
            theShobitaEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "shobita.saxena", ofType: "jpg")!)
            theShobitaEntity.imName       = "sip:shobhita.saxena@adient.com"
            theShobitaEntity.profileUrl    = "https://mysite.adient.com/person.aspx/?user=sheryl.l.haislet%40adient.com"
            theShobitaEntity.reportsToId   = "julie.ragland@adient.com"
            myShobitaEntity = theShobitaEntity
        }else {
            let shobitaEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
            shobitaEntity.globalUserId = "ashobitas"
            shobitaEntity.employeeId   = "shobhita.saxena@adient.com"
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
            shobitaEntity.reportsToId   = "julie.ragland@adient.com"
            shobitaEntity.company       = myCompanyEntity
            shobitaEntity.theirAddress  = myHelmAddressEntity1
            myShobitaEntity = shobitaEntity
        }

        
        if let theDepartmentEntity = fetchDepartment(departmentName: "AP-Adient-IT-CTU 08") {
            theDepartmentEntity.headReportsToId = "julie.ragland@adient.com"
            theDepartmentEntity.departmentHeadId = "shobhita.saxena@adient.com"
            myShobitaEntity?.theirDepartment = theDepartmentEntity
        }else {
            let shobitaDepartmentEntity:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
            shobitaDepartmentEntity.departmentName = "AP-Adient-IT-CTU 08"
            shobitaDepartmentEntity.headReportsToId = "julie.ragland@adient.com"
            shobitaDepartmentEntity.departmentHeadId = "shobhita.saxena@adient.com"
            shobitaDepartmentEntity.departmentId = 5
            myShobitaEntity?.theirDepartment = shobitaDepartmentEntity
        }

        var mySarahEntity : PeopleEntity?
        if let theSarahEntity = fetchEmployeeId(employeeId: "sarah.a.hendrixson@adient.com") {
            theSarahEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "sarah.hendrixson", ofType: "jpg")!)
            theSarahEntity.imName       = "sip:sarah.a.hendrixson@adient.com"
            theSarahEntity.profileUrl    = "hhttps://mysite.adient.com/person.aspx/?user=sarah.a.hendrixson%40adient.com"
            theSarahEntity.reportsToId   = "shobhita.saxena@adient.com"
            theSarahEntity.company       = myCompanyEntity
            theSarahEntity.theirAddress  = myAddressEntity1
            mySarahEntity = theSarahEntity
        }else {
            let sarahEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
            sarahEntity.globalUserId = "ahendrixsons"
            sarahEntity.employeeId   = "40"
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
            sarahEntity.reportsToId   = "shobhita.saxena@adient.com"
            sarahEntity.company       = myCompanyEntity
            sarahEntity.theirAddress  = myAddressEntity1
            mySarahEntity = sarahEntity
        }
        
        if let theDepartmentEntity = fetchDepartment(departmentName: "AP-Supp-CTU-Ply-IT App Mgmt") {
            theDepartmentEntity.headReportsToId = "shobhita.saxena@adient.com"
            theDepartmentEntity.departmentHeadId = "sarah.a.hendrixson@adient.com"
            mySarahEntity?.theirDepartment = theDepartmentEntity
        }else {
            let departmentEntity:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
            departmentEntity.departmentName = "AP-Supp-CTU-Ply-IT App Mgmt"
            departmentEntity.headReportsToId = "shobhita.saxena@adient.com"
            departmentEntity.departmentHeadId = "sarah.a.hendrixson@adient.com"
            departmentEntity.departmentId = 5
            mySarahEntity?.theirDepartment = departmentEntity
        }

        var myMikeChabotPeopleEntity : PeopleEntity?
        
        if let theMikeChabotPeopleEntity = fetchEmployeeId(employeeId:"mike.chabot@adient.com") {
            theMikeChabotPeopleEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "mike.chabot", ofType: "jpg")!)
            theMikeChabotPeopleEntity.imName       = "sip:mike.chabot@adient.com"
            theMikeChabotPeopleEntity.profileUrl   = "https://mysite.adient.com/person.aspx/?user=mike.chabot%40adient.com"
            theMikeChabotPeopleEntity.reportsToId  = "randall.j.urban@adient.com"
            theMikeChabotPeopleEntity.theirAddress = myAddressEntity1
            theMikeChabotPeopleEntity.company      = myCompanyEntity
            
        } else {
            let mikeEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
            mikeEntity.globalUserId = "achabotm"
            mikeEntity.employeeId   = "21"
            mikeEntity.lastname     = "Chabot"
            mikeEntity.firstname    = "Mike"
            mikeEntity.middlename   = "M"
            mikeEntity.email        = "mike.chabot@adient.com"
            mikeEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "mike.chabot", ofType: "jpg")!)
            mikeEntity.deskphone    = "+16163942516"
            mikeEntity.mobilephone  = "+16162183730"
            mikeEntity.imName       = "sip:mike.chabot@adient.com"
            mikeEntity.title         = "Dir Solutions Delivery Srvcs"
            mikeEntity.profileUrl    = "https://mysite.adient.com/person.aspx/?user=mike.chabot%40adient.com"
            mikeEntity.company       = myCompanyEntity
            mikeEntity.reportsToId   = "randall.j.urban@adient.com"
            mikeEntity.theirAddress    = myAddressEntity1

        }
        if let theDigitalOffice = fetchDepartment(departmentName: "IT Digital Office") {
            theDigitalOffice.departmentHeadId  = "randall.j.urban@adient.com"
            theDigitalOffice.headReportsToId   = "sheryl.l.haislet@adient.com"  //randy reports
            myDigitalOfficeDepartment = theDigitalOffice
        }else {
            let departmentEntity:DepartmentEntity = NSEntityDescription.insertNewObject(forEntityName: "DepartmentEntity", into: managedContext) as! DepartmentEntity
            
            departmentEntity.departmentName    = "IT Digital Office"
            departmentEntity.departmentHeadId  = "randall.j.urban@adient.com"
            departmentEntity.headReportsToId   = "sheryl.l.haislet@adient.com"  //randy reports to sheryl
            departmentEntity.departmentId = 1
            myDigitalOfficeDepartment = departmentEntity
        }
        myMikeChabotPeopleEntity?.theirDepartment = myDigitalOfficeDepartment

        var myRandallPeopleEntity : PeopleEntity?
        if let theRandallUrbanPeopleEntity = fetchEmployeeId(employeeId:"randall.j.urban@adient.com") {
            theRandallUrbanPeopleEntity.imName       = "sip:randall.j.urban@adient.com"
            theRandallUrbanPeopleEntity.profileUrl   = "https://mysite.adient.com/person.aspx/?user=randall.j.urban%40adient.com"
            theRandallUrbanPeopleEntity.reportsToId  = "sheryl.l.haislet@adient.com"
            theRandallUrbanPeopleEntity.company      = myCompanyEntity
            theRandallUrbanPeopleEntity.theirAddress = myHelmAddressEntity1
            myRandallPeopleEntity = theRandallUrbanPeopleEntity
            
        }else {
            let randallEntity:PeopleEntity = NSEntityDescription.insertNewObject(forEntityName: "PeopleEntity", into: managedContext) as! PeopleEntity
            randallEntity.employeeId   = "randall.j.urban@adient.com"
            randallEntity.globalUserId = "aurbanr"
            randallEntity.picture      = NSData(contentsOfFile: Bundle.main.path(forResource: "randy.urban", ofType: "jpg")!)
            randallEntity.email        = "randall.j.urban@adient.com"
            randallEntity.firstname    = "Randall"
            randallEntity.middlename   = "J"
            randallEntity.lastname     = "Urban"
            randallEntity.title        = "VP Digital Office"
            randallEntity.deskphone    = "+17342546613"
            randallEntity.mobilephone  = "+17344175548"
            randallEntity.imName       = "sip:randall.j.urban@adient.com"
            randallEntity.profileUrl   = "https://mysite.adient.com/person.aspx/?user=randall.j.urban%40adient.com"
            randallEntity.reportsToId  = "sheryl.l.haislet@adient.com"
            randallEntity.company      = myCompanyEntity
            randallEntity.theirAddress = myHelmAddressEntity1
            myRandallPeopleEntity      = randallEntity
        }
        myRandallPeopleEntity?.theirDepartment = myDigitalOfficeDepartment
        
        self.importPlants()
        self.saveContext()
        return
    }

}

extension Data {
    var string: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}
extension String {
    var data: Data {
        return Data(utf8)
    }
    var base64Decoded: Data? {
        return Data(base64Encoded: self)
    }
}

