#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#include "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  [GMSServices provideAPIKey:@"ENTER-MAPS-API-KEY-HERE"];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
