//
//  AppDelegate.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/9/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging
import Stripe
import BRYXBanner

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var banner: Banner?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google auth
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        //STPPaymentConfiguration.shared().publishableKey = "pk_test_XXhtxu1S44u1en0gH6ozoB7t"
        STPPaymentConfiguration.shared().publishableKey = "pk_live_qgUYywOaOSnKHZvAUSrbaDch"
        //"pk_test_6pRNASCoBOKtIshFeQd4XMUh"
        
        // maybe I need to do this in Home View, seems like it doesn't like it when user isn't logged in
//        CategoriesManager.sharedInstance
        
//        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
//        let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
//        application.registerForRemoteNotifications()
//        application.registerUserNotificationSettings(notificationSettings)
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FIRApp.configure()
        
        // [START add_token_refresh_observer]
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        // [END add_token_refresh_observer]
  
//        application.setMinimumBackgroundFetchInterval(60*15) // every 15 min
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let absoluteString = url.absoluteString
        if absoluteString.hasPrefix("fb") { // facebook
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        else  { // google, make this else if
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(
            application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return googleDidHandle || facebookDidHandle
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        FBSDKAppEvents.activateApp()
    }

//    func applicationDidEnterBackground(_ application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

//    func applicationDidBecomeActive(_ application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        FBSDKAppEvents.activateApp()
//    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        print("MessageID: \(userInfo["gcm_message_id"])")
//        print(userInfo)
//    }

    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
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
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        let title = userInfo["title"] as! String
        let message = userInfo["message"] as! String
        
//        print("title: \(title) message: \(message)")
        banner = Banner(title: title, subtitle: message, image: nil, backgroundColor: UIColor.nbGreen)
        banner?.dismissesOnTap = true
        banner?.show(duration: 3.0)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    // [START connect_to_fcm]
    func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
//        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
        
//        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.prod)
    }
    
    // [START connect_on_active]
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
        print("application did become active")
        NewAccountManager.sharedInstance.signInSilently()
    }
    
    // [END connect_on_active]
    // [START disconnect_from_fcm]
    func applicationDidEnterBackground(_ application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        
        application.setMinimumBackgroundFetchInterval(60*15) // every 15 min
//        application.setMinimumBackgroundFetchInterval(60*5) // every 5 min
    }
    // [END disconnect_from_fcm]
    
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let location = LocationManager.sharedInstance.location else {
            print("No location available")
            return
        }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        NBRequest.fetchNotifications(latitude, longitude: longitude) { message in
            print("message: \(message)")
            
            if message != "No Message" {
                if #available(iOS 10.0, *) {
                    let content = UNMutableNotificationContent()
                    content.title = NSString.localizedUserNotificationString(forKey: "Nearby:", arguments: nil)
                    content.body = NSString.localizedUserNotificationString(forKey: message, arguments: nil)
                    content.sound = UNNotificationSound.default()
//                    content.badge = UIApplication.shared.applicationIconBadgeNumber + 1;
                    content.categoryIdentifier = "com.iuxtainc.nearby"
                    // Deliver the notification in five seconds.
                    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
                    let request = UNNotificationRequest.init(identifier: "OneSecond", content: content, trigger: trigger)
                    
                    // Schedule the notification.
                    let center = UNUserNotificationCenter.current()
                    center.add(request)
                }
                else {
                    let localNotification = UILocalNotification()
                    localNotification.fireDate = Date().addingTimeInterval(1)
                    localNotification.alertBody = message
                    localNotification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.shared.scheduleLocalNotification(localNotification)
                }
            
                completionHandler(UIBackgroundFetchResult.noData)
            }
        }
        completionHandler(UIBackgroundFetchResult.noData)
    }
}


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        var title = "";
        if userInfo["title"] != nil {
           title = userInfo["title"] as! String
        }
        if userInfo["message"] != nil {
            let message = userInfo["message"] as! String
            banner = Banner(title: title, subtitle: message, image: nil, backgroundColor:         UIColor.nbGreen)
            banner?.dismissesOnTap = true
            banner?.show(duration: 3.0)
        }
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        var title = "";
        if userInfo["title"] != nil {
            title = userInfo["title"] as! String
        }
        if let message = userInfo["message"] as? String {
            banner = Banner(title: title, subtitle: message, image: nil, backgroundColor:         UIColor.nbGreen)
            banner?.dismissesOnTap = true
            banner?.show(duration: 3.0)
        }

        completionHandler()
    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print(remoteMessage.appData)
        
        let title = remoteMessage.appData["title"] as? String
        if let message = remoteMessage.appData["message"] as? String {
            banner = Banner(title: title, subtitle: message, image: nil, backgroundColor:         UIColor.nbGreen)
            banner?.dismissesOnTap = true
            banner?.show(duration: 3.0)
        }
    }
}
