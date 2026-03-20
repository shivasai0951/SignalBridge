# Tencent Cloud TRTC Setup Guide

## Overview
Your SignalBridge app now automatically handles authentication - **no login UI needed**! Each user gets a unique ID automatically, and the app generates authentication tokens in the background.

## Quick Setup (5 minutes)

### Step 1: Get Tencent Cloud Credentials

1. **Sign up** at [Tencent Cloud Console](https://console.cloud.tencent.com/)
2. Navigate to **TRTC (Tencent Real-Time Communication)**
3. Create a new application
4. You'll receive:
   - **SDKAppID** (a number like `1400123456`)
   - **Secret Key** (a string like `abc123def456...`)

### Step 2: Configure Your App

Open `lib/Service/tencent_config.dart` and replace the placeholder values:

```dart
class TencentConfig {
  static const int sdkAppId = 1400123456;  // ← Your actual SDKAppID
  
  static const String secretKey = "your_actual_secret_key_here";  // ← Your actual Secret Key
}
```

### Step 3: Test the App

1. **Install on Device A**
   - App auto-generates User ID (e.g., `84222431`)
   - Copy this ID from the Dashboard

2. **Install on Device B**
   - App auto-generates different User ID (e.g., `92847562`)
   - Add Device A's ID as a contact

3. **Make a Call**
   - Device B clicks call button
   - Device A receives incoming call notification
   - Accept → Connected! ✅

## How It Works (No Login Required)

```
User Opens App
    ↓
Auto-generates unique User ID (saved locally)
    ↓
Auto-generates UserSig token (using your Secret Key)
    ↓
Auto-authenticates with Tencent Cloud
    ↓
Ready to make/receive calls!
```

## Security Notes

⚠️ **Important**: The `secretKey` is currently stored in the app code. For production apps:
- Move secret key generation to a backend server
- Have the app request UserSig from your server (not generate it locally)
- This prevents users from extracting your secret key

For testing/development, the current setup works perfectly fine.

## Troubleshooting

### Error: "Invalid login, please login again"
- Check that `sdkAppId` and `secretKey` in `tencent_config.dart` are correct
- Verify your Tencent Cloud TRTC application is active
- Make sure you copied the Secret Key correctly (no extra spaces)

### Calls not connecting
- Ensure both devices have valid Tencent credentials configured
- Check internet connection on both devices
- Verify both users have different User IDs

### No incoming call notification
- Make sure the receiving device has the app running
- Check that `CallService.instance.setContext(context)` is called (already done in Dashboard)

## Cost

Tencent Cloud TRTC offers:
- **Free tier**: 10,000 minutes/month
- Perfect for testing and small-scale apps
- Check [Tencent Cloud Pricing](https://www.tencentcloud.com/pricing/trtc) for details

## Support

For Tencent Cloud TRTC issues:
- [Official Documentation](https://www.tencentcloud.com/document/product/647)
- [Flutter SDK Guide](https://www.tencentcloud.com/document/product/647/39243)
