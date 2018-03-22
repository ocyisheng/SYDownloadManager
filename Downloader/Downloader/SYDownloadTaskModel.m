//
//  DownloadTaskModel.m
//  Downloader
//
//  Created by 高春阳 on 2018/3/16.
//  Copyright © 2018年 gao. All rights reserved.
//

#import "SYDownloadTaskModel.h"
#import <objc/runtime.h>

@interface SYDownloadTaskModel ()
@end
@implementation SYDownloadTaskModel
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList([SYDownloadTaskModel class], &count);
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
        Ivar *ivarList = class_copyIvarList([SYDownloadTaskModel class], &count);
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
+ (void)archiveObject:(id)object toPath:(NSString *)path{
    [NSKeyedArchiver archiveRootObject:object toFile:path];
}
+ (id)unArchiveObjectFromPath:(NSString *)path{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}
@end
