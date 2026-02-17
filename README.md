# tche_organiza

A new Flutter project.


### 1. **Android (Play Console)**

First, ensure you have a keystore file. If you don't have one, create it:

```bash
keytool -genkey -v -keystore ~/tche_organiza-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tche_organiza
```



To get your SHA-1 key:

```bash
keytool -list -v -keystore ~/tche_organiza-release-key.jks -alias tche_organiza
```

### Setting Up the Key

Create or update `android/key.properties` with the following content:

```properties
storePassword=<your_keystore_password>
keyPassword=<your_key_password>
keyAlias=tche_organiza
storeFile=<path_to_keystore>/tche_organiza-release-key.jks
```

Replace:
- `<your_keystore_password>` - The password you set when creating the keystore
- `<your_key_password>` - The password for the key alias
- `<path_to_keystore>` - The full path to your keystore file (e.g., `/Users/adsouza/tche_organiza-release-key.jks`)

Then build the app bundle:

```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Build for Android (App Bundle - recommended for Play Console)
flutter build appbundle --release

# Open the output directory
open build/app/outputs/bundle/release/
```

The app bundle will be located at: `build/app/outputs/bundle/release/app-release.aab`

### 2. **iOS (App Store) - Using Xcode**

```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Build the iOS app (this prepares it for Xcode)
flutter build ios --release

# Open the project in Xcode
open ios/Runner.xcworkspace
```

Once Xcode opens:
1. Select "Any iOS Device" or "Generic iOS Device" as the build target
2. Go to **Product** → **Archive**
3. Once the archive completes, the Organizer window will open
4. Select your archive and click **Distribute App**
5. Follow the prompts to upload to App Store Connect

### 3. **Additional Notes**

Before building, make sure to:
- Configure your `android/key.properties` file with keystore details
- Ensure code signing is configured in Xcode (Team, Bundle Identifier, etc.)
- Update version numbers in pubspec.yaml if needed (currently at `1.0.0+3`)
- Test on real devices before submitting