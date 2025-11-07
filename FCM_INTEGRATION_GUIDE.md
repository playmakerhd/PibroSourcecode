# Firebase Cloud Messaging Integration Guide

## Overview
Firebase Cloud Messaging (FCM) has been successfully integrated into the Pibro mobile app. The implementation follows best practices and integrates seamlessly with your existing architecture.

## Files Modified/Created

### 1. `lib/core/services/firebase_messaging_service.dart` (NEW)
- Singleton service class for handling FCM operations
- Background message handler for when app is not active
- Foreground message handler for when app is active
- Token management and refresh handling
- Topic subscription/unsubscription support

### 2. `lib/main.dart` (MODIFIED)
- Added Firebase initialization
- Registered background message handler
- Initialized Firebase Messaging Service

### 3. `android/app/build.gradle` (MODIFIED)
- Added `firebase-messaging` dependency

## Features Implemented

### ✅ Background Message Handling
Messages are handled even when the app is closed or in the background.

### ✅ Foreground Message Handling
Messages are received when the app is actively being used.

### ✅ Token Management
- Device FCM token is retrieved and logged
- Token refresh is automatically handled
- Token available via `FirebaseMessagingService().fcmToken`

### ✅ Notification Tap Handling
- Handles when user taps a notification while app is in background
- Handles when app is opened from terminated state via notification

### ✅ Topic Subscription
Subscribe/unsubscribe to topics for targeted messaging.

## Usage Examples

### Get FCM Token
```dart
final fcmToken = FirebaseMessagingService().fcmToken;
print('FCM Token: $fcmToken');

// Send this token to your backend server for targeted messaging
```

### Subscribe to a Topic
```dart
await FirebaseMessagingService().subscribeToTopic('news');
await FirebaseMessagingService().subscribeToTopic('promotions');
```

### Unsubscribe from a Topic
```dart
await FirebaseMessagingService().unsubscribeFromTopic('news');
```

### Handle Navigation from Notifications
In `firebase_messaging_service.dart`, update the `_handleMessageOpenedApp` method:

```dart
void _handleMessageOpenedApp(RemoteMessage message) {
  PibroLogger.logger.d('Message opened app: ${message.messageId}');
  PibroLogger.logger.d('Message data: ${message.data}');

  // Navigate based on message data
  if (message.data.containsKey('screen')) {
    switch (message.data['screen']) {
      case 'policy_details':
        Get.toNamed(AppRoutes.policyDetails, arguments: message.data);
        break;
      case 'claims':
        Get.toNamed(AppRoutes.claims);
        break;
      // Add more cases as needed
    }
  }
}
```

### Show Local Notifications for Foreground Messages
In `firebase_messaging_service.dart`, update the `_handleForegroundMessage` method:

```dart
void _handleForegroundMessage(RemoteMessage message) {
  PibroLogger.logger.d('Message received in foreground: ${message.messageId}');
  
  if (message.notification != null) {
    // Option 1: Show a GetX snackbar
    Get.snackbar(
      message.notification!.title ?? 'Notification',
      message.notification!.body ?? '',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
    
    // Option 2: Use flutter_local_notifications package for richer notifications
    // See: https://pub.dev/packages/flutter_local_notifications
  }
}
```

## Testing

### Test FCM Integration

1. **Check Token Generation**
   - Run the app and check the console/logs for the FCM token
   - Look for log: `FCM Token: <your-token>`

2. **Test via Firebase Console**
   - Go to Firebase Console > Cloud Messaging
   - Click "Send your first message"
   - Enter notification title and text
   - Select your app
   - Send test message to the FCM token

3. **Test Background Messages**
   - Send a notification while app is in background
   - Tap the notification to verify it opens the app

4. **Test Foreground Messages**
   - Send a notification while app is open
   - Verify the log messages appear

## Next Steps (TODO)

1. **Send Token to Backend**
   - Modify `_initFCM()` to send the FCM token to your backend API
   - Store the token associated with the user account

2. **Implement Local Notifications**
   - Add `flutter_local_notifications` package if you want to show notifications when app is in foreground
   - Configure notification channels for Android

3. **Handle Data-Only Messages**
   - Currently handles notification messages
   - Add logic for data-only messages if needed

4. **Deep Linking**
   - Implement deep linking for better navigation from notifications
   - Map notification data to specific app screens

5. **Analytics**
   - Track notification open rates
   - Log user engagement with notifications

## Message Format

### Notification Message (from Firebase Console)
```json
{
  "notification": {
    "title": "Policy Renewal",
    "body": "Your policy is due for renewal"
  },
  "data": {
    "screen": "policy_details",
    "policyId": "12345"
  }
}
```

### Data-Only Message (for background processing)
```json
{
  "data": {
    "type": "policy_update",
    "policyId": "12345",
    "status": "renewed"
  }
}
```

## Important Notes

⚠️ **iOS Configuration Required**
- This implementation is Android-ready
- For iOS, you need to:
  - Configure APNs (Apple Push Notification service)
  - Add push notification capability in Xcode
  - Request permission in iOS-specific code

⚠️ **google-services.json**
- Ensure `android/app/google-services.json` is properly configured
- Download from Firebase Console if not already present

⚠️ **Background Message Handler**
- Must be a top-level function (not inside a class)
- Annotated with `@pragma('vm:entry-point')`
- Registered before app initialization

## Troubleshooting

### Token not generated?
- Check if Firebase is properly initialized
- Verify `google-services.json` is present
- Check app permissions

### Notifications not received?
- Verify the FCM token is correct
- Check Firebase Console for delivery status
- Ensure device has internet connection
- Check if app is properly registered with Firebase

### Background handler not working?
- Ensure handler is registered before `runApp()`
- Check if handler is a top-level function
- Review logs for any errors

## Documentation
- [Firebase Messaging Flutter Plugin](https://pub.dev/packages/firebase_messaging)
- [Firebase Console](https://console.firebase.google.com/)
- [FCM Architecture](https://firebase.google.com/docs/cloud-messaging)
