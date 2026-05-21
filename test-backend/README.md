# PayWay Sample Backend

This folder contains a small Node.js backend you can use to test the Flutter checkout flow before plugging into real ABA PayWay webhooks.

## What it does

- Creates a payment session at `POST /api/payway/payment-sessions`
- Returns a KHQR payload for the Flutter app to render
- Lets the app poll payment status at `GET /api/payway/payments/:orderId/status`
- Lets you confirm a payment manually or through a future ABA webhook

## Install

```powershell
cd D:\LEN\fast_food_app\test-backend
npm install
```

## Run

```powershell
npm start
```

## Optional environment variables

Create a `.env` file in this folder or export variables before running:

```bash
PORT=3000
PAYWAY_MERCHANT_ID=1748758
PAYWAY_BAKONG_ACCOUNT_ID=yorn_sokhlen@bkrt
PAYWAY_MERCHANT_NAME=YORN SOKH LEN
PAYWAY_MERCHANT_CITY=Phnom Penh
PAYWAY_CURRENCY=USD
```

## Flutter configuration

The Flutter app already points to:

```dart
static const String _baseUrl = 'http://127.0.0.1:3000';
```

If you deploy the backend elsewhere, set `PAYWAY_BACKEND_URL` at build time.

## Test the backend quickly

```powershell
npm run demo -- ORDER_123 9.99
```

This will:

1. Create a payment session
2. Check status
3. Mark the payment as confirmed
4. Check status again

## API summary

### `POST /api/payway/payment-sessions`

Body:

```json
{
  "orderId": "ORDER_123",
  "amount": 9.99,
  "currency": "USD",
  "merchantName": "YORN SOKH LEN",
  "merchantCity": "Phnom Penh"
}
```

Response includes:

- `transactionId`
- `qrCode`
- `amount`
- `currency`
- `description`
- `timestamp`
- `status`

### `GET /api/payway/payments/:orderId/status?amount=9.99`

Returns:

```json
{ "status": "pending" }
```

or:

```json
{ "status": "confirmed" }
```

### `POST /api/payway/test/confirm-payment`

Body:

```json
{ "orderId": "ORDER_123", "amount": 9.99 }
```

Use this to simulate an ABA PayWay webhook during local development.

## Production path

When you have the real ABA PayWay webhook/API docs:

1. Keep the same session/status endpoints
2. Replace the manual test-confirm endpoint with a real webhook receiver
3. Store sessions in a database instead of memory
4. Secure the webhook with signature verification
5. Point Flutter to your production backend URL

