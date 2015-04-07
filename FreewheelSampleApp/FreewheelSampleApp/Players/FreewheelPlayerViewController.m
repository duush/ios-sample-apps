/**
 * @class      SimplePlayerViewController SimplePlayerViewController.m "SimplePlayerViewController.m"
 * @brief      A Player that can be used to simply load an embed code and play it
 * @details    SimplePlayerViewController in Ooyala Sample Apps
 * @date       12/12/14
 * @copyright  Copyright (c) 2014 Ooyala, Inc. All rights reserved.
 */


#import "FreewheelPlayerViewController.h"
#import <OoyalaSDK/OOOoyalaPlayerViewController.h>
#import <OoyalaSDK/OOOoyalaPlayer.h>
#import <OoyalaSDK/OOPlayerDomain.h>
#import <OoyalaSDK/OOEmbeddedSecureURLGenerator.h>
#import <OoyalaFreewheelSDK/OOFreewheelManager.h>

@interface FreewheelPlayerViewController ()
@property OOOoyalaPlayerViewController *ooyalaPlayerViewController;
@property (nonatomic) OOFreewheelManager *adsManager;
@property NSString *embedCode;
@property NSString *nib;
@property NSString *pcode;
@property NSString *playerDomain;
@end

@implementation FreewheelPlayerViewController

- (id)initWithPlayerSelectionOption:(PlayerSelectionOption *)playerSelectionOption {
  self = [super initWithPlayerSelectionOption: playerSelectionOption];
  self.nib = @"PlayerSimple";
  self.pcode =@"R3ZHExOjHcfMbqoMxpYBE7PbDEyB";
  self.playerDomain = @"http://www.ooyala.com";

  if (self.playerSelectionOption) {
    self.embedCode = self.playerSelectionOption.embedCode;
    self.title = self.playerSelectionOption.title;
  }
  self.embedCode = @"Z0MXVmczqsdxTaSa8VWeBfgenf1RO7Q4";
  return self;
}

- (void)loadView {
  [super loadView];
  [[NSBundle mainBundle] loadNibNamed:self.nib owner:self options:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Create Ooyala ViewController
  OOOoyalaPlayer *player = [[OOOoyalaPlayer alloc] initWithPcode:self.pcode domain:[[OOPlayerDomain alloc] initWithString:self.playerDomain] embedTokenGenerator:self];
  self.ooyalaPlayerViewController = [[OOOoyalaPlayerViewController alloc] initWithPlayer:player];

  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector:@selector(notificationHandler:)
                                               name:nil
                                             object:_ooyalaPlayerViewController.player];

  // Attach it to current view
  [self addChildViewController:_ooyalaPlayerViewController];
  [self.playerView addSubview:_ooyalaPlayerViewController.view];
  [self.ooyalaPlayerViewController.view setFrame:self.playerView.bounds];

  self.adsManager = [[OOFreewheelManager alloc] initWithOoyalaPlayerViewController:self.ooyalaPlayerViewController];

  NSMutableDictionary *fwParameters = [[NSMutableDictionary alloc] init];
  // Parameters been Set same as that we use in Yaveo  - NSTG
  [fwParameters setObject:@"382101"forKey:@"fw_ios_mrm_network_id"];
  [fwParameters setObject:@"5d494.v.fwmrm.net" forKey:@"fw_ios_ad_server"];
  [fwParameters setObject:@"382101:hott_ios_live" forKey:@"fw_ios_player_profile"];
  [fwParameters setObject:@"dtv_ipad" forKey:@"fw_ios_site_section_id"];
  [fwParameters setObject:self.embedCode forKey:@"fw_ios_video_asset_id"];

  //[fwParameters setObject:@"90750" forKey:@"fw_ios_mrm_network_id"];
//  [fwParameters setObject:@"http://g1.v.fwmrm.net/" forKey:@"fw_ios_ad_server"];
//  [fwParameters setObject:@"90750:ooyala_ios" forKey:@"fw_ios_player_profile"];
//  [fwParameters setObject:@"channel=TEST;subchannel=TEST;section=TEST;mode=online;player=ooyala;beta=n" forKey:@"FRMSegment"];
  //[fwParameters setObject:@"ooyala_test_site_section" forKey:@"fw_ios_site_section_id"];
  //[fwParameters setObject:@"ooyala_test_video_with_bvi_cuepoints" forKey:@"fw_ios_video_asset_id"];
  [self.adsManager overrideFreewheelParameters:fwParameters];

  // Load the video
  [_ooyalaPlayerViewController.player setEmbedCode: self.embedCode];
  [_ooyalaPlayerViewController.player play];
}

- (void) notificationHandler:(NSNotification*) notification {

  // Ignore TimeChangedNotificiations for shorter logs
  if ([notification.name isEqualToString:OOOoyalaPlayerTimeChangedNotification]) {
    return;
  }

  NSLog(@"Notification Received: %@. state: %@. playhead: %f",
        [notification name],
        [OOOoyalaPlayer playerStateToString:[self.ooyalaPlayerViewController.player state]],
        [self.ooyalaPlayerViewController.player playheadTime]);
}


// //to use, add  embedTokenGenerator:self to our ViewController alloc above
- (void)tokenForEmbedCodes:(NSArray *)embedCodes callback:(OOEmbedTokenCallback)callback {
  NSMutableDictionary* params = [NSMutableDictionary dictionary];
  params[@"account_id"] = @"abc";  //Only used for concurrent streams
  params[@"override_syndication_group"] = @"override_all_synd_groups";
  NSString* uri = [NSString stringWithFormat:@"/sas/embed_token/%@/%@", self.pcode, [embedCodes componentsJoinedByString:@","]];
  OOEmbeddedSecureURLGenerator* urlGen = [[OOEmbeddedSecureURLGenerator alloc] initWithAPIKey:@"API Key for Provider R3ZHExOjHcfMbqoMxpYBE7PbDEyB" secret:@"API Secret"];
  NSURL* embedTokenUrl = [urlGen secureURL:@"http://player.ooyala.com" uri:uri params:params];
  callback([embedTokenUrl absoluteString]);
}

@end
