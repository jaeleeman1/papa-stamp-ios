//
//  RangingTableViewController.m
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

#import "RangingTableViewController.h"
#import "RangedBeaconViewController.h"
#import "RecoDefaults.h"

@interface RangingTableViewController ()

@end

@implementation RangingTableViewController {
    NSMutableDictionary *_rangedBeacon;
    NSMutableDictionary *_rangedRegions;
    RECOBeaconManager *_recoManager;
    NSArray *_uuidList;
    NSArray *_stateCategory;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView reloadData];
    
    _rangedBeacon = [[NSMutableDictionary alloc] init];
    _rangedRegions = [[NSMutableDictionary alloc] init];
    
    _recoManager = [[RECOBeaconManager alloc] init];
    _recoManager.delegate = self;
    _uuidList = [RecoDefaults sharedDefaults].supportedUUIDs;
    _stateCategory = @[@(RECOProximityUnknown),
                       @(RECOProximityImmediate),
                       @(RECOProximityNear),
                       @(RECOProximityFar)];

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
    [self startRanging];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopRanging];
    
}

- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID andIdentifier:(NSString*)identifier {
    RECOBeaconRegion *recoRegion = [[RECOBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:identifier];
    
    _rangedRegions[recoRegion] = [NSArray array];
}

- (void) startRanging {
    if (![RECOBeaconManager isRangingAvailable]) {
        return;
    }
    
    [_rangedRegions enumerateKeysAndObjectsUsingBlock:^(RECOBeaconRegion *recoRegion, NSArray *beacons, BOOL *stop) {
        [_recoManager startRangingBeaconsInRegion:recoRegion];
    }];
}

- (void) stopRanging; {
    [_rangedRegions enumerateKeysAndObjectsUsingBlock:^(RECOBeaconRegion *recoRegion, NSArray *beacons, BOOL *stop) {
        [_recoManager stopRangingBeaconsInRegion:recoRegion];
    }];
}

#pragma mark - RECOBeaconManager delegate methods

- (void)recoManager:(RECOBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(RECOBeaconRegion *)region {
    NSLog(@"didRangeBeaconsInRegion: %@, ranged %lu beacons", region.identifier, (unsigned long)[beacons count]);
    
    _rangedRegions[region] = beacons;
    [_rangedBeacon removeAllObjects];
    
    NSMutableArray *allBeacons = [NSMutableArray array];
    
    NSArray *arrayOfBeaconsInRange = [_rangedRegions allValues];
    [arrayOfBeaconsInRange enumerateObjectsUsingBlock:^(NSArray *beaconsInRange, NSUInteger idx, BOOL *stop){
        [allBeacons addObjectsFromArray:beaconsInRange];
    }];
    
    [_stateCategory enumerateObjectsUsingBlock:^(NSNumber *range, NSUInteger idx, BOOL *stop){
        NSArray *beaconsInRange = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
        
        if ([beaconsInRange count]) {
            _rangedBeacon[range] = beaconsInRange;
        }
    }];
    [self.tableView reloadData];
}

- (void)recoManager:(RECOBeaconManager *)manager rangingDidFailForRegion:(RECOBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"rangingDidFailForRegion: %@ error: %@", region.identifier, [error localizedDescription]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _rangedBeacon.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *beaconList = [_rangedBeacon allValues];
    NSLog(@"section %ld, count %lu", (long)section, (unsigned long)[beaconList[section] count]);
    return [beaconList[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    NSArray *rangeList = [_rangedBeacon allKeys];
    switch ([rangeList[section] integerValue]) {
        case RECOProximityNear:
            title = NSLocalizedString(@"Near", @"near section header");
            break;
        case RECOProximityImmediate:
            title = NSLocalizedString(@"Immediate", @"immediate section header");
            break;
        case RECOProximityFar:
            title = NSLocalizedString(@"Far", @"far section header");
            break;
        default:
            title = NSLocalizedString(@"Unknown", @"Unknown section header");
            break;
    }
    return title;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"rangedBeaconCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    NSNumber *range = [_rangedBeacon allKeys][indexPath.section];
    RECOBeacon *beacon = _rangedBeacon[range][indexPath.row];
    
    cell.textLabel.text = beacon.proximityUUID.UUIDString;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@ acc: %.2fm rssi: %ld", beacon.major, beacon.minor, beacon.accuracy, (long)beacon.rssi];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    RangedBeaconViewController *beaconViewController = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSNumber *range = [_rangedBeacon allKeys][indexPath.section];
    RECOBeacon *recoBeacon = _rangedBeacon[range][indexPath.row];
    beaconViewController.beacon = recoBeacon;
}

@end
