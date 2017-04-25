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


}

