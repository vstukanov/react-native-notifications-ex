// @flow
import { NativeModules, NativeEventEmitter } from "react-native";
const { PushNotificationEx } = NativeModules;

class Application {
  emitter = new NativeEventEmitter(PushNotificationEx);

  didRegisterForRemoteNotifications: (string) => void = null;
  didFailToRegisterForRemoteNotifications: (error) => void = null;

  constructor() {
    this.emitter.addListener('applicationDidRegisterForRemoteNotifications', deviceToken => {
      if (this.didRegisterForRemoteNotifications) {
        this.didRegisterForRemoteNotifications(deviceToken);
      } else {
        console.warn('Application.didRegisterForRemoteNotifications handler are missing', deviceToken);
      }
    });

    this.emitter.addListener('applicationDidFailToRegisterForRemoteNotifications', error => {
      if (this.didFailToRegisterForRemoteNotifications) {
        this.didFailToRegisterForRemoteNotifications(error);
      } else {
        console.warn('Application.didFailToRegisterForRemoteNotifications handler are missing', error);
      }
    });
  }

  // Registering for Remote Notifications
  registerForRemoteNotifications(): Promise<boolean> {
    return PushNotificationEx.applicationRegisterForRemoteNotifications();
  }

  unregisterForRemoteNotifications(): Promise<boolean> {
    return PushNotificationEx.applicationUnregisterForRemoteNotifications();
  }

  isRegisteredForRemoteNotifications(): Promise<boolean> {
    return PushNotificationEx.applicationIsRegisteredForRemoteNotifications();
  }

  // Badge Icon Number
  setBadgeIconNumber(number: number): Promise<boolean> {
    return PushNotificationEx.applicationSetIconBadgeNumber(number);
  }

  getBadgeIconNumber(): Promise<number> {
    return PushNotificationEx.applicationGetIconBadgeNumber();
  }
}

export default new Application();
