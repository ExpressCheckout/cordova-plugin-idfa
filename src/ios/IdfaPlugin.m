#import "IdfaPlugin.h"
#import "UICKeyChainStore.h"
#import <AdSupport/ASIdentifierManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation IdfaPlugin

- (void)getInfo:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        BOOL adidEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
        NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *uuidUserDefaults = [defaults objectForKey:@"uuid"];

        NSDictionary* resultData;
        
        NSString *uuid = [UICKeyChainStore stringForKey:@"uuid"];
        if (!uuid) {
            uuid = uuidUserDefaults;
        }
        if (!uuid) {
            if (adidEnabled) {
              uuid = idfaString;
            } else {
              uuid = [[NSUUID UUID] UUIDString];
            }
        }

        [defaults setObject:uuid forKey:@"uuid"];
        [defaults synchronize];
        [UICKeyChainStore setString:uuid forKey:@"uuid"];


        if (@available(iOS 14, *)) {
            NSNumber* trackingPermission = @(ATTrackingManager.trackingAuthorizationStatus);
            // workaround, as long as Apple deferred the roll-out of manadatory tracking permission popup
            // we'll assume that if the idfa string is not nullish, then it's allowed by user
            if (!adidEnabled && uuid != nil && ![@"00000000-0000-0000-0000-000000000000" isEqualToString:uuid]) {
                adidEnabled = YES;
            }

            resultData = @{
                @"idfa": uuid,
                @"trackingLimited": [NSNumber numberWithBool:!adidEnabled],
                @"trackingPermission": trackingPermission
            };
        } else {
            resultData = @{
                @"idfa": uuid,
                @"trackingLimited": [NSNumber numberWithBool:!adidEnabled]
            };
        }

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultData];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)requestPermission:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        if (@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                CDVPluginResult* pluginResult =
                    [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSUInteger:status];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult
                                             resultWithStatus:CDVCommandStatus_ERROR
                                             messageAsString:@"requestPermission is supported only for iOS >= 14"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

@end
