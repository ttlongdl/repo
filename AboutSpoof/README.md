# AboutSpoof

Tiny rootless jailbreak tweak for Dopamine/ElleKit.

It only changes the value returned for `UserAssignedDeviceName` inside the Settings app, so **Settings > General > About > Model Name** can display **iPhone 18 Pro**.

- Target: rootless iOS 15+ (intended/test target: iOS 17.0 Dopamine)
- Injection scope: `com.apple.Preferences` only
- Does **not** edit `com.apple.MobileGestalt.plist`
- Does **not** spoof serial, UDID, hardware identifier, or model globally
- Remove the package to revert.

Initial build is deliberately minimal for testing on the iPhone 12 Pro.
