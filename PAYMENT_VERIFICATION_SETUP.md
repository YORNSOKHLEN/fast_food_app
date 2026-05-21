# Payment Verification Setup Guide

## Overview
Your app now implements **real ABA KHQR payment verification** with polling. The app will:

1. Generate an ABA KHQR QR code
2. **Poll your backend** every 2 seconds for 5 minutes to verify payment
3. **Only save the order** after payment is confirmed by ABA
4. Show real-time verification status to the user

## What You Need to Do

### 1. Set Backend URL
Update the backend URL in `lib/data/repositories/payment/payment_verification_service.dart`:

```dart
static const String _baseUrl = 'YOUR_BACKEND_URL'; // Change this!
// Example: 'https://api.yourapp.com'
```

### 2. Create Backend Endpoint

Your backend must implement this endpoint:

**Endpoint:**
```
GET /api/payment/verify/{orderId}?merchantId={merchantId}&amount={amount}
```

**Query Parameters:**
- `orderId` (string): Order ID from the app
- `merchantId` (string): Your ABA merchant ID (`ec475573`)
- `amount` (number): Payment amount in USD

**Response (JSON):**
```json
Success:
{
  "status": "confirmed",
  "transactionId": "ABA_TXN_123456",
  "timestamp": "2026-05-20T10:30:00Z"
}

Pending:
{
  "status": "pending"
}

Failed:
{
  "status": "failed",
  "error": "Payment not received"
}
```

---

## Implementation Strategies

### **Option A: Direct ABA Integration** (Recommended for Production)

Your backend should:
1. Have a database table for pending payments
2. When user pays via KHQR, the ABA payment gateway sends a **webhook/callback** to your server
3. Your server saves the confirmed payment to the database
4. App polls your endpoint → you query the database → return status

**ABA Webhook Integration:**
- Register webhook URL with ABA
- Example: `https://yourapi.com/webhooks/aba-payment`
- ABA posts to this when payment is confirmed
- Save payment confirmation to database with `orderId`

**Backend Pseudocode (Node.js):**
```javascript
// Save payments when ABA webhook confirms
app.post('/webhooks/aba-payment', (req, res) => {
  const { orderId, amount, transactionId } = req.body;
  
  // Save to database
  db.payments.create({
    orderId,
    status: 'confirmed',
    aba_transaction_id: transactionId
  });
  
  res.json({ success: true });
});

// App polls this endpoint
app.get('/api/payment/verify/:orderId', (req, res) => {
  const { orderId } = req.params;
  const { merchantId, amount } = req.query;
  
  const payment = db.payments.findOne({ orderId });
  
  if (payment?.status === 'confirmed') {
    return res.json({ 
      status: 'confirmed',
      transactionId: payment.aba_transaction_id
    });
  }
  
  return res.json({ status: 'pending' });
});
```

---

### **Option B: KHQR SDK Integration** (Alternative)

If ABA provides a KHQR SDK/API:
1. Your backend calls ABA's API to check transaction status
2. Backend response with confirmed/pending/failed

**Backend Pseudocode:**
```javascript
app.get('/api/payment/verify/:orderId', async (req, res) => {
  const { orderId } = req.params;
  const { merchantId, amount } = req.query;
  
  // Query ABA's payment API
  const abaResponse = await ABA_API.checkTransaction({
    merchantId,
    orderId,
    amount
  });
  
  if (abaResponse.status === 'COMPLETED') {
    return res.json({ 
      status: 'confirmed',
      transactionId: abaResponse.txnId
    });
  }
  
  return res.json({ status: 'pending' });
});
```

---

### **Option C: Database Polling** (Development/Testing)

For testing without ABA integration:

**Backend Pseudocode:**
```javascript
// Simulate payment confirmation after 3 seconds
app.post('/api/payment/simulate/:orderId', (req, res) => {
  const { orderId } = req.params;
  
  // Simulate: mark as confirmed after 3 seconds
  setTimeout(() => {
    db.payments.update(
      { orderId },
      { status: 'confirmed' }
    );
  }, 3000);
  
  res.json({ success: true });
});

// App polls this
app.get('/api/payment/verify/:orderId', (req, res) => {
  const payment = db.payments.findOne({ orderId });
  return res.json({ 
    status: payment?.status || 'pending'
  });
});
```

---

## Testing Checklist

- [ ] Backend endpoint created and accessible
- [ ] Backend URL set in `payment_verification_service.dart`
- [ ] Payment verification working in development
- [ ] App shows "Payment Confirmed" after payment received
- [ ] Order saves automatically after verification
- [ ] Timeout handling (5 minutes without confirmation)

---

## Error Handling

The app automatically:
- **Retries** if network error occurs
- **Continues polling** for 5 minutes (QR validity)
- **Shows status** to user in real-time
- **Disables "Continue"** button until verified
- **Prevents saving order** without verification

---

## Important Notes

⚠️ **Security:**
- Verify `merchantId` and `amount` match before confirming
- Validate HTTPS only in production
- Add authentication/API key to your endpoint

⚠️ **ABA Merchant Credentials:**
Your credentials are in `lib/data/repositories/payment/khqr_payment_repository.dart`:
- `merchantId = 'ec475573'`
- `bakongAccountId = 'yorn_sokhlen@bkrt'`

**Remember:** The KHQR QR code can only verify payment through ABA's system, not through your app. Real money only transfers when users scan and pay through ABA Mobile or compatible apps.

---

## Contact ABA for:
- KHQR production credentials (if testing)
- Webhook endpoint documentation
- Transaction verification API
- Support for direct ABA payment status checks

---

## Example: Full Node.js Implementation

```javascript
const express = require('express');
const app = express();

// Mock database
const payments = {};

// Webhook from ABA (when payment is received)
app.post('/webhooks/aba-payment', express.json(), (req, res) => {
  const { orderId, amount, transactionId } = req.body;
  payments[orderId] = { 
    status: 'confirmed', 
    aba_txn: transactionId,
    amount,
    timestamp: new Date()
  };
  res.json({ success: true });
});

// App polls this every 2 seconds
app.get('/api/payment/verify/:orderId', (req, res) => {
  const { orderId } = req.params;
  const payment = payments[orderId];
  
  if (payment?.status === 'confirmed') {
    return res.json({ status: 'confirmed', transactionId: payment.aba_txn });
  }
  
  return res.json({ status: 'pending' });
});

app.listen(3000, () => console.log('Payment API running...'));
```

---

## Debugging

Enable logging in `payment_verification_service.dart` to see polling requests:

```dart
// In PaymentVerificationService
print('Polling payment status for $orderId...');
print('Response: ${response.statusCode} - ${response.body}');
```

Check Firebase/backend logs for:
- Incoming webhook calls from ABA
- Payment verification requests from app
- Order save confirmations

