import AppClip
import Firebase
import Root
import SwiftUI

@main
struct ColorsWeSeeAppClip: App {
  
  init() {
    FirebaseApp.configure()
  }

  @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate

  var body: some Scene {
    AppRootScene(delegate: delegate)
  }
}
