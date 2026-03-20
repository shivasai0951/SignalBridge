# 🚀 QuickStart - Free P2P Calling

## What You Get

✅ **Random 8-digit User ID** - Auto-generated on first install  
✅ **Save Contacts** - Store other users' IDs  
✅ **Free P2P Calls** - Direct WebRTC, no tokens, no cloud costs  
✅ **Audio & Video** - Both supported  

## 3-Step Setup

### 1️⃣ Create Free Firebase Project (5 min)

```bash
# Go to: https://console.firebase.google.com/
# Click "Add Project" → Name it "signalbridge" → Create
# Enable "Realtime Database" → Start in Test Mode
```

### 2️⃣ Add Firebase to Your App (3 min)

**For Android:**
1. In Firebase Console, click Android icon
2. Package name: `com.example.signalbridge`
3. Download `google-services.json`
4. Place in: `android/app/google-services.json`

**Update `android/build.gradle`:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**Update `android/app/build.gradle`:**
```gradle
apply plugin: 'com.google.gms.google-services'
```

**Run FlutterFire CLI (Easiest Method):**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase automatically
flutterfire configure
```

This will auto-generate `lib/firebase_options.dart` with your credentials!

### 3️⃣ Test Between Two Devices

**Device A:**
```bash
flutter run
# Note your ID: 12345678
```

**Device B:**
```bash
flutter run
# Note your ID: 87654321
# Add Device A's ID (12345678) as contact
# Click call button → Device A receives call!
```

## How It Works

```
📱 Device A (12345678)
    ↓
🔥 Firebase (Free Signaling - just exchanges connection info)
    ↓
📱 Device B (87654321)
    ↓
🎯 Direct P2P WebRTC Connection Established
    ↓
🎵 Audio/Video flows directly between devices (FREE!)
```

## Manual Firebase Config (Alternative)

If you don't use FlutterFire CLI, update `lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIza...', // From Firebase Console
  appId: '1:123...', // From Firebase Console
  messagingSenderId: '123456789',
  projectId: 'signalbridge-xxxxx',
  databaseURL: 'https://signalbridge-xxxxx-default-rtdb.firebaseio.com',
  storageBucket: 'signalbridge-xxxxx.appspot.com',
);
```

## Database Rules (Important!)

In Firebase Console → Realtime Database → Rules:

**For Testing:**
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

## Costs

| Service | Cost |
|---------|------|
| Firebase Realtime DB | FREE (1GB storage, 10GB/month) |
| WebRTC P2P | FREE (unlimited) |
| STUN Servers | FREE |
| **Total** | **$0.00** |

## Troubleshooting

**"Firebase not initialized"**
```bash
flutter clean
flutter pub get
flutter run
```

**"Calls not connecting"**
- Check Firebase Realtime Database is enabled
- Verify both devices have internet
- Make sure database rules allow read/write

**"No incoming call"**
- Ensure receiving device has app running
- Check Firebase Console → Database → Data tab

## Features

✅ Auto-generated 8-digit user IDs  
✅ Save unlimited contacts  
✅ Audio calls (green phone icon)  
✅ Video calls (blue video icon)  
✅ Incoming call notifications  
✅ Accept/Reject calls  
✅ End call anytime  

## Next Steps

1. Run `flutterfire configure` to auto-setup Firebase
2. Install on two devices
3. Exchange user IDs
4. Start calling for FREE! 🎉

## Support

- Full setup guide: `P2P_SETUP.md`
- [Firebase Docs](https://firebase.google.com/docs)
- [WebRTC Docs](https://webrtc.org/)
