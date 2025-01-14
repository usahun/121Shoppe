//
//  AppDelegate.swift
//  VSMS
//
//  Created by Vuthy Tep on 2/22/19.
//  Copyright © 2019 121. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SideMenuSwift
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder,
                   UIApplicationDelegate,
                   CLLocationManagerDelegate,
                   LocationServiceDelegate,
                   UNUserNotificationCenterDelegate,
                   MessagingDelegate{
   
    
    var locationservice = LocationService.sharedInstance
    var window: UIWindow?
    var InstantID: String = ""
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        //Config Firebase
        if #available(iOS 3.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        FirebaseApp.configure()

        ///get InstantID
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                self.InstantID = result.token
            }
        }

        //Config Facebook
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Google API Key
        GMSServices.provideAPIKey("AIzaSyCnzDhy4WqYYUBp6NnctYHfxxUdJmJeF-I")
        GMSPlacesClient.provideAPIKey("AIzaSyCnzDhy4WqYYUBp6NnctYHfxxUdJmJeF-I")
        
        //Start up with Slide Menu
        //day-13-08-2019
//        let contentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SideMenu") as! MyNavigation
//
//        let menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "leftMenu") as! MenuViewController
//        menuViewController.delegate = contentViewController
//
//        let sideMenuController = SideMenuController(contentViewController: contentViewController, menuViewController: menuViewController)
           let contentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
        self.window?.rootViewController = contentViewController
        self.window?.makeKeyAndVisible()

        //////////////////
        
       
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func tracingLocation(currentLocation: CLLocation) {
        locationservice.lastLocation = currentLocation
    }
    
    func tracingLocationDidFailWithError(error: Error) {
        
    }

    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    

    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      print("APNs token retrieved: \(deviceToken)")

      // With swizzling disabled you must set the APNs token here.
      // Messaging.messaging().apnsToken = deviceToken
    }
}

//
//// [START ios_10_message_handling]
//@available(iOS 10, *)
//extension AppDelegate : UNUserNotificationCenterDelegate {
//
//  // Receive displayed notifications for iOS 10 devices.
//  func userNotificationCenter(_ center: UNUserNotificationCenter,
//                              willPresent notification: UNNotification,
//    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//    let userInfo = notification.request.content.userInfo
//
//    // With swizzling disabled you must let Messaging know about the message, for Analytics
//    // Messaging.messaging().appDidReceiveMessage(userInfo)
//
//    // Print message ID.
//    if let messageID = userInfo[gcmMessageIDKey] {
//      print("Message ID: \(messageID)")
//    }
//
//    // Print full message.
//    print(userInfo)
//
//    // Change this to your preferred presentation option
//    completionHandler([])
//  }
//
//  func userNotificationCenter(_ center: UNUserNotificationCenter,
//                              didReceive response: UNNotificationResponse,
//                              withCompletionHandler completionHandler: @escaping () -> Void) {
//    let userInfo = response.notification.request.content.userInfo
//    // Print message ID.
//    if let messageID = userInfo[gcmMessageIDKey] {
//      print("Message ID: \(messageID)")
//    }
//
//    // Print full message.
//    print(userInfo)
//
//    completionHandler()
//  }
//}
//// [END ios_10_message_handling]
//
//
//extension AppDelegate : MessagingDelegate {
//  // [START refresh_token]
//  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//    print("Firebase registration token: \(fcmToken)")
//    
//    let dataDict:[String: String] = ["token": fcmToken]
//    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
//    // TODO: If necessary send token to application server.
//    // Note: This callback is fired at each app startup and whenever a new token is generated.
//  }
//  // [END refresh_token]
//
//  // [START ios_10_data_message]
//  // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
//  // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
//  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//    print("Received data message: \(remoteMessage.appData)")
//  }
//  // [END ios_10_data_message]
//}

