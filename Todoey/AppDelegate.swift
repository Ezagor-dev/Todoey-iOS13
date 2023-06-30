//
//  AppDelegate.swift
//
//  Created by Ezagor on 06/12/2023
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            print("Realm file URL: \(Realm.Configuration.defaultConfiguration.fileURL)")

            let userDefaults = UserDefaults.standard
            let hasCompletedOnboarding = userDefaults.bool(forKey: "HasCompletedOnboarding")
            
            if hasCompletedOnboarding {
                showCategoryViewController()
            } else {
                showOnboardingViewController()
            }
        do{
            _ = try Realm()
        }catch{
            print("Error initialising new realm, \(error)")
        }
            
            return true
        }
        
        private func showOnboardingViewController() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let onboardingViewController = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController")
            window?.rootViewController = onboardingViewController
        }
        
        private func showCategoryViewController() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let categoryViewController = storyboard.instantiateViewController(withIdentifier: "CategoryViewController")
            let navigationController = UINavigationController(rootViewController: categoryViewController)
            window?.rootViewController = navigationController
        }


            
           
            
           
    }
    

