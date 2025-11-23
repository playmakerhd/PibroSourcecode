import 'package:pibro/network/models/platform_user/platform_user.dart';
import 'package:pibro/network/models/platform_user/lead_information.dart';

class LeadResponse {
  LeadResponse(this.leadInfo);

  late LeadInformation leadInfo;

  factory LeadResponse.fromJson(dynamic json) {
    return LeadResponse(LeadInformation.fromJson(json));
  }
}

class UnifiedEntityResponse {
  UnifiedEntityResponse({
    this.customer,
    this.lead,
    required this.entityType,
  });

  PlatformUser? customer;
  LeadInformation? lead;
  String entityType; // 'LEAD' or 'CUSTOMER'

  bool get isLead => entityType.toUpperCase() == 'LEAD';
  bool get isCustomer => entityType.toUpperCase() == 'CUSTOMER';

  // Get unified entity ID
  String? get entityID => isLead ? lead?.leadID : customer?.customerID;

  // Get unified name
  String? get entityName {
    if (isLead) {
      final fullName = lead?.leadFullName ?? '';
      if (fullName.isNotEmpty) return fullName;
      return '${lead?.leadFirstName ?? ''} ${lead?.leadLastName ?? ''}'.trim();
    }
    return customer?.customerName ??
        customer?.customerFullName ??
        '${customer?.customerFirstName ?? ''} ${customer?.customerLastName ?? ''}'
            .trim();
  }

  // Get unified email
  String? get entityEmail => isLead ? lead?.leadEmail : customer?.customerEmail;

  // Get unified phone
  String? get entityPhone => isLead ? lead?.leadPhone : customer?.customerPhone;

  // Get unified address
  String? get entityAddress =>
      isLead ? lead?.leadAddress1 : customer?.customerAddress1;

  // Get unified city
  String? get entityCity => isLead ? lead?.leadCity : customer?.customerCity;

  // Get unified state
  String? get entityState => isLead ? lead?.leadState : customer?.customerState;

  // Get unified country
  String? get entityCountry =>
      isLead ? lead?.leadCountry : customer?.customerCountry;

  // Convert to JSON format suitable for storage
  Map<String, dynamic> toStorageJson() {
    if (isLead && lead != null) {
      return {
        ...lead!.toPlatformUserFormat(),
        'EntityType': 'LEAD',
      };
    } else if (isCustomer && customer != null) {
      return {
        'CustomerID': customer!.customerID,
        'CustomerName': entityName,
        'CustomerFirstName': customer!.customerFirstName,
        'CustomerLastName': customer!.customerLastName,
        'CustomerEmail': customer!.customerEmail,
        'CustomerPhone': customer!.customerPhone,
        'CustomerAddress1': customer!.customerAddress1,
        'CustomerCity': customer!.customerCity,
        'CustomerState': customer!.customerState,
        'CustomerCountry': customer!.customerCountry,
        'CustomerDateOfBirth': customer!.customerDateOfBirth,
        'CustomerTypeID': customer!.customerTypeID,
        'EntityType': 'CUSTOMER',
      };
    }
    return {};
  }
}
