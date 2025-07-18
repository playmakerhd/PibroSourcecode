import 'package:pibro/network/models/platform_user/platform_user.dart';

import 'base_response.dart';

class ProfileResponse extends CustomBaseResponse {
  ProfileResponse(super.responseData);

  late PlatformUser user;

  @override
  parseResponseData() {
    try {
      user = PlatformUser.fromJson(getResponseBody());
    } catch (e) {
      handleParsingError(e);
    }
  }
}
