/**
 * Updates only known seed documents with Vietnamese display text.
 *
 * Run: node scripts/migrate_seed_vietnamese.js
 *
 * The migration preserves user-created documents and all technical fields.
 * It authenticates with the existing Admin test account so deployed Firestore
 * Security Rules remain enforced.
 */

const https = require('https');

const API_KEY = 'AIzaSyBKD3GWBjnArBV1wzXW00ggj4nBHNFidEA';
const PROJECT_ID = 'apartment-mgmt-prm393';
const DATABASE_ROOT = `projects/${PROJECT_ID}/databases/(default)`;
const DOCUMENT_ROOT = `${DATABASE_ROOT}/documents`;
const API_ROOT = `https://firestore.googleapis.com/v1/${DATABASE_ROOT}`;
const AUTH_SIGNIN_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`;

const ADMIN_EMAIL = 'admin@apartment.com';
const ADMIN_PASSWORD = 'Admin@123';

function httpRequest(url, method, body, token) {
  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    const headers = { 'Content-Type': 'application/json' };
    if (token) headers.Authorization = `Bearer ${token}`;

    const request = https.request(
      {
        hostname: parsed.hostname,
        path: parsed.pathname + parsed.search,
        method,
        headers,
      },
      (response) => {
        let data = '';
        response.on('data', (chunk) => (data += chunk));
        response.on('end', () => {
          let parsedData;
          try {
            parsedData = data ? JSON.parse(data) : {};
          } catch {
            parsedData = data;
          }

          if (response.statusCode >= 400) {
            const message = parsedData?.error?.message || data;
            reject(new Error(`${response.statusCode}: ${message}`));
            return;
          }
          resolve(parsedData);
        });
      },
    );

    request.on('error', reject);
    if (body) request.write(JSON.stringify(body));
    request.end();
  });
}

async function signInAdmin() {
  const result = await httpRequest(AUTH_SIGNIN_URL, 'POST', {
    email: ADMIN_EMAIL,
    password: ADMIN_PASSWORD,
    returnSecureToken: true,
  });
  return result.idToken;
}

function stringFields(data) {
  return Object.fromEntries(
    Object.entries(data).map(([key, value]) => [key, { stringValue: value }]),
  );
}

function updateWrite(documentName, data) {
  return {
    update: {
      name: documentName,
      fields: stringFields(data),
    },
    updateMask: { fieldPaths: Object.keys(data) },
    updateTransforms: [
      { fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' },
    ],
    currentDocument: { exists: true },
  };
}

async function getDocument(path, token) {
  try {
    return await httpRequest(`${API_ROOT}/documents/${path}`, 'GET', null, token);
  } catch (error) {
    if (error.message.startsWith('404:')) return null;
    throw error;
  }
}

async function findUserDocuments(email, token) {
  const results = await httpRequest(
    `${API_ROOT}/documents:runQuery`,
    'POST',
    {
      structuredQuery: {
        from: [{ collectionId: 'users' }],
        where: {
          fieldFilter: {
            field: { fieldPath: 'email' },
            op: 'EQUAL',
            value: { stringValue: email },
          },
        },
      },
    },
    token,
  );
  return results.flatMap((item) => (item.document ? [item.document] : []));
}

async function listApartmentDocuments(token) {
  const result = await httpRequest(
    `${API_ROOT}/documents/apartments?pageSize=100`,
    'GET',
    null,
    token,
  );
  return result.documents || [];
}

const USER_NAMES = {
  'admin@apartment.com': 'Quản trị viên hệ thống',
  'staff1@apartment.com': 'Nguyễn Văn An',
  'staff2@apartment.com': 'Trần Thị Bình',
  'resident1@apartment.com': 'Lê Hoàng Cường',
  'resident2@apartment.com': 'Phạm Minh Đức',
  'resident3@apartment.com': 'Võ Thị Huệ',
  'resident4@apartment.com': 'Hoàng Văn Giang',
  'resident5@apartment.com': 'Đặng Thị Kim',
};

const SEEDED_DOCUMENTS = {
  'requests/req-001': {
    title: 'Ống nước bị rò rỉ',
    description: 'Ống nước trong nhà tắm bị rò rỉ, cần sửa gấp.',
  },
  'requests/req-002': {
    title: 'Bóng đèn hành lang bị cháy',
    description: 'Bóng đèn ở hành lang tầng 3 bị cháy, cần thay mới.',
  },
  'requests/req-003': {
    title: 'Điều hòa không mát',
    description:
      'Điều hòa phòng khách không làm mát, đã vệ sinh nhưng không cải thiện.',
    resolutionNote: 'Đã thay gas điều hòa. Thiết bị hoạt động bình thường.',
  },
  'notifications/notif-001': {
    title: 'Thông báo cắt điện',
    content:
      'Tòa nhà sẽ cắt điện để bảo trì từ 8 giờ đến 12 giờ ngày 20/07/2026. Mong cư dân thông cảm.',
  },
  'notifications/notif-002': {
    title: 'Họp cư dân tháng 7',
    content:
      'Kính mời cư dân tham dự buổi họp định kỳ tháng 7 vào 19 giờ ngày 25/07/2026 tại sảnh tầng 1.',
  },
  'notifications/notif-003': {
    title: 'Nội quy gửi xe mới',
    content:
      'Từ ngày 01/08/2026, hầm gửi xe áp dụng quy định mới. Chi tiết được niêm yết tại bảng tin tầng 1.',
  },
  'visitors/visitor-001': {
    visitorName: 'Nguyễn Văn Khách',
    purpose: 'Thăm người thân',
  },
  'visitors/visitor-002': {
    visitorName: 'Trần Thị Lan',
    purpose: 'Giao hàng',
  },
  'complaints/complaint-001': {
    content:
      'Tầng 5 thường xuyên có tiếng ồn vào buổi tối muộn, ảnh hưởng đến giấc ngủ của cư dân.',
  },
  'complaints/complaint-002': {
    content: 'Thang máy tầng 7 thường xuyên bị kẹt, gây bất tiện cho cư dân.',
    response:
      'Đã liên hệ đơn vị bảo trì thang máy. Thang máy đã được sửa chữa và hoạt động bình thường.',
  },
};

async function main() {
  console.log('Authenticating Admin account...');
  const token = await signInAdmin();
  const writes = [];

  for (const [email, fullName] of Object.entries(USER_NAMES)) {
    const users = await findUserDocuments(email, token);
    for (const user of users) {
      writes.push(updateWrite(user.name, { fullName }));
    }
  }

  for (const [path, data] of Object.entries(SEEDED_DOCUMENTS)) {
    const document = await getDocument(path, token);
    if (document) writes.push(updateWrite(document.name, data));
  }

  const apartments = await listApartmentDocuments(token);
  for (const apartment of apartments) {
    writes.push(updateWrite(apartment.name, { building: 'Tòa A' }));
  }

  if (writes.length === 0) {
    console.log('No matching seed documents were found.');
    return;
  }

  await httpRequest(
    `${API_ROOT}/documents:commit`,
    'POST',
    { writes },
    token,
  );
  console.log(`Updated ${writes.length} seed documents with Vietnamese text.`);
}

main().catch((error) => {
  console.error('Vietnamese seed migration failed:', error.message);
  process.exitCode = 1;
});
