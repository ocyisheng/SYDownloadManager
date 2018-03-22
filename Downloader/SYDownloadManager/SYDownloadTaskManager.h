//
//  SYDownloadManager.h
//  Downloader
//
//  Created by 高春阳 on 2018/3/15.
//  Copyright © 2018年 gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYDownloadTaskModel.h"

@interface SYDownloadTaskManager : NSObject

@property (nonatomic, assign) NSUInteger maxTaskCount;
@property (nonatomic, copy) void(^downloadTaskCompletionHandle)(NSString *url, NSString *locationPath);
@property (nonatomic, copy) void(^downloadTaskProgressHandle)(NSString *url, float progress);
@property (nonatomic, copy) void(^downloadTaskStateChangedHandle)(SYDownloadTaskModel *model);

@property (nonatomic, assign) BOOL allowsCellularAccess;//移动网络
- (void)addTaskWithURLStr:(NSString *)url
                     type:(NSString *)type;

- (void)suspendTaskWithURLStr:(NSString *)url;

- (void)resumeTaskWithURLStr:(NSString *)url;

- (void)deleteTaskWithURLStr:(NSString *)url;

- (NSArray<SYDownloadTaskModel *> *)allDownloadTaskModels;

- (SYDownloadTaskModel *)taskModelWithURLStr:(NSString *)url;

- (NSString *)locationPathWithURLStr:(NSString *)url;
@end
