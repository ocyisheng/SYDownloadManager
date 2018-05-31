//
//  DownloadTaskModel.h
//  Downloader
//
//  Created by 高春阳 on 2018/3/16.
//  Copyright © 2018年 gao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,SYDownloadTaskState) {
    //已添加，需要调用开始
    SYDownloadTaskStateAdded        = 1,
    //下载中
    SYDownloadTaskStateDownloading  = 2,
    //暂停
    SYDownloadTaskStateSuspend      = 3,
    //完成
    SYDownloadTaskStateFinshed      = 4,
    //等待
    SYDownloadTaskStateWaiting      = 5,//在队列中等待下载，这些是可以自动开始下载的任务
    //失败
    SYDownloadTaskStateFail         = 6,

};
@interface SYDownloadTaskModel : NSObject<NSCoding>
//下载链接
@property (nonatomic, copy) NSString *url;
//文件的扩展名
@property (nonatomic, copy) NSString *type;
//缓存文件名称
@property (nonatomic, copy) NSString *cacheFileName;
//总大小
@property (nonatomic, assign) long long totalSize;
//当前下载大小
@property (nonatomic, assign) long long currentSize;
//进度状况
@property (nonatomic, assign) float progress;
//状态
@property (nonatomic, assign) SYDownloadTaskState state;
@end
