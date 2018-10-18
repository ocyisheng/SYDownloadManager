//
//  SYGCDDownloadDataTask.m
//  Downloader
//
//  Created by gao on 2018/10/16.
//  Copyright © 2018年 gao. All rights reserved.
//

#import "SYGCDDownloadDataTask.h"
#import "SYGCDDownloadTaskModel.h"
#import <UIKit/UIKit.h>
@interface SYGCDDownloadDataTask ()<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) SYGCDDownloadTaskModel *model;
@property (nonatomic, assign) BOOL allowsCellularAccess;
@property (nonatomic, copy) void(^progressHandle)(float progress, NSData *receiveData);
@property (nonatomic, copy) void(^completeHandle)(SYGCDDownloadTaskState taskState, NSString *url);
@end

@implementation SYGCDDownloadDataTask

// 1.多链接并发任务
// 2.单个链接多点下载，到合成成功通知
// 3.任务的顺序管理

/*
 1.
 信号量
 */
- (instancetype)initWithTaskModle:(SYGCDDownloadTaskModel *)taskModle
{
    self = [super init];
    if (self) {
        _model = taskModle;
        _model.state = SYGCDDownloadTaskStateAdded;
    }
    return self;
}

- (NSNumber *)downloadTaskWithProgress:(void(^)(float progress, NSData *receiveData))progress
                              complete:(void(^)(SYGCDDownloadTaskState taskState, NSString *url))complete{
    self.progressHandle = progress;
    self.completeHandle = complete;
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.model.url]];
    [httpRequest setValue:[NSString stringWithFormat:@"bytes=%lld-",self.model.currentSize] forHTTPHeaderField:@"range"];
    self.dataTask = [self.session dataTaskWithRequest:[httpRequest copy]];
    return @(self.dataTask.taskIdentifier);
}

- (void)suspend {
    //暂停
}

- (void)resume {
    //重启
}
- (void)delete {
    //删除
}
#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{
    //session invalid
    NSLog(@"session 被取消");
    NSLog(@"%@",error);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    //默认originalRequest和currentRequest是相同的，当重定向后currentRequest为最新的链接
    NSString *url = task.originalRequest.URL.absoluteString;
    //完成、失败、暂停,都要调用completionTask，改变operation executing，并标识finished = YES 状态
    //当finished = yes 时,operation被queue自动移除
    // [[self _taskOperationWithURLStr:url] completionTask];
    //    [self.taskStore closeOutputStreamWithURLStr:url];
    //    //错误处理
        if (error == nil) {
            if (self.completeHandle) {//下载完成
                self.completeHandle(SYGCDDownloadTaskStateFinshed, url);
            }
            self.model.state = SYGCDDownloadTaskStateFinshed;
        }else{
            // -1009无网 -1001超时 -999取消
            //并未取消任务
            if (error.code != -999) {
                if (error.code == -1009 && self.allowsCellularAccess == NO) {
                    [self _alertWithMessage:@"已禁止移动网络数据传输" actionTitles:@[@"取消",@"允许"] actionHandle:^(NSUInteger actionIndex) {
                        if (actionIndex == 1) {
                           // [self setAllowsCellularAccess:YES];
                            //取消session
                            self.session = nil;
                            self.model.state = SYGCDDownloadTaskStateSuspend;
                        }
                    }];
                }
            }
        }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
        NSString *urlKey = dataTask.originalRequest.URL.absoluteString;
    //    [self.taskStore openOutputStreamWithResponse:response forURL:urlKey];
    self.model.state = SYGCDDownloadTaskStateDownloading;
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    //收到数据
    NSString *urlKey = dataTask.originalRequest.URL.absoluteString;
    if (self.progressHandle) {
        if (self.model.totalSize > 0) {
            self.model.progress = (float)self.model.currentSize / self.model.totalSize;
        }
        self.progressHandle(self.model.progress, data);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    //允许重定向，newrequest是新的
    completionHandler(request);
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
- (NSURLSession *)session {
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
        _session.configuration.allowsCellularAccess = NO;
    }
    return _session;
}
@end
