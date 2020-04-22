#import <stdlib.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>
#import <React/RCTEventEmitter.h>

#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>

@interface PushNotificationEx : RCTEventEmitter <RCTBridgeModule, UNUserNotificationCenterDelegate>
+ (PushNotificationEx *) sharedNotificationManager;
+ (void) userNotificationCenter:(UNUserNotificationCenter *)center
 didReceiveNotificationResponse:(UNNotificationResponse *)response
          withCompletionHandler:(void (^)(void))completionHandler;

- (void) applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void) applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
@property NSMutableDictionary<NSNumber *, id> *notificationCompletionHandlers;
@end
