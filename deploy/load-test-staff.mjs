const baseUrl = process.env.API_BASE_URL ?? 'http://127.0.0.1:3000/api';
const adminUsername = process.env.ADMIN_USERNAME ?? 'owner';
const adminPassword = process.env.ADMIN_PASSWORD;
const staffCount = Number(process.env.STAFF_COUNT ?? '8');
const parcelsPerStaff = Number(process.env.PARCELS_PER_STAFF ?? '10');
const runId = Date.now();

if (!adminPassword) {
  throw new Error('ADMIN_PASSWORD is required');
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

async function login(username, password) {
  return request('/auth/login', {
    method: 'POST',
    body: { username, password, rememberMe: false },
  });
}

const admin = await login(adminUsername, adminPassword);
const staffUsers = await Promise.all(
  Array.from({ length: staffCount }, async (_, index) => {
    const username = `load_staff_${runId}_${index}`;
    const password = `LoadPass${runId}${index}!`;
    await request('/users', {
      method: 'POST',
      token: admin.accessToken,
      body: {
        username,
        password,
        displayName: `Load Staff ${index}`,
        role: 'STAFF',
      },
    });
    const session = await login(username, password);
    return { index, username, token: session.accessToken };
  }),
);

const startedAt = Date.now();
await Promise.all(
  staffUsers.map(async (staff) => {
    for (let itemIndex = 0; itemIndex < parcelsPerStaff; itemIndex += 1) {
      const code = `LOAD-${runId}-${staff.index}-${itemIndex}`;
      await request('/parcels/receive', {
        method: 'POST',
        token: staff.token,
        body: {
          trackingCode: code,
          customerName: `Load Customer ${staff.index}`,
          clientMutationId: `load-r-${code}`,
        },
      });
      await request(`/parcels/${encodeURIComponent(code)}/arrive`, {
        method: 'POST',
        token: staff.token,
        body: { clientMutationId: `load-a-${code}` },
      });
      await request(`/parcels/${encodeURIComponent(code)}/pickup`, {
        method: 'POST',
        token: staff.token,
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
      staffUsers: staffUsers.map((staff) => staff.username),
    },
    null,
    2,
  ),
);
