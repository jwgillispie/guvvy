import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Load Google Maps API key
    // Option 1: Load from Keys.plist (recommended for security)
    // if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
    //    let keys = NSDictionary(contentsOfFile: path),
    //    let apiKey = keys["GoogleMapsAPIKey"] as? String {
    //   GMSServices.provideAPIKey(apiKey)
    // }
    // Option 2: Directly set the API key (less secure)
    let apiKey = "AIzaSyC4iqrXzbVD3zbYDtp-UPy2lWuW4g_LICs"
    GMSServices.provideAPIKey(apiKey)
    // else {
    //   // Handle the case where the API key isn't found
    //   print("Warning: Google Maps API key not found")
    // }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

