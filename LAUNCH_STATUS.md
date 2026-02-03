# One Message - Launch Status Report

**Date**: February 3, 2026
**Phase**: Phase 5 - Optimization & Launch
**Overall Progress**: 20% Complete

---

## ✅ Step 1: Legal Document Hosting - COMPLETE

### What Was Done

1. **Created GitHub Pages Structure**
   - Created `Docs/` folder for hosting
   - Copied `privacy_policy.html` and `terms_of_service.html`
   - Created beautiful landing page (`index.html`)

2. **Updated App Code**
   - Updated `settings_screen.dart` with production URLs:
     - Privacy Policy: `https://junjun1730.github.io/severalbible/privacy_policy.html`
     - Terms of Service: `https://junjun1730.github.io/severalbible/terms_of_service.html`
   - Replaced placeholder `https://example.com` URLs

3. **Documentation**
   - Created `GITHUB_PAGES_SETUP.md` with:
     - 5-minute setup guide
     - Verification checklist
     - Troubleshooting tips
     - Alternative hosting options

4. **Git Commits**
   - Committed all changes to `main` branch
   - Pushed to GitHub repository
   - Ready for GitHub Pages deployment

### Next Action Required

**YOU MUST DO THIS NOW** (5 minutes):

1. Go to: https://github.com/junjun1730/severalbible/settings/pages

2. Under **Source**, select:
   - Branch: `main`
   - Folder: `/Docs`

3. Click **Save**

4. Wait 2-3 minutes, then verify:
   - https://junjun1730.github.io/severalbible/
   - https://junjun1730.github.io/severalbible/privacy_policy.html
   - https://junjun1730.github.io/severalbible/terms_of_service.html

5. Test in app:
   ```bash
   flutter run
   # Navigate to Settings > Legal
   # Tap Privacy Policy (should open in browser)
   # Tap Terms of Service (should open in browser)
   ```

### Verification Checklist

- [ ] GitHub Pages enabled in repository settings
- [ ] Landing page loads in browser
- [ ] Privacy Policy opens in browser
- [ ] Terms of Service opens in browser
- [ ] Links work in iOS Simulator
- [ ] Links work on physical device

**Status**: ✅ **Code Complete** - Waiting for GitHub Pages activation

---

## ⬜ Step 2: Screenshot Capture - NOT STARTED

**Estimated Time**: 2-3 hours
**Priority**: 🔴 CRITICAL (App Store requirement)

### Requirements

**iOS Screenshots** (iPhone 14 Pro Max - 6.7"):
1. Login Screen - Social login buttons visible
2. Daily Feed - 3 beautiful scripture cards
3. Prayer Note - Meditation modal open
4. My Library - Calendar with notes
5. Premium Landing - Subscription screen

**Resolution**: 1290 x 2796 pixels (PNG)

**Android Screenshots** (Pixel 6 Pro):
- Same 5 screens as iOS
- **Resolution**: 1440 x 3120 pixels (PNG)

### Capture Commands

**iOS**:
```bash
# Start simulator
flutter run

# Navigate to each screen, then:
xcrun simctl io booted screenshot screenshot_ios_1_login.png
xcrun simctl io booted screenshot screenshot_ios_2_feed.png
xcrun simctl io booted screenshot screenshot_ios_3_prayer.png
xcrun simctl io booted screenshot screenshot_ios_4_library.png
xcrun simctl io booted screenshot screenshot_ios_5_premium.png
```

**Android**:
```bash
# Start emulator
flutter run

# Navigate to each screen, then:
adb exec-out screencap -p > screenshot_android_1_login.png
adb exec-out screencap -p > screenshot_android_2_feed.png
adb exec-out screencap -p > screenshot_android_3_prayer.png
adb exec-out screencap -p > screenshot_android_4_library.png
adb exec-out screencap -p > screenshot_android_5_premium.png
```

### Tips
- Use **actual content**, not dummy data
- Ensure UI is clean and professional
- Purple branding (#7C6FE8) should be visible
- Status bar: 9:41 AM, full battery, WiFi
- No debug banners or overlays

---

## ⬜ Step 3: Store Description Writing - NOT STARTED

**Estimated Time**: 2-3 hours
**Priority**: 🔴 CRITICAL (App Store requirement)

### App Store (iOS) Metadata

**App Name** (30 chars):
```
One Message - Daily Scripture & Prayer
```

**Subtitle** (30 chars):
```
Read, Write, Archive Spiritual Growth
```

**Description** (4000 chars):
```
[TODO: Write compelling marketing copy highlighting:]
- Daily scripture delivery (customized, no duplicates)
- Prayer journaling (write and archive)
- Spiritual growth tracking
- Three tiers: Guest, Member, Premium
- Key benefits of each tier
- Beautiful Material 3 UI
- Secure authentication (Google, Apple)
```

**Keywords** (100 chars):
```
scripture,prayer,meditation,bible,spiritual,devotional,faith,christian,daily,journal
```

**Categories**:
- Primary: Lifestyle
- Secondary: Books & Reference

**URLs**:
- Support: https://junjun1730.github.io/severalbible/
- Privacy Policy: https://junjun1730.github.io/severalbible/privacy_policy.html

### Google Play (Android) Metadata

**App Title** (50 chars):
```
One Message - Daily Scripture & Prayer
```

**Short Description** (80 chars):
```
Daily spiritual content. Record prayers. Archive your faith journey.
```

**Full Description** (4000 chars):
```
[TODO: Similar to App Store, optimized for Google Play]
```

**Category**: Lifestyle

---

## ⬜ Step 4: App Icon Creation - NOT STARTED

**Estimated Time**: 1-2 hours
**Priority**: 🟡 HIGH (Currently using placeholder)

### Requirements

- **Size**: 1024 x 1024 PNG
- **Style**: Minimal, modern
- **Color**: Purple #7C6FE8 (brand color)
- **Theme**: Bible/prayer/spiritual growth

### Design Ideas

1. Book icon + Purple gradient
2. Praying hands silhouette
3. Cross + open book
4. Number "1" + message bubble
5. Simple scripture scroll

### Implementation

**Option A**: Design yourself (Figma, Canva, Adobe Illustrator)
**Option B**: AI generation (DALL-E, Midjourney)
**Option C**: Hire freelancer (Fiverr, $20-50, 1-2 days)

**Generate all sizes**:
```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#7C6FE8"
```

```bash
flutter pub run flutter_launcher_icons
```

---

## ⬜ Step 5: Splash Screen Update - NOT STARTED

**Estimated Time**: 1 hour
**Priority**: 🟡 MEDIUM (Currently using Flutter default)

### Requirements

- **Background**: Purple #7C6FE8 or White
- **Logo**: App icon or logotype
- **Style**: Simple, clean
- **Duration**: 1-2 seconds (automatic)

### Implementation

```yaml
# pubspec.yaml
flutter_native_splash:
  color: "#7C6FE8"
  image: assets/splash/splash_logo.png
  android_12:
    color: "#7C6FE8"
    image: assets/splash/splash_logo.png
```

```bash
flutter pub run flutter_native_splash:create
```

---

## ⬜ Step 6: TestFlight / Internal Testing - NOT STARTED

**Estimated Time**: 3-5 days
**Priority**: 🟡 HIGH (Pre-launch requirement)

### iOS - TestFlight

**Prerequisites**:
- [ ] Apple Developer Program account ($99/year)
- [ ] App created in App Store Connect
- [ ] Bundle ID: `com.onemessage.app` (example)
- [ ] Provisioning Profile generated

**Build & Upload**:
```bash
flutter build ios --release
# Then in Xcode: Product > Archive > Upload
```

**TestFlight Setup**:
1. Create Internal Testing group
2. Add tester emails (up to 100)
3. Distribute build
4. Testers install via TestFlight app

### Android - Google Play Internal Testing

**Prerequisites**:
- [ ] Google Play Console account ($25 one-time)
- [ ] App created in Console
- [ ] Package name: `com.onemessage.app`
- [ ] Upload key generated

**Build & Upload**:
```bash
flutter build appbundle --release
# Upload build/app/outputs/bundle/release/app-release.aab
```

**Internal Testing Setup**:
1. Create Internal Testing track
2. Upload AAB
3. Add tester list (emails)
4. Distribute

### Testing Checklist

**Core Functionality**:
- [ ] Login/Registration (Google OAuth, Apple Sign-In)
- [ ] Scripture loading (Guest 1/day, Member 3/day)
- [ ] Prayer note writing/saving
- [ ] My Library calendar view
- [ ] Premium subscription flow (sandbox)
- [ ] Settings screen
- [ ] Legal links (Privacy Policy, Terms)

**Platform-Specific**:
- [ ] iOS: Back gesture, Safe area, Dynamic type
- [ ] Android: Back button, Material design, Different screen sizes

**Edge Cases**:
- [ ] No internet connection
- [ ] Session expiry
- [ ] Subscription cancellation
- [ ] Account deletion

### Feedback Collection

**Tools**:
- TestFlight built-in feedback
- Google Forms survey
- Bug tracking: GitHub Issues

**Focus Areas**:
- Crashes or freezes
- UI/UX confusion
- Performance issues
- Text errors/typos
- Missing features

---

## Timeline Estimate

| Step | Duration | Dependencies | Priority |
|------|----------|--------------|----------|
| 1. Legal Hosting | ✅ Done (30 min) | None | 🔴 CRITICAL |
| 2. Screenshots | 2-3 hours | None | 🔴 CRITICAL |
| 3. Store Description | 2-3 hours | None | 🔴 CRITICAL |
| 4. App Icon | 1-2 hours | Design decision | 🟡 HIGH |
| 5. Splash Screen | 1 hour | App icon | 🟡 MEDIUM |
| 6. Testing | 3-5 days | Steps 1-5 | 🟡 HIGH |

**Minimum Launch Time**: 5-7 hours + 3-5 days testing
**Full Launch Time**: 8-10 hours + 3-5 days testing

---

## Current State Summary

### ✅ What's Complete

**Code & Features** (100%):
- 167 tests passing
- All 5 phases implemented (Phase 1-4.5)
- Material 3 UI with AppButton system
- Authentication (Google OAuth, Apple Sign-In)
- Scripture delivery (Guest, Member, Premium tiers)
- Prayer note system with calendar
- Subscription & monetization (In-App Purchase ready)
- Settings with legal section

**Legal Documents** (100%):
- Privacy Policy written
- Terms of Service written
- Settings integration complete
- GitHub Pages structure ready
- URLs updated in code

### ⬜ What's Remaining

**App Store Assets** (0%):
- Screenshots (0/10 captured)
- Store descriptions (0/2 written)
- App icon (placeholder only)
- Splash screen (Flutter default)

**Testing** (0%):
- TestFlight setup (not started)
- Internal testing (not started)
- QA validation (not started)
- Bug fixes (TBD based on feedback)

---

## Recommended Next Actions

### Immediate (Today):

1. **Enable GitHub Pages** (5 minutes)
   - Go to repository settings
   - Enable Pages with `/Docs` folder
   - Verify URLs work

2. **Capture Screenshots** (2-3 hours)
   - iOS: 5 screens at 1290x2796
   - Android: 5 screens at 1440x3120
   - Save to `store_assets/screenshots/` folder

3. **Write Store Descriptions** (2-3 hours)
   - App Store metadata
   - Google Play metadata
   - Save to `store_assets/` folder

### This Week:

4. **Create App Icon** (1-2 hours)
   - Design or commission icon
   - Generate all sizes
   - Test in simulator/emulator

5. **Update Splash Screen** (1 hour)
   - Create branded splash
   - Generate native assets
   - Verify on devices

### Next Week:

6. **Set Up TestFlight** (3-5 days)
   - Create release builds
   - Invite internal testers
   - Run QA testing
   - Fix critical bugs

---

## Blocker Status

**Current Blockers**: ❌ None!

All technical work is complete. Remaining tasks are:
- Asset creation (non-blocking, can be done in parallel)
- Testing (dependent on assets)

**Ready for**: App Store submission after completing all 6 steps

---

## Support & Resources

**Documentation**:
- GitHub Pages Setup: `Docs/GITHUB_PAGES_SETUP.md`
- Project Guidelines: `CLAUDE.md`
- Development Plan: `PLANNER.md`

**Repository**:
- GitHub: https://github.com/junjun1730/severalbible
- GitHub Pages: https://junjun1730.github.io/severalbible/ (pending activation)

**Next Steps Guide**:
1. Enable GitHub Pages (YOU → 5 min)
2. Capture screenshots (YOU → 2-3 hours)
3. Write descriptions (YOU → 2-3 hours)
4. Create icon (YOU or Designer → 1-2 hours)
5. Update splash (YOU → 1 hour)
6. Run testing (YOU + Testers → 3-5 days)

**Target Launch**: 2-3 weeks from now (after testing & app store review)

---

**Last Updated**: February 3, 2026
**Next Milestone**: Screenshot Capture (Step 2)
**Overall Progress**: 20% (1/6 steps complete)
