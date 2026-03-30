# How to Make Calls - Pure P2P

## 🎯 Quick Guide

Your app uses **manual code exchange** for P2P calling. Here's how:

---

## 📞 Making a Call (You're the Caller)

### Step 1: Initiate Call
1. Open Dashboard
2. Find your contact
3. Click **green phone icon** (audio) or **blue video icon** (video)

### Step 2: Share Offer Code
1. Dialog appears with **Offer Code**
2. Click **"Copy Offer"** button
3. Send code to your contact via:
   - WhatsApp
   - SMS
   - Telegram
   - Any messaging app

**Example Offer Code:**
```json
{"callerId":"12345678","offer":"v=0\r\no=- 123...","targetId":"87654321"}
```

### Step 3: Wait for Answer
1. Contact receives your offer
2. Contact accepts call
3. Contact sends back **Answer Code**

### Step 4: Complete Connection
1. Paste the **Answer Code** in the text field
2. Click **"Connect"** button
3. ✅ **Call connected!**

---

## 📲 Receiving a Call (You're the Receiver)

### Step 1: Receive Offer Code
Someone sends you an offer code via WhatsApp/SMS/etc.

**Example:**
```json
{"callerId":"61525007","offer":"v=0\r\no=- 4933...","targetId":"84222431"}
```

### Step 2: Open Receive Dialog
1. Open Dashboard
2. Click **green "Receive Call" button** (bottom floating button)
3. Paste the offer code in the text field
4. Click **"Accept Call"**

### Step 3: Share Answer Code
1. Call screen appears
2. Click **"Accept"** (green button)
3. Dialog shows **Answer Code**
4. Click **"Copy & Continue"**
5. Send answer code back to caller

**Example Answer Code:**
```json
{"answer":"v=0\r\no=- 789...","callerId":"84222431"}
```

### Step 4: Connected!
Caller pastes your answer → ✅ **Call connected!**

---

## 🎨 UI Elements

### Dashboard Buttons

**Bottom Right (2 Floating Buttons):**
- 🟢 **Green button** (top) = Receive incoming call (paste offer)
- 🔵 **Blue button** (bottom) = Add new contact

**Contact List:**
- 🟢 **Phone icon** = Audio call
- 🔵 **Video icon** = Video call
- ✏️ **Edit icon** = Edit contact
- 🔴 **Delete icon** = Delete contact

---

## 📋 Example Flow

### Complete Call Example

**Device A (Caller - ID: 12345678)**
1. Clicks call on contact "87654321"
2. Gets offer code:
   ```json
   {"callerId":"12345678","offer":"v=0...","targetId":"87654321"}
   ```
3. Copies and sends via WhatsApp to Device B
4. Waits...

**Device B (Receiver - ID: 87654321)**
1. Receives offer code on WhatsApp
2. Opens app → Clicks green "Receive Call" button
3. Pastes offer code → Clicks "Accept Call"
4. Clicks green "Accept" button
5. Gets answer code:
   ```json
   {"answer":"v=0...","callerId":"87654321"}
   ```
6. Copies and sends back to Device A

**Device A (Caller)**
1. Receives answer code
2. Pastes in "Answer Code" field
3. Clicks "Connect"
4. ✅ **Call connected!**

---

## 💡 Tips

### For Best Experience:
- ✅ Keep both apps open during setup
- ✅ Copy entire code (don't miss any characters)
- ✅ Use a reliable messaging app
- ✅ Both devices need internet connection

### Troubleshooting:
- ❌ **"Invalid code"** → Copy the entire code again
- ❌ **"Not connecting"** → Check internet on both devices
- ❌ **"No audio/video"** → Grant permissions in settings

---

## 🔒 Privacy

**Your codes are private:**
- Codes only work between you and your contact
- No server sees your codes
- Exchange via your trusted messaging app
- Call audio/video goes directly P2P

---

## 🚀 Why Manual Exchange?

**Advantages:**
- ✅ Zero cost (no server needed)
- ✅ Complete privacy (you control the codes)
- ✅ Works with any messaging app
- ✅ No registration required
- ✅ No cloud dependency

**Trade-off:**
- ⚠️ Requires copy/paste (2 codes per call)
- ⚠️ Both users must be active

---

## 📱 Quick Reference

| Action | Button | Location |
|--------|--------|----------|
| Receive Call | 🟢 Green FAB | Bottom right (top) |
| Add Contact | 🔵 Blue FAB | Bottom right (bottom) |
| Audio Call | 🟢 Phone icon | Contact list |
| Video Call | 🔵 Video icon | Contact list |

---

## ✨ That's It!

You're now ready to make **free, private, peer-to-peer calls** without any cloud services!

**Remember:** 
1. Caller sends **Offer**
2. Receiver sends **Answer**
3. Connected! 🎉
