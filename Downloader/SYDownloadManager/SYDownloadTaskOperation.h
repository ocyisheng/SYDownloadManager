//
//  SYDownloaderTask.h
//  SYDownloader
//
//  Created by 高春阳 on 2018/3/15.
//  Copyright © 2018年 gao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYDownloadTaskOperation : NSOperation
///url作为identify
@property (nonatomic, copy, readonly) NSString *__nullable identify;
///添加任务
- (instancetype)initWithDataTask:(NSURLSessionDataTask *__nullable)dataTask;
///暂停任务
- (void)suspendTask;
///删除任务
- (void)removeTask;
///结束任务
- (void)completionTask;
@end
