# UNTRACED - Product Requirements Document

**Project:** TikTok URL Anonymizer (Flutter Mobile App)  
**App Name:** UNTRACED  
**Version:** 1.0  
**Status:** Ready for Development  
**Date:** December 10, 2025  
**Platform:** Android (Phase 1), iOS (Phase 2)

---

## 1. Introduction & Overview

### Problem Statement
When users share TikTok videos, the platform embeds tracking data into the URLs:
- **vm.tiktok.com wrapper** - Short URL redirect with click ID tracking
- **ttclid parameter** - 30-day validity click tracking
- **Query parameters** - utm_source, utm_campaign, behavioral tracking
- **User data** - is_copy_url, is_from_webapp, redirect flags

Users have no easy way to remove this tracking before sharing. **UNTRACED** solves this by providing a one-tap URL anonymizer that removes all tracking while preserving the clean, functional link.

### Solution Overview
UNTRACED is a lightweight, privacy-first Flutter mobile app that:
1. Receives TikTok URLs via Android Share Intent
2. Follows HTTP redirects to expand short URLs
3. Extracts the video ID and username via regex
4. Removes all tracking parameters
5. Copies the clean URL to clipboard
6. Shows success feedback to the user

### Goal
Enable users to share TikTok videos anonymously without tracking footprints, maintaining complete privacy with zero backend infrastructure.

---

## 2. Goals

1. **Remove Tracking:** Strip all 10 tracking elements from TikTok URLs (vm.tiktok.com wrapper, ttclid, query parameters)
2. **100% Client-Side:** Zero backend, zero data transmission (except HTTP redirect for URL expansion)
3. **Zero Data Collection:** No analytics, no crash reporting, no user data storage
4. **One-Tap Experience:** Users tap "Share" → select UNTRACED → get clean URL in clipboard
5. **Instant Feedback:** Clear visual confirmation that tracking was removed
6. **Cross-Platform:** Android Phase 1 (v1.0), iOS Phase 2 (v1.0+)
7. **Future-Proof:** Architecture supports history, batch processing, and freemium features in v1.1+

---

## 3. User Stories

### Story 1: Privacy-Conscious Sharer
**As a** user concerned about my privacy  
**I want to** share TikTok videos without leaving a tracking footprint  
**So that** I can share what I like without TikTok monitoring my sharing behavior

**Acceptance Criteria:**
- I can open a TikTok link in UNTRACED via share intent
- The app removes all tracking parameters
- I get a clean URL copied to clipboard
- I see a success message confirming it worked

---

### Story 2: Anti-Surveillance User
**As a** user who doesn't trust TikTok's data collection  
**I want to** know exactly what's being removed from my URLs  
**So that** I can verify the app actually protects my privacy

**Acceptance Criteria:**
- The app shows what tracking was removed
- I can see the original vs. clean URL
- The privacy guarantee is clearly stated
- No data is sent anywhere except the HTTP redirect

---

### Story 3: Power User
**As a** tech-savvy user  
**I want to** batch process multiple TikTok links  
**So that** I don't have to manually clean each one

**Acceptance Criteria:**
- (Future v1.1) I can paste/upload multiple URLs
- (Future v1.1) App processes all at once
- (Future v1.1) I get a file with clean URLs

---

## 4. Functional Requirements

### 4.1 Share Intent Receiving (5 Requirements)

**REQ-4.1.1:** The app must register to receive Android Share Intent for URLs containing "tiktok.com"  
**REQ-4.1.2:** The app must display a splash screen while processing (max 2 seconds)  
**REQ-4.1.3:** The app must accept URLs in formats: vm.tiktok.com/xxxxx, tiktok.com/@username/video/xxxxx, and mixed variants  
**REQ-4.1.4:** The app must handle malformed URLs gracefully with error message  
**REQ-4.1.5:** The app must support both direct URL input (paste) and share intent on Android

---

### 4.2 HTTP Redirect Following (5 Requirements)

**REQ-4.2.1:** For short URLs (vm.tiktok.com), the app must follow HTTP redirects with User-Agent header  
**REQ-4.2.2:** The app must set User-Agent to a mobile browser string (e.g., Chrome mobile) to receive full URLs  
**REQ-4.2.3:** The app must follow redirects up to 5 hops maximum (prevent infinite loops)  
**REQ-4.2.4:** The app must timeout after 10 seconds if redirect server doesn't respond  
**REQ-4.2.5:** The app must handle network errors with user-friendly message ("Network timeout, try again")

---

### 4.3 URL Parsing & Extraction (5 Requirements)

**REQ-4.3.1:** The app must extract the video ID (19 digits) using regex pattern: `video/(\d{19})`  
**REQ-4.3.2:** The app must extract the username using regex pattern: `@([a-zA-Z0-9._-]+)/video`  
**REQ-4.3.3:** The app must validate that video ID is exactly 19 digits (reject otherwise)  
**REQ-4.3.4:** The app must normalize URLs to standard format: `https://www.tiktok.com/@username/video/19digitID`  
**REQ-4.3.5:** The app must support both http:// and https:// protocols

---

### 4.4 Parameter Stripping (3 Requirements)

**REQ-4.4.1:** The app must remove all query parameters (everything after "?")  
**REQ-4.4.2:** The app must remove the vm.tiktok.com wrapper (convert short URL to long URL)  
**REQ-4.4.3:** The app must ensure the final URL contains ONLY: scheme + domain + @username + /video/ + 19-digit ID

---

### 4.5 URL Rebuilding (3 Requirements)

**REQ-4.5.1:** The app must reconstruct clean URL as: `https://www.tiktok.com/@username/video/19digitID`  
**REQ-4.5.2:** The app must verify clean URL matches pattern before copying  
**REQ-4.5.3:** The app must prevent any tracking parameters from appearing in final URL

---

### 4.6 Clipboard Operations (3 Requirements)

**REQ-4.6.1:** The app must copy the clean URL to clipboard using Flutter's Clipboard service  
**REQ-4.6.2:** The app must NOT attempt to copy if URL is invalid (show error instead)  
**REQ-4.6.3:** The app must provide haptic feedback (vibration) on successful copy

---

### 4.7 User Feedback (4 Requirements)

**REQ-4.7.1:** The app must display a success screen showing: "Link cleaned & copied!"  
**REQ-4.7.2:** The app must display a comparison: Original (dirty) URL → Clean URL  
**REQ-4.7.3:** The app must show what tracking was removed (e.g., "Removed: ttclid, utm_source, 3 other parameters")  
**REQ-4.7.4:** The app must display a "Share Clean URL" button to share the cleaned version

---

### 4.8 Error Handling (5 Requirements)

**REQ-4.8.1:** If URL is not a TikTok link: Show "Not a TikTok URL" message with "Try Again" button  
**REQ-4.8.2:** If network timeout: Show "Network timeout. Try again or check connection" message  
**REQ-4.8.3:** If regex extraction fails: Show "Couldn't extract video ID. Try another link" message  
**REQ-4.8.4:** If clipboard fails: Show "Couldn't copy to clipboard. Try again"  
**REQ-4.8.5:** All errors must include a "Try Again" button that clears state and returns to input

---

### 4.9 Offline Capability (3 Requirements)

**REQ-4.9.1:** The app must work offline for LONG URLs (tiktok.com/@username/video/xxxxx) without network  
**REQ-4.9.2:** The app must show error "Needs internet for short links (vm.tiktok.com)" if offline and short URL provided  
**REQ-4.9.3:** The app must detect internet connectivity and display status to user

---

### 4.10 Permissions (4 Requirements)

**REQ-4.10.1:** The app must request INTERNET permission (for HTTP redirects)  
**REQ-4.10.2:** The app must request CLIPBOARD permission (to copy to clipboard) - Android 13+  
**REQ-4.10.3:** The app must request VIBRATE permission (for haptic feedback)  
**REQ-4.10.4:** The app must handle permission denials gracefully with explanation: "Need [permission] to continue"

---

## 5. Non-Goals (Out of Scope)

- ❌ **Backend API:** No server-side processing, no data storage
- ❌ **User Accounts:** No login, no authentication, no user profiles
- ❌ **Analytics:** No crash reporting, no event tracking, no Google Analytics
- ❌ **Multiple Platforms:** Phase 1 is Android only (iOS in Phase 2)
- ❌ **Video Downloading:** Not a TikTok video downloader
- ❌ **History Storage:** Phase 1 does not store URL history (added in v1.1)
- ❌ **Cloud Sync:** Not applicable (no backend)
- ❌ **Web Version:** Mobile-only initially
- ❌ **Ad-Supported Free Tier:** v1.0 is ad-free, freemium model in v1.2+

---

## 6. Design Considerations

### UI Flow

**Screen 1: Input Screen**
- Empty state with call-to-action: "Paste TikTok Link or Use Share"
- Text input field (pre-filled if shared)
- "Process" button
- Info text: "Your link stays private. We remove tracking."

**Screen 2: Processing Screen**
- Loading spinner
- Progress text: "Removing tracking..."
- Should complete in < 2 seconds

**Screen 3: Success Screen**
- ✅ "Link Cleaned & Copied!"
- Original URL (grayed out/crossed out)
- Arrow indicating transformation
- Clean URL (highlighted)
- "Tracking Removed:" badge showing count
- "Share Clean Link" button
- "Try Another" button

**Screen 4: Error Screen**
- ❌ Error message (specific to error type)
- "Try Again" button
- Optional: "Why this error?" explanation

### Design System
- **Colors:** Clean aesthetic (white background, teal accent #208299, gray for secondary)
- **Typography:** Simple, readable (Segoe UI / system font)
- **Spacing:** Generous padding (16-20px margins)
- **Accessibility:** WCAG AA compliant, high contrast, large touch targets (48px minimum)
- **Icons:** Material Design 3 or simple custom icons
- **Animations:** Smooth transitions (250ms standard)

---

## 7. Technical Considerations

### Architecture (Flutter)
- **State Management:** Provider or Riverpod
- **HTTP Client:** http or dio package
- **Regex:** dart:core RegExp
- **Clipboard:** flutter/services.dart Clipboard
- **Permissions:** permission_handler package
- **Connectivity:** connectivity_plus package

### Key Technical Requirements
1. **HTTP Redirect Following:** Must use `dart:io` HttpClient with User-Agent header
2. **No Storage:** All processing in-memory only (no shared preferences, no database)
3. **Error Handling:** Try-catch around all network calls and regex operations
4. **Timeout Handling:** Set 10-second timeout on HTTP requests
5. **Regex Patterns:**
   - Video ID: `video/(\d{19})`
   - Username: `@([a-zA-Z0-9._-]+)/video`
   - Domain validation: `tiktok\.com`

### Security
- ✅ No API keys stored (no backend)
- ✅ No user data transmitted
- ✅ HTTPS only for all network requests
- ✅ No certificate pinning needed (using standard HTTPS)
- ✅ Input validation on all URLs

### Dependencies
```
flutter: ^3.0
http: ^1.1.0  # For HTTP requests
permission_handler: ^11.4.0  # For Android permissions
connectivity_plus: ^5.0.0  # For network detection
provider: ^6.0.0  # For state management (optional)
```

---

## 8. Success Metrics

1. **URL Processing Success Rate:** ≥99% of valid TikTok URLs processed correctly
2. **Processing Speed:** ≥90% of URLs processed in < 5 seconds
3. **Error Handling:** <1% error rate for user input handling
4. **Crash-Free Rate:** ≥99.5% crash-free rate
5. **User Retention:** Track in v1.1+ (not applicable for v1.0 single-use)
6. **Tracking Removal Verification:** 100% of output URLs should be "clean" (verified via regex)
7. **Permission Acceptance:** ≥85% of users grant required permissions
8. **App Store Rating:** Target ≥4.5 stars on Play Store

---

## 9. Open Questions

**Q1:** Should we implement offline mode for long URLs only (vm.tiktok.com needs internet)?  
**Answer:** YES - REQ-4.9.1 implements this. Users can process long URLs offline, short URLs require internet.

**Q2:** What if TikTok changes URL format in the future?  
**Answer:** v1.0 uses regex patterns. Monitor TikTok URL changes. Plan for regex updates in maintenance releases. Pattern is stable as of Dec 2025.

**Q3:** Should we track anonymized URL statistics (without user data)?  
**Answer:** NO - Zero data collection mandate. v1.0 has no telemetry. Revisit if business model changes in v1.2+.

**Q4:** What happens if user denies clipboard permission?  
**Answer:** REQ-4.10.2 specifies we show explanation. v1.0 requires clipboard. v1.1 could add share button as fallback.

**Q5:** Should we support other social platforms (Instagram, Twitter) in future?  
**Answer:** Out of scope for v1.0. Possible expansion in v1.2+. Focus on TikTok first.

**Q6:** How long should the success screen stay visible?  
**Answer:** Remains visible until user clicks "Try Another" or "Share Clean Link". No auto-dismiss.

---

## 10. Acceptance Criteria (v1.0 Launch)

### Core Functionality
- [ ] User can share TikTok URL via Android Share Intent
- [ ] User can manually paste TikTok URL
- [ ] App successfully follows HTTP redirects for short URLs
- [ ] App extracts 19-digit video ID correctly
- [ ] App extracts username correctly
- [ ] App removes all query parameters from URL
- [ ] App removes vm.tiktok.com wrapper
- [ ] App converts URL to standard format: tiktok.com/@user/video/19digits
- [ ] Clean URL is copied to clipboard without errors
- [ ] User receives success confirmation with before/after comparison

### Error Handling
- [ ] Non-TikTok URLs trigger appropriate error message
- [ ] Network timeouts trigger "try again" option
- [ ] Malformed URLs trigger helpful error
- [ ] Permission denials are handled gracefully
- [ ] All error states have "Try Again" button

### Privacy & Security
- [ ] ZERO data transmitted to backend (only HTTP redirect for URL expansion)
- [ ] ZERO user data stored locally
- [ ] ZERO analytics/crash reporting
- [ ] HTTPS enforced for all requests
- [ ] Privacy policy explicitly states zero data collection

### Testing
- [ ] Unit tests: 80%+ code coverage on URL parsing
- [ ] Integration tests: 5+ test scenarios (happy path, network timeout, invalid URL, permission denial, offline mode)
- [ ] Manual testing: All error messages, all edge cases
- [ ] Network analysis: Verify no unexpected data transmission

### Performance
- [ ] ≥90% of URLs processed in < 5 seconds
- [ ] ≤2 seconds for processing screen (max spinner duration)
- [ ] < 30MB app size
- [ ] Minimal memory usage (< 50MB RAM)

### Store Approval
- [ ] App passes Google Play Store review
- [ ] Privacy policy meets app store requirements
- [ ] No prohibited permissions requested
- [ ] No trademark violations (UNTRACED is clear)

---

## 11. Release Plan

### Phase 1: v1.0 (December 2025 - January 2026)
**Platform:** Android  
**Deliverables:**
- Core URL anonymization
- Share Intent receiving
- Clipboard copying
- Error handling
- Privacy policy

**Timeline:** 4 weeks from approval  
**Success:** Approved on Google Play Store

---

### Phase 2: v1.0 iOS (January - February 2026)
**Platform:** iOS  
**Additions:**
- Share Sheet extension
- Different UX for iOS clipboard limitations
- TestFlight beta

---

### Phase 3: v1.1 (Q1 2026)
**New Features:**
- History (last 20 URLs)
- Batch processing (multiple URLs at once)
- Favorites (save clean URLs)
- Export to file

---

### Phase 4: v1.2+ (Q2 2026+)
**Future Considerations:**
- Freemium model (unlimited free, paid features)
- Web version
- Browser extension (Chrome, Firefox)
- Other platform support (Instagram, Twitter)
- Advanced analytics (zero-data)

---

## 12. Privacy & Data Policy

### Explicit Guarantees
✅ **100% Client-Side Processing:** All URL processing happens on your device  
✅ **Zero Data Storage:** We don't store your URLs, ever  
✅ **Zero Data Transmission:** No data sent to our servers (only HTTP redirect to expand short URLs)  
✅ **Zero Analytics:** No crash reporting, event tracking, or analytics  
✅ **Zero User Profiles:** No login, no accounts, no personal data collection  
✅ **Open Source Ready:** Code available for review (future)

### Network Calls
Only network call: HTTP redirect follow for short URLs (vm.tiktok.com → expanded URL)  
- This happens on TikTok's servers, not ours
- We don't log or store this

### Permissions Requested
- `INTERNET` - For HTTP redirect following only
- `CLIPBOARD` - To copy clean URL to your clipboard
- `VIBRATE` - For haptic feedback on success

---

**End of PRD**

*Document Version: 1.0*  
*Last Updated: December 10, 2025*  
*Status: Ready for Development*
