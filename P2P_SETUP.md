# Free P2P Calling Setup Guide

## 🎉 Completely Free - No Tokens, No Cloud Costs!

Your SignalBridge app now uses **100% free peer-to-peer WebRTC calling** with Firebase for signaling only.

## How It Works

```
User A (ID: 12345678) ←→ Firebase (Free Signaling) ←→ User B (ID: 87654321)
                              ↓
                    Direct P2P Connection (WebRTC)
                    Audio/Video flows directly between devices
```

## Quick Setup (10 minutes)

### Step 1: Create Free Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `signalbridge` (or any name)
4. Disable Google Analytics (optional)
5. Click "Create Project"

### Step 2: Enable Realtime Database

1. In Firebase Console, go to **Realtime Database**
2. Click "Create Database"
3. Choose location (closest to your users)
4. Start in **Test Mode** (for development)
5. Click "Enable"

### Step 3: Configure Android App

1. In Firebase Console, click the Android icon
2. Register app with package name: `com.kandoji.signalbridge` (or your actual package)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

Add to `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Add to `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

### Step 4: Configure iOS App (if needed)

1. In Firebase Console, click the iOS icon
2. Register app with bundle ID
3. Download `GoogleService-Info.plist`
4. Add to `ios/Runner/GoogleService-Info.plist`

### Step 5: Update Database Rules (Important!)

In Firebase Console → Realtime Database → Rules, replace with:

```json
{
  "rules": {
    "calls": {
      "$userId": {
        ".read": "$userId === auth.uid || $userId === auth.uid",
        ".write": true,
        "$callId": {
          ".read": true,
          ".write": true
        }
      }
    }
  }
}
```

For development/testing, you can use:
```json
{
  "rules": {
    "calls": {
      ".read": true,
      ".write": true
    }
  }
}
```

⚠️ **Note**: Open rules are fine for testing but should be secured for production.

## How Users Connect

### Device A (Caller)
1. Opens app → Gets random 8-digit ID: `12345678`
2. Saves Device B's ID: `87654321` as contact
3. Clicks call button
4. App sends call signal via Firebase
5. WebRTC establishes direct P2P connection

### Device B (Receiver)
1. Opens app → Gets random 8-digit ID: `87654321`
2. Receives incoming call notification
3. Accepts call
4. Direct P2P audio/video connection established

## What's Free?

✅ **Firebase Realtime Database** (Free tier):
- 1 GB stored data
- 10 GB/month downloaded
- 100 simultaneous connections
- Perfect for signaling!

✅ **WebRTC P2P Connection**:
- Completely free
- No bandwidth limits
- Direct device-to-device
- No server costs

✅ **STUN Servers** (Google's free STUN):
- Used for NAT traversal
- Completely free
- No registration needed

## Cost Breakdown

| Component | Cost |
|-----------|------|
| Firebase Signaling | FREE (within limits) |
| WebRTC P2P Audio/Video | FREE (unlimited) |
| STUN Servers | FREE |
| **Total** | **$0.00** |

## Testing

1. **Install on Device A**
   ```
   flutter run
   ```
   - Note the 8-digit ID (e.g., `12345678`)

2. **Install on Device B**
   ```
   flutter run
   ```
   - Note the 8-digit ID (e.g., `87654321`)

3. **Add Contact**
   - On Device B, add Device A's ID as contact

4. **Make Call**
   - Click green phone icon (audio) or blue video icon
   - Device A receives incoming call
   - Accept → Connected via P2P! 🎉

## Troubleshooting

### Firebase not initialized
- Make sure `google-services.json` is in `android/app/`
- Run `flutter clean && flutter pub get`
- Rebuild the app

### Calls not connecting
- Check Firebase Realtime Database is enabled
- Verify database rules allow read/write
- Check internet connection on both devices
- Ensure both devices have different user IDs

### No incoming call notification
- Make sure app is running on receiving device
- Check Firebase Database → Data tab to see if call signal is sent
- Verify `P2PCallService.instance.setContext()` is called

### Audio/Video not working
- Grant microphone/camera permissions
- Check device settings
- Try audio-only call first

## Security Notes

**For Production:**
1. Implement Firebase Authentication
2. Secure database rules with auth
3. Add end-to-end encryption for signaling
4. Validate user IDs server-side

**Current Setup:**
- Fine for testing/development
- Database rules are open (test mode)
- No authentication required

## Limits & Scaling

**Firebase Free Tier:**
- Up to 100 simultaneous users
- 10 GB/month data transfer
- Perfect for personal/small apps

**If you exceed limits:**
- Upgrade to Firebase Spark plan (pay-as-you-go)
- Or implement your own signaling server
- WebRTC P2P remains free regardless!

## Alternative Signaling (No Firebase)

If you don't want to use Firebase, you can:
1. Set up a simple Node.js WebSocket server (free on Render/Railway)
2. Use PeerJS (free P2P library with free signaling)
3. Implement QR code exchange for direct connection

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [WebRTC Documentation](https://webrtc.org/)
- [Flutter WebRTC Plugin](https://pub.dev/packages/flutter_webrtc)
