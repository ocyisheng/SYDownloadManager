//
//  NSOperationQueue+DelayAddOperation.h
//  Downloader
//
//  Created by 高春阳 on 2018/3/20.
//  Copyright © 2018年 gao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (SYDelayAddOperation)
//https://github.com/ocyisheng/SYDownloadManager.git
/*
 
 这里这些方法可以解决，自定义operation在queue中处于ready状态，但并没有excuting,而此时有想要取消operation，而出现报错
 
 XXXoperation went isFinished == YES without being started by the queue it is in
 
 这个错误的原因是：没有调用start方法 却改变了operation的状态（isFinished == YES），导致queue对operation的调度出现错乱
 切记！！！！！一旦operation处于ready状态，不要强制改变operation的状态
 
 解决思路是
 1.通过比较maxConcurrentOperationCount 和 operationCount，来决定是否addOperation:,如果添加的操作数<= maxConcurrentOperationCount,就不会有operation处于ready状态
 2.自动开始下一个operation问题的解决，使用属性observe自释放的原理(kvo)，通过SYOperationQueueObsever实例对象观测queue的operationCount，当operationCount 少于maxConcurrentOperationCount，就调用addOperation:
 3.手动移除waiting的operation，但需要手动取消operation时就removeOperation:
 */

///移除操作
- (void)syDelay_removeOperation:(NSOperation *)operation;
///添加操作
- (void)syDelay_addOperation:(NSOperation *)operation;
///获取所有操作，包含waiting的
- (NSArray<NSOperation *> *)syDelay_operations;
@end
