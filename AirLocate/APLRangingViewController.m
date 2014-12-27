/*
     File: APLRangingViewController.m
 Abstract: View controller that illustrates how to start and stop ranging for a beacon region.
 
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "APLRangingViewController.h"
#import "APLDefaults.h"
#import "BNCHBunchManager.h"
@import CoreLocation;


@interface APLRangingViewController () <CLLocationManagerDelegate, BNCHBunchManagerDelegate>

@property CLLocationManager *locationManager;
@property NSMutableDictionary *rangedRegions;
@property NSMutableDictionary *bunchRangedRegions;
@property (nonatomic) BNCHBunchManager  *bunchManager;

@end


@implementation APLRangingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // This location manager will be used to demonstrate how to range beacons.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //Работа с BunchManager очень похожа на работу со стандартным Location Manager в iOS
    self.bunchManager = [[BNCHBunchManager alloc] init];
    self.bunchManager.delegate = self;


    // Populate the regions we will range once.
    self.rangedRegions = [[NSMutableDictionary alloc] init];
    
    /*    for (NSUUID *uuid in [APLDefaults sharedDefaults].supportedProximityUUIDs)
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        self.rangedRegions[region] = [NSArray array];
    }*/
    
    self.bunchRangedRegions = [[NSMutableDictionary alloc] init];
    BNCHBunchRegion *bunchRegion = [[BNCHBunchRegion alloc] initRegionWithIdentifier:BunchIdentifier];
//    BNCHBunchRegion *bunchRegion = [[BNCHBunchRegion alloc] initRegionWithMajor:90 minor:91 identifier:@"BunchSampleApp"];
    self.bunchRangedRegions[bunchRegion] = [NSArray array];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Start ranging when the view appears.
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager startRangingBeaconsInRegion:region];
    }

    for (BNCHBunchRegion *bunchRegion in self.bunchRangedRegions)
    {
        [self.bunchManager startRangingBunchesInRegion:bunchRegion];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // Stop ranging when the view goes away.
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }

    for (BNCHBunchRegion *bunchRegion in self.bunchRangedRegions)
    {
        [self.bunchManager stopRangingBunchesInRegion:bunchRegion];
    }
}


#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    /*
     CoreLocation will call this delegate method at 1 Hz with updated range information.
     Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
     regions.  It will be displayed multiple times if that is the case.  If that is not desired,
     use a set instead of an array.
     */
    
    BNCHBunchRegion* rgn = [[BNCHBunchRegion alloc]initRegionWithIdentifier:StandartBeaconIdentifier];
    self.bunchRangedRegions[rgn] = beacons;

    self.rangedRegions[region] = beacons;
    
    [self.tableView reloadData];
}

#pragma mark - Bunch manager delegate
-(void)bunchManager:(BNCHBunchManager *)manager rangingBunchesDidFailForRegion:(BNCHBunchRegion *)region withError:(NSError *)error
{
    NSLog(@"%@%@:%@:%@",NSStringFromSelector(_cmd), manager, region, error);
}

- (void)bunchManager:(BNCHBunchManager *)manager didRangeBunches:(NSArray *)beacons inRegion:(BNCHBunchRegion *)region
{
    /*
     CoreLocation will call this delegate method at 1 Hz with updated range information.
     Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
     regions.  It will be displayed multiple times if that is the case.  If that is not desired,
     use a set instead of an array.
     */
    if(region.regionType == BNCHRegionTypeSimple)
    {
        BNCHBunchRegion* rgn = [[BNCHBunchRegion alloc]initRegionWithIdentifier:BunchIdentifier];
        self.bunchRangedRegions[rgn] = beacons;
    }
    else
    {
        BNCHBunchRegion* rgn = [[BNCHBunchRegion alloc]initRegionWithIdentifier:SecuredBunchIdentifier];
        self.bunchRangedRegions[rgn] = beacons;
    }
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionKey = [NSArray arrayWithObjects:BunchIdentifier, SecuredBunchIdentifier, StandartBeaconIdentifier, nil];
    
    BNCHBunchRegion* region = [[BNCHBunchRegion alloc]initRegionWithIdentifier:sectionKey[section]];
    
    return [self.bunchRangedRegions[region] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *sectionKey = [NSArray arrayWithObjects:BunchIdentifier, SecuredBunchIdentifier, StandartBeaconIdentifier, nil];
    
    return sectionKey[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
 
    NSArray *sectionKey = [NSArray arrayWithObjects:BunchIdentifier, SecuredBunchIdentifier, StandartBeaconIdentifier, nil];
    
    BNCHBunchRegion* region = [[BNCHBunchRegion alloc]initRegionWithIdentifier:sectionKey[indexPath.section]];
    
    CLBeacon *beacon = self.bunchRangedRegions[region][indexPath.row];
    cell.detailTextLabel.text = [beacon.proximityUUID UUIDString];

    NSString *formatString = NSLocalizedString(@"Major: %@, Minor: %@, Acc: %.2fm", @"Format string for ranging table cells.");
    cell.textLabel.text = [NSString stringWithFormat:formatString, beacon.major, beacon.minor, beacon.accuracy];

    return cell;
}


@end
