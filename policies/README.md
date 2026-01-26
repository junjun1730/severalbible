# Legal Documents - One Message

This directory contains the Privacy Policy and Terms of Service for the One Message app.

## Files

- `privacy_policy.md` - Privacy Policy (Markdown format)
- `privacy_policy.html` - Privacy Policy (Mobile-optimized HTML)
- `terms_of_service.md` - Terms of Service (Markdown format)
- `terms_of_service.html` - Terms of Service (Mobile-optimized HTML)

## Hosting Options

These legal documents need to be publicly accessible via HTTPS URLs for the app to link to them.

### Option 1: GitHub Pages (Recommended for MVP)

**Quick Setup:**

1. Create a new branch called `gh-pages`:
   ```bash
   git checkout -b gh-pages
   ```

2. Copy the HTML files to the root:
   ```bash
   cp policies/privacy_policy.html privacy.html
   cp policies/terms_of_service.html terms.html
   ```

3. Commit and push:
   ```bash
   git add privacy.html terms.html
   git commit -m "docs: add legal policies for GitHub Pages"
   git push origin gh-pages
   ```

4. Enable GitHub Pages:
   - Go to repository Settings > Pages
   - Source: Deploy from branch `gh-pages`
   - Save

5. Your policies will be available at:
   - `https://[username].github.io/severalbible/privacy.html`
   - `https://[username].github.io/severalbible/terms.html`

6. Update `lib/features/settings/presentation/screens/settings_screen.dart`:
   ```dart
   static const String privacyPolicyUrl =
       'https://[username].github.io/severalbible/privacy.html';
   static const String termsOfServiceUrl =
       'https://[username].github.io/severalbible/terms.html';
   ```

### Option 2: Separate Repository (Cleaner)

Create a dedicated repository like `onemessage-policies`:

1. Create new repository on GitHub
2. Upload HTML files
3. Enable GitHub Pages
4. URLs: `https://[username].github.io/onemessage-policies/privacy.html`

### Option 3: Custom Domain (Production)

For production release, host on your own domain:

1. Purchase domain (e.g., `onemessageapp.com`)
2. Set up hosting (Netlify, Vercel, or GitHub Pages with custom domain)
3. Deploy HTML files to `/legal/privacy` and `/legal/terms`
4. URLs:
   - `https://onemessageapp.com/legal/privacy`
   - `https://onemessageapp.com/legal/terms`

### Option 4: Supabase Storage (Alternative)

You can also host on Supabase Storage:

```bash
# Upload to Supabase Storage bucket (make it public)
supabase storage upload policies privacy_policy.html
supabase storage upload policies terms_of_service.html
```

Then get public URLs and update the app.

## Before App Store Submission

**CRITICAL**: You MUST have these documents publicly hosted before submitting to App Store or Google Play.

- [ ] Privacy Policy URL is live and accessible
- [ ] Terms of Service URL is live and accessible
- [ ] URLs are updated in `settings_screen.dart`
- [ ] Links tested on both iOS and Android devices
- [ ] Documents are mobile-responsive and readable

## Updating Policies

When updating these documents:

1. Update the "Last Updated" date
2. Redeploy to your hosting platform
3. Notify users in-app if changes are material (legal requirement)

## Legal Disclaimer

**IMPORTANT**: These templates are provided as a starting point. You should:

- Review with a lawyer before using in production
- Customize contact information (email, website, address)
- Ensure compliance with your specific jurisdiction
- Update based on your actual data practices
- Consider consulting with a legal professional specializing in app privacy

## Contact Information to Replace

Before going live, replace all placeholder contact information:

- `support@onemessageapp.com` → Your actual support email
- `https://onemessageapp.com` → Your actual website
- `[Your business address]` → Your actual business address (required in some jurisdictions)

## Mobile Responsiveness

The HTML versions are optimized for mobile viewing with:

- Responsive design (adapts to screen size)
- Readable font sizes
- Touch-friendly spacing
- Clean, professional styling
- Fast loading (no external dependencies)

Test on both iOS and Android devices before launch.
