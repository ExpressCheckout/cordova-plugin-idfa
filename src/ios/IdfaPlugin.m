#import "IdfaPlugin.h"
#import "UICKeyChainStore.h"
#import <AdSupport/ASIdentifierManager.h>

@implementation IdfaPlugin

- (void)getInfo:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *uuidUserDefaults = [defaults objectForKey:@"uuid"];

        NSString *uuid = [UICKeyChainStore stringForKey:@"uuid"];
        if (!uuid) {
            uuid = uuidUserDefaults;
        }
        if (!uuid) {
            uuid = [[NSUUID UUID] UUIDString];
        }

        [defaults setObject:uuid forKey:@"uuid"];
        [defaults synchronize];
        [UICKeyChainStore setString:uuid forKey:@"uuid"];

        NSDictionary* resultData = @{
            @"uuid": uuid,
        };

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
            @"uuid": uuid
        }];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
