require('dotenv').config();

const cors = require('cors');
const express = require('express');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const MERCHANT_ID = process.env.PAYWAY_MERCHANT_ID || 'YOUR_MERCHANT_ID';
const BAKONG_ACCOUNT_ID = process.env.PAYWAY_BAKONG_ACCOUNT_ID || 'YOUR_BAKONG_ACCOUNT_ID';
const MERCHANT_NAME = process.env.PAYWAY_MERCHANT_NAME || 'YORN SOKH LEN';
const MERCHANT_CITY = process.env.PAYWAY_MERCHANT_CITY || 'Phnom Penh';
const CURRENCY_DEFAULT = process.env.PAYWAY_CURRENCY || 'USD';

const sessions = new Map();

function tlv(tag, value) {
  const text = String(value);
  return `${tag}${String(text.length).padStart(2, '0')}${text}`;
}

function crc16(input) {
  let crc = 0xffff;

  for (const code of input) {
    crc ^= code.charCodeAt(0) << 8;
    for (let i = 0; i < 8; i += 1) {
      if ((crc & 0x8000) !== 0) {
        crc = ((crc << 1) ^ 0x1021) & 0xffff;
      } else {
        crc = (crc << 1) & 0xffff;
      }
    }
  }

  return crc.toString(16).toUpperCase().padStart(4, '0');
}

function currencyToNumeric(currency) {
  const normalized = String(currency || CURRENCY_DEFAULT).toUpperCase();
  switch (normalized) {
    case 'KHR':
      return '116';
    case 'USD':
    default:
      return '840';
  }
}

function buildKhqrPayload({ orderId, amount, currency }) {
  const merchantInfo = [
    tlv('00', BAKONG_ACCOUNT_ID),
    tlv('01', MERCHANT_ID),
    tlv('02', 'ABA PayWay'),
  ].join('');

  const payload = [
    tlv('00', '01'),
    tlv('01', '12'),
    tlv('29', merchantInfo),
    tlv('52', '5999'),
    tlv('53', currencyToNumeric(currency)),
    tlv('54', Number(amount).toFixed(2)),
    tlv('58', 'KH'),
    tlv('59', MERCHANT_NAME),
    tlv('60', MERCHANT_CITY),
    tlv('62', tlv('01', orderId)),
  ].join('');

  const withCrcMarker = `${payload}6304`;
  return `${withCrcMarker}${crc16(withCrcMarker)}`;
}

function createSession({ orderId, amount, currency, merchantName, merchantCity }) {
  const now = new Date();
  const expiresAt = new Date(now.getTime() + 5 * 60 * 1000);

  const session = {
    transactionId: orderId,
    qrCode: buildKhqrPayload({ orderId, amount, currency }),
    amount: Number(amount),
    currency: currency || CURRENCY_DEFAULT,
    description: `Order #${orderId}`,
    timestamp: now.toISOString(),
    status: 'pending',
    merchantName: merchantName || MERCHANT_NAME,
    merchantCity: merchantCity || MERCHANT_CITY,
    expiresAt: expiresAt.toISOString(),
    confirmedAt: null,
    providerTransactionId: null,
  };

  sessions.set(orderId, session);
  return session;
}

function ensureSession(orderId) {
  return sessions.get(orderId) || null;
}

function setConfirmed(orderId, { amount, transactionId }) {
  const existing = ensureSession(orderId);
  const session = existing || createSession({ orderId, amount: amount || 0, currency: CURRENCY_DEFAULT });

  if (amount != null && Number(session.amount) !== Number(amount)) {
    return { error: 'Amount mismatch' };
  }

  session.status = 'confirmed';
  session.confirmedAt = new Date().toISOString();
  session.providerTransactionId = transactionId || `PAYWAY_${Date.now()}`;
  sessions.set(orderId, session);
  return { session };
}

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', provider: 'payway-sample-backend' });
});

app.post('/api/payway/payment-sessions', (req, res) => {
  const { orderId, amount, currency, merchantName, merchantCity } = req.body || {};

  if (!orderId) {
    return res.status(400).json({ error: 'orderId is required' });
  }

  if (amount == null || Number.isNaN(Number(amount)) || Number(amount) <= 0) {
    return res.status(400).json({ error: 'amount must be greater than zero' });
  }

  const session = createSession({
    orderId,
    amount,
    currency,
    merchantName,
    merchantCity,
  });

  return res.status(201).json(session);
});

app.get('/api/payway/payments/:orderId/status', (req, res) => {
  const { orderId } = req.params;
  const amount = req.query.amount;
  const session = ensureSession(orderId);

  if (!session) {
    return res.status(404).json({ status: 'pending' });
  }

  if (amount != null && Number(amount) !== Number(session.amount)) {
    return res.status(400).json({ status: 'failed', error: 'Amount mismatch' });
  }

  const expired = session.status === 'pending' && new Date(session.expiresAt).getTime() <= Date.now();
  if (expired) {
    session.status = 'expired';
    sessions.set(orderId, session);
    return res.status(410).json({ status: 'expired', error: 'Payment session expired' });
  }

  return res.json({
    orderId,
    status: session.status,
    amount: session.amount,
    currency: session.currency,
    transactionId: session.providerTransactionId,
    confirmedAt: session.confirmedAt,
    expiresAt: session.expiresAt,
  });
});

app.post('/api/payway/webhooks/aba', (req, res) => {
  const { orderId, amount, transactionId } = req.body || {};

  if (!orderId) {
    return res.status(400).json({ error: 'orderId is required' });
  }

  const result = setConfirmed(orderId, { amount, transactionId });
  if (result.error) {
    return res.status(400).json({ error: result.error });
  }

  return res.json({ success: true, status: result.session.status, orderId });
});

app.post('/api/payway/test/confirm-payment', (req, res) => {
  const { orderId, amount } = req.body || {};

  if (!orderId) {
    return res.status(400).json({ error: 'orderId is required' });
  }

  const result = setConfirmed(orderId, { amount, transactionId: `TEST_${Date.now()}` });
  if (result.error) {
    return res.status(400).json({ error: result.error });
  }

  return res.json({ success: true, status: result.session.status, orderId });
});

app.get('/api/payway/debug/payments', (_req, res) => {
  return res.json({
    merchant: {
      merchantId: MERCHANT_ID,
      bakongAccountId: BAKONG_ACCOUNT_ID,
      merchantName: MERCHANT_NAME,
      merchantCity: MERCHANT_CITY,
    },
    sessions: Array.from(sessions.values()),
  });
});

app.listen(PORT, () => {
  console.log(`PayWay sample backend running on http://localhost:${PORT}`);
  console.log(`POST /api/payway/payment-sessions`);
  console.log(`GET  /api/payway/payments/:orderId/status?amount=...`);
  console.log(`POST /api/payway/webhooks/aba`);
  console.log(`POST /api/payway/test/confirm-payment`);
});

