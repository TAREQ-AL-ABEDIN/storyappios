//
//  AppDelegate.swift
//  BaseProject
//
//  Created by Admin on 9/27/17.
//  Copyright © 2017 Annanovas IT Ltd. All rights reserved.
//

import UIKit
import CoreData
import FBSDKLoginKit
import SystemConfiguration
import GoogleMobileAds

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let prefs = UserDefaults.standard

let coreDataFileName = "StoryApp"
let googleApiKey = "AIzaSyDRAEgAHgH_ZGnIrTZxGVUE-Y8LigHVrnI"
let baseUrl = "http://www.techmaticbd.com/textstory/public/api"
let imageUrl = "http://www.techmaticbd.com/textstory/public/categoryImage/"
let storyImagePath = "http://www.techmaticbd.com/textstory/public/storyImage/"
let authkey = "TS.online.app"

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE            = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
    static let IS_IPHONE_XR         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 896.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO_9_7      = IS_IPAD
    static let IS_IPAD_PRO_12_9     = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}

struct Version{
    static let SYS_VERSION_FLOAT = (UIDevice.current.systemVersion as NSString).floatValue
    static let iOS7 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
    static let iOS8 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
    static let iOS9 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
    static let iOS10 = (Version.SYS_VERSION_FLOAT >= 10.0 && Version.SYS_VERSION_FLOAT < 11.0)
}

struct FontWeight{
    static let IPHONE_X_FONTWEIGHT = CGFloat(1.0)
    static let IPHONE_6_FONTWEIGHT = CGFloat(0.93)
    static let IPHONE_6P_FONTWEIGHT = CGFloat(1.0)
    static let IPHONE_5_FONTWEIGHT = CGFloat(0.87)
    static let IPHONE_4_OR_LESS = CGFloat(0.9)
}

extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        
        if vc.isKind(of: UINavigationController.self) {
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom( vc: navigationController.visibleViewController!)
            
        } else if vc.isKind(of: UITabBarController.self) {
            
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)
            
        } else {
            
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController.presentedViewController!)
                
            } else {
                return vc;
            }
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,VungleSDKDelegate {

    var window: UIWindow?
    var storyBoard: UIStoryboard?
    
    var drawerViewController: LeftMenuViewController?
    var drawerController: KYDrawerController?
    
    var hvc:HomeViewController?
    var rootVC:RootViewController?
    var noConnectionVC:NoConnectionViewController?
    
    var currentNaviCon: UINavigationController?
    var previousNaviCon: UINavigationController? = nil
    var naviCon: UINavigationController?
    var rootNaviCon: UINavigationController? = nil
    var removeAddsNaviCon: UINavigationController? = nil
    var aboutNaviCon: UINavigationController? = nil
    var settingNaviCon: UINavigationController? = nil
    
    var myServerSyncDB : FMDatabaseQueue?
    var serverDataSync : SyncServerData = SyncServerData.sharedInstance
    var localDataSync : SyncLocalData = SyncLocalData ()
    
    var commonSync : CommonDataSync = CommonDataSync.sharedInstance
    var storiesListDataSync : StoriesListDataSync = StoriesListDataSync.sharedInstance
    var storiesDetailsDataSync : StoriesDetailsDataSync = StoriesDetailsDataSync.sharedInstance
    
    var loadingView: UIView!
    
    var isSetting_flag:Int = 0
    
    let vungle_placement_id = "DEFAULT-2331611"
    var isPlayable : Bool = false
    var bannerView: GADBannerView!
    
    let admob_appID = "ca-app-pub-4806809135067780~7012178951"
    let admob_app_banner_unitID = "ca-app-pub-4806809135067780/8488912151"
    let admob_app_inters_unitID = "ca-app-pub-4806809135067780/3821704403"

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UIApplication.shared.isStatusBarHidden = true
        window?.backgroundColor = UIColor.white
        
        self.initializeVungle()
        
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_6P{
            self.storyBoard = getStoryBoard(name: "Main-iPhone5")
        }
        else if DeviceType.IS_IPHONE_X || DeviceType.IS_IPHONE_XR{
            self.storyBoard = getStoryBoard(name: "Main-iPhoneX")
        }
        else{
           self.storyBoard = getStoryBoard(name: "Main-iPhone5")
        }
        
        if (prefs.value(forKey: "file_merged") == nil || !(prefs.value(forKey: "file_merged") as! String == "YES")) {
            self.copyDatabaseFile()
        }
        
        let dbPath: String = getPath(fileName:("\(coreDataFileName).sqlite"))
        self.myServerSyncDB = FMDatabaseQueue(path: dbPath)
        
        //self.goToLoginView()
        //self.createViewDeck()
        self.showRootView()
        self.setupLoadingView()
        
        self.noConnectionVC = storyBoard?.instantiateViewController(withIdentifier: "NoConnectionViewController") as? NoConnectionViewController
        self.noConnectionVC?.view.alpha = 0
        self.window?.addSubview((noConnectionVC?.view)!)
        
        GADMobileAds.configure(withApplicationID: admob_appID)
    
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.frame.origin.y = ScreenSize.SCREEN_HEIGHT - 100
        bannerView.backgroundColor = UIColor.red
        self.window!.addSubview(bannerView)
        self.window!.bringSubview(toFront: bannerView)
        
        bannerView.adUnitID = admob_app_banner_unitID
        bannerView.rootViewController = self.window?.rootViewController
        bannerView.load(GADRequest())

        return true
    }
    
    func initializeVungle(){
        let appID = "5c8152dd38bae442557b0e44";
        let placementIDsArray:Array<String> = ["DEFAULT-2331611", "UPHOOK-4550675"];
        
        let sdk:VungleSDK = VungleSDK.shared()
        do {
            try sdk.start(withAppId: appID, placements: placementIDsArray)
        }
        catch let error as NSError {
            print("Error while starting VungleSDK : \(error.domain)")
            return;
        }
        
        sdk.delegate = self
    }
    
    //MARK: - Vungle & adMob
    func vungleSDKDidInitialize() {
        print("vungleSDKDidInitialize")
        
        do {
            try VungleSDK.shared().loadPlacement(withID: vungle_placement_id)
        }
        catch let error as NSError {
            print("Unable to load placement with reference ID :\(vungle_placement_id), Error: \(error)")
            return
        }
    }
    
    func vungleAdPlayabilityUpdate(_ isAdPlayable: Bool, placementID: String?, error: Error?) {
        print("vungleAdPlayabilityUpdate")
        
        if (placementID == vungle_placement_id) {
            self.isPlayable = isAdPlayable;
        }
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
        if (prefs.value(forKey:"ageRestriction") != nil && (prefs.value(forKey:"ageRestriction") as! String == "YES")) {
            //self.requestForData()
        }
    }
    
    func requestForData(){
        commonSync.requestForCommonData()
        storiesListDataSync.requestForStoriesList()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    @objc func showRootView (){
        //Root View adjustment
        if (prefs.value(forKey:"ageRestriction") == nil || !(prefs.value(forKey:"ageRestriction") as! String == "YES")) {
            self.goToLoginView()
        }
        else{
            self.createViewDeck()
        }
    }
    
    @objc func createViewDeck() {
        
        if DeviceType.IS_IPAD{
            self.drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: 568.0)
        }
        else if DeviceType.IS_IPHONE_5{
            self.drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: 190.0)
        }
        else{
            self.drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: 190.0)
        }
        
        //storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        self.drawerViewController = storyBoard?.instantiateViewController(withIdentifier: "LeftMenuViewController") as? LeftMenuViewController
        
        self.drawerController?.drawerViewController = drawerViewController
        self.window?.rootViewController = drawerController
        self.window?.makeKeyAndVisible()
    }
    
    @objc func goToLoginView (){
        
        let arvc   = self.storyBoard?.instantiateViewController(withIdentifier: "AgeRestrictionViewController") as? AgeRestrictionViewController
        self.naviCon = UINavigationController(rootViewController: arvc!)
        
        naviCon?.setNavigationBarHidden(true, animated: false)
        naviCon?.setToolbarHidden(true, animated: false)
        
        self.currentNaviCon = self.naviCon
        self.currentNaviCon?.navigationBar.isHidden = true
        self.currentNaviCon?.toolbar.isHidden = true
        
        self.window?.rootViewController = self.currentNaviCon
        self.window?.makeKeyAndVisible()
    }
    
    func setupLoadingView (){
        
        let loadingframe: CGRect = UIScreen.main.bounds
        loadingView = UIView(frame: loadingframe)
        loadingView.backgroundColor = UIColor.clear
        loadingView.alpha = 0.0
        window?.addSubview(loadingView)
        
        let loadingBkImg = UIImageView()
        loadingBkImg.frame = loadingframe
        loadingBkImg.backgroundColor = UIColor.black
        loadingView.addSubview(loadingBkImg)
        loadingBkImg.alpha = 0.7
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.frame = CGRect(x: (loadingframe.size.width - 37) / 2, y: (loadingframe.size.height - 37) / 2, width: 37, height: 37)
        loadingView.addSubview(spinner)
        spinner.startAnimating()
    }
    
    func backToPreviousView(){
        
        //self.currentNaviCon?.popToRootViewController(animated: false)
        //self.previousNaviCon?.popToRootViewController(animated: false)
        
        DispatchQueue.main.async(execute: {
            appDelegate.currentNaviCon = appDelegate.previousNaviCon
            appDelegate.window?.bringSubview(toFront: (appDelegate.currentNaviCon?.view)!)
            appDelegate.drawerController?.mainViewController = appDelegate.currentNaviCon
            
            /*if let topController = appDelegate.currentNaviCon?.visibleViewController {
             
             if (topController.isKind(of: DashboardViewController.self)){
             (topController as! DashboardViewController).bringBottomViewToFront()
             }
             else if (topController.isKind(of: ScanViewController.self)){
             (topController as! ScanViewController).bringBottomViewToFront()
             }
             else if (topController.isKind(of: ContactViewController.self)){
             (topController as! ContactViewController).bringBottomViewToFront()
             }
             else if (topController.isKind(of: IndexViewController.self)){
             (topController as! IndexViewController).bringBottomViewToFront()
             }
             }*/
        })
    }
    
    // MARK: - Alert Methodes
    
    func showAlert(message: String, vc: UIViewController) -> Void
    {
        let alert = UIAlertController(title: "Alert",
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methodes
    
    func getStoryBoard(name : String)-> UIStoryboard
    {
        let stb = UIStoryboard(name: name, bundle: nil)
        return stb
    }
    
    func getPath(fileName: String) -> String {
        let pathsDocument = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let uniquePath = NSURL(fileURLWithPath: pathsDocument).appendingPathComponent(fileName)
        
        return (uniquePath?.path)!
    }
    
    func copyDatabaseFile() {
        
        let bundlePath = Bundle.main.path(forResource: coreDataFileName, ofType: ".sqlite")
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let fileManager = FileManager.default
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent("\(coreDataFileName).sqlite")
        let fullDestPathString = String(describing: fullDestPath)
        
        print(bundlePath ?? ">>>", "\n") //prints the correct path
        print(destPath , "\n") //prints the correct path
        print(fileManager.fileExists(atPath: bundlePath!)) // prints true
        print(fullDestPathString)
        
        do{
            try fileManager.copyItem(atPath: bundlePath!, toPath: (fullDestPath?.path)!)
            print("Load sqlite file")
            prefs.set("YES", forKey: "file_merged")
            prefs.synchronize()
        }catch{
            print("\n")
            print(error)
        }
    }
    
    func fileExistsInProject(fileName: String) -> Bool {
        let fileManager = FileManager.default
        let fileInResourcesFolder: String = URL(fileURLWithPath: (Bundle.main.resourcePath)!).appendingPathComponent(fileName).absoluteString
        return fileManager.fileExists(atPath: fileInResourcesFolder)
    }
    
    func fileExistsInDocumentsDirectory(fileName: String) -> Bool {
        let fileManager = FileManager.default
        let arrayPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path: String? = arrayPaths.first
        let imageFileName = NSURL(fileURLWithPath: path!).appendingPathComponent(fileName)
        
        //print("app.path : \(path)");
        //print("app.fileExistsInDocumentsDirectory : \(imageFileName?.path! as NSString)");
        
        return fileManager.fileExists(atPath: (imageFileName?.path)!)
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: coreDataFileName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    @available(iOS 10.0, *)
    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    @available(iOS 10.0, *)
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    @available(iOS 10.0, *)
    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.perform {
            block(self.viewContext)
        }
    }
    
    @available(iOS 10.0, *)
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer.performBackgroundTask(block)
    }

    // MARK: - No Internet Connection
    
    func noConnectedToNetwork() {
        // ViewControllers view ist fully loaded and could present further ViewController
        //Here you could do any other UI operations
        if Reachability.isConnectedToNetwork() == true
        {
            print("Connected")
        }
        else
        {
            ((appDelegate.noConnectionVC?.view)!).removeFromSuperview()
            appDelegate.window?.addSubview((appDelegate.noConnectionVC?.view)!)
            appDelegate.noConnectionVC?.view.alpha = 1
        }
        
    }
    public class Reachability {
        class func isConnectedToNetwork() -> Bool {
            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
                return false
            }
            let isReachable = flags == .reachable
            let needsConnection = flags == .connectionRequired
            return isReachable && !needsConnection
            
        }
    }

    // MARK: - Core Data Saving support

    func saveContext () {

        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }else {
            
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch let error as NSError {
                    print("Ops there was an error \(error.localizedDescription)")
                    abort()
                }
            }
            
        }
    }
    
    // Applications default directory address
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    lazy var managedObjectModel: NSManagedObjectModel = {

        let modelURL = Bundle.main.url(forResource: coreDataFileName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(coreDataFileName).sqlite")
        do {
            // If your looking for any kind of migration then here is the time to pass it to the options
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let  error as NSError {
            print("Ops there was an error \(error.localizedDescription)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }()
    
    lazy var allManagedObjectContext: NSManagedObjectContext = {
        let coordinator = self.managedObjectContext.persistentStoreCoordinator
        var context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.managedObjectContext
        return context
    }()
}

