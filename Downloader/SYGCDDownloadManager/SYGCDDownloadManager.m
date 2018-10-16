//
//  SYGCDDownloadManager.m
//  Downloader
//
//  Created by gao on 2018/10/16.
//  Copyright © 2018年 gao. All rights reserved.
//

#import "SYGCDDownloadManager.h"
#import <UIKit/UIKit.h>
@interface SYGCDDownloadManager ()<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;//下载任务的会话
@end
@implementation SYGCDDownloadManager


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

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    //默认originalRequest和currentRequest是相同的，当重定向后currentRequest为最新的链接
    NSString *url = task.originalRequest.URL.absoluteString;
    //完成、失败、暂停,都要调用completionTask，改变operation executing，并标识finished = YES 状态
    //当finished = yes 时,operation被queue自动移除
   // [[self _taskOperationWithURLStr:url] completionTask];
//    [self.taskStore closeOutputStreamWithURLStr:url];
//    //错误处理
//    if (error == nil) {
//        if (self.downloadTaskCompletionHandle) {//下载完成
//            self.downloadTaskCompletionHandle(url, [self.taskStore cacheFilePathWithURL:url]);
//        }
//        [self _setTaskState:SYDownloadTaskStateFinshed forURL:url];
//    }else{
//        // -1009无网 -1001超时 -999取消
//        //并未取消任务
//        if (error.code != -999) {
//            if (error.code == -1009 && self.allowsCellularAccess == NO) {
//                [self _alertWithMessage:@"已禁止移动网络数据传输" actionTitles:@[@"取消",@"允许"] actionHandle:^(NSUInteger actionIndex) {
//                    if (actionIndex == 1) {
//                        [self setAllowsCellularAccess:YES];
//                        //取消session
//                        self.session = nil;
//                    }
//                }];
//            }
//            [self _setTaskState:SYDownloadTaskStateFail forURL:url];
//        }
//    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
//    NSString *urlKey = dataTask.originalRequest.URL.absoluteString;
//    [self.taskStore openOutputStreamWithResponse:response forURL:urlKey];
//    [self _setTaskState:SYDownloadTaskStateDownloading forURL:urlKey];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    //收到数据
//    NSString *urlKey = dataTask.originalRequest.URL.absoluteString;
//    [self.taskStore appenOutputStreamWithData:data forURL:urlKey];
//    if (self.downloadTaskProgressHandle) {
//        self.downloadTaskProgressHandle(urlKey, [self.taskStore taskModelWithURL:urlKey].progress);
//    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    //允许重定向，newrequest是新的
    completionHandler(request);
}
@end
