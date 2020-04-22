// @flow
import { NativeModules, NativeEventEmitter } from "react-native";
const { PushNotificationEx } = NativeModules;

export type AuthorizationOptions = {
  badge: ?boolean,
  sound: ?boolean,
  alert: ?boolean,
  carPlay: ?boolean,
  criticalAlert: ?boolean,
  providesAppNotificationSettings: ?boolean,
  provisional: ?boolean,
  announcement: ?boolean
};

export type AuthorizationStatus =
  | "authorized"
  | "denied"
  | "notDetermined"
  | "provisional"
  | "unknown";

export type NotificationSetting =
  | "enabled"
  | "disabled"
  | "notSupported"
  | "unknown";

export type AlertStyle = "none" | "banner" | "alert" | "unknown";

export type ShowPreviewsSetting =
  | "always"
  | "whenAuthenticated"
  | "never"
  | "unknown";

export type NotificationSettings = {
  authorizationStatus: AuthorizationStatus,

  // Getting Device-Specific Settings
  notificationCenterSetting: NotificationSetting,
  lockScreenSetting: NotificationSetting,
  carPlaySetting: NotificationSetting,
  alertSetting: NotificationSetting,
  badgeSetting: NotificationSetting,
  soundSetting: NotificationSetting,
  criticalAlertSetting: NotificationSetting,

  // Getting Interface Settings
  alertStyle: AlertStyle,
  showPreviewsSetting: ShowPreviewsSetting,
  providesAppNotificationSettings: boolean
};

export type NotificationActionOptions =
  | "foreground"
  | "destructive"
  | "authenticationRequired";

export type NotificationAction = {
  identifier: string,
  title: string,
  options: NotificationActionOptions
};

export type NotificationCategoryOptions = {
  customDismissAction: ?boolean,
  allowInCarPlay: ?boolean,
  hiddenPreviewShowTitle: ?boolean,
  hiddenPreviewShowSubtitle: ?boolean,
  allowAnnouncement: ?boolean
};

export type NotificationCategory = {
  identifier: string,
  actions: NotificationAction[],
  intentIdentifiers: string[],
  hiddenPreviewBodyPlaceholder: ?string,
  categorySummaryFormat: ?string,
  options: NotificationCategoryOptions
};

export type NotificationAttachment = {
  identifier: string,
  URL: string,
  options: {
    typeHintKey: ?string,
    thumbnailClippingRectKey: ?string,
    thumbnailHiddenKey: ?number,
    thumbnailTimeKey: ?number
  }
};

export type NotificationSound = {
  volume: ?number,
  soundName: ?string,
  defaultSound: ?boolean,
  defaultCritical: ?boolean,
  criticalSoundName: ?string
};

export type NotificationContent = {
  title: ?string,
  subtitle: ?string,
  body: ?string,
  badge: ?number,
  sound: ?NotificationSound,
  launchImageName: ?string,
  userInfo: {},
  attachments: ?(NotificationAttachment[]),
  summaryArgument: ?string,
  summaryArgumentCount: ?string,
  categoryIdentifier: ?string,
  threadIdentifier: ?string,
  targetContentIdentifier: ?string
};

type TimeIntervalNotificationTrigger = {
  type: "timeInterval",
  timeInterval: number,
  repeats: boolean
};

type DateComponent = {
  era: ?number,
  year: ?number,
  yearForWeekOfYear: ?number,
  quarter: ?number,
  month: ?number,
  leapMonth: ?boolean,

  weekday: ?number,
  weekdayOrdinal: ?number,
  weekOfMonth: ?number,
  weekOfYear: ?number,
  day: ?number,

  hour: ?number,
  minute: ?number,
  second: ?number,
  nanosecond: ?number
};

type CalendarIntervalNotificationTrigger = {
  type: "calendar",
  dateComponent: DateComponent,
  repeats: boolean
};

type LocationNotificationTrigger = {
  type: "location",
  latitude: number,
  longitude: number,
  radius: number,
  identifier: string,
  notifyOnEntry: boolean,
  notifyOnExit: boolean
};

export type NotificationTrigger =
  | TimeIntervalNotificationTrigger
  | CalendarIntervalNotificationTrigger
  | LocationNotificationTrigger;

export type NotificationRequest = {
  identifier: string,
  content: NotificationContent,
  trigger: ?NotificationTrigger
};

export type NotificationPresentationOptions = {
  badge: ?boolean,
  alert: ?boolean,
  sound: ?boolean
};

export type NotificationResponse = {
  actionIdentifier: string,
  notification: Notification,
};

class UserNotificationCenter {
  emitter = new NativeEventEmitter(PushNotificationEx);

  willPresentNotificationHandler: () => NotificationPresentationOptions = null;
  didReceiveNotificationResponseHandler: (
    response: NotificationResponse,
    completionHandler: function
  ) => void = null;

  constructor() {
    this.emitter.addListener(
      "userNotificationCenterWillPresentNotification",
      request => {
        const presentationOptions = this.willPresentNotificationHandler
          ? this.willPresentNotificationHandler(request.notification)
          : {};

        if (!this.willPresentNotificationHandler) {
          console.warn(
            "NotificationCenter.willPresentNotificationHandler are missing."
          );
        }

        PushNotificationEx.notificationCenterApplyWillPresentNotificationHandler(
          {
            handlerId: request.handlerId,
            presentationOptions
          }
        );
      }
    );

    this.emitter.addListener(
      "userNotificationCenterDidReceiveNotificationResponse",
      response => {
        const applyNotificationResponseHandler = () => {
          PushNotificationEx.notificationCenterApplyDidReceiveNotificationResponseHandler(
            response
          );
        };

        if (this.didReceiveNotificationResponseHandler) {
          this.didReceiveNotificationResponseHandler(
            response.notificationResponse,
            applyNotificationResponseHandler
          );
        } else {
          console.warn(
            "You have to define a NotificationCenter.didReceiveNotificationResponseHandler to be able to handle notification actions."
          );
          applyNotificationResponseHandler();
        }
      }
    );

    PushNotificationEx.notificationCenterApplyPendingNotificationResponses();
  }

  async bundleResourceURL(
    resource: string,
    ext: string,
    subpath: ?string = null
  ): Promise<?string> {
    return PushNotificationEx.bundleResourceURL(resource, ext, subpath);
  }

  get supportsContentExtensions(): boolean {
    return PushNotificationEx.notificationCenterSupportsContentExtensions;
  }

  // Managing Settings and Authorization
  requestAuthorization(options: AuthorizationOptions): Promise<boolean, any> {
    return PushNotificationEx.notificationCenterRequestAuthorization(options);
  }

  getNotificationSettings(): Promise<NotificationSettings, any> {
    return PushNotificationEx.notificationCenterGetNotificationSettings();
  }

  // Registering the Notification Categories
  setNotificationCategories(categories: NotificationCategory[]) {
    return PushNotificationEx.notificationCenterSetNotificationCategories(
      categories
    );
  }

  getNotificationCategories(): Promise<NotificationCategory[]> {
    return PushNotificationEx.notificationCenterGetNotificationCategories();
  }

  // Scheduling and Canceling Notification Requests
  addNotificationRequest(request: NotificationRequest): Promise<boolean> {
    return PushNotificationEx.notificationCenterAddNotificationRequest(request);
  }

  getPendingNotificationRequests(): Promise<NotificationRequest[]> {
    return PushNotificationEx.notificicationCenterGetPendingNotificationRequests();
  }

  removePendingNotificationRequests(identifiers: String[]): Promise<boolean> {
    return PushNotificationEx.notificationCenterRemovePendingNotificationReguests(
      identifiers
    );
  }

  removeAllPendingNotificationRequests(): Promise<boolean> {
    return PushNotificationEx.notificationCenterRemoveAllPendingNotificationRequests();
  }

  // Managing Delivered Notifications
  getDeliveredNotifications(): Promise<Notification[]> {
    return PushNotificationEx.notificationCenterGetDeliveredNotifications();
  }

  removeDeliveredNotifications(identifiers: string[]): Promise<boolean> {
    return PushNotificationEx.notificationCenterRemoveDeliveredNotifications(
      identifiers
    );
  }

  removeAllDeliveredNotifications(): Promise<boolean> {
    return PushNotificationEx.notificationCenterRemoveAllDeliveredNotifications();
  }
}

export default new UserNotificationCenter();
