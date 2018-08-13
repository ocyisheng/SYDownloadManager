//
//  SYDownloadManager.m
//  Downloader
//
//  Created by 高春阳 on 2018/3/15.
//  Copyright © 2018年 gao. All rights reserved.
//

#import "SYDownloadTaskManager.h"
#import "SYDownloadTaskOperation.h"
#import "SYDownloadTaskStore.h"
#import "NSOperationQueue+SYDelayAddOperation.h"

@interface SYDownloadTaskManager ()<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *downloadOperationQueue;
@property (nonatomic, strong) SYDownloadTaskStore *taskStore;//数据储存的
@end

@implementation SYDownloadTaskManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxTaskCount = 3;
        _allowsCellularAccess = NO;
        _taskStore = [[SYDownloadTaskStore alloc]init];
        _downloadOperationQueue = [[NSOperationQueue alloc]init];
        _downloadOperationQueue.maxConcurrentOperationCount = _maxTaskCount;
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.allowsCellularAccess = NO;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    }
    return self;
}
- (NSString *)locationPathWithURLStr:(NSString *)url{
    return [self.taskStore cacheFilePathWithURL:url];
}
- (SYDownloadTaskModel *)taskModelWithURLStr:(NSString *)url{
    return [self.taskStore taskModelWithURL:url];
}
- (NSArray<SYDownloadTaskModel *> *)allDownloadTaskModels{
    return self.taskStore.taskModels.allValues;
}

- (void)addTaskWithURLStr:(NSString *)url type:(NSString *)type{
    [self.taskStore addTaskModeWithURLStr:url type:type];
    [self _setTaskState:SYDownloadTaskStateAdded forURL:url];
}
- (void)deleteTaskWithURLStr:(NSString *)url{
    SYDownloadTaskModel *model = [self.taskStore taskModelWithURL:url];
    if (model.state == SYDownloadTaskStateDownloading || model.state == SYDownloadTaskStateWaiting) {
        //taskOperation在队列中，需要先取消operation，再从store中删除model
        [[self _taskOperationWithURLStr:url] removeTask];
        //从等待数组中移除operation，
        [self.downloadOperationQueue syDelay_removeOperation:[self _taskOperationWithURLStr:url]];
    }
    //删除model
    [self.taskStore deleteTaskModelWithURLStr:url];
}

- (void)suspendTaskWithURLStr:(NSString *)url{
    SYDownloadTaskModel *model = [self.taskStore taskModelWithURL:url];
    if (model.state == SYDownloadTaskStateDownloading || model.state == SYDownloadTaskStateWaiting) {
        [[self _taskOperationWithURLStr:url] suspendTask];
        [self.downloadOperationQueue syDelay_removeOperation:[self _taskOperationWithURLStr:url]];
        [self _setTaskState:SYDownloadTaskStateSuspend forURL:url];
    }
}
- (void)resumeTaskWithURLStr:(NSString *)url{
    SYDownloadTaskModel *model = [self.taskStore taskModelWithURL:url];
    if (model.state == SYDownloadTaskStateAdded || model.state == SYDownloadTaskStateSuspend || model.state == SYDownloadTaskStateFail) {
        NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [httpRequest setValue:[NSString stringWithFormat:@"bytes=%lld-",model.currentSize] forHTTPHeaderField:@"range"];
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:[httpRequest copy]];
        SYDownloadTaskOperation *taskOp = [self _taskOperationWithURLStr:url];
        if (taskOp == nil) {
            taskOp = [[SYDownloadTaskOperation alloc]initWithDataTask:dataTask];
        }
        //启动的时机由downloadOperationQueue决定
        [self.downloadOperationQueue syDelay_addOperation:taskOp];
        //这里是等待中，并不能立即开启
        [self _setTaskState:SYDownloadTaskStateWaiting forURL:url];
    }
}
- (void)setMaxTaskCount:(NSUInteger)maxTaskCount{
    _maxTaskCount = maxTaskCount;
    _downloadOperationQueue.maxConcurrentOperationCount = maxTaskCount;
}

- (void)setAllowsCellularAccess:(BOOL)allowsCellularAccess{
    _allowsCellularAccess = allowsCellularAccess;
    if (_allowsCellularAccess == NO) {
        [self.downloadOperationQueue cancelAllOperations];
        [self.downloadOperationQueue.syDelay_operations enumerateObjectsUsingBlock:^(NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SYDownloadTaskOperation *operation = (SYDownloadTaskOperation *)obj;
            [self.downloadOperationQueue syDelay_removeOperation:operation];
            [operation suspendTask];
            [self _setTaskState:SYDownloadTaskStateSuspend forURL:operation.identify];
        }];
    }
    self.session.configuration.allowsCellularAccess = allowsCellularAccess;
}
- (void)_setTaskState:(SYDownloadTaskState)state forURL:(NSString *)url{
    [self.taskStore taskModelWithURL:url].state = state;
    if (self.downloadTaskStateChangedHandle) {
        self.downloadTaskStateChangedHandle([self.taskStore taskModelWithURL:url]);
    }
}
- (SYDownloadTaskOperation *)_taskOperationWithURLStr:(NSString *)url{
    NSArray <NSOperation *> * operations = [self.downloadOperationQueue syDelay_operations];
    __block SYDownloadTaskOperation *taskOp = nil;
    [operations enumerateObjectsUsingBlock:^(NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SYDownloadTaskOperation *op = (SYDownloadTaskOperation *)obj;
        if ([op.identify isEqualToString:url]) {
            taskOp = op;
            *stop = YES;
        }
    }];
    return taskOp;
}
- (void)_alertWithMessage:(NSString *)message actionTitles:(NSArray <NSString *> *)titles actionHandle:(void(^)(NSUInteger actionIndex))actionHandle{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:titles[0] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (actionHandle) {
            actionHandle(0);
        }
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:titles[1] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (actionHandle) {
            actionHandle(1);
        }
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancleAction];
    
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{
    //session invalid
    NSLog(@"session 被取消");
    NSLog(@"%@",error);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    //默认originalRequest和currentRequest是相同的，当重定向后currentRequest为最新的链接
    NSString *url = task.currentRequest.URL.absoluteString;
    //完成、失败、暂停,都要调用completionTask，改变operation executing，并标识finished = YES 状态
    //当finished = yes 时,operation被queue自动移除
    [[self _taskOperationWithURLStr:url] completionTask];
    [self.taskStore closeOutputStreamWithURLStr:url];
    //错误处理
    if (error == nil) {
        if (self.downloadTaskCompletionHandle) {//下载完成
            self.downloadTaskCompletionHandle(url, [self.taskStore cacheFilePathWithURL:url]);
        }
        [self _setTaskState:SYDownloadTaskStateFinshed forURL:url];
    }else{
        // -1009无网 -1001超时 -999取消
        //并未取消任务
        if (error.code != -999) {
            if (error.code == -1009 && self.allowsCellularAccess == NO) {
                [self _alertWithMessage:@"已禁止移动网络数据传输" actionTitles:@[@"取消",@"允许"] actionHandle:^(NSUInteger actionIndex) {
                    if (actionIndex == 1) {
                        [self setAllowsCellularAccess:YES];
                        //取消session
                        self.session = nil;
                    }
                }];
            }
            [self _setTaskState:SYDownloadTaskStateFail forURL:url];
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
    NSString *urlKey = dataTask.currentRequest.URL.absoluteString;
    [self.taskStore openOutputStreamWithResponse:response forURL:urlKey];
    [self _setTaskState:SYDownloadTaskStateDownloading forURL:urlKey];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    //收到数据
    NSString *urlKey = dataTask.currentRequest.URL.absoluteString;
    [self.taskStore appenOutputStreamWithData:data forURL:urlKey];
    if (self.downloadTaskProgressHandle) {
        self.downloadTaskProgressHandle(urlKey, [self.taskStore taskModelWithURL:urlKey].progress);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    //允许重定向，newrequest是新的
    completionHandler(request);
}

@end


