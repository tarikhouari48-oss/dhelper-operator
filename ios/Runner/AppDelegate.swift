import Flutter
import UIKit
import GoogleMaps  // only needed if you add Maps to operator app later

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Replace with your Google Maps API key from Google Cloud Console
    // Enable: Maps SDK for iOS at console.cloud.google.com/apis
    GMSServices.provideAPIKey("REPLACE_WITH_GOOGLE_MAPS_API_KEY")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
