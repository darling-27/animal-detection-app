# Animal Detection App - Error Fixes TODO

## Current Status: 🔒 Security Fixed, Firebase Next

### Priority 1: Security (✅ COMPLETE)
- [x] Remove exposed Google Maps API key from AndroidManifest.xml  
- [x] Add secure local.properties configuration
- [x] Update gradle to load from local.properties

### Priority 2: Firebase Initialization (⏳ In Progress)
- [ ] Add Firebase.initializeApp() to main.dart
- [ ] Initialize FirebaseService singleton

### Priority 3: Code Quality (⏳ Pending)
- [ ] Remove all TODO comments from login_screen.dart
- [ ] Add basic forgot password/register stubs
- [ ] Fix widget_test.dart to match actual UI
- [ ] Add null checks to FirebaseService methods

### Priority 4: Verification (⏳ Pending)
- [ ] Run `flutter pub get`
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`
- [ ] Verify app builds without errors

**Next: Firebase initialization → Code cleanup → Final verification**
*Updated: $(date)*
