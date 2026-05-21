# Payment Verification Architecture

## System Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                                 │
│                    (fast_food_app)                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ABA QR Payment Screen                                             │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │ [QR Code]                                                  │   │
│  │                                                            │   │
│  │ Status: ✓ Payment confirmed!                              │   │
│  │ (Auto-updated via PaymentVerificationService)             │   │
│  │                                                            │   │
│  │ [CONTINUE BUTTON] ← Enabled only after verified ✅        │   │
│  │ [CANCEL BUTTON]                                           │   │
│  └────────────────────────────────────────────────────────────┘   │
│                            ↑                                        │
│                            │                                        │
│                   PaymentVerificationService                        │
│                   ┌──────────────────────────┐                      │
│                   │ Polls every 2 seconds    │                      │
│                   │ for 5 minutes             │                      │
│                   └──────────────────────────┘                      │
│                            │                                        │
│                            ↓ (HTTP GET)                             │
└──────────────────────────────────────────────────────────┬──────────┘
                            ↓
        ┌──────────────────────────────────────────┐
        │    YOUR BACKEND                          │
        │    /api/payment/verify/{orderId}         │
        ├──────────────────────────────────────────┤
        │  Endpoint Response:                      │
        │  {                                       │
        │    "status": "pending"|"confirmed"|..    │
        │  }                                       │
        └──────────────────────────────────────────┘
                            ↑
                            │
        ┌───────────────────┴────────────────────┐
        ↓                                        ↓
    [WEBHOOK FROM ABA]                  [DIRECT API CHECK]
    When payment received                Against ABA Payment API
    
    ABA Bank
    ┌──────────────────────────────┐
    │ User scans KHQR QR code      │
    │ Pays via ABA Mobile App      │
    │ ABA confirms payment         │
    │ ...notifies your backend      │
    └──────────────────────────────┘
```

---

## Data Flow - Step by Step

### 1. User Initiates Payment
```
Order Controller
    └─→ Generate Order ID
    └─→ Show ABA QR Payment Screen
    └─→ Pass orderId & amount
```

### 2. Payment Screen Loads
```
ABA QR Payment Screen
    ├─→ Generate KHQR QR Code via khqr_payment_repository
    ├─→ Display beautiful QR
    └─→ Start PaymentVerificationService polling
```

### 3. Polling Starts (Background)
```
PaymentVerificationService.verifyPaymentWithPolling()
    ├─→ Loop every 2 seconds:
    │   ├─→ GET /api/payment/verify/{orderId}
    │   ├─→ Check response status
    │   ├─→ Update UI with status
    │   └─→ Repeat until confirmed or timeout
    │
    ├─→ Return true if confirmed
    └─→ Return false if timeout (5 min)
```

### 4. User Scans & Pays
```
ABA Mobile App (or KhqrCardWidget)
    ├─→ User scans QR code
    ├─→ Enters amount
    ├─→ Confirms payment
    └─→ Payment sent to ABA
```

### 5. Backend Receives Payment
```
Your Backend
    ├─→ Receives ABA webhook callback
    │   (or checks ABA API)
    ├─→ Verifies transactionId
    ├─→ Saves to database: 
    │   {
    │     orderId: "XYZ123",
    │     status: "confirmed",
    │     aba_txn_id: "ABA_12345"
    │   }
    └─→ Response ready for polling
```

### 6. App Detects Payment
```
PaymentVerificationService
    ├─→ Polls again (every 2 sec)
    ├─→ Backend returns: { status: "confirmed" }
    ├─→ Polling stops ✓
    └─→ Returns true to screen
```

### 7. App Shows Success
```
ABA QR Payment Screen
    ├─→ Status → "✓ Payment confirmed by ABA!"
    ├─→ Button → Enabled
    ├─→ User sees success state
    └─→ Ready to continue
```

### 8. Order Saves
```
Order Controller
    ├─→ User clicks "Continue"
    ├─→ Calls _saveOrderAndComplete()
    ├─→ Save to Firestore
    ├─→ Clear cart
    └─→ Show success screen ✅
```

---

## File Relationships

```
aba_qr_payment_screen.dart
│
├── Uses: PaymentVerificationService
│         (polls backend for verification)
│
├── Uses: KHQRPaymentRepository
│         (generates QR code)
│
├── Uses: KhqrCardWidget
│         (displays QR beautifully)
│
└── Returns: true/false to OrderController


OrderController
│
├── Calls: ABAQRPaymentScreen
│          (shows payment UI)
│
├── Receives: true if verified, false if not
│
└── Then: Either saves order OR shows error
         (only if true)


Your Backend API
│
├── Receives: GET /api/payment/verify/{orderId}?merchantId=...&amount=...
│
├── Checks: Database for payment confirmation
│           (from ABA webhook)
│
└── Returns: { status: "confirmed"|"pending"|"failed" }
```

---

## Polling Timeline Example

```
T=0s     User sees QR
         Status: "Waiting for KHQR scan..."
         
         [Backend: Payment not yet received]
         
T=2s     Poll 1: GET /api/payment/verify/order123
         Response: { status: "pending" }
         Status UI: "Checking payment... (2s elapsed)"
         
T=4s     Poll 2: GET /api/payment/verify/order123
         Response: { status: "pending" }
         Status UI: "Checking payment... (4s elapsed)"
         
[... User scans QR and pays in ABA Mobile ...]
[... Backend receives webhook from ABA ...]
[... Backend saves payment to database ...]

T=12s    Poll 6: GET /api/payment/verify/order123
         Response: { status: "confirmed" }
         Status UI: "✓ Payment confirmed by ABA!"
         Button: ENABLED ✅
         
T=13s    User clicks [Continue]
         Order saves to Firebase
         Success screen shows
```

---

## Testing the Full Flow

```
┌─────────────────────────────────────────┐
│ Terminal 1: Flutter App                 │
│ $ flutter run                           │
│ Show ABA QR Screen                      │
│ Polling starts...                       │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│ Terminal 2: Test Backend                │
│ $ node server.js                        │
│ Listening on http://localhost:3000      │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│ Terminal 3: Trigger Payment             │
│ $ curl -X POST http://localhost:3000... │
│ Confirm payment for orderId             │
│ (See package installation in your app)  │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│ Watch Terminal 1 (Flutter App)          │
│ Status changes to "Payment confirmed!" │
│ Button becomes enabled                  │
│ Order saves                             │
└─────────────────────────────────────────┘
```

---

## Configuration Files

### 1. Flutter App - payment_verification_service.dart
```dart
static const String _baseUrl = 'YOUR_BACKEND_URL';
// ↑ Change this to your backend URL
```

### 2. Your Backend - API Endpoint
```
GET /api/payment/verify/{orderId}
    Query params: merchantId, amount
    Returns: { status: "pending"|"confirmed" }
```

### 3. ABA Integration
```
Webhook: POST /webhooks/aba-payment
    Body: { orderId, amount, transactionId, ... }
    Save to database with status: "confirmed"
```

---

## Environment Scenarios

### Development (Local Testing)
```
Flutter App
    ↓
http://localhost:3000/api/payment/verify
    ↓
Test Backend (server.js in test-backend/)
    ↓
In-memory mock payment storage
```

### Staging (Sandbox ABA)
```
Flutter App
    ↓
https://staging-api.yourapp.com/api/payment/verify
    ↓
Your Staging Backend
    ↓
ABA Sandbox webhook → Database
```

### Production (Real ABA)
```
Flutter App
    ↓
https://api.yourapp.com/api/payment/verify
    ↓
Your Production Backend
    ↓
Real ABA webhook → Database
```

---

## Security Layers

```
️Frontend Security (Flutter)
├── Verify merchantId matches
├── Verify amount matches
├── Timeout after 5 minutes
└── Disable button until verified

Backend Security (Node.js/Python/etc)
├── Validate API key/authentication
├── Check merchant against order record
├── Verify amount before confirming
├── Log all confirmations
└── Add idempotency checks

ABA Integration Security
├── Verify webhook signature
├── Check request source
├── Add rate limiting
└── TLS/HTTPS only
```

---

## Summary

**Old:** App → Click button → Save order ❌
**New:** App → Poll backend → Get verified → Save order ✅

The payment verification service is the bridge between your app and actual payment confirmation from ABA, ensuring orders only save when real payment is confirmed.

