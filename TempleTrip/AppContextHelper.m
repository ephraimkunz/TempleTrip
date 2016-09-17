//
//  AppContextHelper.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 2/6/16.
//  Copyright © 2016 Ephraim Kunz. All rights reserved.
//

#import "AppContextHelper.h"
#include <sys/sysctl.h>

@implementation AppContextHelper

+ (NSString *) platformString{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine= malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = @(machine);
    free(machine);
    
    // Reading a file with platform names
    // http://theiphonewiki.com/wiki/Models
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *filePath = [bundle pathForResource:@"PlatformNames" ofType:@"plist"];
    NSDictionary *platformNamesDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    // Changing a platform name to a human readable version
    NSString *readableName = platformNamesDic[platform];
    
    return readableName;
}

+ (NSString *)systemVersion
{
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString *)appName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]?
    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]:
    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

+ (NSString *)appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBuild
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

@end
