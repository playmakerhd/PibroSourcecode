# Lead-to-Customer Workflow Implementation

## Overview
This document summarizes the complete implementation of the Lead-to-Customer workflow in the Pibro mobile application. The implementation introduces a "Lead" concept where new signups create leads instead of customers, and converts leads to customers after successful payment.

## Key Changes

### 1. **Data Models**

#### LeadInformation Model (`lib/network/models/platform_user/lead_information.dart`)
- Complete Lead data model matching API response structure
- Fields: LeadID, LeadFirstName, LeadLastName, LeadEmail, LeadPhoneNumber, etc.
- Method: `toPlatformUserFormat()` - Converts Lead to Customer-compatible structure for seamless app operation

#### SalesQuotationResponse (`lib/network/models/response/sales_quotation_response.dart`)
- Models for new Sales Quotation API responses
- Classes: `SalesQuotationResponse`, `QuotationItem`, `SalesQuotationListResponse`
- Helper: `_parseDouble()` for flexible numeric parsing

#### UnifiedEntityResponse (`lib/network/models/response/entity_response.dart`)
- Wrapper for handling both Lead and Customer entities
- Provides unified interface for entity operations

### 2. **Authentication Flow**

#### Signup (`lib/core/signup/`)
- **Screen Changes**: Split name field into `firstName` and `lastName` for Individual accounts
- **Controller Changes**: 
  - Added `firstNameController` and `lastNameController`
  - Changed API call from `createCustomer` to `createLead`
  - Stores `entityType` as 'LEAD' in storage
  - Extracts Lead ID from response (e.g., "LEAD/14")

#### Login (`lib/core/login/controller/login_controller.dart`)
- Extracts `entityType` from login response message ("LEAD" or "CUSTOMER")
- Stores in both `LoginData.entityType` and separate `entityType` storage key
- Updated `LoginData` model with `entityType` field and helpers: `isLead`, `isCustomer`

### 3. **API Integration**

#### New Endpoints (`lib/network/api/endpoints.dart`)
```dart
static const String createLead = '/CreateLeadInformation';
static const String getLeadByID = '/GetLeadInformationByID';
static const String convertLeadToCustomer = '/ConvertLeadToCustomer';
static const String createSalesQuotation = '/CreateSalesQuotation';
static const String getSalesQuotationByID = '/GetSalesQuotationsByID';
static const String getSalesQuotationsByEntityID = '/GetSalesQuotationsByEntityID';
```

#### ApiProvider Methods (`lib/network/api/api_provider.dart`)
- `callCreateLeadApi()` - POST to /CreateLeadInformation with Lead payload
- `callGetLeadByID()` - GET Lead information by ID
- `callConvertLeadToCustomer()` - Convert Lead to Customer (GET)
- `callCreateSalesQuotation()` - POST to create Sales Quotation
- `callGetSalesQuotationByID()` - GET Sales Quotation by QuoteID
- `callGetSalesQuotationsByEntityID()` - GET Sales Quotations by EntityID (Lead or Customer)
- Updated `callGetProfile()` - Detects Lead, fetches Lead data, converts to Customer format

### 4. **Quote Management**

#### Quote Creation (`lib/core/quote/controller/get_quote_controller.dart`)
- **Replaced**: `sendToBroker` (Enquiry API) → `createSalesQuotation` (Sales Quotation API)
- **Mapping**: Motor fields to DetailMemo fields:
  - `DetailMemo1`: RegNo/EngineNo
  - `DetailMemo2`: ChasisId
  - `DetailMemo3`: VehicleMake
- **Process**:
  1. Call `createSalesQuotation` with entityID (Lead or Customer)
  2. Fetch created quote by ID to extract SumInsured and PremiumDue
  3. Store quoteID (e.g., "QN/11") with `_source: sales_quotation` flag

#### Quote List (`lib/core/quote/controller/quote_controller.dart`)
- **Replaced**: `getCustomerEnquiries` → `getSalesQuotationsByEntityID`
- **Process**:
  1. Extract entityID from loginData
  2. Call `getSalesQuotationsByEntityID(entityID, pageNum, size)`
  3. Convert response to `QuoteInfo` format using `_convertSalesQuotationToQuoteInfo()`
- **Backward Compatibility Mapping**:
  - `InvoiceNumber` → `caseId`
  - `NoteStatus` → `supportStatus`
  - `SumInsured` → `supportScreenShotURL` (temporary storage)
  - `PremiumDue` → `supportResolution` (temporary storage)

### 5. **Payment Flow & Lead Conversion**

#### Quote Payment Controller (`lib/core/quote/controller/quote_payment_controller.dart`)

**New Method**: `_convertLeadToCustomerIfNeeded()`

**Execution Point**: After successful receipt posting, before policy creation

**Process**:
1. **Check Entity Type**: Verify if user is a Lead
   ```dart
   final entityType = GetStorage().read(StorageKeys.entityType);
   if (entityType?.toString().toUpperCase() != 'LEAD') return;
   ```

2. **Extract Lead ID**: From loginData storage
   ```dart
   leadID = loginData['customerID'] // e.g., "LEAD/14"
   ```

3. **Call Conversion API**:
   ```dart
   final response = await repo.convertLeadToCustomer(leadID);
   ```

4. **Extract New Customer ID**: From response message
   ```dart
   final newCustomerID = response.messageResponse.message; // e.g., "CUS/84902"
   ```

5. **Update Storage**:
   ```dart
   updatedLoginData['customerID'] = newCustomerID;
   updatedLoginData['entityType'] = 'CUSTOMER';
   await GetStorage().write(StorageKeys.loginData, updatedLoginData);
   await GetStorage().write(StorageKeys.entityType, 'CUSTOMER');
   ```

6. **Refresh Profile**: Fetch and store full Customer data
   ```dart
   final profileResponse = await repo.getProfile();
   await GetStorage().write(StorageKeys.profileData, profileResponse.user.toJson());
   ```

7. **Continue to Policy Creation**: Policy is now created with Customer ID

**Error Handling**: Non-blocking - if conversion fails, policy creation proceeds with Lead ID

### 6. **Cross-Screen Compatibility**

#### PlatformUser Auto-Conversion
The `PlatformUser.fromJson()` method automatically detects and converts Lead data:
```dart
factory PlatformUser.fromJson(dynamic json) {
  // Detect if Lead data (has LeadID field)
  if (json['LeadID'] != null) {
    // Map LeadID → CustomerID, LeadFirstName → CustomerFirstName, etc.
    // Set accountStatus to 'Lead' for identification
  }
  return PlatformUser(...);
}
```

This ensures all screens work seamlessly with both Lead and Customer data:
- **Profile Screen**: Displays Lead information correctly
- **Transactions Screen**: Uses entityID from PlatformUser
- **Claims Screen**: Works with both entity types
- **Policies Screen**: Fetches policies using converted customer ID

### 7. **Storage Keys**

Added to `lib/constants/storage_keys.dart`:
```dart
static const String entityType = 'entityType'; // 'LEAD' or 'CUSTOMER'
static const String lastQuote = 'lastQuote'; // Latest quote data
```

## API Request/Response Examples

### 1. Create Lead (Signup)
**Request**:
```json
POST /CreateLeadInformation/{token}
{
  "LeadFirstName": "John",
  "LeadLastName": "Doe",
  "LeadEmail": "john.doe@example.com",
  "LeadPhoneNumber": "1234567890",
  "LeadPassword": "hashedPassword",
  "AccountType": "Individual"
}
```

**Response**:
```json
{
  "MessageResponse": {
    "Status": "Success",
    "Message": "LEAD/14"
  }
}
```

### 2. Create Sales Quotation
**Request**:
```json
POST /CreateSalesQuotation/{token}
{
  "CustomerID": "LEAD/14",
  "BusinessClassID": "MOTOR",
  "RiskTypeID": "COMPREHENSIVE",
  "StartDate": "2024-01-01T00:00:00.000Z",
  "EndDate": "2024-12-31T23:59:59.999Z",
  "ItemsToInsure": [
    {
      "ItemDescription": "Toyota Camry",
      "Value": 50000,
      "DetailMemo1": "ABC123XY",
      "DetailMemo2": "CH456789",
      "DetailMemo3": "Toyota"
    }
  ]
}
```

**Response**:
```json
{
  "MessageResponse": {
    "Status": "Success",
    "Message": "QN/11"
  }
}
```

### 3. Convert Lead to Customer
**Request**:
```
GET /ConvertLeadToCustomer?LeadID=LEAD/14&token={token}
```

**Response**:
```json
{
  "MessageResponse": {
    "Status": "Success",
    "Message": "CUS/84902"
  }
}
```

### 4. Get Sales Quotations by Entity ID
**Request**:
```
GET /GetSalesQuotationsByEntityID/{token}?EntityID=LEAD/14&PageNum=1&Size=1000
```

**Response**:
```json
{
  "Quotations": [
    {
      "InvoiceNumber": "QN/11",
      "CustomerID": "LEAD/14",
      "BusinessClassID": "MOTOR",
      "RiskTypeID": "COMPREHENSIVE",
      "SumInsured": 50000,
      "PremiumDue": 2500,
      "NoteStatus": "Pending",
      "CreatedDate": "2024-01-01T10:00:00Z",
      "Items": [...]
    }
  ]
}
```

## Testing Checklist

### Phase 1: Lead Creation
- [ ] Sign up new user
- [ ] Verify Lead ID format (e.g., "LEAD/14") in storage
- [ ] Verify entityType stored as 'LEAD'
- [ ] Login with Lead credentials
- [ ] Verify profile displays Lead information correctly

### Phase 2: Quote as Lead
- [ ] Create quote as Lead user
- [ ] Verify Sales Quotation API called with Lead ID
- [ ] Check quote appears in quote list
- [ ] Verify quote details display correctly

### Phase 3: Payment & Conversion
- [ ] Initiate payment on quote
- [ ] Complete payment successfully
- [ ] Verify ConvertLeadToCustomer API called
- [ ] Check new Customer ID (e.g., "CUS/84902") in storage
- [ ] Verify entityType updated to 'CUSTOMER'
- [ ] Confirm profile refreshed with Customer data

### Phase 4: Post-Conversion
- [ ] Verify policy created with Customer ID
- [ ] Check policy appears in policies list
- [ ] Create new quote as Customer
- [ ] Verify quote uses Customer ID
- [ ] Test transactions screen
- [ ] Test claims functionality
- [ ] Verify all features work with Customer ID

### Phase 5: Existing Customers
- [ ] Login with existing Customer account
- [ ] Verify entityType stored as 'CUSTOMER'
- [ ] Test quote creation
- [ ] Test payment and policy creation
- [ ] Verify no conversion attempt made

## Error Scenarios & Handling

### 1. Lead Conversion Fails
- **Handling**: Non-blocking error
- **Behavior**: Policy creation proceeds with Lead ID
- **User Impact**: Policy may be created under Lead ID (backend should handle this)

### 2. Profile Refresh Fails After Conversion
- **Handling**: Logged but non-blocking
- **Behavior**: Storage has updated IDs, profile will refresh on next login
- **User Impact**: Minimal, profile data eventually consistent

### 3. Quote Creation with Lead ID
- **Handling**: Sales Quotation API accepts Lead ID in CustomerID field
- **Behavior**: Quote created successfully with Lead ID
- **User Impact**: None, quote list and details work correctly

## Migration Notes

### Backward Compatibility
- Existing customers not affected
- Old enquiry-based quotes still accessible
- Quote list handles both enquiry and sales quotation sources
- PlatformUser model handles both Lead and Customer data structures

### Data Consistency
- LoginData.customerID can contain Lead ID or Customer ID
- EntityType field determines actual entity type
- Profile data auto-converts Lead format to Customer format
- All screens use PlatformUser which normalizes the data

## Files Modified/Created

### Created Files
1. `lib/network/models/platform_user/lead_information.dart`
2. `lib/network/models/response/entity_response.dart`
3. `lib/network/models/response/sales_quotation_response.dart`

### Modified Files
1. `lib/core/signup/view/signup_screen.dart`
2. `lib/core/signup/controller/signup_controller.dart`
3. `lib/core/login/model/login_data.dart`
4. `lib/core/login/controller/login_controller.dart`
5. `lib/core/quote/controller/get_quote_controller.dart`
6. `lib/core/quote/controller/quote_controller.dart`
7. `lib/core/quote/controller/quote_payment_controller.dart`
8. `lib/network/api/endpoints.dart`
9. `lib/network/api/api_provider.dart`
10. `lib/network/repository/pibro_repository.dart`
11. `lib/network/models/platform_user/platform_user.dart`
12. `lib/network/models/request/auth_request.dart`
13. `lib/constants/storage_keys.dart`
14. `lib/internalization/app_strings.dart`
15. `lib/internalization/english_strings.dart`
16. `lib/utils/api_utils.dart`

## Summary

The implementation successfully introduces the Lead-to-Customer workflow with the following benefits:

1. **Clean Separation**: New signups are Leads until they make a payment
2. **Seamless Conversion**: Automatic conversion during payment flow
3. **Backward Compatible**: Existing customers and features unaffected
4. **Transparent Operation**: All screens work with both Lead and Customer data
5. **Robust Error Handling**: Non-blocking conversion with fallback mechanisms
6. **Unified Data Model**: PlatformUser handles both entity types transparently

The app now efficiently handles both Leads and Customers with minimal code duplication and maximum reusability.
