import 'package:pibro/network/models/response/base_response.dart';
import 'package:pibro/network/models/response/quotes_response.dart'
    show QuoteInfo;

/// Wraps the single-enquiry payload returned by:
///   GET /GetCustomerEnquiriesByID/{caseId}/{token}
///
/// We only really need SupportScreenShotURL (sum insured) and
/// SupportResolution (premium), but QuoteInfo maps the whole object.
class QuoteByIdResponse extends CustomBaseResponse {
  QuoteByIdResponse(super.responseData);

  QuoteInfo? quote;

  @override
  void parseResponseData() {
    try {
      final body = getResponseBody();
      if (body == null) {
        quote = null;
        return;
      }
      // API returns a single object for this endpoint
      quote = QuoteInfo.fromJson(body);
    } catch (e) {
      handleParsingError(e);
      quote = null;
    }
  }
}
