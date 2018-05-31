//
//  SYDownloaderTask.m
//  SYDownloader
//
//  Created by 高春阳 on 2018/3/15.
//  Copyright © 2018年 gao. All rights reserved.
//

#import "SYDownloadTaskOperation.h"

@interface SYDownloadTaskOperation ()
{
    BOOL _executing;
    BOOL _finished;
    BOOL _cancelled;
}
@property (nonatomic,strong,readwrite) NSURLSessionDataTask *dataTask;
@property (nonatomic,copy,readwrite) NSString *identify;
@end

@implementation SYDownloadTaskOperation
- (instancetype)initWithDataTask:(NSURLSessionDataTask *)dataTask{
    self = [super init];
    if (self) {
        _dataTask = dataTask;
        _identify = dataTask.currentRequest.URL.absoluteString;
    }
    return self;
}

- (void)suspendTask{
    //暂停task
    if (self.isExecuting) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
        _executing = NO;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    }
    [self cancel];
    
}
- (void)removeTask{
    //暂停task
    if (self.isExecuting) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
        _executing = NO;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    }
    [self cancel];
}
- (void)completionTask{
    if (self.isFinished == NO) {
        //完成task
        [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
        [self willChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
        _executing = NO;
        _finished = YES;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
        [self didChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
    }
}

//以下的重写父类方法，
- (void)start{
    //开始
    if (self.isCancelled) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
        _finished = YES;
         [self didChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
    }else{
        [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
        _executing = YES;
        [self.dataTask resume];
        [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    }
}
- (void)cancel{
    //取消
    [self willChangeValueForKey:NSStringFromSelector(@selector(isCancelled))];
    _cancelled = YES;
    [self.dataTask cancel];
    self.dataTask = nil;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isCancelled))];
    //设置finished 为YES，operation将自动从queue中移除
    [self completionTask];
}
- (BOOL)isFinished{
    return _finished;
}
- (BOOL)isExecuting{
    return _executing;
}
- (BOOL)isCancelled{
    return _cancelled;
}
- (BOOL)isAsynchronous{
    return YES;
}
@end
