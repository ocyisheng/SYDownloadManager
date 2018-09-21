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
///设置最大并发任务数量
@property (nonatomic, assign) NSUInteger maxTaskCount;
///下载完成的回调
@property (nonatomic, copy) void(^downloadTaskCompletionHandle)(NSString *url, NSString *locationPath);
///下载进度的回调
@property (nonatomic, copy) void(^downloadTaskProgressHandle)(NSString *url, float progress);
///下载任务状态改变的回调
@property (nonatomic, copy) void(^downloadTaskStateChangedHandle)(SYDownloadTaskModel *model);
///是否允许移动网路下载，默认不允许
@property (nonatomic, assign) BOOL allowsCellularAccess;


/**
 添加下载任务

 @param url 下载文件的链接
 @param type 文件的扩展名称
 */
- (void)addTaskWithURLStr:(NSString *)url
                     type:(NSString *)type;

/**
 暂停下载任务

 @param url 要暂停任务的链接
 */
- (void)suspendTaskWithURLStr:(NSString *)url;

/**
 重启下载任务

 @param url 要重启任务的链接
 */
- (void)resumeTaskWithURLStr:(NSString *)url;

/**
 删除下载任务

 @param url 要删除任务的链接
 */
- (void)deleteTaskWithURLStr:(NSString *)url;

/**
 获取所有的下载任务模型

 @return array
 */
- (NSArray<SYDownloadTaskModel *> *)allDownloadTaskModels;

/**
 获取下载任务的模型

 @param url 任务的链接
 @return SYDownloadTaskModel 实例
 */
- (SYDownloadTaskModel *)taskModelWithURLStr:(NSString *)url;

/**
 获取下载任务的本地储存路径，对于同一下载链接有唯一路径

 @param url 任务的链接；
 @return NSString
 */
- (NSString *)locationPathWithURLStr:(NSString *)url;
@end
