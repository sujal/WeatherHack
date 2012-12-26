//
//  FCWHPrimaryControlView.m
//  WeatherHack
//
//  Created by Sujal Shah on 12/25/12.
//  Copyright (c) 2012 Forche LLC. All rights reserved.
//

#import "FCWHPrimaryControlView.h"

@implementation FCWHPrimaryControlView

@synthesize currentTemp=_currentTemp;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addObserver:self forKeyPath:@"signalStrength" options:NSKeyValueObservingOptionNew context:NULL];
        self.signalStrength = nil;
    }
    return self;
}

- (void)awakeFromNib {
    NSLog(@"I am awake!");
    
    [self addObserver:self forKeyPath:@"signalStrength" options:NSKeyValueObservingOptionNew context:NULL];
    self.signalStrength = nil;
    
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"signalStrength"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - custom setters/getters

- (void) setCurrentTemp:(float)currentTemp {
    [self willChangeValueForKey:@"currentTemp"];
    
    _currentTemp = currentTemp;
    
    [self didChangeValueForKey:@"currentTemp"];
}

- (void)setControlState:(FCWHControlState)controlState {
    [self willChangeValueForKey:@"controlState"];
    _controlState = controlState;
    
    switch (controlState) {
        case FCWHControlStateDisconnected:
            self.tempLabel.text = @"----";
            self.statusLabel.text = NSLocalizedString(@"Disconnected.", "");
            self.statusHintLabel.text = NSLocalizedString(@"Slide up to search for devices.", "");
            self.statusHintLabel.hidden = NO;
            [self.activityIndicator stopAnimating];
            self.signalStrength = nil;
            break;
        case FCWHControlStateConnecting:
            self.statusLabel.text = NSLocalizedString(@"Connecting...", "");
            self.statusHintLabel.text = NSLocalizedString(@"Please wait.", "");
            self.statusHintLabel.hidden = NO;
            [self.activityIndicator startAnimating];
            self.signalStrength = nil;
            break;
        case FCWHControlStateConnected:
            self.statusLabel.text = NSLocalizedString(@"Connected!", "");
            self.statusHintLabel.hidden = YES;
            [self.activityIndicator stopAnimating];
            break;
        case FCWHControlStateDisconnecting:
            self.statusLabel.text = NSLocalizedString(@"Disconnecting...", "");
            self.statusHintLabel.text = NSLocalizedString(@"Please wait.", "");
            self.statusHintLabel.hidden = NO;
            [self.activityIndicator startAnimating];
            break;
            
        default:
            break;
    }
    
    [self didChangeValueForKey:@"controlState"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"signalStrength"]) {
        self.signalStrengthLabel.hidden = (self.signalStrength == nil);
        if (self.signalStrength) {
            self.signalStrengthLabel.text = [self.signalStrength stringValue];
        }
    }
}

@end
