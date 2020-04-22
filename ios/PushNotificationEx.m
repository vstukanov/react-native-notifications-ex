#import "PushNotificationEx.h"

#pragma mark - Constans -

#pragma mark Errors
static NSString* const kErrorsAuthorizationRequestDenied = @"authorization_request_denied";
static NSString* const kErrorsAuthorizationRequestDeniedMessage = @"Authorization request denied by user";
static NSString* const kErrorsNotificationAttachmentFailed = @"notification_attachment";
static NSString* const kErrorsNotificationAttachmentFailedMessage = @"Cannot create attachment";
static NSString* const kErrorsNotificationRequestFailed = @"notification_request";
static NSString* const kErrorsNotificationRequestFailedMessage = @"Notification request failed";

#pragma mark AuthorizationStatus
static NSString* const kAuthorizationStatusAuthorized = @"authorized";
static NSString* const kAuthorizationStatusDenied = @"denied";
static NSString* const kAuthorizationStatusProvisional = @"provisional";
static NSString* const kAuthorizationStatusNotDetermined = @"notDetermined";
static NSString* const kAuthorizationStatusUnknown = @"unknown";

#pragma mark NotificationSetting
static NSString* const kNotificationSettingNotSupported = @"notSupported";
static NSString* const kNotificationSettingDisabled = @"disabled";
static NSString* const kNotificationSettingEnabled = @"enabled";

#pragma mark AlertStyle
static NSString* const kAlertStyleNone = @"none";
static NSString* const kAlertStyleBanner = @"banner";
static NSString* const kAlertStyleAlert = @"alert";

#pragma mark ShowPreviewsSetting
static NSString* const kShowPreviewsSettingAlways = @"always";
static NSString* const kShowPreviewsSettingWhenAuthorized = @"whenAuthorized";
static NSString* const kShowPreviewsSettingNever = @"never";


#pragma mark - Converters -
@implementation RCTConvert(UNAuthorizationOptions)
+ (UNAuthorizationOptions)UNAuthorizationOptions:(id)json
{
    UNAuthorizationOptions options = UNAuthorizationOptionNone;
    NSDictionary<NSString *, id> *optionsPayload = [self NSDictionary:json];
    
    if ([RCTConvert BOOL:optionsPayload[@"badge"]]) {
        options |= UNAuthorizationOptionBadge;
    }
    
    if ([RCTConvert BOOL:optionsPayload[@"sound"]]) {
        options |= UNAuthorizationOptionSound;
    }
    
    if ([RCTConvert BOOL:optionsPayload[@"alert"]]) {
        options |= UNAuthorizationOptionAlert;
    }
    
    if ([RCTConvert BOOL:optionsPayload[@"carPlay"]]) {
        options |= UNAuthorizationOptionCarPlay;
    }
    
    if ([RCTConvert BOOL:optionsPayload[@"carPlay"]]) {
        options |= UNAuthorizationOptionCarPlay;
    }
    
    if (@available(iOS 12, *)) {
        if ([RCTConvert BOOL:optionsPayload[@"criticalAlert"]]) {
            options |= UNAuthorizationOptionCriticalAlert;
        }
        
        if ([RCTConvert BOOL:optionsPayload[@"providesAppNotificationSettings"]]) {
            options |= UNAuthorizationOptionProvidesAppNotificationSettings;
        }
        
        if ([RCTConvert BOOL:optionsPayload[@"provisional"]]) {
            options |= UNAuthorizationOptionProvisional;
        }
    }
    
    if (@available(iOS 13, *)) {
        if ([RCTConvert BOOL:optionsPayload[@"announcement"]]) {
            options |= UNAuthorizationOptionAnnouncement;
        }
    }
    
    return options;
}
@end

@implementation RCTConvert(UNNotificationActionOptions)

+ (UNNotificationActionOptions)UNNotificationActionOptions:(id)json {
    NSDictionary<NSString*,id> *optionsPayload = [self NSDictionary:json];
    UNNotificationActionOptions options = UNNotificationActionOptionNone;
    
    if ([RCTConvert BOOL:optionsPayload[@"authenticationRequired"]]) {
        options |= UNNotificationActionOptionAuthenticationRequired;
    }
    
    if ([RCTConvert BOOL:optionsPayload[@"destructive"]]) {
        options |= UNNotificationActionOptionDestructive;
    }
    
    if ([RCTConvert BOOL:optionsPayload[@"foreground"]]) {
        options |= UNNotificationActionOptionForeground;
    }
    
    return options;
}

@end

@implementation RCTConvert(UNNotificationAction)

+ (UNNotificationAction*)UNNotificationAction:(id)json {
    NSDictionary<NSString*,id> *action = [self NSDictionary:json];
    NSString *identifier = [RCTConvert NSString:action[@"identifier"]];
    NSString *title = [RCTConvert NSString:action[@"title"]];
    UNNotificationActionOptions options = [RCTConvert UNNotificationActionOptions:action[@"options"]];

    if ([[RCTConvert NSString:json[@"type"]] isEqualToString:@"text"]) {
        return [UNTextInputNotificationAction
                actionWithIdentifier:identifier
                               title:title
                             options:options
                textInputButtonTitle:[RCTConvert NSString:action[@"textInputButtonTitle"]]
                textInputPlaceholder:[RCTConvert NSString:action[@"textInputPlaceholder"]]];
    }
    return [UNNotificationAction
            actionWithIdentifier:identifier
            title:title
            options:options];
}

@end

@implementation RCTConvert(UNNotificationCategoryOptions)

+(UNNotificationCategoryOptions)UNNotificationCategoryOptions:(id)json
{
    NSDictionary<NSString*,id> *optionsPayload = [self NSDictionary:json];
    UNNotificationCategoryOptions options = UNNotificationCategoryOptionNone;
    
    if ([RCTConvert BOOL:optionsPayload[@"customDismissAction"]]) {
        options |= UNNotificationCategoryOptionCustomDismissAction;
    }
    
    if ([RCTConvert BOOL:optionsPayload[@"AllowInCarPlay"]]) {
        options |= UNNotificationCategoryOptionAllowInCarPlay;
    }
    
    if (@available(iOS 11, *)) {
        if ([RCTConvert BOOL:optionsPayload[@"hiddenPreviewsShowTitle"]]) {
            options |= UNNotificationCategoryOptionHiddenPreviewsShowTitle;
        }
        
        if ([RCTConvert BOOL:optionsPayload[@"hiddenPreviewsShowSubtitle"]]) {
            options |= UNNotificationCategoryOptionHiddenPreviewsShowSubtitle;
        }
    }
    
    if (@available(iOS 13, *)) {
        if ([RCTConvert BOOL:optionsPayload[@"allowAnnouncement"]]) {
            options |= UNNotificationCategoryOptionAllowAnnouncement;
        }
    }
    
    return options;
}

@end

@implementation RCTConvert(UNNotificationCategory)

+ (UNNotificationCategory*)UNNotificationCategory:(id)json {
    NSDictionary<NSString*,id> *categoryPayload = [self NSDictionary:json];
    
    NSString* identifier = [RCTConvert NSString:categoryPayload[@"identifier"]];
    
    NSArray<NSDictionary*> *actionsPayload = [self NSDictionaryArray:categoryPayload[@"actions"]];
    NSMutableArray<UNNotificationAction*> *actions = [NSMutableArray arrayWithCapacity:actionsPayload.count];
    
    for (NSDictionary* actionPayload in actionsPayload) {
        [actions addObject:[RCTConvert UNNotificationAction:actionPayload]];
    }
    
    NSArray<NSString*> *intentIdentifiers = [self NSStringArray:categoryPayload[@"intentIdentifiers"]];
    UNNotificationCategoryOptions options = [self UNNotificationCategoryOptions:categoryPayload[@"options"]];
    
    if (@available(iOS 12, *)) {
        return [UNNotificationCategory
                categoryWithIdentifier:identifier
                actions:actions
                intentIdentifiers:intentIdentifiers
                hiddenPreviewsBodyPlaceholder:[RCTConvert NSString:categoryPayload[@"hiddenPreviewsBodyPlaceholder"]]
                categorySummaryFormat:[RCTConvert NSString:categoryPayload[@"categorySummaryFormat"]]
                options:options];
    }
    
    if (@available(iOS 11, *)) {
        return [UNNotificationCategory
                categoryWithIdentifier:identifier
                actions:actions
                intentIdentifiers:intentIdentifiers
                hiddenPreviewsBodyPlaceholder:[RCTConvert NSString:categoryPayload[@"hiddenPreviewsBodyPlaceholder"]]
                options:options];
    }
    
    return [UNNotificationCategory
            categoryWithIdentifier:identifier
            actions:actions
            intentIdentifiers:intentIdentifiers
            options:options];
}

@end

@implementation RCTConvert(UNNotificationSound)
+ (UNNotificationSound *) UNNotificationSound:(id)json {
    NSDictionary *soundPayload = [self NSDictionary:json];
    bool hasVolume = soundPayload[@"volume"] != nil;
    float volume = (float) [RCTConvert CGFloat:soundPayload[@"volume"]];
    NSString *soundName = [RCTConvert NSString:soundPayload[@"soundName"]];
    
    if (@available(iOS 12, *)) {
        if ([RCTConvert BOOL:soundPayload[@"defaultCritical"]]) {
            if (hasVolume) {
                return [UNNotificationSound defaultCriticalSoundWithAudioVolume:volume];
            }

            return [UNNotificationSound defaultCriticalSound];
        }

        NSString *criticalSoundName = [RCTConvert NSString:soundPayload[@"criticalSoundName"]];

        if (criticalSoundName) {
            if (volume) {
                return [UNNotificationSound criticalSoundNamed:criticalSoundName withAudioVolume:volume];
            }

            return [UNNotificationSound criticalSoundNamed:criticalSoundName];
        }
    }

    if (soundName) {
        return [UNNotificationSound soundNamed:soundName];
    }

    if ([RCTConvert BOOL:soundPayload[@"defaultSound"]]) {
        return [UNNotificationSound defaultSound];
    }

    return NULL;
}
@end

@implementation RCTConvert(UNNotificationAttachment)
+ (UNNotificationAttachment *) UNNotificationAttachment:(id)json {
    NSDictionary *attachmentPayload = [self NSDictionary:json];
    NSDictionary *optionsPayload = [self NSDictionary:attachmentPayload[@"options"]];

    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if (optionsPayload[@"typeHintKey"]) {
        options[UNNotificationAttachmentOptionsTypeHintKey] = [RCTConvert NSString:optionsPayload[@"typeHintKey"]];
    }

    if (optionsPayload[@"thumbnailClippingRectKey"]) {
        CGRect rect = [RCTConvert CGRect:optionsPayload[@"thumbnailClippingRectKey"]];
        options[UNNotificationAttachmentOptionsThumbnailClippingRectKey] = (__bridge id) CGRectCreateDictionaryRepresentation(rect);
    }

    if (optionsPayload[@"thumbnailHiddenKey"]) {
        options[UNNotificationAttachmentOptionsThumbnailHiddenKey] = [RCTConvert NSNumber:optionsPayload[@"thumbnailHiddenKey"]];
    }

    if (optionsPayload[@"thumbnailTimeKey"]) {
        options[UNNotificationAttachmentOptionsThumbnailTimeKey] = [RCTConvert NSNumber:optionsPayload[@"thumbnailTimeKey"]];
    }

    NSError *notificationError;

    UNNotificationAttachment *notificationAttachment = [UNNotificationAttachment
            attachmentWithIdentifier:[RCTConvert NSString:attachmentPayload[@"identifier"]]
                                 URL:[RCTConvert NSURL:attachmentPayload[@"URL"]]
                             options:options
                               error:&notificationError];

    if (notificationError) {
        RCTLogError(@"[%@] %@ %@",
                kErrorsNotificationAttachmentFailed,
                kErrorsNotificationAttachmentFailedMessage,
                notificationError);

        return NULL;
    }

    return notificationAttachment;
}
@end

@implementation RCTConvert(UNNotificationContent)
+ (UNNotificationContent *) UNNotificationContent:(id)json {
    NSDictionary *contentPayload = [self NSDictionary:json];
    UNMutableNotificationContent *notificationContent = [[UNMutableNotificationContent alloc] init];

    if (contentPayload[@"title"]) {
        notificationContent.title = [RCTConvert NSString:contentPayload[@"title"]];
    }

    if (contentPayload[@"subtitle"]) {
        notificationContent.subtitle = [RCTConvert NSString:contentPayload[@"subtitle"]];
    }

    if (contentPayload[@"body"]) {
        notificationContent.body = [RCTConvert NSString:contentPayload[@"body"]];
    }

    if (contentPayload[@"badge"] != nil) {
        notificationContent.badge = [RCTConvert NSNumber:contentPayload[@"badge"]];
    }

    if (contentPayload[@"sound"]) {
        notificationContent.sound = [RCTConvert UNNotificationSound:contentPayload[@"sound"]];
    }

    if (contentPayload[@"launchImageName"]) {
        notificationContent.launchImageName = [RCTConvert NSString:contentPayload[@"launchImageName"]];
    }

    if (contentPayload[@"userInfo"]) {
        notificationContent.userInfo = [RCTConvert NSDictionary:contentPayload[@"userInfo"]];
    }

    NSArray<NSDictionary *> *attachmentsPayload = [RCTConvert NSDictionaryArray:contentPayload[@"attachments"]];
    NSMutableArray<UNNotificationAttachment*> *attachments = [NSMutableArray arrayWithCapacity:attachmentsPayload.count];
    for(NSDictionary *attachmentPayload in attachmentsPayload) {
        UNNotificationAttachment *attachment = [RCTConvert UNNotificationAttachment:attachmentPayload];
        if (attachment) {
            [attachments addObject:attachment];
        }
    }

    notificationContent.attachments = attachments;
    
    if (@available(iOS 12, *)) {
        if (contentPayload[@"summaryArgument"]) {
            notificationContent.summaryArgument = [RCTConvert NSString:contentPayload[@"summaryArgument"]];
        }

        if (contentPayload[@"summaryArgumentCount"]) {
            notificationContent.summaryArgumentCount = [RCTConvert uint64_t:contentPayload[@"summaryArgumentCount"]];
        }
    }

    if (contentPayload[@"categoryIdentifier"]) {
        notificationContent.categoryIdentifier = [RCTConvert NSString:contentPayload[@"categoryIdentifier"]];
    }

    if (contentPayload[@"threadIdentifier"]) {
        notificationContent.threadIdentifier = [RCTConvert NSString:contentPayload[@"threadIdentifier"]];
    }

    if (@available(iOS 13, *)) {
        if (contentPayload[@"targetContentIdentifier"]) {
            notificationContent.targetContentIdentifier = [RCTConvert NSString:contentPayload[@"targetContentIdentifier"]];
        }
    }

    return notificationContent;
}
@end

@implementation RCTConvert(NSDateComponents)
+ (NSDateComponents *)NSDateComponents: (id)json {
    NSDictionary *payload = [self NSDictionary:json];
    NSDateComponents *components = [[NSDateComponents alloc] init];

    if (payload[@"era"]) {
        [components setEra:[RCTConvert NSNumber:payload[@"era"]].intValue];
    }

    if (payload[@"year"]) {
        [components setYear:[RCTConvert NSNumber:payload[@"year"]].intValue];
    }

    if (payload[@"yearForWeekOfYear"]) {
        [components setYearForWeekOfYear:[RCTConvert NSNumber:payload[@"yearForWeekOfYear"]].intValue];
    }

    if (payload[@"quarter"]) {
        [components setQuarter:[RCTConvert NSNumber:payload[@"quarter"]].intValue];
    }

    if (payload[@"month"]) {
        [components setMonth:[RCTConvert NSNumber:payload[@"month"]].intValue];
    }

    if (payload[@"leapMonth"]) {
        [components setLeapMonth:[RCTConvert BOOL:payload[@"leapMonth"]]];
    }

    // Weeks and Days
    if (payload[@"weekday"]) {
        [components setWeekday:[RCTConvert NSNumber:payload[@"weekday"]].intValue];
    }

    if (payload[@"weekdayOrdinal"]) {
        [components setWeekdayOrdinal:[RCTConvert NSNumber:payload[@"weekdayOrdinal"]].intValue];
    }

    if (payload[@"weekOfMonth"]) {
        [components setWeekOfMonth:[RCTConvert NSNumber:payload[@"weekOfMonth"]].intValue];
    }

    if (payload[@"weekOfYear"]) {
        [components setWeekOfYear:[RCTConvert NSNumber:payload[@"weekOfYear"]].intValue];
    }

    if (payload[@"day"]) {
        [components setDay:[RCTConvert NSNumber:payload[@"day"]].intValue];
    }

    // Hours and Second
    if (payload[@"hour"]) {
        [components setHour:[RCTConvert NSNumber:payload[@"hour"]].intValue];
    }

    if (payload[@"minute"]) {
        [components setMinute:[RCTConvert NSNumber:payload[@"minute"]].intValue];
    }

    if (payload[@"second"]) {
        [components setSecond:[RCTConvert NSNumber:payload[@"second"]].intValue];
    }

    if (payload[@"nanosecond"]) {
        [components setNanosecond:[RCTConvert NSNumber:payload[@"nanosecond"]].intValue];
    }

    return components;
}
@end

@implementation RCTConvert(UNNotificationTrigger)
+ (UNNotificationTrigger *) UNNotificationTrigger:(id)json {
    NSDictionary *triggerPayload = [self NSDictionary:json];
    NSString *type = triggerPayload[@"type"];
    BOOL repeats = [RCTConvert BOOL:triggerPayload[@"repeats"]];

    if ([type isEqualToString:@"timeInterval"]) {
        NSNumber *timeInterval = [RCTConvert NSNumber:triggerPayload[@"timeInterval"]];
        return [UNTimeIntervalNotificationTrigger
                triggerWithTimeInterval:timeInterval.doubleValue
                                repeats:repeats];
    }

    if ([type isEqualToString:@"calendar"]) {
        return [UNCalendarNotificationTrigger
                triggerWithDateMatchingComponents:[RCTConvert NSDateComponents:triggerPayload[@"dateComponent"]]
                                          repeats:repeats];
    }

    if ([type isEqualToString:@"location"]) {
        // TODO: provide better location triggers
        double latitude = [RCTConvert NSNumber:triggerPayload[@"latitude"]].doubleValue;
        double longitude = [RCTConvert NSNumber:triggerPayload[@"longitude"]].doubleValue;
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);

        CLCircularRegion *region = [[CLCircularRegion alloc]
                initWithCenter:center
                        radius:[RCTConvert NSNumber:triggerPayload[@"radius"]].doubleValue
                    identifier:[RCTConvert NSString:triggerPayload[@"identifier"]]];

        region.notifyOnEntry = [RCTConvert BOOL:triggerPayload[@"notifyOnEntry"]];
        region.notifyOnExit = [RCTConvert BOOL:triggerPayload[@"notifyOnExit"]];

        return [UNLocationNotificationTrigger
                triggerWithRegion:region
                          repeats:repeats];
    }

    RCTLogWarn(@"Unknown notification trigger: %@", triggerPayload);
    return NULL;
}
@end

@implementation RCTConvert(UNNotificationRequest)
+ (UNNotificationRequest *) UNNotificationRequest:(id)json {
    NSDictionary *request = [self NSDictionary:json];
    NSString *identifier = [RCTConvert NSString:request[@"identifier"]];
    UNNotificationContent *content = [RCTConvert UNNotificationContent:request[@"content"]];
    UNNotificationTrigger *trigger = NULL;

    if (request[@"trigger"]) {
        trigger = [RCTConvert UNNotificationTrigger:request[@"trigger"]];
    }

    return [UNNotificationRequest requestWithIdentifier:identifier
                                                content:content
                                                trigger:trigger];
}
@end

@implementation RCTConvert(UNNotificationPresentationOptions)
+ (UNNotificationPresentationOptions)UNNotificationPresentationOptions:(id)json
{
    NSDictionary<NSString *, id> *jsonOptions = [RCTConvert NSDictionary:json];
    UNNotificationPresentationOptions options = UNNotificationPresentationOptionNone;

    if ([RCTConvert BOOL:jsonOptions[@"badge"]]) {
        options |= UNNotificationPresentationOptionBadge;
    }

    if ([RCTConvert BOOL:jsonOptions[@"alert"]]) {
        options |= UNNotificationPresentationOptionAlert;
    }

    if ([RCTConvert BOOL:jsonOptions[@"sound"]]) {
        options |= UNNotificationPresentationOptionSound;
    }

    return options;
}
@end

#pragma mark - Formatters -

static NSString* RCTFormatAuthorizationStatus(UNAuthorizationStatus status) {
    switch (status) {
        case UNAuthorizationStatusAuthorized:
            return kAuthorizationStatusAuthorized;
            
        case UNAuthorizationStatusDenied:
            return kAuthorizationStatusDenied;
            
        case UNAuthorizationStatusProvisional:
            return kAuthorizationStatusProvisional;
            
        case UNAuthorizationStatusNotDetermined:
            return kAuthorizationStatusNotDetermined;
            
        default:
            return kAuthorizationStatusUnknown;
    }
}

static NSString* RCTFormatNotificationSetting(UNNotificationSetting setting) {
    switch (setting) {
        case UNNotificationSettingEnabled:
            return kNotificationSettingEnabled;
        
        case UNNotificationSettingDisabled:
            return kNotificationSettingDisabled;
        
        case UNNotificationSettingNotSupported:
            return kNotificationSettingNotSupported;
            
        default:
            return kNotificationSettingNotSupported;
    }
}

static NSString* RCTFormatAlertStyle(UNAlertStyle alertStyle) {
    switch (alertStyle) {
        case UNAlertStyleNone:
            return kAlertStyleNone;
            
        case UNAlertStyleAlert:
            return kAlertStyleAlert;
            
        case UNAlertStyleBanner:
            return kAlertStyleBanner;
            
        default:
            return kAlertStyleNone;
    }
}

API_AVAILABLE(ios(11.0))
static NSString* RCTFormatShowPreviewsSetting(UNShowPreviewsSetting previewSetting) {
    switch (previewSetting) {
        case UNShowPreviewsSettingNever:
            return kShowPreviewsSettingNever;
            
        case UNShowPreviewsSettingAlways:
            return kShowPreviewsSettingAlways;
            
        case UNShowPreviewsSettingWhenAuthenticated:
            return kShowPreviewsSettingWhenAuthorized;
            
        default:
            return kShowPreviewsSettingNever;
    }
}

static NSDictionary* RCTFormatNotificationSettings(UNNotificationSettings* settings) {
    NSMutableDictionary *formattedSettings = [NSMutableDictionary dictionary];
    
    formattedSettings[@"authorizationStatus"] = RCTFormatAuthorizationStatus(settings.authorizationStatus);

    // Device specific settings
    
    formattedSettings[@"notificationCenterSetting"] = RCTFormatNotificationSetting(settings.notificationCenterSetting);
    formattedSettings[@"lockScreenSetting"] = RCTFormatNotificationSetting(settings.lockScreenSetting);
    formattedSettings[@"carPlaySetting"] = RCTFormatNotificationSetting(settings.carPlaySetting);
    
    formattedSettings[@"alertSetting"] = RCTFormatNotificationSetting(settings.alertSetting);
    formattedSettings[@"badgeSetting"] = RCTFormatNotificationSetting(settings.badgeSetting);
    formattedSettings[@"soundSetting"] = RCTFormatNotificationSetting(settings.soundSetting);
    
    if (@available(iOS 12, *)) {
        formattedSettings[@"criticalAlertSetting"] = RCTFormatNotificationSetting(settings.criticalAlertSetting);
    }
    
    // Interface settings
    
    formattedSettings[@"alertStyle"] = RCTFormatAlertStyle(settings.alertStyle);
    
    if (@available(iOS 11, *)) {
        formattedSettings[@"showPreviewsSetting"] = RCTFormatShowPreviewsSetting(settings.showPreviewsSetting);
    }
    
    if (@available(iOS 12, *)) {
        formattedSettings[@"providesAppNotificationSettings"] = @(settings.providesAppNotificationSettings);
    }
    
    return formattedSettings;
}

static NSDictionary* RCTFormatNotificationActionOption(UNNotificationActionOptions options) {
    NSMutableDictionary<NSString*,NSNumber*> *formattedOptions = [NSMutableDictionary dictionary];
    
    if (options & UNNotificationActionOptionForeground) {
        formattedOptions[@"foreground"] = @true;
    }
    
    if (options & UNNotificationActionOptionDestructive) {
        formattedOptions[@"destructive"] = @true;
    }
    
    if (options & UNNotificationActionOptionAuthenticationRequired) {
        formattedOptions[@"authenticationRequired"] = @true;
    }
    
    return formattedOptions;
}

static NSDictionary* RCTFormatNotificationAction(UNNotificationAction *action) {
    NSMutableDictionary<NSString*, id> *formattedAction = [NSMutableDictionary dictionary];
    
    formattedAction[@"identifier"] = action.identifier;
    formattedAction[@"title"] = action.title;
    formattedAction[@"options"] = RCTFormatNotificationActionOption(action.options);
    
    return formattedAction;
}

static NSDictionary* RCTFormatNotificationCategoryOptions(UNNotificationCategoryOptions options) {
    NSMutableDictionary<NSString*, NSNumber*> *formattedOptions = [NSMutableDictionary dictionary];
    
    if (options & UNNotificationCategoryOptionCustomDismissAction) {
        formattedOptions[@"customDismissAction"] = @true;
    }
    
    if (options & UNNotificationCategoryOptionAllowInCarPlay) {
        formattedOptions[@"allowInCarPlay"] = @true;
    }
    
    if (@available(iOS 13, *)) {
        if (options & UNNotificationCategoryOptionAllowAnnouncement) {
            formattedOptions[@"allowAnnouncement"] = @true;
        }
    }
    
    if (@available(iOS 11, *)) {
        if (options & UNNotificationCategoryOptionHiddenPreviewsShowTitle) {
            formattedOptions[@"hiddenPreviewsShowTitle"] = @true;
        }
        
        if (options & UNNotificationCategoryOptionHiddenPreviewsShowSubtitle) {
            formattedOptions[@"hiddenPreviewsShowSubtitle"] = @true;
        }
    }
    
    return formattedOptions;
}

static NSDictionary* RCTFormatNotificationCategory(UNNotificationCategory* category) {
    NSMutableDictionary *formattedCategory = [NSMutableDictionary dictionary];
    
    formattedCategory[@"identifier"] = category.identifier;
    NSMutableArray<NSDictionary*> *actions = [NSMutableArray arrayWithCapacity:category.actions.count];
    
    for (UNNotificationAction *action in category.actions) {
        [actions addObject:RCTFormatNotificationAction(action)];
    }
    formattedCategory[@"actions"] = actions;
    formattedCategory[@"intentIdentifiers"] = category.intentIdentifiers;
    
    if (@available(iOS 11, *)) {
        formattedCategory[@"hiddenPreviewsBodyPlaceholder"] = category.hiddenPreviewsBodyPlaceholder;
    }
    
    if (@available(iOS 12, *)) {
        formattedCategory[@"categorySummaryFormat"] = category.categorySummaryFormat;
    }
    
    formattedCategory[@"options"] = RCTFormatNotificationCategoryOptions(category.options);
    
    return formattedCategory;
}

static NSDictionary* RCTFormatNotificationAttachment(UNNotificationAttachment *attachment) {
    NSMutableDictionary *formattedAttachment = [NSMutableDictionary dictionary];
    formattedAttachment[@"identifier"] = attachment.identifier;
    formattedAttachment[@"url"] = [attachment.URL absoluteString];
    formattedAttachment[@"type"] = attachment.type;
    return formattedAttachment;
}

static NSDictionary* RCTFormatNotificationContent(UNNotificationContent *content) {
    NSMutableDictionary *formattedContent = [NSMutableDictionary dictionary];

    formattedContent[@"title"] = content.title;
    formattedContent[@"subtitle"] = content.subtitle;
    formattedContent[@"body"] = content.body;

    formattedContent[@"badge"] = [NSNull null];
    if (content.badge != nil) {
        formattedContent[@"badge"] = content.badge;
    }

    formattedContent[@"sound"] = [NSNull null];
    if (content.sound != nil) {
        // TODO: can we do something better here?
        formattedContent[@"sound"] = @true;
    }

    formattedContent[@"launchImageName"] = content.launchImageName;

    formattedContent[@"userInfo"] = [NSNull null];
    if (content.userInfo != nil) {
        formattedContent[@"userInfo"] = content.userInfo;
    }

    formattedContent[@"attachments"] = [NSNull null];
    if (content.attachments.count) {
        NSMutableArray<NSDictionary *> *attachments = [NSMutableArray arrayWithCapacity:content.attachments.count];
        for (UNNotificationAttachment *attachment in content.attachments) {
            [attachments addObject:RCTFormatNotificationAttachment(attachment)];
        }
        formattedContent[@"attachments"] = attachments;
    }

    if (@available(iOS 12, *)) {
        formattedContent[@"summaryArgument"] = content.summaryArgument;
        formattedContent[@"summaryArgumentCount"] = @(content.summaryArgumentCount);
    }

    formattedContent[@"categoryIdentifier"] = content.categoryIdentifier;
    formattedContent[@"threadIdentifier"] = content.threadIdentifier;

    if (@available(iOS 13, *)) {
        formattedContent[@"targetContentIdentifier"] = content.targetContentIdentifier;
    }

    return formattedContent;
}

static NSString *RCTFormatDate(NSDate *date) {
    return [[[NSISO8601DateFormatter alloc] init] stringFromDate:date];
}

static NSDictionary* RCTFormatTimeIntervalNotificationTrigger(UNTimeIntervalNotificationTrigger *trigger) {
    NSMutableDictionary *formattedTrigger = [NSMutableDictionary dictionary];
    formattedTrigger[@"type"] = @"timeInterval";
    formattedTrigger[@"timeInterval"] = @(trigger.timeInterval);
    formattedTrigger[@"nextTriggerDate"] = [NSNull null];
    formattedTrigger[@"repeats"] = @(trigger.repeats);

    NSDate *nextTriggerDate = [trigger nextTriggerDate];
    if (nextTriggerDate) {
        formattedTrigger[@"nextTriggerDate"] = RCTFormatDate(nextTriggerDate);
    }
    return formattedTrigger;
}

static NSDictionary* RCTFormatCalendarNotificationTrigger(UNCalendarNotificationTrigger *trigger) {
    NSMutableDictionary *formattedTrigger = [NSMutableDictionary dictionary];
    formattedTrigger[@"type"] = @"calendar";
    formattedTrigger[@"nextTriggerDate"] = [NSNull null];
    // todo: provide full formatter?
    formattedTrigger[@"dateComponents"] = [trigger.dateComponents description];
    formattedTrigger[@"repeats"] = @(trigger.repeats);

    NSDate *nextTriggerDate = [trigger nextTriggerDate];
    if (nextTriggerDate) {
        formattedTrigger[@"nextTriggerDate"] = RCTFormatDate(nextTriggerDate);
    }
    return formattedTrigger;
}

static NSDictionary* RCTFormatLocationNotificationTrigger(UNLocationNotificationTrigger *trigger) {
    NSMutableDictionary *formattedTrigger = [NSMutableDictionary dictionary];
    formattedTrigger[@"type"] = @"location";
    formattedTrigger[@"repeats"] = @(trigger.repeats);

    CLCircularRegion *region = (CLCircularRegion *) trigger.region;

    formattedTrigger[@"latitude"] = @(region.center.latitude);
    formattedTrigger[@"longitude"] = @(region.center.longitude);

    formattedTrigger[@"radius"] = @(region.radius);
    formattedTrigger[@"identifier"] = region.identifier;
    formattedTrigger[@"notifyOnExit"] = @(region.notifyOnExit);
    formattedTrigger[@"notifyOnEntry"] = @(region.notifyOnEntry);

    return formattedTrigger;
}

static NSDictionary* RCTFormatNotificationTrigger(UNNotificationTrigger *trigger) {
    if ([trigger isKindOfClass:[UNTimeIntervalNotificationTrigger class]]) {
        return RCTFormatTimeIntervalNotificationTrigger((UNTimeIntervalNotificationTrigger *) trigger);
    }

    if ([trigger isKindOfClass:[UNCalendarNotificationTrigger class]]) {
        return RCTFormatCalendarNotificationTrigger((UNCalendarNotificationTrigger *) trigger);
    }

    if ([trigger isKindOfClass:[UNLocationNotificationTrigger class]]) {
        return RCTFormatLocationNotificationTrigger((UNLocationNotificationTrigger *) trigger);
    }

    return @{@"type": @"push", @"repeats": @false};
}

static NSDictionary* RCTFormatNotificationRequest(UNNotificationRequest *request) {
    NSMutableDictionary *formattedRequest = [NSMutableDictionary dictionary];

    formattedRequest[@"identifier"] = request.identifier;
    formattedRequest[@"content"] = RCTFormatNotificationContent(request.content);
    formattedRequest[@"trigger"] = RCTFormatNotificationTrigger(request.trigger);

    return formattedRequest;
}

static NSDictionary* RCTFormatNotification(UNNotification *notification) {
    NSMutableDictionary *formattedNotification = [NSMutableDictionary dictionary];
    formattedNotification[@"date"] = RCTFormatDate(notification.date);
    formattedNotification[@"request"] = RCTFormatNotificationRequest(notification.request);
    return formattedNotification;
}

static NSDictionary* RCTFormatNotificationResponse(UNNotificationResponse *response) {
    NSMutableDictionary *formattedResponse = [NSMutableDictionary dictionary];
    formattedResponse[@"actionIdentifier"] = response.actionIdentifier;
    formattedResponse[@"notification"] = RCTFormatNotification(response.notification);
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        formattedResponse[@"userText"] = ((UNTextInputNotificationResponse *) response).userText;
    }
    return formattedResponse;
}

#pragma mark - Module -
static PushNotificationEx *sharedInstance = nil;
static NSMutableArray<NSDictionary *> *pendingNotificationResponses = nil;

@implementation PushNotificationEx

@synthesize notificationCompletionHandlers;

RCT_EXPORT_MODULE()

- (id)init {
    if (self = [super init]) {
        sharedInstance = self;
        self.notificationCompletionHandlers = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (PushNotificationEx *) sharedNotificationManager {
    return sharedInstance;
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"userNotificationCenterWillPresentNotification",
            @"userNotificationCenterDidReceiveNotificationResponse",
            @"applicationDidRegisterForRemoteNotifications",
            @"applicationDidFailToRegisterForRemoteNotifications"];
}

- (NSDictionary *)constantsToExport
{
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    
    return @{
        @"notificationCenterSupportsContentExtensions": @(notificationCenter.supportsContentExtensions),
        @"notificationDefaultActionIdentifier": UNNotificationDefaultActionIdentifier,
        @"notificationDismissActionIdentifier": UNNotificationDismissActionIdentifier
    };
}

#pragma mark bundleResourceURL
RCT_EXPORT_METHOD(bundleResourceURL:(NSString *)resource
            ofType:(NSString *)ext
            inDirectory:(NSString *)subpath
            withResolver:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject)
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *URL = [[bundle URLForResource:resource withExtension:ext subdirectory:subpath] absoluteString];
    resolve(URL);
}

#pragma mark - UNNotificationCenterDelegate -
- (void) userNotificationCenter:(UNUserNotificationCenter *)center
        willPresentNotification:(UNNotification *)notification
          withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    NSUInteger handlerId = [completionHandler hash];
    self.notificationCompletionHandlers[@(handlerId)] = completionHandler;
    [self sendEventWithName:@"userNotificationCenterWillPresentNotification"
                       body:@{@"handlerId": @(handlerId), @"notification": RCTFormatNotification(notification)}];
}

- (void) userNotificationCenter:(UNUserNotificationCenter *)center
 didReceiveNotificationResponse:(UNNotificationResponse *)response
          withCompletionHandler:(void (^)(void))completionHandler
{
    NSUInteger handlerId = [completionHandler hash];
    self.notificationCompletionHandlers[@(handlerId)] = completionHandler;
    [self sendEventWithName:@"userNotificationCenterDidReceiveNotificationResponse"
                       body:@{@"handlerId": @(handlerId), @"notificationResponse": RCTFormatNotificationResponse(response)}];
}

+ (void) userNotificationCenter:(UNUserNotificationCenter *)center
 didReceiveNotificationResponse:(UNNotificationResponse *)response
          withCompletionHandler:(void (^)(void))completionHandler
{
    if (!sharedInstance) {
        if (!pendingNotificationResponses) {
            pendingNotificationResponses = [NSMutableArray array];
        }
        [pendingNotificationResponses addObject:@{
                @"center": center,
                @"response": response,
                @"completionHandler": completionHandler
        }];
    } else {
        [sharedInstance userNotificationCenter:center
                       didReceiveNotificationResponse:response
                         withCompletionHandler:completionHandler];
    }
}

RCT_EXPORT_METHOD(notificationCenterApplyPendingNotificationResponses:(RCTPromiseResolveBlock)resolve
            withReject:(RCTPromiseRejectBlock)reject)
{
    for (NSDictionary *args in pendingNotificationResponses) {
        [self userNotificationCenter:(UNUserNotificationCenter *) args[@"center"]
      didReceiveNotificationResponse:(UNNotificationResponse *) args[@"response"]
               withCompletionHandler:(void (^)(void)) args[@"completionHandler"]];
    }

    [pendingNotificationResponses removeAllObjects];
}

RCT_EXPORT_METHOD(notificationCenterApplyWillPresentNotificationHandler:(NSDictionary *) payload
            withResolver:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject)
{
    NSNumber *handlerId = [RCTConvert NSNumber:payload[@"handlerId"]];

    if (self.notificationCompletionHandlers[handlerId]) {
        void (^completionHandler)(UNNotificationPresentationOptions) = self.notificationCompletionHandlers[handlerId];
        completionHandler([RCTConvert UNNotificationPresentationOptions:payload[@"presentationOptions"]]);
        [self.notificationCompletionHandlers removeObjectForKey:handlerId];
        resolve(@true);
        return;
    }

    resolve(@false);
}

RCT_EXPORT_METHOD(notificationCenterApplyDidReceiveNotificationResponseHandler:(NSDictionary *) payload
            withResolver:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject)
{
    NSNumber *handlerId = [RCTConvert NSNumber:payload[@"handlerId"]];

    if (self.notificationCompletionHandlers[handlerId]) {
        void (^completionHandler)(void) = self.notificationCompletionHandlers[handlerId];
        completionHandler();
        [self.notificationCompletionHandlers removeObjectForKey:handlerId];
        resolve(@true);
        return;
    }

    resolve(@false);
}


#pragma mark - Managing Settings and Authorization -
RCT_EXPORT_METHOD(notificationCenterRequestAuthorization:(UNAuthorizationOptions) options
                  withResolver:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:options
                                                                        completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            return resolve(@true);
        }
        
        reject(kErrorsAuthorizationRequestDenied, kErrorsAuthorizationRequestDeniedMessage, error);
    }];
}

RCT_EXPORT_METHOD(notificationCenterGetNotificationSettings:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        resolve(RCTFormatNotificationSettings(settings));
    }];
}
#pragma mark - Registering the Notification Categories -
RCT_EXPORT_METHOD(notificationCenterSetNotificationCategories:(NSArray<id>*)categoriesPayload
                  withResolver:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    NSMutableSet<UNNotificationCategory*> *categories = [NSMutableSet setWithCapacity:categoriesPayload.count];
    
    for (id categoryPayload in categoriesPayload) {
        [categories addObject:[RCTConvert UNNotificationCategory:categoryPayload]];
    }
    
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
    resolve(@true);
}

RCT_EXPORT_METHOD(notificationCenterGetNotificationCategories:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> * _Nonnull categories) {
        NSMutableArray<NSDictionary*> *formattedCategories = [NSMutableArray arrayWithCapacity:categories.count];
        
        for (UNNotificationCategory* category in categories) {
            [formattedCategories addObject:RCTFormatNotificationCategory(category)];
        }
        
        resolve(formattedCategories);
    }];
}

#pragma mark - Scheduling and Canceling Notification Requests -
RCT_EXPORT_METHOD(notificationCenterAddNotificationRequest:(UNNotificationRequest *) request
                  withResolver:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [[UNUserNotificationCenter currentNotificationCenter]
            addNotificationRequest:request
             withCompletionHandler:^(NSError *error) {
                 if (!error) {
                     return resolve([NSNull null]);
                 }

                 reject(kErrorsNotificationRequestFailed, kErrorsNotificationRequestFailedMessage, error);
             }];
}

RCT_EXPORT_METHOD(notificationCenterGetPendingNotificationRequests:(RCTPromiseResolveBlock)resolve
            withReject:(RCTPromiseRejectBlock)reject)
{
    [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> *requests) {
        NSMutableArray *pendingRequest = [NSMutableArray arrayWithCapacity:requests.count];
        for (UNNotificationRequest *request in requests) {
            [pendingRequest addObject:RCTFormatNotificationRequest(request)];
        }
        resolve(pendingRequest);
    }];
}

RCT_EXPORT_METHOD(notificationCenterRemovePendingNotificationRequests:(NSArray<NSString *> *)identifiers
            withResolver:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject)
{
    [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:identifiers];
    resolve(@true);
}

RCT_EXPORT_METHOD(notificationCenterRemoveAllPendingNotificationRequests:(RCTPromiseResolveBlock)resolve
            withReject:(RCTPromiseRejectBlock)reject)
{
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    resolve(@true);
}

#pragma mark - Managing Delivered Notifications -
RCT_EXPORT_METHOD(notificationCenterGetDeliveredNotifications:(RCTPromiseResolveBlock)resolve
            withReject:(RCTPromiseRejectBlock)reject)
{
    [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> *notifications) {
        NSMutableArray *deliveredNotifications = [NSMutableArray arrayWithCapacity:notifications.count];

        for (UNNotification *notification in notifications) {
            [deliveredNotifications addObject:RCTFormatNotification(notification)];
        }

        resolve(deliveredNotifications);
    }];
}

RCT_EXPORT_METHOD(notificationCenterRemoveDeliveredNotifications:(NSArray<NSString *> *)identifiers
            withResolver:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject)
{
    [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:identifiers];
    resolve(@true);
}

RCT_EXPORT_METHOD(notificationCenterRemoveAllDeliveredNotifications:(RCTPromiseResolveBlock)resolve
            withReject:(RCTPromiseRejectBlock)reject)
{
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    resolve(@true);
}

#pragma mark - Registering for Remote Notifications -
RCT_EXPORT_METHOD(applicationRegisterForRemoteNotifications:(RCTPromiseResolveBlock)resolve
            withReject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        resolve(@true);
    });
}

RCT_EXPORT_METHOD(applicationUnregisterForRemoteNotifications:(RCTPromiseResolveBlock)resolve
            withReject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        resolve(@true);
    });
}

RCT_EXPORT_METHOD(applicationIsRegisteredForRemoteNotifications:(RCTPromiseResolveBlock)resolve
            withReject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        resolve(@([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]));
    });
}

RCT_EXPORT_METHOD(applicationSetIconBadgeNumber:(NSInteger)number
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withReject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].applicationIconBadgeNumber = number;
        resolve(@true);
    });
}

RCT_EXPORT_METHOD(applicationGetIconBadgeNumber:(RCTPromiseResolveBlock)resolve
                  withReject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        resolve(@([UIApplication sharedApplication].applicationIconBadgeNumber));
    });
}


- (void) applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSMutableString *deviceTokenHex = [NSMutableString string];

    [deviceToken enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        for (NSUInteger i = 0; i < byteRange.length; ++i) {
            [deviceTokenHex appendFormat:@"%02x", ((uint8_t*)bytes)[i]];
        }
    }];

    [self sendEventWithName:@"applicationDidRegisterForRemoteNotifications" body:deviceTokenHex];
}

- (void)applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [self sendEventWithName:@"applicationDidFailToRegisterForRemoteNotifications"
                       body:@{@"message": error.localizedDescription,
                               @"code": @(error.code),
                               @"userInfo": error.userInfo}];
}
@end
