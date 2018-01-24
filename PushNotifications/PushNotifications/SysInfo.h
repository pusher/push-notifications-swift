#ifndef SysInfo_h
#define SysInfo_h

#import <TargetConditionals.h>

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#define SYSINFO_OSX 1
#else
#define SYSINFO_IOS 1
#endif

#endif /* SysInfo_h */
