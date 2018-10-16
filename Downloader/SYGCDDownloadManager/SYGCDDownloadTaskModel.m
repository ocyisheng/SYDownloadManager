//
//  SYGCDDownloadTaskModel.m
//  Downloader
//
//  Created by gao on 2018/10/16.
//  Copyright © 2018年 gao. All rights reserved.
//

#import "SYGCDDownloadTaskModel.h"
#import <objc/runtime.h>

@implementation SYGCDDownloadTaskModel
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList([SYGCDDownloadTaskModel class], &count);
    for (int i = 0; i < count; i ++) {
        const char *name = ivar_getName(ivarList[i]);
        NSString *nameKey = [NSString stringWithUTF8String:name];
        [aCoder encodeObject:[self valueForKey:nameKey] forKey:nameKey];
    }
    free(ivarList);
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        unsigned int count = 0;
        Ivar *ivarList = class_copyIvarList([SYGCDDownloadTaskModel class], &count);
        for (int i = 0; i < count; i ++) {
            const char *name = ivar_getName(ivarList[i]);
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivarList);
    }
    return self;
}
@end
