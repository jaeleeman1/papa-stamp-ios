//
//  MonitoringTableViewController.m
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

#import "MonitoringTableViewController.h"
#import "RecoDefaults.h"
@interface MonitoringTableViewController ()

@end

@implementation MonitoringTableViewController {
    NSMutableDictionary *_monitoredRegion;
    NSMutableDictionary *_detectedRegion;
    RECOBeaconManager *_recoManager;
    NSArray *_uuidList;
    NSArray *_stateCategory;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    _monitoredRegion = [[NSMutableDictionary alloc] init];
    _detectedRegion = [[NSMutableDictionary alloc] init];
    
    _recoManager = [[RECOBeaconManager alloc] init];
    _recoManager.delegate = self;
    
    _uuidList = [RecoDefaults sharedDefaults].supportedUUIDs;
    _stateCategory = @[@(RECOBeaconRegionUnknown),
                       @(RECOBeaconRegionInside),
                       @(RECOBeaconRegionOutside)];
    
    for (NSNumber *state in _stateCategory) {
        _detectedRegion[state] = [NSMutableDictionary dictionary];
    }
    
    [_uuidList enumerateObjectsUsingBlock:^(NSUUID *uuid, NSUInteger idx, BOOL *stop) {
        NSString *identifier = [NSString stringWithFormat:@"RECOBeaconRegion-%lu", (unsigned long)idx];
        [self registerBeaconRegionWithUUID:uuid andIdentifier:identifier];
    }];

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startMonitoring];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopMonitoring];
}

- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID andIdentifier:(NSString*)identifier {
    RECOBeaconRegion *region = [[RECOBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:identifier];
    
    [region setNotifyOnEntry:YES];
    [region setNotifyOnExit:YES];
    
    [_monitoredRegion setObject:region forKey:region.identifier];
}

- (void)startMonitoring {
    if (![RECOBeaconManager isMonitoringAvailable]) {
        return;
    }

    NSArray *allRegions = [_monitoredRegion allValues];
    [allRegions enumerateObjectsUsingBlock:^(RECOBeaconRegion *region, NSUInteger idx, BOOL *stop) {
        [_recoManager startMonitoringForRegion:region];
        NSLog(@"startMonitoringForRegion: %@", region.identifier);
        
        [_detectedRegion[@(RECOBeaconRegionUnknown)] setObject:region forKey:region.identifier];
    }];
}

- (void)stopMonitoring {
    NSArray *allRegions = [_monitoredRegion allValues];
    [allRegions enumerateObjectsUsingBlock:^(RECOBeaconRegion *region, NSUInteger idx, BOOL *stop) {
        [_recoManager stopMonitoringForRegion:region];
        [_monitoredRegion removeObjectForKey:region.identifier];
    }];
}

#pragma mark - RECOBeaconManager delegate methods

- (void)recoManager:(RECOBeaconManager *)manager didEnterRegion:(RECOBeaconRegion *)region {
    NSLog(@"didEnterRegion %@", region.identifier);
}

- (void)recoManager:(RECOBeaconManager *)manager didExitRegion:(RECOBeaconRegion *)region {
    NSLog(@"didExitRegion %@", region.identifier);
}

- (void)recoManager:(RECOBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"didChangeAuthorizationStatus");
}
- (void)recoManager:(RECOBeaconManager *)manager didDetermineState:(RECOBeaconRegionState)state forRegion:(RECOBeaconRegion *)region {
    NSLog(@"didDetermineState %@", region.identifier);
    
    switch (state) {
        case RECOBeaconRegionInside:
            _detectedRegion[@(RECOBeaconRegionInside)][region.identifier] = region;
            
            [_detectedRegion[@(RECOBeaconRegionOutside)] removeObjectForKey:region.identifier];
            [_detectedRegion[@(RECOBeaconRegionUnknown)] removeObjectForKey:region.identifier];
            
            if ([_detectedRegion[@(RECOBeaconRegionUnknown)] count] > 0) {
                NSDictionary *unknownRegions = [_detectedRegion[@(RECOBeaconRegionUnknown)] copy];
                [_detectedRegion[@(RECOBeaconRegionOutside)] addEntriesFromDictionary:unknownRegions];
                [_detectedRegion[@(RECOBeaconRegionUnknown)] removeAllObjects];
            }
            break;
            
        case RECOBeaconRegionOutside:
            _detectedRegion[@(RECOBeaconRegionOutside)][region.identifier] = region;
            
            [_detectedRegion[@(RECOBeaconRegionInside)] removeObjectForKey:region.identifier];
            [_detectedRegion[@(RECOBeaconRegionUnknown)] removeObjectForKey:region.identifier];
            if ([_detectedRegion[@(RECOBeaconRegionUnknown)] count] > 0) {
                NSDictionary *unknownRegions = [_detectedRegion[@(RECOBeaconRegionUnknown)] copy];
                [_detectedRegion[@(RECOBeaconRegionInside)] addEntriesFromDictionary:unknownRegions];
                [_detectedRegion[@(RECOBeaconRegionUnknown)] removeAllObjects];
            }
            break;
            
        case RECOBeaconRegionUnknown:
            _detectedRegion[@(RECOBeaconRegionUnknown)][region.identifier] = region;
            [_detectedRegion[@(RECOBeaconRegionInside)] removeObjectForKey:region.identifier];
            [_detectedRegion[@(RECOBeaconRegionOutside)] removeObjectForKey:region.identifier];
            break;
    }
    
    [self.tableView reloadData];
}

- (void)recoManager:(RECOBeaconManager *)manager didStartMonitoringForRegion:(RECOBeaconRegion *)region{
    NSLog(@"didStartMonitoringForRegion: %@", region.identifier);
    [_recoManager requestStateForRegion:region];
}

- (void)recoManager:(RECOBeaconManager *)manager monitoringDidFailForRegion:(RECOBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion: %@ error: %@", region.identifier, [error localizedDescription]);

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    int cnt = 0;
    for (NSNumber *state in _stateCategory) {
        if ([_detectedRegion[state] count] > 0) {
            cnt++;
        }
    }
    return cnt;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *stateList = [NSMutableArray array];
    for (NSNumber *state in _stateCategory) {
        if ([_detectedRegion[state] count] > 0) {
            [stateList addObject:state];
        }
    }
    NSNumber *state = stateList[section];
    NSArray *regionsOfState = [[_detectedRegion objectForKey:state] allValues];
    return [regionsOfState count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    
    NSMutableArray *stateList = [NSMutableArray array];
    for (NSNumber *state in _stateCategory) {
        if ([_detectedRegion[state] count] > 0) {
            [stateList addObject:state];
        }
    }
    
    switch ([stateList[section] integerValue]) {
        case RECOBeaconRegionInside:
            title = @"Inside of";
            break;
        case RECOBeaconRegionOutside:
            title = @"Outside of";
            break;
        case RECOBeaconRegionUnknown:
            title = @"Unknown";
            break;
            
        default:
            break;
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"regionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
  
    NSMutableArray *stateList = [NSMutableArray array];
    for (NSNumber *state in _stateCategory) {
        if ([_detectedRegion[state] count] > 0) {
            [stateList addObject:state];
        }
    }
    
    NSNumber *state = stateList[indexPath.section];
    RECOBeaconRegion *region = [_detectedRegion[state] allValues][indexPath.row];

    NSString *currTime = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    cell.textLabel.text = region.identifier;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"updated: %@", currTime];
    
    return cell;
}

@end
