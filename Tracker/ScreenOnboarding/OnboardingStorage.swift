import UIKit

final class OnboardingStorage {
    static let shared = OnboardingStorage()
    private var userDefaults = UserDefaults.standard
    private init() { }
    
    var checkSecondSetup: Bool {
        get {
            userDefaults.bool(forKey: "checkSetup")
        }
        set {
            userDefaults.setValue(newValue, forKey: "checkSetup")
        }
    }
}
