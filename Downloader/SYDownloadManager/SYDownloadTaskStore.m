//
//  SYDownloadTaskStore.m
//  SYDownloader
//
//  Created by 高春阳 on 2018/3/18.
//  Copyright © 2018年 gao. All rights reserved.
//

#import "SYDownloadTaskStore.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h> 

@interface SYDownloadTaskStore ()
@property (nonatomic, strong) NSMutableDictionary <NSString *,NSOutputStream *> *outputStreamDic;
@property (nonatomic, strong) NSMutableDictionary <NSString *,SYDownloadTaskModel *> *taskModelDic;
@property (nonatomic, copy) NSString *cacheDirect;
@end

@implementation SYDownloadTaskStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
        }
    return self;
}
- (void)willResignActiveNotification{
    //储存model
    [SYDownloadTaskModel archiveObject:self.taskModelDic toPath:[self.cacheDirect stringByAppendingPathComponent:@"downloadTask_archives"]];
}
- (void)deleteTaskModelWithURLStr:(NSString *)url{
    NSString *cachePath = [self cacheFilePathWithURL:url];
     [self.taskModelDic removeObjectForKey:url];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    });
}
- (void)addTaskModeWithURLStr:(NSString *)url type:(NSString *)type{
    if ([self.taskModelDic objectForKey:url] == nil) {
        SYDownloadTaskModel *model = [SYDownloadTaskModel new];
        model.url = url;
        model.type = type;
        model.cacheFileName = [NSString stringWithFormat:@"%@.%@",[SYDownloadTaskStore md5:model.url],model.type];
        [self.taskModelDic setObject:model forKey:model.url];
    }
}

- (void)openOutputStreamWithResponse:(NSURLResponse *)response forURL:(NSString *)url;{
    SYDownloadTaskModel *model = [self.taskModelDic objectForKey:url];
    if (model.currentSize == 0) {
        //注意这里的是根据range返回的剩余的数据量
         model.totalSize = response.expectedContentLength;
    }
    NSOutputStream  *stream = [NSOutputStream outputStreamToFileAtPath:[self cacheFilePathWithURL:url] append:YES];
    [stream open];
    [self.outputStreamDic setObject:stream forKey:url];
}
- (NSString *)cacheFilePathWithURL:(NSString *)url{
    return [self.cacheDirect stringByAppendingPathComponent:[self.taskModelDic objectForKey:url].cacheFileName];
}
- (void)appenOutputStreamWithData:(NSData *)data forURL:(NSString *)url{
    NSOutputStream  *stream = [self.outputStreamDic objectForKey:url];
    [stream write:data.bytes maxLength:data.length];
     SYDownloadTaskModel *model = [self.taskModelDic objectForKey:url];
    model.currentSize += data.length;
    if (model.totalSize > 0) {
        model.progress = (float)model.currentSize / model.totalSize;
    }
}

- (void)closeOutputStreamWithURLStr:(NSString *)url{
    NSOutputStream  *stream = [self.outputStreamDic objectForKey:url];
    if (stream) {
        [stream close];
        [self.outputStreamDic removeObjectForKey:url];
    }
}
- (SYDownloadTaskModel *)taskModelWithURL:(NSString *)url{
    return [self.taskModelDic objectForKey:url];
}

- (NSDictionary<NSString *,SYDownloadTaskModel *> *)taskModels{
    return self.taskModelDic;
}
- (NSMutableDictionary <NSString *,NSOutputStream*> *)outputStreamDic{
    if (_outputStreamDic == nil) {
        _outputStreamDic = [NSMutableDictionary dictionary];
    }
    return _outputStreamDic;
}

- (NSMutableDictionary <NSString *,SYDownloadTaskModel*> *)taskModelDic{
    if (_taskModelDic == nil) {
        _taskModelDic = [SYDownloadTaskModel unArchiveObjectFromPath:[self.cacheDirect stringByAppendingPathComponent:@"downloadTask_archives"]];
        [_taskModelDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SYDownloadTaskModel * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.state == SYDownloadTaskStateDownloading || obj.state == SYDownloadTaskStateWaiting) {
                obj.state = SYDownloadTaskStateSuspend;
            }
        }];
        if (_taskModelDic == nil) {
            _taskModelDic = [NSMutableDictionary dictionary];
        }
    }
    return _taskModelDic;
}

- (NSString *)cacheDirect{
    if (_cacheDirect == nil) {
        _cacheDirect = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        _cacheDirect = [_cacheDirect stringByAppendingPathComponent:@"__downloadOperationQueueCache"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_cacheDirect] == NO) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_cacheDirect withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _cacheDirect;
}

+ (NSString *)md5:(NSString *)str{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (uint32_t)strlen(cStr),result );
    NSMutableString *hash =[NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}
@end
