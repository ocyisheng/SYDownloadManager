//
//  SYGCDDownloadTaskModel.h
//  Downloader
//
//  Created by gao on 2018/10/16.
//  Copyright © 2018年 gao. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,SYGCDDownloadTaskState) {
    //已添加，需要调用开始
    SYGCDDownloadTaskStateAdded        = 1,
    //下载中
    SYGCDDownloadTaskStateDownloading  = 2,
    //暂停
    SYGCDDownloadTaskStateSuspend      = 3,
    //完成
    SYGCDDownloadTaskStateFinshed      = 4,
    //等待
    SYGCDDownloadTaskStateWaiting      = 5,//在队列中等待下载，这些是可以自动开始下载的任务
    //失败
    SYGCDDownloadTaskStateFail         = 6,
    
};
@interface SYGCDDownloadTaskModel : NSObject
//下载链接
@property (nonatomic, copy) NSString *url;
//文件的扩展名
@property (nonatomic, copy) NSString *type;
//缓存文件名称
@property (nonatomic, copy) NSString *cacheFileName;
//总大小
@property (nonatomic, assign) long long totalSize;//分片 可以计算，实际的大小
//当前下载大小
@property (nonatomic, assign) long long currentSize;//
//进度状况
@property (nonatomic, assign) float progress;//
//状态
@property (nonatomic, assign) SYGCDDownloadTaskState state;
//分片下标
@property (nonatomic, assign) NSUInteger segmentIndex;
//分片数量
@property (nonatomic, assign) NSUInteger segmentCount;

@end
