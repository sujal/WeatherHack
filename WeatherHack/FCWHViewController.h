//
//  FCWHViewController.h
//  WeatherHack
//
//  Created by Sujal Shah on 12/25/12.
//  Copyright (c) 2012 Forche LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "FCWHPrimaryControlView.h"

@interface FCWHViewController : UIViewController <UIScrollViewDelegate,BLEDelegate> {
    BOOL requestInFlight;
}

@property (nonatomic,retain) BLE* bleShield;

@property (nonatomic,weak) IBOutlet UIScrollView* scrollView;
@property (nonatomic,weak) IBOutlet FCWHPrimaryControlView* controlView;
@property (nonatomic,weak) IBOutlet UILabel* bottomControlLabel;

@property (nonatomic,strong) NSTimer* weatherPollingTimer;

@end
