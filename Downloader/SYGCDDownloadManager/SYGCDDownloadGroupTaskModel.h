//
//  SYGCDDownloadGroupTaskModel.h
//  Downloader
//
//  Created by gao on 2018/10/16.
//  Copyright © 2018年 gao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYGCDDownloadTaskModel.h"

@interface SYGCDDownloadGroupTaskModel : NSObject
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
@property (nonatomic, assign) float progress;//
//状态
@property (nonatomic, assign) SYGCDDownloadTaskState state;
//分片下标
@property (nonatomic, assign) NSUInteger segmentIndex;
//分片数量
@property (nonatomic, assign) NSUInteger segmentCount;
@end
