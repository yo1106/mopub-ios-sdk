//
//  MPGoogleAdMobInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPGoogleAdMobInterstitialCustomEvent.h"
#import "MPInterstitialAdController.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"
#import <CoreLocation/CoreLocation.h>

@interface MPInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd;
- (GADRequest *)buildGADRequest;

@end

@implementation MPInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd
{
    return [[[GADInterstitial alloc] init] autorelease];
}

- (GADRequest *)buildGADRequest
{
    return [GADRequest request];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPGoogleAdMobInterstitialCustomEvent ()

@property (nonatomic, retain) GADInterstitial *interstitial;

@end

@implementation MPGoogleAdMobInterstitialCustomEvent

@synthesize interstitial = _interstitial;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.interstitial = [[MPInstanceProvider sharedProvider] buildGADInterstitialAd];

    self.interstitial.adUnitID = [info objectForKey:@"adUnitID"];
    self.interstitial.delegate = self;

    GADRequest *request = [[MPInstanceProvider sharedProvider] buildGADRequest];

    CLLocation *location = self.delegate.location;
    if (location) {
        [request setLocationWithLatitude:location.coordinate.latitude
                               longitude:location.coordinate.longitude
                                accuracy:location.horizontalAccuracy];
    }

    // Here, you can specify a list of devices that will receive test ads.
    // See: http://code.google.com/mobile/ads/docs/ios/intermediate.html#testdevices
    request.testDevices = [NSArray arrayWithObjects:
                           GAD_SIMULATOR_ID,
                           // more UDIDs here,
                           nil];

    [self.interstitial loadRequest:request];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitial presentFromRootViewController:rootViewController];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
    self.interstitial = nil;
    [super dealloc];
}

#pragma mark - IMAdInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    [self.delegate interstitialCustomEvent:self didLoadAd:self];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial
{
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
