const http = require('http');

const BASE_URL = process.env.BASE_URL || 'http://127.0.0.1:3000';
const ORDER_ID = process.argv[2] || `ORDER_${Date.now()}`;
const AMOUNT = Number(process.argv[3] || '9.99');

function request(method, path, body) {
  const url = new URL(path, BASE_URL);

  return new Promise((resolve, reject) => {
    const req = http.request(
      url,
      {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          let parsed = data;
          try {
            parsed = data ? JSON.parse(data) : {};
          } catch (_) {}
          resolve({ statusCode: res.statusCode, body: parsed });
        });
      },
    );

    req.on('error', reject);

    if (body) {
      req.write(JSON.stringify(body));
    }

    req.end();
  });
}

async function main() {
  console.log(`Base URL: ${BASE_URL}`);
  console.log(`Order ID: ${ORDER_ID}`);
  console.log(`Amount: ${AMOUNT}`);

  console.log('\n1) Creating payment session...');
  const created = await request('POST', '/api/payway/payment-sessions', {
    orderId: ORDER_ID,
    amount: AMOUNT,
    currency: 'USD',
    merchantName: 'YORN SOKH LEN',
    merchantCity: 'Phnom Penh',
  });
  console.log(created);

  console.log('\n2) Checking status...');
  const status1 = await request('GET', `/api/payway/payments/${ORDER_ID}/status?amount=${AMOUNT}`);
  console.log(status1);

  console.log('\n3) Confirming payment...');
  const confirmed = await request('POST', '/api/payway/test/confirm-payment', {
    orderId: ORDER_ID,
    amount: AMOUNT,
  });
  console.log(confirmed);

  console.log('\n4) Checking status again...');
  const status2 = await request('GET', `/api/payway/payments/${ORDER_ID}/status?amount=${AMOUNT}`);
  console.log(status2);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
