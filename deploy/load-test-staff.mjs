const baseUrl = process.env.API_BASE_URL ?? 'http://127.0.0.1:3000/api';
const username = process.env.STAFF_USERNAME ?? 'owner';
const password = process.env.STAFF_PASSWORD;
const staffCount = Number(process.env.STAFF_COUNT ?? '8');
const parcelsPerStaff = Number(process.env.PARCELS_PER_STAFF ?? '10');

if (!password) {
  throw new Error('STAFF_PASSWORD is required');
}

async function request(path, options = {}) {
  const response = await fetch(`${baseUrl}${path}`, {
    ...options,
    headers: {
      'content-type': 'application/json',
      ...(options.token ? { authorization: `Bearer ${options.token}` } : {}),
      ...options.headers,
    },
    body:
      options.body === undefined ? undefined : JSON.stringify(options.body),
  });
  if (!response.ok) {
    throw new Error(`${options.method ?? 'GET'} ${path} ${response.status}: ${await response.text()}`);
  }
  return response.json();
}

const login = await request('/auth/login', {
  method: 'POST',
  body: { username, password, rememberMe: false },
});

const startedAt = Date.now();
await Promise.all(
  Array.from({ length: staffCount }, async (_, staffIndex) => {
    for (let itemIndex = 0; itemIndex < parcelsPerStaff; itemIndex += 1) {
      const code = `LOAD-${Date.now()}-${staffIndex}-${itemIndex}`;
      await request('/parcels/receive', {
        method: 'POST',
        token: login.accessToken,
        body: {
          trackingCode: code,
          customerName: `Load Staff ${staffIndex}`,
          clientMutationId: `load-r-${code}`,
        },
      });
      await request(`/parcels/${encodeURIComponent(code)}/arrive`, {
        method: 'POST',
        token: login.accessToken,
        body: { clientMutationId: `load-a-${code}` },
      });
      await request(`/parcels/${encodeURIComponent(code)}/pickup`, {
        method: 'POST',
        token: login.accessToken,
        body: { clientMutationId: `load-p-${code}` },
      });
    }
  }),
);

console.log(
  JSON.stringify(
    {
      staffCount,
      parcelsPerStaff,
      totalParcels: staffCount * parcelsPerStaff,
      durationMs: Date.now() - startedAt,
    },
    null,
    2,
  ),
);
