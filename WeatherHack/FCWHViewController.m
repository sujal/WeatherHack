//
//  FCWHViewController.m
//  WeatherHack
//
//  Created by Sujal Shah on 12/25/12.
//  Copyright (c) 2012 Forche LLC. All rights reserved.
//
//  Note: Some code taken from BLE sample projects, including iOS Chat.
//  That code is found here: 

#import "FCWHViewController.h"

#define TRIGGERING_OFFSET 60.0
#define BLE_CONNECT_TIMEOUT 3.0

@interface FCWHViewController ()
- (void) connectToDevice;
- (void) connectionTimeout:(NSTimer*)timer;
- (void) sendWeatherRequest;
- (void) beginPollingForWeather;
- (NSString*)labelForBottomControl;
- (void) weatherPollFired:(NSTimer*)timer;
@end

@implementation FCWHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.bleShield = [[BLE alloc] init];
    [self.bleShield controlSetup:1];
    self.bleShield.delegate = self;
    
    self.scrollView.contentSize = self.scrollView.bounds.size;
    self.scrollView.directionalLockEnabled = YES;
    
    self.controlView.controlState = FCWHControlStateDisconnected;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (self.weatherPollingTimer) {
        [self.weatherPollingTimer invalidate];
        self.weatherPollingTimer = nil;
    }
    if (self.bleShield.activePeripheral) {
        if(self.bleShield.activePeripheral.isConnected)
        {
            self.controlView.controlState = FCWHControlStateDisconnecting;
            [[self.bleShield CM] cancelPeripheralConnection:[self.bleShield activePeripheral]];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x != 0 && scrollView.contentOffset.y != 0) {
        NSLog(@"Stopping diagonal");
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
    }
    
    if (scrollView.contentOffset.y > TRIGGERING_OFFSET) {
        // TODO: modify to animate properly
        self.bottomControlLabel.textColor = [UIColor activatedControlColor];
        self.bottomControlLabel.text = [NSString stringWithFormat:@"%@ ✓", [self labelForBottomControl]];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"Offset: %@", NSStringFromCGPoint(scrollView.contentOffset));

    if (scrollView.contentOffset.y > TRIGGERING_OFFSET) {
        NSLog(@"Bottom!");
        if (!decelerate) {
            self.bottomControlLabel.textColor = [UIColor standardControlColor];
            self.bottomControlLabel.text = self.labelForBottomControl;
        }
        [self connectToDevice];        
    }
    
    if (scrollView.contentOffset.y < -TRIGGERING_OFFSET) {
        NSLog(@"Top!");
    }
    
    if (scrollView.contentOffset.x < -TRIGGERING_OFFSET) {
        NSLog(@"Left!");
    }
    
    
    if (scrollView.contentOffset.x > TRIGGERING_OFFSET) {
        NSLog(@"Right!");
    }

    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.bottomControlLabel.textColor = [UIColor standardControlColor];
    self.bottomControlLabel.text = [self labelForBottomControl];

}

#pragma mark - private

- (void) connectToDevice {
    
    if (self.bleShield.activePeripheral)
        if(self.bleShield.activePeripheral.isConnected)
        {
            self.controlView.controlState = FCWHControlStateDisconnecting;
            [[self.bleShield CM] cancelPeripheralConnection:[self.bleShield activePeripheral]];
            return;
        }
    
//    self.bleShield = [[BLE alloc] init];
//    [self.bleShield controlSetup:1];
//    self.bleShield.delegate = self;
    
    self.controlView.controlState = FCWHControlStateConnecting;
    if (self.bleShield.peripherals)
        self.bleShield.peripherals = nil;
    
    [self.bleShield findBLEPeripherals:(int)BLE_CONNECT_TIMEOUT];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)BLE_CONNECT_TIMEOUT
                                     target:self
                                   selector:@selector(connectionTimeout:)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (void) connectionTimeout:(NSTimer*)timer {
    // called at the end of our connection wait window. Connect to first found
    // device.
    
    if(self.bleShield.peripherals.count > 0)
    {
        [self.bleShield connectPeripheral:[self.bleShield.peripherals objectAtIndex:0]];
    }
    else
    {
        self.controlView.controlState = FCWHControlStateDisconnected;
    }

}

- (void)sendWeatherRequest {
    
    if (requestInFlight)
        return;
    
    NSLog(@"sending weather request");
    
    requestInFlight = YES;
    NSData* requestData = nil;
    requestData = [@"T0" dataUsingEncoding:NSUTF8StringEncoding];
    [self.bleShield write:requestData];
}

- (void) beginPollingForWeather {
    if (self.weatherPollingTimer != nil) {
        return;
    }
    // send the first request
    [self sendWeatherRequest];
    self.weatherPollingTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                                target:self
                                                              selector:@selector(weatherPollFired:)
                                                              userInfo:nil
                                                               repeats:YES];
}

- (void) weatherPollFired:(NSTimer*)timer {
    [self sendWeatherRequest];
}

- (NSString*)labelForBottomControl {
    
    return (self.controlView.controlState == FCWHControlStateDisconnected ?
            NSLocalizedString(@"Search for Devices","") :
            NSLocalizedString(@"Disconnect",""));
    
}
#pragma mark - BLEDelegate

- (void)bleDidConnect {
    self.controlView.controlState = FCWHControlStateConnected;
    [self beginPollingForWeather];
}

-(void)bleDidDisconnect {
    self.controlView.controlState = FCWHControlStateDisconnected;
    if (self.bleShield.peripherals)
        self.bleShield.peripherals = nil;
    [self.weatherPollingTimer invalidate];
    self.weatherPollingTimer = nil;

//    self.bleShield = nil;
}

-(void)bleDidReceiveData:(unsigned char *)data length:(int)length {
    NSLog(@"Got Data of length: %d", length);
    requestInFlight = NO;
    
    if (length % 4 == 0) {
        float temp;
        for (int i=0; i<length; i+=4) {
            memcpy(&temp, &data[i], 4);
            NSLog(@"temp is %f", temp);
        }
        self.controlView.tempLabel.text = [NSString stringWithFormat:@"%.2f°",temp];
    }
    
}

- (void)bleDidUpdateRSSI:(NSNumber *)rssi {
    self.controlView.signalStrength = rssi;
}


@end
