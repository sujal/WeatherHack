//
//  FCWHPrimaryControlView.h
//  WeatherHack
//
//  Created by Sujal Shah on 12/25/12.
//  Copyright (c) 2012 Forche LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FCWHControlStateDisconnected,
    FCWHControlStateConnecting,
    FCWHControlStateConnected,
    FCWHControlStateDisconnecting
} FCWHControlState;

@interface FCWHPrimaryControlView : UIView

@property (nonatomic,weak) IBOutlet UILabel* tempLabel;
@property (nonatomic,weak) IBOutlet UILabel* statusLabel;
@property (nonatomic,weak) IBOutlet UILabel* statusHintLabel;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint* statusHintLabelHeightConstraint;
@property (nonatomic,weak) IBOutlet UILabel* signalStrengthLabel;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic,assign) float currentTemp;
@property (nonatomic,copy) NSNumber* signalStrength;
@property (nonatomic,assign) FCWHControlState controlState;

@end
