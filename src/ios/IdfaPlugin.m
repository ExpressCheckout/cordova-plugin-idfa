#import "IdfaPlugin.h"
#import "UICKeyChainStore.h"
#import <AdSupport/ASIdentifierManager.h>

@implementation IdfaPlugin

- (void)getInfo:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        BOOL adidEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
        NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *uuidUserDefaults = [defaults objectForKey:@"uuid"];
        
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

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
            @"idfa": idfaString,
            @"uuid": uuid,
            @"limitAdTracking": [NSNumber numberWithBool:!adidEnabled]
        }];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
