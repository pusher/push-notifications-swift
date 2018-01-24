#import "SysInfo.h"

#ifdef SYSINFO_OSX
#import <Cocoa/Cocoa.h>
#else // !SYSINFO_OSX
#import <UIKit/UIKit.h>
#endif // SYSINFO_OSX

//! Project version number for PushNotifications.
FOUNDATION_EXPORT double PushNotificationsVersionNumber;

//! Project version string for PushNotifications.
FOUNDATION_EXPORT const unsigned char PushNotificationsVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PushNotifications/PublicHeader.h>


