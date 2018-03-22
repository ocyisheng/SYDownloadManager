//
//  NSOperationQueue+DelayAddOperation.m
//  Downloader
//
//  Created by 高春阳 on 2018/3/20.
//  Copyright © 2018年 gao. All rights reserved.
//

#import "NSOperationQueue+SYDelayAddOperation.h"
#import <objc/runtime.h>

@interface SYOperationQueueObsever : NSObject
@property (nonatomic, assign) NSOperationQueue *operationQueue;//观察它的operationCount
@end

@interface NSOperationQueue ()
@property (nonatomic, strong) NSMutableArray <NSOperation *> *sy_waitingOperations;
@property (nonatomic, strong) SYOperationQueueObsever *sy_operationQueueObsever;
@end

@implementation SYOperationQueueObsever

- (void)dealloc
{
    [self.operationQueue removeObserver:self forKeyPath:@"operationCount" context:@"DelayAddOperationContextKey"];
}

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
{
    self = [super init];
    if (self) {
        _operationQueue = operationQueue;
        [_operationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:@"DelayAddOperationContextKey"];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context{
    
    
    NSString *conextStr = (__bridge NSString *)(context);
    if ([keyPath isEqualToString:@"operationCount"] && [conextStr isEqualToString:@"DelayAddOperationContextKey"]) {
        NSNumber *counts = change[NSKeyValueChangeNewKey];
        if (counts.unsignedIntegerValue < self.operationQueue.maxConcurrentOperationCount && self.operationQueue.sy_waitingOperations.count >=1) {
            //当queue中的操作数量少于最大操作数，并且有等待中的operation，
            //就可以将最先等待的operation取出添加到queue中，
            //并将operation从等待队列中移除
            [self.operationQueue addOperation:self.operationQueue.sy_waitingOperations.firstObject];
            [self.operationQueue.sy_waitingOperations removeObjectAtIndex:0];
        }
    }
}
@end

@implementation NSOperationQueue (DelayAddOperation)

- (void)syDelay_removeOperation:(NSOperation *)operation{
    if ([self.sy_waitingOperations containsObject:operation]) {
         [self.sy_waitingOperations removeObject:operation];
    }
}
- (NSArray<NSOperation *> *)syDelay_operations{
    [self sy_operationQueueObsever];//初始化observe
    //注意这里不要改变 waitingOperations 的内容
    NSMutableArray <NSOperation *> *operations = [self.operations mutableCopy];;
    [operations addObjectsFromArray:[self.sy_waitingOperations copy]];
    return [operations copy];
}

- (void)syDelay_addOperation:(NSOperation *)operation{
    [self sy_operationQueueObsever];//初始化observe
    if (self.operationCount >= self.maxConcurrentOperationCount ) {
        if ([self.sy_waitingOperations containsObject:operation] == NO) {
            [self.sy_waitingOperations addObject:operation];
        }
    }else{
        [self addOperation:operation];
    }
}

- (SYOperationQueueObsever *)sy_operationQueueObsever{
    id obsever = objc_getAssociatedObject(self, _cmd);
    if (obsever == nil) {
        obsever = [[SYOperationQueueObsever alloc]initWithOperationQueue:self];
        objc_setAssociatedObject(self, _cmd, obsever, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obsever;
}

- (NSMutableArray <NSOperation *>*)sy_waitingOperations{
    id operations = objc_getAssociatedObject(self, _cmd);
    if (operations == nil){
        operations = [NSMutableArray array];
        objc_setAssociatedObject(self, @selector(sy_waitingOperations), operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return operations;
}
@end



