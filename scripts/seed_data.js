/**
 * Seed Data Script for Apartment Building Management System
 * 
 * Run: node scripts/seed_data.js
 * 
 * This script creates:
 * - Firebase Auth users (admin, staff, residents)
 * - Firestore documents (apartments, bills, requests, announcements, visitors, complaints)
 * 
 * Uses Firebase Auth REST API + Firestore REST API
 * No extra dependencies needed.
 */

const https = require('https');
const http = require('http');

const API_KEY = 'AIzaSyBKD3GWBjnArBV1wzXW00ggj4nBHNFidEA';
const PROJECT_ID = 'apartment-mgmt-prm393';
const FIRESTORE_BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;
const AUTH_SIGNUP_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`;

// ============================================================
// Helper functions
// ============================================================

function httpRequest(url, method, body) {
  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    const options = {
      hostname: parsed.hostname,
      path: parsed.pathname + parsed.search,
      method: method,
      headers: { 'Content-Type': 'application/json' },
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch {
          resolve(data);
        }
      });
    });

    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function createAuthUser(email, password) {
  const result = await httpRequest(AUTH_SIGNUP_URL, 'POST', {
    email,
    password,
    returnSecureToken: true,
  });

  if (result.error) {
    if (result.error.message === 'EMAIL_EXISTS') {
      console.log(`  ⚠️  User already exists: ${email}`);
      return null;
    }
    console.error(`  ❌ Error creating ${email}:`, result.error.message);
    return null;
  }

  console.log(`  ✅ Created auth user: ${email} (UID: ${result.localId})`);
  return result.localId;
}

function toFirestoreValue(value) {
  if (value === null || value === undefined) return { nullValue: null };
  if (typeof value === 'string') return { stringValue: value };
  if (typeof value === 'number') {
    if (Number.isInteger(value)) return { integerValue: value.toString() };
    return { doubleValue: value };
  }
  if (typeof value === 'boolean') return { booleanValue: value };
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(toFirestoreValue) } };
  }
  if (typeof value === 'object') {
    const fields = {};
    for (const [k, v] of Object.entries(value)) {
      fields[k] = toFirestoreValue(v);
    }
    return { mapValue: { fields } };
  }
  return { stringValue: String(value) };
}

async function createDocument(collection, docId, data) {
  const fields = {};
  for (const [key, value] of Object.entries(data)) {
    fields[key] = toFirestoreValue(value);
  }

  const url = `${FIRESTORE_BASE}/${collection}?documentId=${docId}`;
  const result = await httpRequest(url, 'POST', { fields });

  if (result.error) {
    if (result.error.code === 409) {
      console.log(`  ⚠️  Document already exists: ${collection}/${docId}`);
      return;
    }
    console.error(`  ❌ Error creating ${collection}/${docId}:`, result.error.message);
    return;
  }

  console.log(`  ✅ Created: ${collection}/${docId}`);
}

// ============================================================
// Seed Data Definitions
// ============================================================

const now = new Date();

const USERS = [
  {
    id: 'admin-001',
    email: 'admin@apartment.com',
    password: 'Admin@123',
    data: {
      email: 'admin@apartment.com',
      fullName: 'System Administrator',
      phone: '0901000001',
      role: 'admin',
      apartmentId: null,
      nationalId: '001000000001',
      dateOfBirth: new Date('1985-01-15'),
      avatarUrl: null,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'staff-001',
    email: 'staff1@apartment.com',
    password: 'Staff@123',
    data: {
      email: 'staff1@apartment.com',
      fullName: 'Nguyen Van An',
      phone: '0901000002',
      role: 'staff',
      apartmentId: null,
      nationalId: '001000000002',
      dateOfBirth: new Date('1990-05-20'),
      avatarUrl: null,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'staff-002',
    email: 'staff2@apartment.com',
    password: 'Staff@123',
    data: {
      email: 'staff2@apartment.com',
      fullName: 'Tran Thi Binh',
      phone: '0901000003',
      role: 'staff',
      apartmentId: null,
      nationalId: '001000000003',
      dateOfBirth: new Date('1992-08-10'),
      avatarUrl: null,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'resident-001',
    email: 'resident1@apartment.com',
    password: 'Resident@123',
    data: {
      email: 'resident1@apartment.com',
      fullName: 'Le Hoang Cuong',
      phone: '0912000001',
      role: 'resident',
      apartmentId: 'apt-0301',
      nationalId: '001200000001',
      dateOfBirth: new Date('1988-03-25'),
      avatarUrl: null,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'resident-002',
    email: 'resident2@apartment.com',
    password: 'Resident@123',
    data: {
      email: 'resident2@apartment.com',
      fullName: 'Pham Minh Duc',
      phone: '0912000002',
      role: 'resident',
      apartmentId: 'apt-0302',
      nationalId: '001200000002',
      dateOfBirth: new Date('1995-07-12'),
      avatarUrl: null,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'resident-003',
    email: 'resident3@apartment.com',
    password: 'Resident@123',
    data: {
      email: 'resident3@apartment.com',
      fullName: 'Vo Thi Hue',
      phone: '0912000003',
      role: 'resident',
      apartmentId: 'apt-0501',
      nationalId: '001200000003',
      dateOfBirth: new Date('1993-11-08'),
      avatarUrl: null,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'resident-004',
    email: 'resident4@apartment.com',
    password: 'Resident@123',
    data: {
      email: 'resident4@apartment.com',
      fullName: 'Hoang Van Giang',
      phone: '0912000004',
      role: 'resident',
      apartmentId: 'apt-0702',
      nationalId: '001200000004',
      dateOfBirth: new Date('1991-02-14'),
      avatarUrl: null,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'resident-005',
    email: 'resident5@apartment.com',
    password: 'Resident@123',
    data: {
      email: 'resident5@apartment.com',
      fullName: 'Dang Thi Kim',
      phone: '0912000005',
      role: 'resident',
      apartmentId: 'apt-1001',
      nationalId: '001200000005',
      dateOfBirth: new Date('1997-06-30'),
      avatarUrl: null,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    },
  },
];

// Generate apartments: 12 floors x 3 rooms per floor = 36 apartments
function generateApartments() {
  const apartments = [];
  const residentMap = {
    'apt-0301': { ownerId: 'resident-001', residentIds: ['resident-001'] },
    'apt-0302': { ownerId: 'resident-002', residentIds: ['resident-002'] },
    'apt-0501': { ownerId: 'resident-003', residentIds: ['resident-003'] },
    'apt-0702': { ownerId: 'resident-004', residentIds: ['resident-004'] },
    'apt-1001': { ownerId: 'resident-005', residentIds: ['resident-005'] },
  };

  for (let floor = 1; floor <= 12; floor++) {
    for (let room = 1; room <= 3; room++) {
      const floorStr = floor.toString().padStart(2, '0');
      const roomStr = room.toString().padStart(2, '0');
      const aptId = `apt-${floorStr}${roomStr}`;
      const number = `${floorStr}${roomStr}`;

      const mapping = residentMap[aptId];

      apartments.push({
        id: aptId,
        data: {
          number: number,
          floor: floor,
          building: 'Building A',
          area: 65.0 + room * 10,
          ownerId: mapping ? mapping.ownerId : null,
          status: mapping ? 'occupied' : 'vacant',
          residentIds: mapping ? mapping.residentIds : [],
          createdAt: now,
          updatedAt: now,
        },
      });
    }
  }
  return apartments;
}

const BILLS = [
  {
    id: 'bill-001',
    data: {
      apartmentId: 'apt-0301',
      residentId: 'resident-001',
      type: 'electricity',
      amount: 450000,
      billingMonth: '2026-06',
      dueDate: new Date('2026-07-15'),
      status: 'unpaid',
      paidAt: null,
      paymentMethod: null,
      createdBy: 'staff-001',
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'bill-002',
    data: {
      apartmentId: 'apt-0301',
      residentId: 'resident-001',
      type: 'water',
      amount: 180000,
      billingMonth: '2026-06',
      dueDate: new Date('2026-07-15'),
      status: 'unpaid',
      paidAt: null,
      paymentMethod: null,
      createdBy: 'staff-001',
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'bill-003',
    data: {
      apartmentId: 'apt-0302',
      residentId: 'resident-002',
      type: 'service',
      amount: 500000,
      billingMonth: '2026-06',
      dueDate: new Date('2026-07-15'),
      status: 'paid',
      paidAt: new Date('2026-07-05'),
      paymentMethod: 'bank_transfer',
      createdBy: 'staff-001',
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'bill-004',
    data: {
      apartmentId: 'apt-0501',
      residentId: 'resident-003',
      type: 'parking',
      amount: 200000,
      billingMonth: '2026-06',
      dueDate: new Date('2026-07-15'),
      status: 'overdue',
      paidAt: null,
      paymentMethod: null,
      createdBy: 'staff-002',
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'bill-005',
    data: {
      apartmentId: 'apt-0702',
      residentId: 'resident-004',
      type: 'electricity',
      amount: 620000,
      billingMonth: '2026-06',
      dueDate: new Date('2026-07-15'),
      status: 'unpaid',
      paidAt: null,
      paymentMethod: null,
      createdBy: 'staff-001',
      createdAt: now,
      updatedAt: now,
    },
  },
];

const REQUESTS = [
  {
    id: 'req-001',
    data: {
      title: 'Ong nuoc bi ro ri',
      description: 'Ong nuoc trong nha tam bi ro ri, can sua gap.',
      category: 'plumbing',
      imageUrls: [],
      residentId: 'resident-001',
      apartmentId: 'apt-0301',
      status: 'pending',
      assignedStaffId: null,
      resolutionNote: null,
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'req-002',
    data: {
      title: 'Bong den hanh lang bi chay',
      description: 'Bong den o hanh lang tang 3 bi chay, can thay moi.',
      category: 'electrical',
      imageUrls: [],
      residentId: 'resident-002',
      apartmentId: 'apt-0302',
      status: 'in_progress',
      assignedStaffId: 'staff-001',
      resolutionNote: null,
      createdAt: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000),
      updatedAt: now,
    },
  },
  {
    id: 'req-003',
    data: {
      title: 'Dieu hoa khong mat',
      description: 'Dieu hoa phong khach khong lam mat, da ve sinh nhung khong cai thien.',
      category: 'general',
      imageUrls: [],
      residentId: 'resident-003',
      apartmentId: 'apt-0501',
      status: 'completed',
      assignedStaffId: 'staff-002',
      resolutionNote: 'Da thay gas dieu hoa. Hoat dong binh thuong.',
      createdAt: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000),
      updatedAt: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000),
    },
  },
];

const NOTIFICATIONS = [
  {
    id: 'notif-001',
    data: {
      title: 'Thong bao cat dien',
      content: 'Toa nha se cat dien de bao tri tu 8h-12h ngay 20/07/2026. Xin cu dan thong cam.',
      type: 'announcement',
      createdBy: 'admin-001',
      targetRoles: ['resident', 'staff'],
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'notif-002',
    data: {
      title: 'Hop cu dan thang 7',
      content: 'Kinh moi cu dan tham du buoi hop dinh ky thang 7 vao 19h ngay 25/07/2026 tai sanh tang 1.',
      type: 'announcement',
      createdBy: 'admin-001',
      targetRoles: ['resident'],
      createdAt: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000),
      updatedAt: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000),
    },
  },
  {
    id: 'notif-003',
    data: {
      title: 'Noi quy gui xe moi',
      content: 'Tu ngay 01/08/2026, ham gui xe ap dung quy dinh moi. Chi tiet xin xem tai bang tin tang 1.',
      type: 'announcement',
      createdBy: 'staff-001',
      targetRoles: ['resident'],
      createdAt: new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000),
      updatedAt: new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000),
    },
  },
];

const VISITORS = [
  {
    id: 'visitor-001',
    data: {
      visitorName: 'Nguyen Van Khach',
      visitorPhone: '0987000001',
      purpose: 'Tham nguoi than',
      registeredBy: 'resident-001',
      apartmentId: 'apt-0301',
      expectedTime: new Date('2026-07-20T14:00:00'),
      checkInTime: null,
      checkOutTime: null,
      status: 'registered',
      checkedInBy: null,
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'visitor-002',
    data: {
      visitorName: 'Tran Thi Lan',
      visitorPhone: '0987000002',
      purpose: 'Giao hang',
      registeredBy: 'resident-002',
      apartmentId: 'apt-0302',
      expectedTime: new Date('2026-07-19T10:00:00'),
      checkInTime: new Date('2026-07-19T10:05:00'),
      checkOutTime: new Date('2026-07-19T10:30:00'),
      status: 'checked_out',
      checkedInBy: 'staff-001',
      createdAt: new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000),
      updatedAt: now,
    },
  },
];

const COMPLAINTS = [
  {
    id: 'complaint-001',
    data: {
      content: 'Tang 5 thuong xuyen co tieng on vao buoi toi muon, anh huong den giac ngu cua cu dan.',
      residentId: 'resident-003',
      apartmentId: 'apt-0501',
      status: 'submitted',
      response: null,
      respondedBy: null,
      respondedAt: null,
      createdAt: now,
      updatedAt: now,
    },
  },
  {
    id: 'complaint-002',
    data: {
      content: 'Thang may tang 7 thuong xuyen bi ket, rat bat tien cho cu dan.',
      residentId: 'resident-004',
      apartmentId: 'apt-0702',
      status: 'resolved',
      response: 'Da lien he don vi bao tri thang may. Thang may da duoc sua chua va hoat dong binh thuong.',
      respondedBy: 'admin-001',
      respondedAt: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000),
      createdAt: new Date(now.getTime() - 5 * 24 * 60 * 60 * 1000),
      updatedAt: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000),
    },
  },
];

// ============================================================
// Main execution
// ============================================================

async function main() {
  console.log('🏢 Apartment Building Management System — Seed Data');
  console.log('================================================\n');

  // 1. Create Auth Users
  console.log('👤 Creating Firebase Auth users...');
  const uidMap = {};
  for (const user of USERS) {
    const uid = await createAuthUser(user.email, user.password);
    if (uid) {
      uidMap[user.id] = uid;
      // Update user data with real UID for Firestore
      user.realUid = uid;
    }
  }
  console.log('');

  // 2. Create Firestore User Documents
  console.log('📄 Creating user documents in Firestore...');
  for (const user of USERS) {
    const docId = user.realUid || user.id;
    await createDocument('users', docId, user.data);
  }
  console.log('');

  // 3. Create Apartments
  console.log('🏠 Creating apartment documents...');
  const apartments = generateApartments();
  for (const apt of apartments) {
    await createDocument('apartments', apt.id, apt.data);
  }
  console.log(`   (${apartments.length} apartments created)`);
  console.log('');

  // 4. Create Bills
  console.log('💰 Creating bill documents...');
  for (const bill of BILLS) {
    await createDocument('bills', bill.id, bill.data);
  }
  console.log('');

  // 5. Create Requests
  console.log('🔧 Creating maintenance request documents...');
  for (const req of REQUESTS) {
    await createDocument('requests', req.id, req.data);
  }
  console.log('');

  // 6. Create Notifications
  console.log('📢 Creating announcement documents...');
  for (const notif of NOTIFICATIONS) {
    await createDocument('notifications', notif.id, notif.data);
  }
  console.log('');

  // 7. Create Visitors
  console.log('🚶 Creating visitor documents...');
  for (const visitor of VISITORS) {
    await createDocument('visitors', visitor.id, visitor.data);
  }
  console.log('');

  // 8. Create Complaints
  console.log('📝 Creating complaint documents...');
  for (const complaint of COMPLAINTS) {
    await createDocument('complaints', complaint.id, complaint.data);
  }
  console.log('');

  // Summary
  console.log('================================================');
  console.log('✅ Seed data completed!\n');
  console.log('📋 Test Accounts:');
  console.log('┌──────────────────────────────┬──────────────┬──────────┐');
  console.log('│ Email                        │ Password     │ Role     │');
  console.log('├──────────────────────────────┼──────────────┼──────────┤');
  console.log('│ admin@apartment.com          │ Admin@123    │ admin    │');
  console.log('│ staff1@apartment.com         │ Staff@123    │ staff    │');
  console.log('│ staff2@apartment.com         │ Staff@123    │ staff    │');
  console.log('│ resident1@apartment.com      │ Resident@123 │ resident │');
  console.log('│ resident2@apartment.com      │ Resident@123 │ resident │');
  console.log('│ resident3@apartment.com      │ Resident@123 │ resident │');
  console.log('│ resident4@apartment.com      │ Resident@123 │ resident │');
  console.log('│ resident5@apartment.com      │ Resident@123 │ resident │');
  console.log('└──────────────────────────────┴──────────────┴──────────┘');
}

main().catch(console.error);
