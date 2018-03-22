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

- (void)addTaskModeWithURLStr:(NSString *)url
                     type:(NSString *)type;

- (void)deleteTaskModelWithURLStr:(NSString *)url;

- (void)openOutputStreamWithResponse:(NSURLResponse *)response
                              forURL:(NSString *)url;

- (void)appenOutputStreamWithData:(NSData *)data
                           forURL:(NSString *)url;

- (void)closeOutputStreamWithURLStr:(NSString *)url;

- (SYDownloadTaskModel *)taskModelWithURL:(NSString *)url;

- (NSDictionary<NSString *,SYDownloadTaskModel *> *)taskModels;

- (NSString *)cacheFilePathWithURL:(NSString *)url;
@end
