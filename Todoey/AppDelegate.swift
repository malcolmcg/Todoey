//
//  AppDelegate.swift
//  Todoey
//
//  Created by Malcolm Shuttleworth on 23/12/2018.
//  Copyright © 2018 Malcolm Shuttleworth. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // print (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)  // prints the location of the app data on the device or simulator... it's long
        
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        // Realm example
/*        let data = Data()
        data.name = "a name"
        data.age = 22 */
        
        do {
            _ = try Realm()
        }
        catch {
            print("Error initialising new Realm \(error)")
        }
        return true
    }
}

