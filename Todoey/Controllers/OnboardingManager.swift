//
//  OnboardingManager.swift
//  AshList
//
//  Created by Ezagor on 30.06.2023.
//  Copyright © 2023 Ezagor. All rights reserved.
//

import Foundation

import UIKit

class OnboardingManager {
    static let shared = OnboardingManager()
    private let onboardingKey = "HasCompletedOnboarding"
    
    var hasCompletedOnboarding: Bool {
        get {
            return UserDefaults.standard.bool(forKey: onboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: onboardingKey)
        }
    }
    
    private init() {}
}
