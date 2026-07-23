# Revised Section II — Software Requirement Specification

## Hướng dẫn sử dụng

Phần từ **II. Software Requirement Specification** đến hết **5.4 Release Scope Exclusions** được viết bằng tiếng Anh để có thể dán trực tiếp vào tài liệu SRS. Phần **Diagram Redrawing Guide** ở cuối file là hướng dẫn tiếng Việt dành cho người vẽ lại sơ đồ và không cần đưa nguyên văn vào SRS.

---

# II. Software Requirement Specification

## 1. Product Overview

The Apartment Building Management System (ABMS) is a mobile application that digitizes the daily operations of a small apartment building. Release 1.0 is designed for one building with 12 floors and approximately 36 to 48 apartment units. The application replaces manual processes such as paper maintenance forms, direct fee notices, phone-based visitor registration, and printed announcements.

The system supports three user roles: Admin, Staff, and Resident. Each role is provided with a dedicated home screen and a role-appropriate set of functions.

- **Admin** manages user accounts, apartments, resident records, announcements, and overview statistics. Admin can also review maintenance requests, complaints, and visitor activities.
- **Staff** manages maintenance requests, bills, payment confirmations, visitor check-in and check-out, complaints, and announcements.
- **Resident** views personal bills and payment history, submits maintenance requests and complaints, registers visitors, reads announcements, and manages personal profile information.

Release 1.0 uses Firebase Authentication for account authentication, Cloud Firestore for application data, and Firebase Storage for uploaded images. The application is implemented with Flutter and is intended for Android and iOS mobile devices.

Invoice payment in Release 1.0 is handled manually. A Resident reviews the building bank account information, performs a bank transfer outside the application, and submits a payment confirmation request. Staff verifies the payment and approves or rejects it. Staff may also record a cash payment. Release 1.0 does not integrate with VNPay, MoMo, an in-app wallet, or another external payment gateway.

The main system capabilities are:

1. Authentication and role-based navigation.
2. User account management.
3. Apartment management.
4. Resident management.
5. Maintenance request management.
6. Bill and manual payment management.
7. Complaint and feedback management.
8. Announcement management.
9. Visitor management.
10. Dashboard statistics and personal profile management.

**Figure 1-1: Apartment Building Management System Context**

The system context diagram shall show the three human actors and the Firebase services used by the mobile application. Detailed redrawing instructions are provided in the Diagram Redrawing Guide.

---

## 2. User Requirements

### 2.1 Actors

| # | Actor | Description |
|---|---|---|
| 1 | Admin | The user responsible for system administration and building master data. Admin manages user accounts, roles, account statuses, apartments, resident records, announcements, and dashboard statistics. Admin may also access operational lists for maintenance requests, complaints, and visitors. |
| 2 | Staff | The building operations user. Staff creates and manages bills, records or verifies payments, processes maintenance requests, responds to complaints, manages visitor entry and exit, and creates or updates announcements. |
| 3 | Resident | A person living in an apartment. A Resident views assigned bills, submits bank-transfer payment confirmations, views payment history, creates maintenance requests and complaints, registers visitors, reads announcements, and views or updates personal profile information. |

### 2.2 Use Cases

#### 2.2.1 Diagram

**Figure 2-1: ABMS Use Case Diagram**

The use case diagram shall contain the three actors defined in Section 2.1 and the use cases listed in Section 2.2.2. Payment Gateway shall not appear as an actor in Release 1.0.

#### 2.2.2 Use Case Descriptions

| ID | Function Group | Use Case | Actors | Use Case Description and Main Flow |
|---|---|---|---|---|
| UC-01 | Authentication | Login | Admin, Staff, Resident | The user enters an email address and password. The system validates the credentials through Firebase Authentication, loads the corresponding user profile, verifies that the account is active, and redirects the user to the home screen for the assigned role. |
| UC-02 | Authentication | Logout | Admin, Staff, Resident | The authenticated user selects Logout. The system ends the Firebase authentication session, clears the current application user state, and returns to the Login screen. |
| UC-03 | Authentication | Change Password | Admin, Staff, Resident | The authenticated user enters the current password, a new password, and password confirmation. The system re-authenticates the user, validates the new password, updates the Firebase Authentication password, and displays the result. |
| UC-04 | Profile Management | View and Update Own Profile | Admin, Staff, Resident | The user opens the Profile screen to view personal information. The user may update permitted profile fields such as full name, phone number, national identity number, and date of birth. The system validates and saves the permitted changes. Role, account status, apartment assignment, and email cannot be changed by the user. |
| UC-05 | Dashboard | View Dashboard Statistics | Admin | Admin opens the dashboard. The system retrieves and displays the number of apartments, residents, pending maintenance requests, unpaid bills, and visitors currently inside the building. |
| UC-06 | User Management | Manage User Accounts | Admin | Admin views, searches, and filters user accounts. Admin may create an account, edit permitted account information, assign a role, assign an apartment, activate an account, or deactivate an account. The system prevents Admin from deactivating the account currently being used. |
| UC-07 | Apartment Management | Manage Apartments | Admin | Admin views, searches, and filters apartments by floor or occupancy status. Admin may view apartment details, create an apartment, update apartment information, or delete an apartment after confirmation. |
| UC-08 | Apartment Management | Assign Resident | Admin | Admin opens an apartment, selects a Resident, and assigns that person to the apartment. The system adds the Resident identifier to the apartment, updates the Resident apartment assignment, marks the apartment as Occupied, and records the selected Resident as the apartment owner in the current screen flow. |
| UC-09 | Resident Management | Manage Resident Records | Admin | Admin views and searches Resident accounts, opens a Resident profile, creates a Resident record, updates Resident information, or changes the Resident account status. |
| UC-10 | Maintenance Request | Submit Maintenance Request | Resident | The Resident enters a title, category, description, and up to three optional images. The system associates the request with the authenticated Resident and apartment, sets the status to Pending, saves the request, and makes it available to Staff and Admin. |
| UC-11 | Maintenance Request | View Own Maintenance Requests | Resident | The Resident opens the maintenance request list, views requests submitted by the current account, selects a request, and views its category, description, images, status, assigned Staff, resolution note, and timestamps when available. |
| UC-12 | Maintenance Request | Manage Maintenance Requests | Admin, Staff | Admin or Staff views all maintenance requests and filters them by status. The user opens a request and updates it from Pending to In Progress or Completed. The system stores the current processing account identifier and an optional resolution note when the update is submitted. |
| UC-13 | Complaint Management | Submit Complaint or Feedback | Resident | The Resident enters complaint or feedback content. The system associates the record with the authenticated Resident and apartment, sets the status to Submitted, and saves the record for review. |
| UC-14 | Complaint Management | View Own Complaints | Resident | The Resident views complaints submitted by the current account, opens a complaint, and views its content, status, response, responder, and response time when available. |
| UC-15 | Complaint Management | Review and Respond to Complaint | Admin, Staff | Admin or Staff views submitted complaints, marks a complaint as In Review when appropriate, enters a response, and resolves the complaint. The system stores the response, responder, response time, and final status. |
| UC-16 | Bill Management | Create Bill | Staff | Staff enters the apartment identifier, bill type, billing month, amount, and due date. The system validates the input, creates the bill with Unpaid status, and makes it available to the assigned Resident. |
| UC-17 | Bill Management | View and Manage Bills | Staff | Staff views and filters bills by apartment, billing month, or status. Staff selects a bill to view its details and any pending payment request. Staff may proceed to record cash payment or approve or reject a bank-transfer confirmation. |
| UC-18 | Bill Management | View My Bills | Resident | The Resident views bills associated with the assigned apartment, including bill type, billing month, amount, due date, and status. The Resident may open an unpaid bill to start manual payment confirmation. |
| UC-19 | Payment Management | Submit Bank-Transfer Payment Confirmation | Resident | The Resident opens an unpaid bill, reviews the building bank account and transfer reference, confirms that the transfer was made, and submits a payment confirmation. The system creates a Pending payment record and changes the bill status to Pending for Staff verification. |
| UC-20 | Payment Management | Record Cash Payment | Staff | Staff opens an unpaid bill, confirms that cash was received, and records the payment. The system creates an Approved cash payment record and changes the bill status to Paid. |
| UC-21 | Payment Management | Approve or Reject Bank Transfer | Staff | Staff opens a bill with a Pending payment, reviews the submitted payment information, and approves or rejects it. Approval changes the payment to Approved and the bill to Paid. Rejection records a reason, changes the payment to Rejected, and returns the bill to Unpaid. |
| UC-22 | Payment Management | View Payment History | Resident | The Resident views payment records associated with the current Resident or apartment. The system displays amount, payment method, payment status, and transaction time. |
| UC-23 | Announcement Management | View Announcements | Admin, Staff, Resident | The user views the in-app announcement list, selects an announcement, and reads its title, content, type, author, target-role metadata, and publication time. Release 1.0 retrieves announcements for all authenticated roles and does not enforce target-role filtering in the list query. |
| UC-24 | Announcement Management | Manage Announcements | Admin, Staff | Admin or Staff creates an announcement by entering a title, content, type, and target roles. The user may also edit or delete an existing announcement. A destructive confirmation is required before deletion. |
| UC-25 | Visitor Management | Register Visitor | Resident | The Resident enters visitor name, phone number, purpose, expected visit time, and apartment information. The system creates a visitor record with Registered status. |
| UC-26 | Visitor Management | View Visitor List | Admin, Staff | Admin or Staff views and searches registered visitors. The list displays visitor identity, apartment, expected time, and the current Registered, Checked In, or Checked Out status. |
| UC-27 | Visitor Management | Check In or Check Out Visitor | Admin, Staff | Admin or Staff selects a visitor, verifies the visitor information, and records Check In when the visitor arrives or Check Out when the visitor leaves. The system stores the relevant timestamps and the Staff or Admin account performing the operation. |

---

## 3. Software Features

### 3.1 Functional Overview

The ABMS provides a centralized mobile platform for apartment administration and daily resident services. Release 1.0 supports the following three roles:

1. Admin.
2. Staff.
3. Resident.

The application uses role-based routing after successful login:

- Admin is redirected to the Admin Home screen.
- Staff is redirected to the Staff Home screen.
- Resident is redirected to the Resident Home screen.

The functional scope of Release 1.0 consists of:

| # | Feature Group | Scope |
|---|---|---|
| 1 | Authentication | Login, logout, session restoration, role-based redirect, and change password. |
| 2 | User Management | Admin user list, search, filter, account creation, account editing, role assignment, apartment assignment, activation, and deactivation. |
| 3 | Apartment Management | Admin apartment list, search, filter, details, create, update, delete, and Resident assignment. |
| 4 | Resident Management | Admin resident list, search, create, update, status management, and profile view. |
| 5 | Maintenance Request | Resident submission and tracking; Admin or Staff review and status updates. |
| 6 | Bill and Payment | Staff bill creation and payment confirmation; Resident bill view, manual transfer confirmation, and payment history. |
| 7 | Complaint and Feedback | Resident submission and tracking; Admin or Staff review and response. |
| 8 | Announcement | Admin or Staff create, edit, and delete; all roles view. |
| 9 | Visitor Management | Resident registration; Admin or Staff visitor list, check-in, and check-out. |
| 10 | Dashboard and Profile | Admin overview statistics and personal profile access for all roles. |

#### 3.1.1 Screen Flow

**Figure 3-1: Role-Based Screen Flow**

After Login, the application routes the user to one of three home screens according to the assigned role. The complete set of nodes and transitions required in the screen flow is provided in the Diagram Redrawing Guide.

#### 3.1.2 Screen Descriptions

| # | Feature | Screen | Description |
|---|---|---|---|
| 1 | Authentication | Splash | Initializes Firebase, restores the authentication session, loads the user profile, and redirects to Login or the correct role home screen. |
| 2 | Authentication | Login | Authenticates all roles using email and password. |
| 3 | Authentication | Change Password | Re-authenticates the current user and changes the Firebase Authentication password. |
| 4 | Profile | User Profile | Displays and updates permitted personal profile information and provides logout and theme controls. |
| 5 | Administration | Admin Home and Dashboard | Displays Admin navigation and overview counters for apartments, residents, pending requests, unpaid bills, and visitors inside. |
| 6 | Administration | User List | Displays, searches, and filters user accounts by role and status. |
| 7 | Administration | User Create | Creates a Firebase Authentication account and the corresponding Firestore user profile. |
| 8 | Administration | User Edit | Updates permitted user fields, role, apartment assignment, and active or inactive status. |
| 9 | Apartment Management | Apartment List | Displays, searches, and filters apartments by floor and occupancy status. |
| 10 | Apartment Management | Apartment Form | Creates or updates apartment number, floor, building, area, price, type, and status. |
| 11 | Apartment Management | Apartment Details | Displays apartment information, owner, residents, and the Resident assignment action. |
| 12 | Resident Management | Resident List | Displays and searches Resident accounts and filters them by status. |
| 13 | Resident Management | Resident Form | Creates or updates Resident identity and apartment information. |
| 14 | Resident Management | Resident Profile | Displays detailed information for a selected Resident. |
| 15 | Staff Operations | Staff Home | Provides tab navigation to maintenance requests, bills, visitors, complaints, and personal profile. |
| 16 | Resident Services | Resident Home | Provides access to bills, maintenance requests, complaints, announcements, visitor registration, payment history, and profile. |
| 17 | Maintenance Request | My Request List | Displays maintenance requests submitted by the current Resident. |
| 18 | Maintenance Request | Request Create | Creates a request with title, category, description, and optional images. |
| 19 | Maintenance Request | Request Details | Displays request information, current status, assigned Staff, images, and resolution note. |
| 20 | Maintenance Request | Request Management | Allows Admin or Staff to view, filter, and update maintenance requests and resolution notes. |
| 21 | Complaint | My Complaint List | Displays complaints submitted by the current Resident. |
| 22 | Complaint | Complaint Create | Creates a complaint or feedback record. |
| 23 | Complaint | Complaint Details | Displays complaint content, status, and response information. |
| 24 | Complaint | Complaint Management | Allows Admin or Staff to review, mark in review, respond to, and resolve complaints. |
| 25 | Bill | Bill List | Allows Staff to view and filter building bills. |
| 26 | Bill | Bill Create | Allows Staff to create a bill for an apartment and billing month. |
| 27 | Bill | Bill Details | Displays bill details and supports cash recording or bank-transfer approval and rejection. |
| 28 | Bill | My Bills | Displays bills associated with the Resident apartment. |
| 29 | Payment | Bill Payment | Displays manual bank-transfer information and submits a payment confirmation request. |
| 30 | Payment | Payment History | Displays payment records associated with the Resident or apartment. |
| 31 | Announcement | Announcement List | Displays announcements visible to the current role. Admin and Staff can open the create screen. |
| 32 | Announcement | Announcement Create or Edit | Allows Admin or Staff to create or edit an announcement and select target roles. |
| 33 | Announcement | Announcement Details | Displays announcement content. Admin and Staff can edit or delete the announcement. |
| 34 | Visitor | Visitor Registration | Allows a Resident to register a visitor and expected arrival time. |
| 35 | Visitor | Visitor List and Check-In/Out | Allows Admin or Staff to view, search, check in, and check out visitors. |

#### 3.1.3 Screen Authorization

`X` indicates that the role is authorized to access the screen or action through the intended application flow.

| # | Screen or Action | Admin | Staff | Resident |
|---|---|---|---|---|
| 1 | Splash | X | X | X |
| 2 | Login | X | X | X |
| 3 | Logout | X | X | X |
| 4 | Change Password | X | X | X |
| 5 | View or Update Own Profile | X | X | X |
| 6 | Admin Home and Dashboard | X |  |  |
| 7 | User List | X |  |  |
| 8 | Create User | X |  |  |
| 9 | Edit User | X |  |  |
| 10 | Assign User Role | X |  |  |
| 11 | Activate or Deactivate User | X |  |  |
| 12 | Apartment List | X |  |  |
| 13 | Apartment Details | X |  |  |
| 14 | Create or Update Apartment | X |  |  |
| 15 | Delete Apartment | X |  |  |
| 16 | Assign Resident to Apartment | X |  |  |
| 17 | Resident List | X |  |  |
| 18 | Resident Profile | X |  |  |
| 19 | Create or Update Resident | X |  |  |
| 20 | Resident Home |  |  | X |
| 21 | Submit Maintenance Request |  |  | X |
| 22 | View Own Maintenance Requests |  |  | X |
| 23 | Request Management | X | X |  |
| 24 | Update Request Status or Resolution | X | X |  |
| 25 | Submit Complaint or Feedback |  |  | X |
| 26 | View Own Complaints |  |  | X |
| 27 | Complaint Management | X | X |  |
| 28 | Respond to Complaint | X | X |  |
| 29 | Bill List |  | X |  |
| 30 | Create Bill |  | X |  |
| 31 | Bill Details and Payment Verification |  | X |  |
| 32 | View My Bills |  |  | X |
| 33 | Submit Bank-Transfer Confirmation |  |  | X |
| 34 | View Personal Payment History |  |  | X |
| 35 | Record Cash Payment |  | X |  |
| 36 | Approve or Reject Bank Transfer |  | X |  |
| 37 | Announcement List and Details | X | X | X |
| 38 | Create or Edit Announcement | X | X |  |
| 39 | Delete Announcement | X | X |  |
| 40 | Register Visitor |  |  | X |
| 41 | Visitor List | X | X |  |
| 42 | Check In or Check Out Visitor | X | X |  |

#### 3.1.4 Non-Screen Functions

| # | Feature | System Function | Description |
|---|---|---|---|
| 1 | Authentication | Authentication State Listener | Listens for Firebase Authentication session changes and updates the current application authentication state. |
| 2 | Authentication | Role-Based Redirect | Loads the Firestore user profile and redirects an authenticated account to the Admin, Staff, or Resident home screen. |
| 3 | Authentication | Active Account Validation | Prevents an inactive account from continuing to use protected application functions. |
| 4 | User Management | User Account Provisioning | Creates a Firebase Authentication account through a secondary Firebase session, creates the Firestore profile, and rolls back the authentication account if profile creation fails. |
| 5 | Data Access | Firestore Repository Services | Provides create, read, update, delete, query, and stream operations for the application collections. |
| 6 | Maintenance Request | Request Image Upload | Uploads selected maintenance request images to Firebase Storage and stores their URLs in the request record. |
| 7 | Payment | Atomic Payment Status Update | Uses a Firestore batch to create or update a payment record and update the related bill status as one operation. |
| 8 | Dashboard | Dashboard Counter Aggregation | Counts apartments, Residents, pending requests, unpaid bills, and checked-in visitors through Firestore aggregate queries. |
| 9 | Search | Vietnamese Text Normalization | Normalizes Vietnamese characters to support case-insensitive and accent-insensitive search. |
| 10 | Localization | Vietnamese Date and Currency Formatting | Formats dates, date-times, billing months, and currency values using the `vi_VN` locale. |

#### 3.1.5 Entity Relationship Diagram

**Figure 3-2: ABMS Entity Relationship Diagram**

The entity relationship diagram shall contain the eight entities listed below. The entities `Meal`, `Meal Subscription`, and `Product` are not part of ABMS and shall be removed.

##### Entity Descriptions

| # | Entity | Description |
|---|---|---|
| 1 | User | Stores authentication-related profile data, role, apartment assignment, identity information, and account status for Admin, Staff, and Resident accounts. |
| 2 | Apartment | Stores apartment number, floor, building, physical information, occupancy status, owner, and assigned Residents. |
| 3 | Request | Stores a maintenance request submitted by a Resident, including category, description, images, processing status, assigned Staff, and resolution note. |
| 4 | Complaint | Stores a complaint or feedback item submitted by a Resident and the response provided by Admin or Staff. |
| 5 | Bill | Stores a bill assigned to an apartment and Resident for a billing month, including type, amount, due date, and payment status. |
| 6 | Payment | Stores a cash or bank-transfer payment record related to a bill, including verification status, proof reference, recorder, and rejection reason. |
| 7 | Notification | Stores an announcement created by Admin or Staff for one or more target roles. |
| 8 | Visitor | Stores a visitor registration and its expected time, check-in time, check-out time, status, and processing Staff. |

#### 3.1.6 Entity Details

##### User

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | uid | X | String | Yes | Firebase Authentication user identifier and Firestore document identifier. |
| 2 | email |  | String | Yes | Unique email address used for login. |
| 3 | fullName |  | String | Yes | User full name. |
| 4 | phone |  | String | Yes | Vietnamese phone number. |
| 5 | role |  | Enum | Yes | One of `admin`, `staff`, or `resident`. |
| 6 | apartmentId |  | String | No | Identifier of the apartment assigned to a Resident. |
| 7 | nationalId |  | String | Yes | National identity number. |
| 8 | dateOfBirth |  | Timestamp | No | User date of birth. |
| 9 | avatarUrl |  | String | No | URL of the profile image. |
| 10 | status |  | Enum | Yes | One of `active` or `inactive`. |
| 11 | createdAt |  | Timestamp | Yes | Account profile creation time. |
| 12 | updatedAt |  | Timestamp | Yes | Most recent profile update time. |

##### Apartment

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | id | X | String | Yes | Firestore apartment document identifier. |
| 2 | number |  | String | Yes | Apartment number. |
| 3 | floor |  | Integer | Yes | Floor number. |
| 4 | building |  | String | Yes | Building name or code. Release 1.0 uses one building. |
| 5 | area |  | Double | Yes | Apartment area in square metres. |
| 6 | ownerId |  | String | No | Identifier of the designated Resident owner. |
| 7 | status |  | Enum | Yes | One of `occupied` or `vacant`. |
| 8 | residentIds |  | Array of String | Yes | Identifiers of Residents assigned to the apartment. The array may be empty. |
| 9 | price |  | Double | No | Apartment rent or reference price in millions of VND. |
| 10 | type |  | String | No | Apartment layout, such as bedroom and bathroom configuration. |
| 11 | createdAt |  | Timestamp | No | Apartment record creation time. |
| 12 | updatedAt |  | Timestamp | No | Most recent apartment record update time. |

##### Request

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | id | X | String | Yes | Firestore maintenance request document identifier. |
| 2 | title |  | String | Yes | Short request title. |
| 3 | description |  | String | Yes | Detailed description of the maintenance issue. |
| 4 | category |  | Enum | Yes | One of `plumbing`, `electrical`, or `general`. |
| 5 | imageUrls |  | Array of String | Yes | URLs of uploaded request images. The array may be empty. |
| 6 | residentId |  | String | Yes | Identifier of the Resident who submitted the request. |
| 7 | apartmentId |  | String | Yes | Identifier of the related apartment. |
| 8 | status |  | Enum | Yes | One of `pending`, `in_progress`, or `completed`. |
| 9 | assignedStaffId |  | String | No | Identifier of the Staff assigned to the request. |
| 10 | resolutionNote |  | String | No | Processing or completion note entered by Staff or Admin. |
| 11 | createdAt |  | Timestamp | Yes | Request submission time. |
| 12 | updatedAt |  | Timestamp | Yes | Most recent request update time. |

##### Complaint

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | id | X | String | Yes | Firestore complaint document identifier. |
| 2 | content |  | String | Yes | Complaint or feedback content. |
| 3 | residentId |  | String | Yes | Identifier of the Resident who submitted the complaint. |
| 4 | apartmentId |  | String | Yes | Identifier of the related apartment. |
| 5 | status |  | Enum | Yes | One of `submitted`, `in_review`, or `resolved`. |
| 6 | response |  | String | No | Response entered by Admin or Staff. |
| 7 | respondedBy |  | String | No | Identifier of the Admin or Staff who responded. |
| 8 | respondedAt |  | Timestamp | No | Response time. |
| 9 | createdAt |  | Timestamp | Yes | Complaint submission time. |
| 10 | updatedAt |  | Timestamp | Yes | Most recent complaint update time. |

##### Bill

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | billId | X | String | Yes | Firestore bill document identifier. |
| 2 | apartmentId |  | String | Yes | Identifier of the billed apartment. |
| 3 | residentId |  | String | Yes | Identifier of the Resident responsible for the bill when available. |
| 4 | type |  | Enum | Yes | One of `electricity`, `water`, `service`, or `parking`. |
| 5 | amount |  | Double | Yes | Bill amount in VND. |
| 6 | billingMonth |  | String | Yes | Billing month in `YYYY-MM` format. |
| 7 | dueDate |  | Timestamp | Yes | Payment due date. |
| 8 | status |  | Enum | Yes | One of `unpaid`, `pending`, `paid`, or `overdue`. |
| 9 | paidAt |  | Timestamp | No | Time at which the bill was approved as paid. |
| 10 | paymentMethod |  | Enum | No | One of `cash` or `bank_transfer`. |
| 11 | createdBy |  | String | Yes | Identifier of the Staff who created the bill. |
| 12 | createdAt |  | Timestamp | Yes | Bill creation time. |
| 13 | updatedAt |  | Timestamp | Yes | Most recent bill update time. |

##### Payment

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | paymentId | X | String | Yes | Firestore payment document identifier. |
| 2 | billId |  | String | Yes | Identifier of the related bill. |
| 3 | apartmentId |  | String | Yes | Identifier of the related apartment. |
| 4 | residentId |  | String | Yes | Identifier of the Resident making the payment. |
| 5 | amount |  | Double | Yes | Payment amount in VND. |
| 6 | paymentMethod |  | Enum | Yes | One of `cash` or `bank_transfer`. |
| 7 | status |  | Enum | Yes | One of `pending`, `approved`, or `rejected`. |
| 8 | proofImageUrl |  | String | No | URL or reference for bank-transfer proof when implemented. |
| 9 | recordedBy |  | String | No | Identifier of the Staff who recorded, approved, or rejected the payment. |
| 10 | rejectReason |  | String | No | Reason entered when a payment is rejected. |
| 11 | createdAt |  | Timestamp | Yes | Payment record creation time. |
| 12 | updatedAt |  | Timestamp | Yes | Most recent payment record update time. |

##### Notification

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | id | X | String | Yes | Firestore announcement document identifier. |
| 2 | title |  | String | Yes | Announcement title. |
| 3 | content |  | String | Yes | Announcement content. |
| 4 | type |  | String | Yes | Announcement category or type. |
| 5 | createdBy |  | String | Yes | Identifier of the Admin or Staff who created the announcement. |
| 6 | targetRoles |  | Array of String | Yes | Roles allowed to receive or view the announcement. |
| 7 | createdAt |  | Timestamp | No | Announcement creation time. |
| 8 | updatedAt |  | Timestamp | No | Most recent announcement update time. |

##### Visitor

| # | Attribute Name | PK | Type | Mandatory | Description |
|---|---|---|---|---|---|
| 1 | id | X | String | Yes | Firestore visitor document identifier. |
| 2 | visitorName |  | String | Yes | Visitor full name. |
| 3 | visitorPhone |  | String | Yes | Visitor phone number. |
| 4 | purpose |  | String | Yes | Purpose of the visit. |
| 5 | registeredBy |  | String | Yes | Identifier of the Resident who registered the visitor. |
| 6 | apartmentId |  | String | Yes | Identifier of the destination apartment. |
| 7 | expectedTime |  | Timestamp | No | Expected arrival time. |
| 8 | checkInTime |  | Timestamp | No | Actual check-in time. |
| 9 | checkOutTime |  | Timestamp | No | Actual check-out time. |
| 10 | status |  | Enum | Yes | One of `registered`, `checked_in`, or `checked_out`. |
| 11 | checkedInBy |  | String | No | Identifier of the Admin or Staff who checked in the visitor. |
| 12 | createdAt |  | Timestamp | No | Visitor registration time. |
| 13 | updatedAt |  | Timestamp | No | Most recent visitor record update time. |

### 3.2 Authentication and Profile Management

#### 3.2.1 Purpose

This feature authenticates all system users, restores existing sessions, redirects authenticated users according to role, supports logout and password changes, and allows users to view or update permitted profile data.

#### 3.2.2 Screens

- Splash.
- Login.
- Change Password.
- User Profile.

#### 3.2.3 Functional Requirements

| ID | Requirement |
|---|---|
| FR-AUTH-01 | The system shall authenticate Admin, Staff, and Resident accounts using email and password through Firebase Authentication. |
| FR-AUTH-02 | The system shall load the Firestore user profile after Firebase Authentication succeeds. |
| FR-AUTH-03 | The system shall deny application access when the Firestore user profile does not exist or the account status is Inactive. |
| FR-AUTH-04 | The system shall redirect an authenticated user to the Admin Home, Staff Home, or Resident Home screen according to the stored role. |
| FR-AUTH-05 | The system shall restore an existing authenticated session when the application starts. |
| FR-AUTH-06 | The system shall allow the user to log out and return to the Login screen. |
| FR-AUTH-07 | The system shall require the current password before changing to a new password. |
| FR-AUTH-08 | The new password and password confirmation shall match and comply with the password validation rules. |
| FR-AUTH-09 | The system shall mask password fields and provide a visibility toggle. |
| FR-AUTH-10 | The user shall be allowed to update only personal profile fields permitted for self-service. |

#### 3.2.4 Login Screen Definition

| # | Field Name | Type | Mandatory | Description |
|---|---|---|---|---|
| 1 | Email | Email text field | Yes | Accepts a valid email address. |
| 2 | Password | Password field | Yes | Masks entered characters and supports show or hide password. |
| 3 | Login | Button | Not applicable | Validates the form, authenticates the account, and redirects by role. |

#### 3.2.5 Alternative and Error Flows

- If the email format is invalid, the system displays an inline validation message.
- If the password is empty, the system displays an inline validation message.
- If Firebase rejects the credentials, the system displays a Vietnamese user-friendly authentication error.
- If the account is inactive, the system ends the session and informs the user that access is disabled.
- If the user profile cannot be loaded, the system displays an error and prevents access to role-specific screens.

### 3.3 User Management

#### 3.3.1 Purpose

This feature allows Admin to provision and maintain application accounts without ending the current Admin authentication session.

#### 3.3.2 Screens

- User List.
- User Create.
- User Edit.

#### 3.3.3 Functional Requirements

| ID | Requirement |
|---|---|
| FR-USER-01 | Admin shall be able to view all user profiles. |
| FR-USER-02 | Admin shall be able to search users by name, email, or apartment identifier. |
| FR-USER-03 | Admin shall be able to filter users by role and account status. |
| FR-USER-04 | Admin shall be able to create an account with email, full name, phone, role, identity information, and optional apartment assignment. |
| FR-USER-05 | User creation shall create both a Firebase Authentication account and a Firestore user profile. |
| FR-USER-06 | If Firestore profile creation fails, the system shall attempt to remove the newly provisioned Firebase Authentication account. |
| FR-USER-07 | Admin shall be able to edit permitted user fields, role, apartment assignment, and account status. |
| FR-USER-08 | Admin shall be able to deactivate an account instead of permanently deleting it. |
| FR-USER-09 | Admin shall not be allowed to deactivate the account currently being used. |
| FR-USER-10 | A newly created account shall have Active status. |

#### 3.3.4 Business Rules

- Only Admin can create or manage user accounts.
- Roles are limited to Admin, Staff, and Resident.
- Account statuses are limited to Active and Inactive.
- Email is the login identifier and cannot be changed through normal profile editing.
- Hard deletion of a user profile is not supported in Release 1.0.

### 3.4 Apartment and Resident Management

#### 3.4.1 Purpose

This feature allows Admin to maintain apartment master data, Resident records, apartment ownership, and apartment membership.

#### 3.4.2 Screens

- Apartment List.
- Apartment Form.
- Apartment Details.
- Resident List.
- Resident Form.
- Resident Profile.

#### 3.4.3 Functional Requirements

| ID | Requirement |
|---|---|
| FR-APT-01 | Admin shall be able to view and search the apartment list. |
| FR-APT-02 | Admin shall be able to filter apartments by floor and occupancy status. |
| FR-APT-03 | Admin shall be able to create and update apartment records. |
| FR-APT-04 | Admin shall be able to delete an apartment only after explicit confirmation. |
| FR-APT-05 | Admin shall be able to view the owner and Resident members assigned to an apartment. |
| FR-APT-06 | Admin shall be able to assign a Resident to an apartment from the Apartment Details screen. |
| FR-APT-07 | The current Apartment Details flow shall store the selected Resident as the apartment owner when assigning that Resident. |
| FR-RES-01 | Admin shall be able to view and search Resident profiles. |
| FR-RES-02 | Admin shall be able to create and update Resident records. |
| FR-RES-03 | Admin shall be able to activate or deactivate a Resident account. |
| FR-RES-04 | A Resident shall be assigned to at most one apartment through the `apartmentId` field. |

#### 3.4.4 Business Rules

- Release 1.0 manages one building with 12 floors and approximately 36 to 48 apartments.
- An apartment may be Vacant or Occupied.
- An apartment may have no owner while vacant.
- The owner must also be represented as a Resident account.
- Assignment operations shall keep the Apartment and User records consistent.

### 3.5 Maintenance Request Management

#### 3.5.1 Purpose

This feature allows Residents to report apartment maintenance issues and allows Admin or Staff to process them.

#### 3.5.2 Screens

- My Request List.
- Request Create.
- Request Details.
- Request Management.

#### 3.5.3 Functional Requirements

| ID | Requirement |
|---|---|
| FR-REQ-01 | A Resident shall be able to create a request with title, description, and category. |
| FR-REQ-02 | A Resident shall be able to attach up to three images to a request. |
| FR-REQ-03 | The system shall associate the request with the authenticated Resident and apartment. |
| FR-REQ-04 | A new request shall have Pending status. |
| FR-REQ-05 | A Resident shall be able to view only requests belonging to the current account through the intended Resident flow. |
| FR-REQ-06 | Admin or Staff shall be able to view all requests and filter by status. |
| FR-REQ-07 | The system shall store the current Admin or Staff account identifier in `assignedStaffId` when that account updates a request. |
| FR-REQ-08 | Admin or Staff shall be able to update a request to In Progress or Completed. |
| FR-REQ-09 | Admin or Staff shall be able to enter a resolution note. |

#### 3.5.4 Status Flow

`Pending → In Progress → Completed`

The status `Confirmed` is not used in Release 1.0.

### 3.6 Complaint and Feedback Management

#### 3.6.1 Purpose

This feature allows Residents to submit complaints or feedback and allows Admin or Staff to review and respond.

#### 3.6.2 Screens

- My Complaint List.
- Complaint Create.
- Complaint Details.
- Complaint Management.

#### 3.6.3 Functional Requirements

| ID | Requirement |
|---|---|
| FR-COM-01 | A Resident shall be able to submit complaint or feedback content. |
| FR-COM-02 | The system shall associate the complaint with the authenticated Resident and apartment. |
| FR-COM-03 | A new complaint shall have Submitted status. |
| FR-COM-04 | A Resident shall be able to view complaints submitted by the current account. |
| FR-COM-05 | Admin or Staff shall be able to view all complaints. |
| FR-COM-06 | Admin or Staff shall be able to mark a complaint as In Review. |
| FR-COM-07 | Admin or Staff shall be able to enter a response and resolve the complaint. |
| FR-COM-08 | The system shall store the responder and response time. |

#### 3.6.4 Status Flow

`Submitted → In Review → Resolved`

### 3.7 Bill and Manual Payment Management

#### 3.7.1 Purpose

This feature allows Staff to create bills and verify manual payments and allows Residents to view bills, submit bank-transfer confirmations, and view payment history.

#### 3.7.2 Screens

- Bill List.
- Bill Create.
- Bill Details.
- My Bills.
- Bill Payment.
- Payment History.

#### 3.7.3 Functional Requirements

| ID | Requirement |
|---|---|
| FR-BILL-01 | Staff shall be able to create a bill with apartment identifier, type, amount, billing month, and due date. |
| FR-BILL-02 | Supported bill types shall be Electricity, Water, Service, and Parking. |
| FR-BILL-03 | A newly created bill shall have Unpaid status. |
| FR-BILL-04 | Staff shall be able to view and filter bills by apartment, billing month, and status. |
| FR-BILL-05 | A Resident shall be able to view bills associated with the assigned apartment. |
| FR-PAY-01 | The Bill Payment screen shall display the building bank account, payment amount, and transfer reference. |
| FR-PAY-02 | A Resident shall be able to submit a bank-transfer payment confirmation for an Unpaid bill. |
| FR-PAY-03 | Submission of a bank-transfer confirmation shall create a Pending payment and change the bill to Pending. |
| FR-PAY-04 | Staff shall be able to approve a Pending bank-transfer payment. |
| FR-PAY-05 | Approval shall change the payment to Approved and the bill to Paid. |
| FR-PAY-06 | Staff shall be able to reject a Pending bank-transfer payment and provide a rejection reason. |
| FR-PAY-07 | Rejection shall change the payment to Rejected and return the bill to Unpaid. |
| FR-PAY-08 | Staff shall be able to record a cash payment directly as Approved. |
| FR-PAY-09 | Payment and bill status changes shall be committed using a Firestore batch. |
| FR-PAY-10 | A Resident shall be able to view payment history. |

#### 3.7.4 Bill Status Flow

- Manual bank transfer: `Unpaid → Pending → Paid`
- Rejected bank transfer: `Unpaid → Pending → Unpaid`
- Cash payment: `Unpaid → Paid`
- An overdue bill may use `Overdue` when overdue-status processing is implemented.

#### 3.7.5 Payment Status Flow

- Bank transfer: `Pending → Approved`
- Rejected bank transfer: `Pending → Rejected`
- Cash payment: the payment is created with `Approved` status.

#### 3.7.6 Release 1.0 Payment Boundary

Release 1.0 does not perform a banking transaction inside the application. It does not maintain an in-app wallet, automatically deduct fees, query a payment gateway, or automatically refund money. The application records and verifies manual cash and bank-transfer payments.

### 3.8 Announcement Management

#### 3.8.1 Purpose

This feature allows Admin and Staff to publish building announcements and allows all authenticated roles to read announcements intended for them.

#### 3.8.2 Screens

- Announcement List.
- Announcement Create or Edit.
- Announcement Details.

#### 3.8.3 Functional Requirements

| ID | Requirement |
|---|---|
| FR-ANN-01 | All authenticated roles shall be able to view the in-app announcement list. Release 1.0 does not filter the list by `targetRoles`. |
| FR-ANN-02 | Admin and Staff shall be able to create an announcement with title, content, type, and target roles. |
| FR-ANN-03 | Admin and Staff shall be able to edit an existing announcement. |
| FR-ANN-04 | Admin and Staff shall be able to delete an announcement after explicit confirmation. |
| FR-ANN-05 | The system shall store the creator, creation time, and last update time when available. |
| FR-ANN-06 | Release 1.0 shall display announcements inside the application. Push delivery is not part of the implemented Release 1.0 flow. |

### 3.9 Visitor Management

#### 3.9.1 Purpose

This feature allows Residents to register expected visitors and allows Admin or Staff to manage visitor entry and exit.

#### 3.9.2 Screens

- Visitor Registration.
- Visitor List and Check-In/Out.

#### 3.9.3 Functional Requirements

| ID | Requirement |
|---|---|
| FR-VIS-01 | A Resident shall be able to register a visitor with name, phone number, purpose, apartment, and expected time. |
| FR-VIS-02 | A new visitor shall have Registered status. |
| FR-VIS-03 | Admin or Staff shall be able to view and search the visitor list. |
| FR-VIS-04 | Admin or Staff shall be able to check in a Registered visitor. |
| FR-VIS-05 | Check-in shall set the status to Checked In and store the check-in time and processing account. |
| FR-VIS-06 | Admin or Staff shall be able to check out a Checked In visitor. |
| FR-VIS-07 | Check-out shall set the status to Checked Out and store the check-out time. |

#### 3.9.4 Status Flow

`Registered → Checked In → Checked Out`

### 3.10 Dashboard

#### 3.10.1 Purpose

The Admin Dashboard provides a compact operational overview of the current Firestore data.

#### 3.10.2 Functional Requirements

| ID | Requirement |
|---|---|
| FR-DASH-01 | Admin shall be able to view the total number of apartment records. |
| FR-DASH-02 | Admin shall be able to view the number of user profiles with the Resident role. |
| FR-DASH-03 | Admin shall be able to view the number of Pending maintenance requests. |
| FR-DASH-04 | Admin shall be able to view the number of Unpaid bills. |
| FR-DASH-05 | Admin shall be able to view the number of visitors with Checked In status. |
| FR-DASH-06 | Admin shall be able to refresh the dashboard counters. |
| FR-DASH-07 | Release 1.0 dashboard output is on-screen summary data and is not an exportable PDF or Excel report. |

### 3.11 Shared User Interface Behaviour

| ID | Requirement |
|---|---|
| FR-UI-01 | Asynchronous screens shall display a loading state while waiting for data. |
| FR-UI-02 | A screen shall display a clear error state and retry action when data loading fails. |
| FR-UI-03 | A list screen shall display an empty state when no matching records exist. |
| FR-UI-04 | Destructive actions shall require explicit user confirmation. |
| FR-UI-05 | Forms shall display inline validation messages for invalid required input. |
| FR-UI-06 | Search for Vietnamese names shall support case-insensitive and accent-insensitive matching where implemented. |
| FR-UI-07 | Dates, date-times, billing months, and currency shall use Vietnamese formatting. |
| FR-UI-08 | The interface shall support light and dark theme modes where the shared theme is applied. |

### 3.12 Screen Input Definitions

| # | Screen or Form | Input Fields | Mandatory and Validation Rules | Actions |
|---|---|---|---|---|
| 1 | Login | Email; Password | Both fields are mandatory. Email must have a valid email format. | Login; show or hide password. |
| 2 | Change Password | Current Password; New Password; Confirm New Password | All fields are mandatory. The new password must satisfy password rules. Confirmation must match the new password. | Change Password; cancel or navigate back. |
| 3 | User Create | Email; Full Name; Phone; Role; Apartment; National ID; Date of Birth | Email, full name, phone, role, and required identity fields must pass form validation. Apartment is optional and is mainly applicable to Resident. | Create User; cancel or navigate back. |
| 4 | User Edit | Full Name; Phone; Role; Apartment; National ID; Date of Birth; Status | Editable fields must pass form validation. Email is read-only. The current Admin cannot deactivate the current account. | Save Changes; activate or deactivate; cancel or navigate back. |
| 5 | Apartment Form | Number; Floor; Building; Area; Price; Type; Status | Required apartment identity and physical fields must contain valid text or numeric values. | Save Apartment; cancel or navigate back. |
| 6 | Resident Form | Email or account identifier as applicable; Full Name; Phone; National ID; Date of Birth; Apartment; Status | Required identity and contact fields must pass validation. | Save Resident; cancel or navigate back. |
| 7 | Profile | Email; Full Name; Phone; National ID; Date of Birth | Email, role, status, and apartment assignment are not editable through self-service. Editable fields must pass validation. | Save Profile; Change Password; Logout; toggle theme. |
| 8 | Request Create | Title; Category; Description; Images | Title and description are mandatory. Category is mandatory. A maximum of three images may be selected. Resident and apartment identifiers come from the authenticated profile. | Pick Images; remove selected image; Submit Request. |
| 9 | Request Processing | Status; Resolution Note | Status must be Pending, In Progress, or Completed. Resolution note is optional. The processing account identifier is taken from the authenticated Admin or Staff profile. | Update Status. |
| 10 | Complaint Create | Content | Complaint or feedback content is mandatory. Resident and apartment identifiers come from the authenticated profile. | Submit Complaint. |
| 11 | Complaint Response | Status; Response | Status must be Submitted, In Review, or Resolved. Response is required when resolving a complaint. | Mark In Review; Save Response and Resolve. |
| 12 | Bill Create | Apartment Identifier; Bill Type; Amount; Billing Month; Due Date | All fields are mandatory. Amount must be a positive number. Billing month uses `YYYY-MM`. Bill type must be Electricity, Water, Service, or Parking. | Create Bill. |
| 13 | Bank-Transfer Confirmation | Bill Identifier; Apartment Identifier; Resident Identifier; Amount; Payment Method; Proof Reference | Bill, apartment, Resident, amount, and payment method are derived from the selected bill and authenticated profile. Release 1.0 currently uses a stored proof reference rather than a complete proof-upload workflow. | Copy Bank Information; Confirm Transfer. |
| 14 | Payment Rejection | Rejection Reason | Rejection reason is mandatory before rejecting a Pending bank-transfer confirmation. | Reject Payment; cancel. |
| 15 | Announcement Create or Edit | Title; Content; Type; Target Roles | Title and content are mandatory. One or more target-role values may be stored as metadata. Release 1.0 does not filter announcement retrieval by target role. | Save Announcement; cancel or navigate back. |
| 16 | Visitor Registration | Visitor Name; Visitor Phone; Purpose; Expected Time; Apartment | Visitor name, phone, purpose, and apartment are mandatory. Expected time is optional when the form permits. | Register Visitor. |

### 3.13 Detailed Use Case Conditions

The main success flows are defined in Section 2.2.2. This section defines the preconditions, triggers, postconditions, and principal alternative or error conditions.

| Use Case | Preconditions | Trigger | Postconditions | Alternative or Error Conditions |
|---|---|---|---|---|
| UC-01 Login | The application has started and the user is not authenticated. A Firebase Authentication account and Firestore user profile exist. | The user submits email and password. | The authentication session and active profile are loaded, and the correct role home screen is displayed. | Invalid email, incorrect password, missing profile, inactive status, or Firebase failure results in an error and no protected access. |
| UC-02 Logout | The user is authenticated. | The user selects Logout. | The session is ended and Login is displayed. | If logout reports an error, the application displays the error and maintains a safe authentication state. |
| UC-03 Change Password | The user is authenticated and knows the current password. | The user submits the password-change form. | Firebase Authentication stores the new password. | Incorrect current password, weak new password, mismatched confirmation, or network failure prevents the update. |
| UC-04 View and Update Own Profile | The user is authenticated and the user profile is loaded. | The user opens Profile or submits profile changes. | The permitted profile data is displayed or updated. | Invalid input or Firestore failure leaves the stored profile unchanged and displays an error. |
| UC-05 View Dashboard Statistics | Admin is authenticated. | Admin opens or refreshes Dashboard. | Current aggregate counters are displayed. | A failed count query displays a dashboard loading error without granting additional permissions. |
| UC-06 Manage User Accounts | Admin is authenticated. | Admin opens User List or submits a create, edit, role, apartment, or status operation. | The relevant Firebase Authentication and Firestore account data is created or updated. | Duplicate email, invalid data, provisioning failure, self-deactivation, or Firestore failure prevents or rolls back the operation where supported. |
| UC-07 Manage Apartments | Admin is authenticated. | Admin opens the apartment feature or submits create, update, or delete. | Apartment data is displayed, created, updated, or deleted. | Invalid input or Firestore failure prevents the change. Delete is cancelled if confirmation is declined. |
| UC-08 Assign Resident | Admin is authenticated and the apartment and Resident records exist. | Admin selects a Resident in the Apartment Details assignment dialog. | The apartment and Resident records are updated, and the apartment becomes Occupied. | Missing records or transaction failure leaves the assignment incomplete and displays an error. |
| UC-09 Manage Resident Records | Admin is authenticated. | Admin opens Resident Management or submits a Resident change. | Resident data is displayed or updated. | Invalid input or Firestore failure prevents the change. |
| UC-10 Submit Maintenance Request | Resident is authenticated and has an apartment assignment. | Resident submits the request form. | A Pending request is stored with uploaded image URLs when images were selected. | A Resident without an apartment, invalid input, upload failure, or Firestore failure prevents submission and displays an error. |
| UC-11 View Own Maintenance Requests | Resident is authenticated. | Resident opens the request list or selects a request. | Requests for the current Resident and the selected details are displayed. | No data displays an empty state. Query failure displays an error and retry option where available. |
| UC-12 Manage Maintenance Requests | Admin or Staff is authenticated and the request exists. | The user opens Request Management or submits a status update. | The request status, processing account identifier, resolution note, and update time are saved. | Invalid status, missing request, or Firestore failure prevents the update. |
| UC-13 Submit Complaint or Feedback | Resident is authenticated and has an apartment assignment. | Resident submits complaint content. | A complaint with Submitted status is stored. | Empty content, missing apartment assignment, or Firestore failure prevents submission. |
| UC-14 View Own Complaints | Resident is authenticated. | Resident opens the complaint list or details. | Complaints for the current Resident are displayed. | No data displays an empty state. Query failure displays an error. |
| UC-15 Review and Respond to Complaint | Admin or Staff is authenticated and the complaint exists. | The user marks the complaint In Review or submits a response. | Status, response, responder, response time, and update time are saved. | Empty required response, missing complaint, or Firestore failure prevents resolution. |
| UC-16 Create Bill | Staff is authenticated. | Staff submits the Bill Create form. | An Unpaid bill is created. | Invalid apartment, amount, month, due date, or Firestore failure prevents creation. |
| UC-17 View and Manage Bills | Staff is authenticated. | Staff opens Bill List, applies filters, or opens Bill Details. | Matching bill and pending-payment information is displayed. | No matching bills displays an empty state. Query failure displays an error. |
| UC-18 View My Bills | Resident is authenticated and has an apartment assignment. | Resident opens My Bills. | Bills for the assigned apartment are displayed. | Missing apartment assignment, no bills, or query failure displays the corresponding empty or error state. |
| UC-19 Submit Bank-Transfer Payment Confirmation | Resident is authenticated and the selected bill is Unpaid. | Resident confirms that a transfer was made. | A Pending payment is created and the bill becomes Pending in one batch. | Cancellation makes no change. Firestore failure prevents both records from being presented as successfully updated. |
| UC-20 Record Cash Payment | Staff is authenticated and the selected bill is not Paid. | Staff confirms cash receipt. | An Approved cash payment is created and the bill becomes Paid. | Cancellation or Firestore failure leaves the bill unchanged. |
| UC-21 Approve or Reject Bank Transfer | Staff is authenticated and a Pending payment exists. | Staff selects Approve or submits Reject with a reason. | Approval produces an Approved payment and Paid bill; rejection produces a Rejected payment and Unpaid bill. | Missing payment, missing rejection reason, cancellation, or Firestore failure prevents the status change. |
| UC-22 View Payment History | Resident is authenticated. | Resident opens Payment History. | Matching payments are displayed in descending time order. | No payments displays an empty state. Query failure displays an error. |
| UC-23 View Announcements | The user is authenticated. | The user opens Announcement List or selects an announcement. | The in-app announcement list or selected announcement is displayed. | No announcements displays an empty state. Query failure displays an error. |
| UC-24 Manage Announcements | Admin or Staff is authenticated. | The user creates, edits, or confirms deletion of an announcement. | The announcement is created, updated, or deleted. | Invalid content or Firestore failure prevents saving. Declining delete confirmation makes no change. |
| UC-25 Register Visitor | Resident is authenticated and has an apartment assignment. | Resident submits the visitor form. | A visitor record with Registered status is created. | Invalid input, missing apartment assignment, or Firestore failure prevents registration. |
| UC-26 View Visitor List | Admin or Staff is authenticated. | The user opens Visitor List or enters a search query. | Matching visitors and their statuses are displayed. | No matching visitors displays an empty state. Query failure displays an error. |
| UC-27 Check In or Check Out Visitor | Admin or Staff is authenticated and the visitor exists. | The user selects the valid check-in or check-out action. | The visitor status, relevant timestamp, and processing account are updated. | An invalid status transition, missing visitor, or Firestore failure prevents the update. |

---

## 4. Non-Functional Requirements

### 4.1 External Interfaces

| Interface | Description |
|---|---|
| Android and iOS Mobile Application | The Flutter mobile application is the user interface for Admin, Staff, and Resident. The application is designed primarily for portrait orientation. |
| Firebase Authentication | Authenticates users by email and password, maintains the authentication session, supports password change, and provides Firebase user identifiers. |
| Cloud Firestore | Stores user profiles, apartments, maintenance requests, complaints, bills, payments, announcements, and visitor records. |
| Firebase Storage | Stores uploaded maintenance request images and provides their download URLs. |
| Device Clipboard | Allows the Resident to copy bank account or transfer-reference information from the manual payment screen. |

The following interfaces are not part of Release 1.0:

- VNPay, MoMo, or another payment gateway.
- An in-app wallet.
- A separate Web Admin application.
- Face recognition hardware or services.
- An Excel or PDF report export service.
- An automated backup and restore interface exposed by the application.

### 4.2 Quality Attributes

#### 4.2.1 Usability

The system shall meet the following usability requirements:

1. The user interface shall be Vietnamese-first and use the `vi_VN` locale for dates and currency.
2. Each role shall be redirected to a home screen containing only the functions intended for that role.
3. Frequently used functions shall be reachable from the role home screen or bottom navigation.
4. Forms shall identify required fields and display validation errors close to the invalid field.
5. Password fields shall mask entered characters and allow the user to toggle visibility.
6. List screens shall provide loading, error, empty, and data states.
7. Destructive actions, including apartment deletion, announcement deletion, and user deactivation, shall require explicit confirmation.
8. Statuses shall be displayed with readable labels and visually distinct status indicators.
9. Monetary values shall be displayed in Vietnamese currency format.
10. The application shall provide feedback after successful or failed create, update, approval, rejection, check-in, and check-out operations.

#### 4.2.2 Reliability

The system shall meet the following reliability requirements:

1. A failed Firestore operation shall not be presented as successful.
2. The application shall display an error message and retain a usable navigation state when a data operation fails.
3. Payment approval, payment rejection, cash recording, and related bill-status updates shall use Firestore batched writes so that related records are updated together.
4. If user account provisioning creates a Firebase Authentication account but fails to create the Firestore profile, the system shall attempt to roll back the new authentication account.
5. The application shall prevent duplicate submission by disabling or guarding a submit action while the corresponding request is being processed.
6. A missing or invalid user profile shall not grant access to a role home screen.
7. Firestore timestamps shall be recorded for creation and update events where supported by the entity.
8. Quantitative production availability, Mean Time Between Failures, and Mean Time To Repair targets shall be defined only when a deployed environment and an operational monitoring process are available.

#### 4.2.3 Performance

The system shall meet the following performance requirements for the Release 1.0 scope:

1. The apartment list shall support the expected building capacity of approximately 36 to 48 apartments.
2. Search and local filtering shall update without requiring a full application restart.
3. A screen shall display an immediate loading indicator when a network request begins.
4. Firestore list results shall be sorted or filtered without blocking normal user interaction.
5. Dashboard counters shall use Firestore count aggregation rather than downloading all documents solely to calculate totals.
6. Images displayed from remote URLs shall use loading placeholders and error handling where applicable.
7. Formal response-time and concurrent-user claims shall be accompanied by a documented test environment and measured results before being stated as verified Release 1.0 characteristics.

#### 4.2.4 Security

The system shall meet the following security requirements:

1. All protected application screens shall require an authenticated Firebase session.
2. Admin routes shall not be accessible to Staff or Resident through the application router.
3. Staff operational routes shall not be accessible to Resident through the application router.
4. User account creation, role changes, and account-status changes shall be restricted to Admin through the intended application flow.
5. An Inactive account shall not be allowed to continue using protected application data.
6. Passwords shall be managed by Firebase Authentication and shall not be stored in Cloud Firestore.
7. Password input shall be masked.
8. A user shall not be permitted to change the account role, status, or apartment assignment through personal profile editing.
9. Firestore Security Rules shall be reviewed before production deployment so that collection-level read and write permissions enforce the same authorization described in Section 3.1.3.
10. API keys and secrets that require confidentiality shall not be committed to the repository.

#### 4.2.5 Maintainability

The system shall meet the following maintainability requirements:

1. The Flutter source code shall follow Dart naming and formatting conventions.
2. Business data structures shall be represented by dedicated model classes.
3. Firebase operations shall be separated into service classes.
4. Screen state shall be managed through Provider-based state classes.
5. Route paths and Firestore collection names shall be defined as shared constants.
6. Reusable loading, empty, error, confirmation, form, and status widgets shall be shared across features.
7. New business logic shall include unit tests, and critical user-interface behaviour shall include widget tests.
8. Source code, comments, and variable names shall be written in English.

#### 4.2.6 Compatibility

1. The application shall support Android and iOS targets supported by the configured Flutter project.
2. The primary mobile interface shall support portrait-up and portrait-down orientations.
3. The application shall use a consistent Material theme and bundled font assets.
4. Release 1.0 does not require a separate browser-based Admin interface.

---

## 5. Requirement Appendix

### 5.1 Business Rules

| ID | Rule Definition |
|---|---|
| BR-01 | The system supports exactly three application roles in Release 1.0: Admin, Staff, and Resident. |
| BR-02 | A user account has either Active or Inactive status. Locked is not a Release 1.0 account status. |
| BR-03 | Only Admin can create accounts, assign roles, change another account status, and manage account apartment assignments through the intended application flow. |
| BR-04 | User accounts are deactivated instead of being permanently deleted in Release 1.0. |
| BR-05 | An Admin cannot deactivate the account currently being used. |
| BR-06 | A Resident account may be assigned to at most one apartment through `apartmentId`. |
| BR-07 | An apartment may contain multiple Resident identifiers and may have one optional owner identifier. |
| BR-08 | Maintenance request categories are Plumbing, Electrical, and General. |
| BR-09 | Maintenance request statuses are Pending, In Progress, and Completed. |
| BR-10 | Complaint statuses are Submitted, In Review, and Resolved. |
| BR-11 | Bill types are Electricity, Water, Service, and Parking. |
| BR-12 | Bill statuses are Unpaid, Pending, Paid, and Overdue. |
| BR-13 | Payment methods are Cash and Bank Transfer. |
| BR-14 | Payment statuses are Pending, Approved, and Rejected. |
| BR-15 | A submitted bank-transfer confirmation places both the payment and the related bill into Pending state. |
| BR-16 | Approval of a payment changes the payment to Approved and the related bill to Paid. |
| BR-17 | Rejection of a bank-transfer confirmation requires a reason, changes the payment to Rejected, and returns the related bill to Unpaid. |
| BR-18 | A cash payment recorded by Staff is created as Approved and changes the related bill to Paid. |
| BR-19 | Release 1.0 does not automatically deduct fees and does not process refunds through an in-app wallet. |
| BR-20 | Admin and Staff can create, edit, and delete announcements; Resident can only view announcements. |
| BR-21 | A new visitor registration has Registered status. A visitor must be Checked In before being Checked Out. |
| BR-22 | A destructive operation requires explicit confirmation before execution. |
| BR-23 | Application dates and currency values use Vietnamese display formatting. |

### 5.2 Common Requirements

| ID | Requirement |
|---|---|
| CR-01 | Required text fields shall reject empty input. |
| CR-02 | Email fields shall validate email format. |
| CR-03 | Vietnamese phone numbers shall be validated according to the application phone rules. |
| CR-04 | Submit actions shall display progress and shall not allow unintended repeated submission while processing. |
| CR-05 | Successful operations shall display a confirmation message. |
| CR-06 | Failed operations shall display a user-friendly Vietnamese error message. |
| CR-07 | Empty list results shall display a dedicated empty state rather than a blank screen. |
| CR-08 | Data-loading failures shall provide a retry action where the screen supports retry. |
| CR-09 | Search input shall be trimmed before matching. |
| CR-10 | Date-time values shall be stored as Firestore timestamps and displayed in Vietnamese format. |
| CR-11 | Currency amounts shall be stored as numeric values and displayed as Vietnamese currency. |
| CR-12 | Record creation and update operations shall maintain creation and update timestamps where defined by the entity. |
| CR-13 | The application shall use shared route constants instead of duplicating route path strings. |
| CR-14 | The application shall use shared collection-name constants for defined Firestore collections. |

### 5.3 Application Messages List

| # | Message Code | Message Type | Context | Content |
|---|---|---|---|---|
| 1 | MSG-001 | Inline | Email is empty | Vui lòng nhập email. |
| 2 | MSG-002 | Inline | Email format is invalid | Email không hợp lệ. |
| 3 | MSG-003 | Inline | Login password is empty | Vui lòng nhập mật khẩu. |
| 4 | MSG-004 | Error message | Login credentials are invalid | Email hoặc mật khẩu không đúng. |
| 5 | MSG-005 | Error message | Account is inactive | Tài khoản đã bị vô hiệu hóa. Vui lòng liên hệ quản trị viên. |
| 6 | MSG-006 | Success message | Password changed successfully | Đổi mật khẩu thành công. |
| 7 | MSG-007 | Empty state | Search has no matching result | Không tìm thấy kết quả phù hợp. |
| 8 | MSG-008 | Success message | User account created | Tạo tài khoản thành công. |
| 9 | MSG-009 | Confirmation dialog | Admin deactivates a user | Vô hiệu hóa tài khoản? Người dùng sẽ không thể truy cập ứng dụng cho đến khi được kích hoạt lại. |
| 10 | MSG-010 | Confirmation dialog | Admin deletes an apartment | Xóa căn hộ? Thao tác này không thể hoàn tác. |
| 11 | MSG-011 | Success message | Maintenance request submitted | Gửi yêu cầu thành công. |
| 12 | MSG-012 | Success message | Maintenance request status updated | Cập nhật trạng thái yêu cầu thành công. |
| 13 | MSG-013 | Success message | Complaint submitted | Gửi khiếu nại thành công. |
| 14 | MSG-014 | Success message | Complaint response saved | Phản hồi khiếu nại thành công. |
| 15 | MSG-015 | Success message | Bill created | Tạo hóa đơn thành công. |
| 16 | MSG-016 | Confirmation dialog | Resident submits bank-transfer confirmation | Bạn xác nhận đã thực hiện chuyển khoản số tiền này đến tài khoản Ban quản lý? |
| 17 | MSG-017 | Success message | Payment confirmation submitted | Yêu cầu thanh toán đã được gửi. Vui lòng chờ Ban quản lý đối soát và phê duyệt. |
| 18 | MSG-018 | Success message | Staff approves payment | Đã xác nhận thanh toán thành công. |
| 19 | MSG-019 | Success message | Staff rejects payment | Đã từ chối yêu cầu thanh toán. |
| 20 | MSG-020 | Confirmation dialog | Admin or Staff deletes an announcement | Xóa thông báo? Thao tác này không thể hoàn tác. |
| 21 | MSG-021 | Success message | Announcement created or updated | Lưu thông báo thành công. |
| 22 | MSG-022 | Success message | Visitor registered | Đăng ký khách thăm thành công. |
| 23 | MSG-023 | Success message | Visitor checked in | Check-in khách thành công. |
| 24 | MSG-024 | Success message | Visitor checked out | Check-out khách thành công. |
| 25 | MSG-025 | Error message | General Firestore operation fails | Không thể thực hiện thao tác. Vui lòng thử lại. |

### 5.4 Release Scope Exclusions

The following functions are explicitly excluded from Release 1.0:

1. Payment gateway integration with VNPay, MoMo, banks, or e-wallet providers.
2. In-app wallet balance, wallet top-up, automatic deduction, and automatic refund.
3. Automatic monthly invoice generation by a scheduled job.
4. Automatic late-fee calculation.
5. Contract management.
6. Amenity booking.
7. Separate service-order management.
8. Face registration and face authentication.
9. Vehicle management.
10. A separate Web Admin application.
11. Excel or PDF report export.
12. System settings management.
13. Audit-log screens.
14. Application-level database backup and restore.
15. Verified production uptime, MTBF, MTTR, and concurrent-user service-level claims without deployment monitoring and performance-test evidence.

---

# Diagram Redrawing Guide

Phần này dùng để vẽ tay. Tên actor, use case, screen và entity nên giữ bằng tiếng Anh để đồng nhất với nội dung SRS.

## A. Figure 1-1 — System Context Diagram

### Thành phần phải có

Vẽ một khối trung tâm:

- `Apartment Building Management System — Flutter Mobile App`

Vẽ ba actor người dùng ở bên trái:

1. `Admin`
2. `Staff`
3. `Resident`

Vẽ ba dịch vụ Firebase ở bên phải:

1. `Firebase Authentication`
2. `Cloud Firestore`
3. `Firebase Storage`

### Luồng dữ liệu cần ghi

Giữa `Admin` và hệ thống:

- User and role management.
- Apartment and Resident management.
- Announcements.
- Dashboard data.
- Request, complaint, and visitor review.

Giữa `Staff` và hệ thống:

- Maintenance processing.
- Bill creation.
- Payment verification.
- Complaint response.
- Visitor check-in and check-out.
- Announcement management.

Giữa `Resident` và hệ thống:

- Login and profile.
- Maintenance requests.
- Complaints and feedback.
- Bills and payment confirmations.
- Visitor registrations.
- Announcements.

Giữa hệ thống và `Firebase Authentication`:

- Login credentials.
- Authentication result.
- Session state.
- Password update.

Giữa hệ thống và `Cloud Firestore`:

- User profiles.
- Apartments.
- Requests.
- Complaints.
- Bills and payments.
- Announcements.
- Visitors.

Giữa hệ thống và `Firebase Storage`:

- Request images.
- Download URLs.

### Thành phần phải xóa khỏi sơ đồ cũ

- `Payment Gateway`.
- `Payment Request`.
- `Transaction Result`.
- `System Report` dưới dạng file export.
- `Task Assignment` nếu sơ đồ đang thể hiện một hệ thống phân công công việc riêng.
- `Worker order update`.
- `Configuration / User Management` nếu nó được nối với actor `System Admin` cũ; thay bằng các luồng Admin ở trên.

Không thêm `Web Admin`, `Wallet`, `VNPay`, `MoMo`, `Face Authentication`, `Vehicle`, `Contract`, `Amenity`, `Service Order`, `Backup`, hoặc `Audit Log`.

## B. Figure 2-1 — Use Case Diagram

### Actors

Chỉ dùng ba actor:

- `Admin`
- `Staff`
- `Resident`

Không dùng:

- `Payment Gateway`
- `System Admin` như một role tách biệt với Admin
- `Building Staff` nếu tài liệu đã chọn tên role là Staff
- `BQL Manager`
- `BQL Staff`
- `BQT Head`
- `BQT Member`

### Cách bố cục khuyến nghị

Nếu một sơ đồ duy nhất quá dày, chia thành ba hình:

1. `Figure 2-1a: Shared and Admin Use Cases`
2. `Figure 2-1b: Staff Use Cases`
3. `Figure 2-1c: Resident Use Cases`

Nếu giảng viên yêu cầu đúng một hình, dùng các package bên trong system boundary:

- Authentication and Profile.
- Administration.
- Maintenance and Complaint.
- Bill and Payment.
- Announcement.
- Visitor.

### Use case chung cho cả ba actor

Nối `Admin`, `Staff`, và `Resident` với:

- `Login`
- `Logout`
- `Change Password`
- `View and Update Own Profile`
- `View Announcements`

Quan hệ:

- `Login` `<<include>>` `Validate Credentials`
- `Login` `<<include>>` `Load User Profile`
- `Login` `<<include>>` `Redirect by Role`

Ba use case include có thể bỏ khỏi hình nếu cần giảm độ phức tạp, nhưng không được thêm Payment Gateway.

### Use case của Admin

Nối `Admin` với:

- `View Dashboard Statistics`
- `Manage User Accounts`
- `Manage Apartments`
- `Assign Resident`
- `Manage Resident Records`
- `Manage Maintenance Requests`
- `Review and Respond to Complaint`
- `Manage Announcements`
- `View Visitor List`
- `Check In or Check Out Visitor`

Quan hệ:

- `Manage User Accounts` `<<include>>` `Create User`
- `Manage User Accounts` `<<include>>` `Edit User`
- `Manage User Accounts` `<<include>>` `Assign Role`
- `Manage User Accounts` `<<include>>` `Activate or Deactivate User`
- `Manage Apartments` `<<include>>` `View Apartment List`
- `Manage Apartments` `<<include>>` `Create or Update Apartment`
- `Manage Apartments` `<<include>>` `View Apartment Details`
- `Assign Resident` có thể đặt là `<<extend>>` từ `View Apartment Details` vì chỉ thực hiện khi Admin mở chi tiết căn hộ.
- `Manage Resident Records` `<<include>>` `View Resident List`
- `Manage Resident Records` `<<include>>` `Create or Update Resident`
- `Manage Maintenance Requests` `<<include>>` `Update Request Status`
- `Review and Respond to Complaint` `<<include>>` `Update Complaint Status`
- `Manage Announcements` `<<include>>` `Create or Edit Announcement`
- `Delete Announcement` `<<extend>>` `Manage Announcements`
- `Check In or Check Out Visitor` `<<extend>>` `View Visitor List`

### Use case của Staff

Nối `Staff` với:

- `Manage Maintenance Requests`
- `Create Bill`
- `View and Manage Bills`
- `Record Cash Payment`
- `Approve or Reject Bank Transfer`
- `Review and Respond to Complaint`
- `Manage Announcements`
- `View Visitor List`
- `Check In or Check Out Visitor`

Quan hệ:

- `View and Manage Bills` `<<include>>` `View Bill Details`
- `Record Cash Payment` `<<extend>>` `View Bill Details`
- `Approve or Reject Bank Transfer` `<<extend>>` `View Bill Details`
- `Manage Maintenance Requests` `<<include>>` `Update Request Status`
- `Review and Respond to Complaint` `<<include>>` `Update Complaint Status`
- `Check In or Check Out Visitor` `<<extend>>` `View Visitor List`

### Use case của Resident

Nối `Resident` với:

- `Submit Maintenance Request`
- `View Own Maintenance Requests`
- `Submit Complaint or Feedback`
- `View Own Complaints`
- `View My Bills`
- `Submit Bank-Transfer Payment Confirmation`
- `View Payment History`
- `Register Visitor`

Quan hệ:

- `Submit Bank-Transfer Payment Confirmation` `<<extend>>` `View My Bills`
- `View Request Details` `<<extend>>` `View Own Maintenance Requests`
- `View Complaint Details` `<<extend>>` `View Own Complaints`

### Use case phải xóa khỏi sơ đồ cũ

- `Process Payment` qua Payment Gateway.
- `Generate Monthly Invoice`.
- `View Reports`.
- `Export Report`.
- `Confirm Request` như một trạng thái riêng.

### Use case phải đổi tên

- `Feedback` → `Submit Complaint or Feedback`
- `Manage Maintenance` → `Manage Maintenance Requests`
- `View Request Status` → `View Own Maintenance Requests`
- `Pay Invoice` → `Submit Bank-Transfer Payment Confirmation`
- `System Admin` → `Admin`
- `Building Staff` → `Staff`

## C. Figure 3-1 — Role-Based Screen Flow

### Luồng bắt đầu

Vẽ:

`Splash → Login`

Từ `Splash`, thêm nhánh:

- Có session hợp lệ và profile Active → `Role Decision`
- Không có session → `Login`
- Profile thiếu hoặc Inactive → `Login with Error Message`

Từ `Login`:

`Login → Role Decision`

Từ `Role Decision`, tạo ba nhánh:

- Role = Admin → `Admin Home`
- Role = Staff → `Staff Home`
- Role = Resident → `Resident Home`

### Nhánh Admin

Từ `Admin Home`, nối đến:

- `Dashboard`
- `User List`
- `Apartment List`
- `Resident List`
- `Announcement List`
- `Request Management`
- `Complaint Management`
- `Visitor List`
- `User Profile`

Các luồng con:

- `User List → User Create`
- `User List → User Edit`
- `Apartment List → Apartment Form`
- `Apartment List → Apartment Details`
- `Apartment Details → Apartment Form`
- `Apartment Details → Assign Resident Dialog`
- `Resident List → Resident Form`
- `Resident List → Resident Profile`
- `Announcement List → Announcement Details`
- `Announcement List → Announcement Create or Edit`
- `Request Management → Request Details`
- `Complaint Management → Complaint Details`
- `Visitor List → Check-In or Check-Out Action`
- `User Profile → Change Password`
- `User Profile → Logout → Login`

### Nhánh Staff

Từ `Staff Home`, nối đến năm tab và một lối tắt:

- `Request Management`
- `Bill List`
- `Visitor List`
- `Complaint Management`
- `User Profile`
- `Announcement List`

Các luồng con:

- `Request Management → Request Details`
- `Bill List → Bill Create`
- `Bill List → Bill Details`
- `Bill Details → Record Cash Payment`
- `Bill Details → Approve or Reject Bank Transfer`
- `Visitor List → Check-In or Check-Out Action`
- `Complaint Management → Complaint Details`
- `Announcement List → Announcement Details`
- `Announcement List → Announcement Create or Edit`
- `User Profile → Change Password`
- `User Profile → Logout → Login`

### Nhánh Resident

Từ `Resident Home`, nối đến:

- `My Bills`
- `My Request List`
- `My Complaint List`
- `Announcement List`
- `Visitor Registration`
- `Payment History`
- `User Profile`

Các luồng con:

- `My Bills → Bill Payment`
- `My Request List → Request Create`
- `My Request List → Request Details`
- `My Complaint List → Complaint Create`
- `My Complaint List → Complaint Details`
- `Announcement List → Announcement Details`
- `User Profile → Change Password`
- `User Profile → Logout → Login`

### Node phải xóa khỏi screen flow cũ

- `ContractMgmt`
- `ContractList`
- `ContractDetail`
- `AmenityMgmt`
- `AmenityList`
- `BookingPage`
- `ServiceMgmt`
- `ServiceList`
- `ServiceOrder`
- `PaymentPage` nếu nó thể hiện gateway hoặc ví

### Node phải thêm so với screen flow cũ

- `Splash`
- `Admin Home`
- `Staff Home`
- `Resident Home`
- `User List`
- `User Create`
- `User Edit`
- `Resident Form`
- `Request Create`
- `Request Management`
- `Complaint List`
- `Complaint Create`
- `Complaint Details`
- `Complaint Management`
- `Bill Create`
- `Bill Details`
- `My Bills`
- `Bill Payment`
- `Payment History`
- `Announcement Create or Edit`
- `Visitor List`
- `Check-In or Check-Out Action`
- `Change Password`
- `User Profile`

## D. Figure 3-2 — Entity Relationship Diagram

### Entities

Vẽ đúng tám entity:

1. `User`
2. `Apartment`
3. `Request`
4. `Complaint`
5. `Bill`
6. `Payment`
7. `Notification`
8. `Visitor`

### Primary keys

- `User.uid`
- `Apartment.id`
- `Request.id`
- `Complaint.id`
- `Bill.billId`
- `Payment.paymentId`
- `Notification.id`
- `Visitor.id`

### Relationships và cardinality

1. `Apartment 1 — 0..* User`
   - Foreign key: `User.apartmentId → Apartment.id`
   - Ý nghĩa: một căn hộ có thể có nhiều Resident; một Resident được gán tối đa một căn hộ.

2. `Apartment 0..1 — 1 User as Owner`
   - Foreign key: `Apartment.ownerId → User.uid`
   - Ý nghĩa: một căn hộ có thể chưa có chủ hộ hoặc có một chủ hộ.

3. `Apartment 1 — 0..* Request`
   - Foreign key: `Request.apartmentId → Apartment.id`

4. `User 1 — 0..* Request as Submitter`
   - Foreign key: `Request.residentId → User.uid`

5. `User 0..1 — 0..* Request as Assigned Staff`
   - Foreign key: `Request.assignedStaffId → User.uid`
   - `assignedStaffId` là optional.

6. `Apartment 1 — 0..* Complaint`
   - Foreign key: `Complaint.apartmentId → Apartment.id`

7. `User 1 — 0..* Complaint as Submitter`
   - Foreign key: `Complaint.residentId → User.uid`

8. `User 0..1 — 0..* Complaint as Responder`
   - Foreign key: `Complaint.respondedBy → User.uid`

9. `Apartment 1 — 0..* Bill`
   - Foreign key: `Bill.apartmentId → Apartment.id`

10. `User 1 — 0..* Bill as Responsible Resident`
    - Foreign key: `Bill.residentId → User.uid`

11. `User 1 — 0..* Bill as Creator`
    - Foreign key: `Bill.createdBy → User.uid`

12. `Bill 1 — 0..* Payment`
    - Foreign key: `Payment.billId → Bill.billId`
    - Một bill có thể có nhiều lần xác nhận nếu lần trước bị từ chối.

13. `Apartment 1 — 0..* Payment`
    - Foreign key: `Payment.apartmentId → Apartment.id`

14. `User 1 — 0..* Payment as Payer`
    - Foreign key: `Payment.residentId → User.uid`

15. `User 0..1 — 0..* Payment as Recorder`
    - Foreign key: `Payment.recordedBy → User.uid`

16. `User 1 — 0..* Notification as Creator`
    - Foreign key: `Notification.createdBy → User.uid`
    - `targetRoles` là mảng role, không phải foreign key đến từng User.

17. `Apartment 1 — 0..* Visitor`
    - Foreign key: `Visitor.apartmentId → Apartment.id`

18. `User 1 — 0..* Visitor as Registering Resident`
    - Foreign key: `Visitor.registeredBy → User.uid`

19. `User 0..1 — 0..* Visitor as Check-In Processor`
    - Foreign key: `Visitor.checkedInBy → User.uid`

### Entity phải xóa khỏi ERD cũ

- `Meal`
- `Meal Subscription`
- `Product`
- Mọi entity mẫu không có model hoặc Firestore collection tương ứng.

### Lưu ý khi vẽ

- Gạch chân hoặc đánh dấu `PK` cho primary key.
- Đánh dấu `FK` cho các trường quan hệ.
- Ghi rõ enum cạnh entity hoặc trong phần ghi chú.
- Có thể không vẽ toàn bộ timestamp để sơ đồ dễ đọc, nhưng bảng Entity Details phải giữ đầy đủ timestamp.
- Không tạo entity `Role`; role đang được lưu bằng enum trong `User`.
- Không tạo entity `Payment Gateway`; Release 1.0 không có tích hợp này.
- Không tạo entity `Report`; Dashboard chỉ tổng hợp số lượng từ các collection hiện có.

## E. Screen Mock-Up Redrawing

Nếu tài liệu yêu cầu mock-up, ưu tiên các màn hình đại diện dưới đây. Không dùng mock-up LMS cũ.

### E.1 Login

Thành phần:

- App logo or building illustration.
- Title: `Welcome Back` hoặc tiêu đề đang dùng trong ứng dụng.
- `Email` field with email icon.
- `Password` field with visibility toggle.
- `Login` button.
- Loading state on the Login button.
- Area for inline validation or authentication error.

Không vẽ:

- Username field.
- Close button.
- Browser URL bar.
- LMS label.

### E.2 Admin Dashboard

Thành phần:

- App bar with `Admin Dashboard`, Refresh, and Logout.
- Five counters: Apartments, Residents, Pending Requests, Unpaid Bills, Visitors Inside.
- Quick access: User Accounts, Apartments, Maintenance Requests, Complaints, Visitors, Announcements.
- Bottom navigation: Dashboard, Apartments, Residents, Profile.

### E.3 Staff Home

Thành phần:

- Indexed content area.
- Bottom navigation: Requests, Bills, Visitors, Complaints, Profile.
- Announcement floating action button.

### E.4 Resident Home

Thành phần:

- Resident greeting or apartment summary.
- Quick actions: Bills, Maintenance Requests, Complaints, Announcements.
- Visitor Registration card.
- Payment History card.
- Bottom navigation matching the implemented Resident home structure.

### E.5 Request Create

Thành phần:

- Title.
- Category selector: Plumbing, Electrical, General.
- Description.
- Image picker and image preview list.
- Submit button.
- Inline validation.

### E.6 Bill Details and Payment Verification

Staff version:

- Bill type, apartment, amount, month, due date, and status.
- Pending payment information when available.
- `Record Cash Payment`.
- `Approve Bank Transfer`.
- `Reject Bank Transfer`.
- Reject-reason dialog.

Resident version:

- Bill information.
- Building bank name and account number.
- Transfer reference.
- Copy actions.
- Confirmation button.
- Text explaining that Staff must verify the transfer.

### E.7 Complaint Management

Thành phần:

- Status filter.
- Complaint list.
- Complaint content and Resident or apartment information.
- Mark In Review action.
- Response input.
- Resolve action.

### E.8 Visitor Management

Resident version:

- Visitor name.
- Phone number.
- Purpose.
- Expected time.
- Register button.

Staff or Admin version:

- Search.
- Visitor list.
- Status badge.
- Check-In action for Registered.
- Check-Out action for Checked In.
- Check-in and check-out timestamps.

### E.9 Announcement

List:

- Announcement cards with title, type, and date.
- Create button visible only to Admin and Staff.

Create or Edit:

- Title.
- Content.
- Type.
- Target roles.
- Save button.

Details:

- Title, content, type, creator, and time.
- Edit and Delete visible only to Admin and Staff.

### E.10 Apartment Details

Thành phần:

- Apartment number, floor, building, area, type, price, and status.
- Owner section.
- Resident member list.
- Assign Resident.
- Edit.
- Delete with confirmation.

---

# Final Consistency Checklist

Trước khi đưa nội dung vào `SRS.docx`, kiểm tra đủ các điểm sau:

- Toàn bộ tài liệu chỉ dùng ba role: Admin, Staff, Resident.
- Không còn BQL Manager, BQL Staff, BQT Head, hoặc BQT Member.
- Không còn Payment Gateway trong Release 1.0.
- Không còn wallet, automatic deduction, automatic refund, hoặc payment retry.
- Thanh toán được mô tả là manual cash hoặc manual bank transfer với Staff verification.
- Request status là Pending, In Progress, Completed.
- Complaint status là Submitted, In Review, Resolved.
- User status là Active hoặc Inactive.
- Visitor status là Registered, Checked In, Checked Out.
- Không còn Contract, Amenity, Service Order, Face Authentication, Vehicle, System Settings, Audit Log, Backup/Restore, hoặc Export Report trong scope Release 1.0.
- Screen flow có ba nhánh sau Login.
- Use case diagram có đúng ba actor.
- ERD có đúng tám entity.
- Không còn `Meal`, `Meal Subscription`, `Product`, `LMS User`, `HungNV`, hoặc ngày `11/05/2013`.
- Giao diện được mô tả là Vietnamese-first, không phải English-only.
- Mobile App phục vụ cả ba role; không mô tả một Web Admin riêng.
- Push notification không được tuyên bố là đã triển khai; Release 1.0 chỉ có in-app announcements.
- Các chỉ tiêu uptime, MTBF, MTTR, response time, và concurrent users chỉ được ghi là verified nếu nhóm có test evidence.
- Authorization table chỉ có ba cột role.
- Application messages phản ánh đúng ngữ cảnh và loại message.
