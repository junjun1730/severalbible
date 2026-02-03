# GitHub Pages Setup Guide

## Quick Setup (5 minutes)

### Step 1: Enable GitHub Pages

1. Go to your repository on GitHub: https://github.com/junjun1730/severalbible

2. Click **Settings** (top right)

3. In the left sidebar, click **Pages** (under "Code and automation")

4. Under **Source**, select:
   - **Source**: Deploy from a branch
   - **Branch**: `main`
   - **Folder**: `/Docs`

5. Click **Save**

6. Wait 1-2 minutes for deployment

### Step 2: Verify URLs

Once deployed, your legal documents will be available at:

- **Landing Page**: https://junjun1730.github.io/severalbible/
- **Privacy Policy**: https://junjun1730.github.io/severalbible/privacy_policy.html
- **Terms of Service**: https://junjun1730.github.io/severalbible/terms_of_service.html

### Step 3: Test in App

1. Run the Flutter app:
   ```bash
   flutter run
   ```

2. Navigate to **Settings** (gear icon in AppBar)

3. Scroll to **Legal** section

4. Tap **Privacy Policy** - should open in browser

5. Tap **Terms of Service** - should open in browser

### Step 4: Test on Physical Device (Recommended)

**iOS**:
```bash
flutter run -d <your-iphone-id>
```

**Android**:
```bash
flutter run -d <your-android-id>
```

Then test the legal links on the actual device.

---

## Troubleshooting

### GitHub Pages not deploying?

1. Check if there's a **Actions** tab error
2. Ensure the `Docs/` folder exists in the `main` branch
3. Wait up to 10 minutes for first deployment

### URLs not working in app?

1. Check if GitHub Pages is enabled (green checkmark in Settings > Pages)
2. Verify URLs in `settings_screen.dart` match your GitHub Pages URL
3. Check device internet connection

### 404 Error on legal pages?

1. Verify file names are exact:
   - `privacy_policy.html` (not `privacy-policy.html`)
   - `terms_of_service.html` (not `terms-of-service.html`)
2. Check case sensitivity (use lowercase)
3. Clear browser cache

---

## Verification Checklist

- [ ] GitHub Pages enabled in repository settings
- [ ] Deployment successful (green checkmark in Pages settings)
- [ ] Landing page loads: https://junjun1730.github.io/severalbible/
- [ ] Privacy Policy loads in browser
- [ ] Terms of Service loads in browser
- [ ] Links work in iOS Simulator
- [ ] Links work in Android Emulator
- [ ] Links work on physical iOS device
- [ ] Links work on physical Android device

---

## Alternative Hosting Options (If Needed)

If GitHub Pages doesn't work, you can use:

1. **Netlify** (Free)
   - Drag and drop `Docs/` folder to Netlify
   - Get custom URL: `https://one-message.netlify.app/`

2. **Vercel** (Free)
   - Connect GitHub repo
   - Deploy automatically

3. **Firebase Hosting** (Free)
   - `firebase init hosting`
   - Deploy `Docs/` folder

4. **Cloudflare Pages** (Free)
   - Connect GitHub repo
   - Auto-deploy on push

---

## Custom Domain (Optional)

If you want a custom domain like `https://onemessageapp.com`:

1. Buy a domain from Namecheap, GoDaddy, etc.
2. Add custom domain in GitHub Pages settings
3. Configure DNS records:
   ```
   A     @     185.199.108.153
   A     @     185.199.109.153
   A     @     185.199.110.153
   A     @     185.199.111.153
   CNAME www   junjun1730.github.io
   ```
4. Update URLs in `settings_screen.dart`

---

## Next Steps

Once GitHub Pages is live and verified:

✅ **Step 1: Legal Document Hosting** - COMPLETE
⬜ **Step 2: Screenshot Capture** - NEXT
⬜ **Step 3: Store Description Writing**
⬜ **Step 4: App Icon Creation**
⬜ **Step 5: Splash Screen Update**
⬜ **Step 6: TestFlight/Internal Testing**

---

**Status**: Ready for App Store submission after completing all 6 steps!
