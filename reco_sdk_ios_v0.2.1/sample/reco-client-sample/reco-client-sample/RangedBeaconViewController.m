//
//  RangedBeaconViewController.m
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

#import "RangedBeaconViewController.h"

@interface RangedBeaconViewController ()

@property (nonatomic, strong) IBOutlet UILabel *uuid;
@property (nonatomic, strong) IBOutlet UILabel *major;
@property (nonatomic, strong) IBOutlet UILabel *minor;
@property (nonatomic, strong) IBOutlet UILabel *rssi;
@property (nonatomic, strong) IBOutlet UILabel *accuracy;

@end

@implementation RangedBeaconViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.uuid setText:[self.beacon.proximityUUID UUIDString]];
    [self.major setText:[self.beacon.major stringValue]];
    [self.minor setText:[self.beacon.minor stringValue]];
    [self.rssi setText:[NSString stringWithFormat:@"%ld", (long)self.beacon.rssi]];
    [self.accuracy setText:[NSString stringWithFormat:@"%.4fm", self.beacon.accuracy]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
