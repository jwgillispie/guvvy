import UIKit
import Flutter
import GoogleMaps  // Make sure this import is present

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add this line before GeneratedPluginRegistrant
    GMSServices.provideAPIKey("AIzaSyDXv8eUg-n_NNUit9u6Fl0v5p11VNfhzuY")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}