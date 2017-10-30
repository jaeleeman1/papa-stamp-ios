//
//  AppDelegate.m
//
//        The MIT License (MIT)
//    Copyright (c) 2014-2015 Perples, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <Reco/Reco.h>
#import "RecoDefaults.h"

@interface AppDelegate () <RECOBeaconManagerDelegate>

@end

@implementation AppDelegate {
    NSMutableArray *_registeredRegions;
    RECOBeaconManager *_recoManager;
    NSArray *_uuidList;
    
    BOOL isInside;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [self checkPermission];
    
    _registeredRegions = [[NSMutableArray alloc] init];
    _uuidList = [RecoDefaults sharedDefaults].supportedUUIDs;
    
    _recoManager = [[RECOBeaconManager alloc] init];
    _recoManager.delegate = self;

    NSSet *monitoredRegion = [_recoManager getMonitoredRegions];
    if ([monitoredRegion count] > 0) {
        self.isBackgroundMonitoringOn = YES;
    } else {
        self.isBackgroundMonitoringOn = NO;
    }
    
    for (int i = 0; i < [_uuidList count]; i++) {
        NSUUID *uuid = [_uuidList objectAtIndex:i];
        NSString *identifier = [NSString stringWithFormat:@"RECOBeaconRegion-%d", i];
        
        [self registerBeaconRegionWithUUID:uuid andIdentifier:identifier];
    }
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
    }
    
    return YES;
}

- (void)checkPermission {
    if ([RECOBeaconManager isMonitoringAvailable]){
        UIApplication *application = [UIApplication sharedApplication];
        if (application.backgroundRefreshStatus != UIBackgroundRefreshStatusAvailable) {
            NSString *title = @"Background App Refresh Permission Denied";
            NSString *message = @"To re-enable, please go to Settings > General and turn on Background App Refresh for this app.";
            [self showAlertWithTitle:title andMessage:message];

        }
    }
    
    if([RECOBeaconManager locationServicesEnabled]){
        NSLog(@"Location Services Enabled");
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            NSString *title = @"Location Service Permission Denied";
            NSString *message = @"To re-enable, please go to Settings > Privacy and turn on Location Service for this app.";
            [self showAlertWithTitle:title andMessage:message];
        }
    }
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID andIdentifier:(NSString*)Identifier {
    RECOBeaconRegion *recoRegion = [[RECOBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:Identifier];
    
    [recoRegion setNotifyOnEntry:YES];
    [recoRegion setNotifyOnExit:YES];
    [_registeredRegions addObject:recoRegion];
}


- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark notificadtion
- (void)_sendEnterLocalNotificationWithMessage:(NSString *)message {
    if (!isInside) {
        UILocalNotification *notice = [[UILocalNotification alloc] init];
        
        notice.alertBody = message;
        notice.alertAction = @"Open";
        notice.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notice];
    }
    
    isInside = YES;
}

- (void)_sendExitLocalNotificationWithMessage:(NSString *)message {
    if (isInside) {
        UILocalNotification *notice = [[UILocalNotification alloc] init];
        
        notice.alertBody = message;
        notice.alertAction = @"Open";
        notice.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notice];
    }
    
    isInside = NO;
}

- (void) startBackgroundMonitoring {
    if (![RECOBeaconManager isMonitoringAvailable]) {
        return;
    }
    
    for (RECOBeaconRegion *recoRegion in _registeredRegions) {
        [_recoManager startMonitoringForRegion:recoRegion];
    }
}

- (void) stopBackgroundMonitoring {
    NSSet *monitoredRegions = [_recoManager getMonitoredRegions];
    for (RECOBeaconRegion *recoRegion in monitoredRegions) {
        [_recoManager stopMonitoringForRegion:recoRegion];
    }
}

#pragma mark RECOBeaconManager delegate methods
- (void) recoManager:(RECOBeaconManager *)manager didDetermineState:(RECOBeaconRegionState)state forRegion:(RECOBeaconRegion *)region {
    NSLog(@"didDetermineState(background) %@", region.identifier);
}

- (void) recoManager:(RECOBeaconManager *)manager didEnterRegion:(RECOBeaconRegion *)region {
    NSLog(@"didEnterRegion(background) %@", region.identifier);
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // don't send any notifications
        NSLog(@"app active: not sending notification");
        return;
    }
    
    NSString *msg = [NSString stringWithFormat:@"didEnterRegion: %@", region.identifier];
    [self _sendEnterLocalNotificationWithMessage:msg];
}

- (void) recoManager:(RECOBeaconManager *)manager didExitRegion:(RECOBeaconRegion *)region {
    NSLog(@"didExitRegion(background) %@", region.identifier);
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // don't send any notifications
        NSLog(@"app active: not sending notification");
        return;
    }
    
    NSString *msg = [NSString stringWithFormat:@"didExitRegion: %@", region.identifier];
    [self _sendExitLocalNotificationWithMessage:msg];
}

- (void) recoManager:(RECOBeaconManager *)manager didStartMonitoringForRegion:(RECOBeaconRegion *)region {
    NSLog(@"didStartMonitoringForRegion(background) %@", region.identifier);
}

- (void) recoManager:(RECOBeaconManager *)manager monitoringDidFailForRegion:(RECOBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion(background) %@, error: %@", region.identifier, [error localizedDescription]);
}
@end
