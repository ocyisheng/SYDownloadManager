//
//  DownloadTaskStore.h
//  Downloader
//
//  Created by 高春阳 on 2018/3/18.
//  Copyright © 2018年 gao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYDownloadTaskModel.h"

@interface SYDownloadTaskStore : NSObject

/**
 添加任务模型

 @param url 任务的链接
 @param type 文件的扩展名
 */
- (void)addTaskModeWithURLStr:(NSString *)url
                     type:(NSString *)type;

/**
 删除任务模型

 @param url 任务的链接
 */
- (void)deleteTaskModelWithURLStr:(NSString *)url;

/**
 开启输出流

 @param response 响应实例
 @param url 任务的链接
 */
- (void)openOutputStreamWithResponse:(NSURLResponse *)response
                              forURL:(NSString *)url;

/**
 添加输出流数据

 @param data 流数据
 @param url 任务的链接
 */
- (void)appenOutputStreamWithData:(NSData *)data
                           forURL:(NSString *)url;

/**
 关闭输出流

 @param url 任务的链接
 */
- (void)closeOutputStreamWithURLStr:(NSString *)url;

/**
 获取任务模型

 @param url 任务的链接
 @return SYDownloadTaskModel
 */
- (SYDownloadTaskModel *)taskModelWithURL:(NSString *)url;

/**
 获取所有的任务模型 value = SYDownloadTaskModel ，key = url

 @return NSDictionary
 */
- (NSDictionary<NSString *,SYDownloadTaskModel *> *)taskModels;

/**
 获取下载任务的本地储存路径

 @param url 任务的链接
 @return NSString 储存路径
 */
- (NSString *)cacheFilePathWithURL:(NSString *)url;
@end
