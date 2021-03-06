//
//  AppDelegate.swift
//  GeoTargeting
//
//  Created by Eugene Trapeznikov on 4/23/16.
//  Copyright © 2016 Evgenii Trapeznikov. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

	var window: UIWindow?
//    let reachability = Reachability();
     private var reachability:Reachability!;

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
                if((error == nil)) {
                    print("Request authorization failed!")
                } else {
                    print("Request authorization succeeded!")
//                    self.showAlert()
                }
            }
        } else {
            // Fallback on earlier versions
        }

        
        FIRApp.configure()
		// Override point for customization after application launch.
        
//        NotificationCenter.default.addObserver(self, selector:Selector(("checkForReachability:")), name: NSNotification.Name.reachabilityChanged, object: nil)
//        let reachability: Reachability = Reachability.forInternetConnection()
//        reachability.startNotifier()
        
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
	}

//    func checkForReachability(notification:NSNotification)
//    {
//        // Remove the next two lines of code. You cannot instantiate the object
//        // you want to receive notifications from inside of the notification
//        // handler that is meant for the notifications it emits.
//
//        //var networkReachability = Reachability.reachabilityForInternetConnection()
//        //networkReachability.startNotifier()
//
//        let networkReachability = notification.object as Reachability;
//        var remoteHostStatus = networkReachability.currentReachabilityStatus()
//
//        if (remoteHostStatus.value == NotReachable.value)
//        {
//            println("Not Reachable")
//        }
//        else if (remoteHostStatus.value == ReachableViaWiFi.value)
//        {
//            println("Reachable via Wifi")
//        }
//        else
//        {
//            println("Reachable")
//        }
//    }

}

