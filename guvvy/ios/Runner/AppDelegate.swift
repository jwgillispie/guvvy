import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Load API key from Keys.plist
    if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
       let keys = NSDictionary(contentsOfFile: path),
       let apiKey = keys["GoogleMapsAPIKey"] as? String {
      GMSServices.provideAPIKey(apiKey)
    } else {
      fatalError("Google Maps API key not found in Keys.plist")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}