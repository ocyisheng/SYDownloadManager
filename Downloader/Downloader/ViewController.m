//
//  ViewController.m
//  Downloader
//
//  Created by 高春阳 on 2018/3/15.
//  Copyright © 2018年 gao. All rights reserved.
//

#import "ViewController.h"

#import "SYDownloadTaskManager.h"
#import "DownloadTableViewCell.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _ticketCont;
    
    dispatch_queue_t _queue;
    
    NSInteger count;
}
@property (nonatomic,strong) NSLock *lock;
@property (nonatomic,strong) SYDownloadTaskManager *taskManager;
@property (nonatomic,strong) NSArray<NSString *> *urls;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *wwanButton;

@end

@implementation ViewController
- (void)addTasks{
    if (count < self.urls.count) {
         [self.taskManager addTaskWithURLStr:self.urls[count] type:@"mp4"];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count ++ inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    }
}
- (void)deleteTask{
    if (count > 0) {
         count --;
        [self.taskManager deleteTaskWithURLStr:self.urls[count]];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]]  withRowAnimation:UITableViewRowAnimationBottom];
        
    }
}
- (void)wwanClick:(UIButton *)button{
    [self.taskManager setAllowsCellularAccess:NO];
    button.selected = !button.isSelected;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addButton.frame = CGRectMake(10, CGRectGetHeight(self.view.bounds) - 50, 60, 40);
    _addButton.backgroundColor = [UIColor orangeColor];
    [_addButton setTitle:@"add" forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(addTasks) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addButton];
    
      _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 60 -10, CGRectGetHeight(self.view.bounds) - 50, 60, 40);
    _deleteButton.backgroundColor = [UIColor orangeColor];
    [_deleteButton setTitle:@"delete" forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteTask) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteButton];
    
    
    _wwanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _wwanButton.frame = CGRectMake(CGRectGetMaxX(self.addButton.frame) +50 , CGRectGetMinY(self.addButton.frame) , 60, 40);
    _wwanButton.backgroundColor = [UIColor orangeColor];
    [_wwanButton setTitle:@"不允许" forState:UIControlStateNormal];
     [_wwanButton setTitle:@"允许" forState:UIControlStateSelected];
    [_wwanButton addTarget:self action:@selector(wwanClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_wwanButton];


    
    self.taskManager = [[SYDownloadTaskManager alloc]init];
    count = self.taskManager.allDownloadTaskModels.count;
    
    __weak typeof (self) weakSelf = self;
    _taskManager.downloadTaskProgressHandle = ^(NSString *url, float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[weakSelf.urls indexOfObject:url]  inSection:0];
            DownloadTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                cell.progress.progress = [weakSelf.taskManager taskModelWithURLStr:url].progress;
            }
        });
    };
    _taskManager.downloadTaskCompletionHandle = ^(NSString *url, NSString *locationPath) {

        NSLog(@"url:%@ \n locationPath:%@",url,locationPath);
    };
    
    _taskManager.downloadTaskStateChangedHandle = ^(SYDownloadTaskModel *model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[weakSelf.urls indexOfObject:model.url]  inSection:0];
            DownloadTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                 cell.stateLabel.text = [weakSelf stringForState:model.state];
            }
        });
    };
    _urls = @[@"http://mmm.xunleiziyuan.net/1712/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E03.mp4",
                       @"http://ooo.xunleiziyuan.net/1712/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E05.mp4",
                       @"http://ooo.xunleiziyuan.net/1712/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E04.mp4",
                       @"http://zuidazy.xunleiziyuan.net/1801/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E06.mp4",
                       @"http://zuidazy.xunleiziyuan.net/1801/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E07.mp4",
                       @"http://xunleia.zuida360.com/1801/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E08.mp4",
                       @"http://xunleia.zuida360.com/1801/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E09.mp4",
                       @"http://xunleia.zuida360.com/1802/%E7%A5%9E%E7%9B%BE%E5%B1%80%E7%89%B9%E5%B7%A5S05E10.mp4",
                       @"http://app.datuhongan.com/uploads/video/201612/ld.mp4",
                       @"http://app.datuhongan.com/uploads/video/201612/rrz.mp4",
                       @"http://app.datuhongan.com/uploads/video/201612/sybzxls.mp4",
                       @"http://app.datuhongan.com/uploads/video/201612/sjxymgh.mp4"];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DownloadTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DownloadTableViewCell" forIndexPath:indexPath];
    SYDownloadTaskModel *model = [self.taskManager taskModelWithURLStr:_urls[indexPath.row]];
    cell.nameLabel.text = [NSString stringWithFormat:@"taks_%ld",indexPath.row];
    cell.stateLabel.text = [self stringForState:model.state];
    cell.progress.progress = model.progress;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *url = self.urls[indexPath.row];
    SYDownloadTaskModel *model = [self.taskManager taskModelWithURLStr:url];
    if (model.state == SYDownloadTaskStateAdded || model.state == SYDownloadTaskStateSuspend || model.state == SYDownloadTaskStateFail) {
        [self.taskManager resumeTaskWithURLStr:url];
    }else if (model.state == SYDownloadTaskStateDownloading || model.state == SYDownloadTaskStateWaiting){
         [self.taskManager suspendTaskWithURLStr:url];
    }else if(model.state == SYDownloadTaskStateFinshed){
        //play
    }
    
}
- (NSString *)stringForState:(NSInteger)state{
    NSString *str = @"";
    switch (state) {
        case   SYDownloadTaskStateAdded:
            str = @"已添加";
            break;
        case   SYDownloadTaskStateDownloading:
            str = @"下载中";
            break;
        case   SYDownloadTaskStateSuspend:
            str = @"暂停了";
            break;
        case   SYDownloadTaskStateWaiting:
            str = @"等待中";
            break;
        case   SYDownloadTaskStateFinshed:
            str = @"完成了";
            break;
        case   SYDownloadTaskStateFail:
            str = @"失败了";
            break;
    }
    return str;
}
- (void)queueTest{
    _ticketCont = 50;
    
    _queue = dispatch_queue_create("my.test.quque.ticketqueue", NULL);
    
    /*
     
     50 张火车票
     
     */
    self.lock = [[NSLock alloc]init];
    
    // Do any additional setup after loading the view, typically from a nib.
    //窗口1，每次只能进行一次的操作
    NSOperationQueue *queue1 = [[NSOperationQueue alloc]init];
    queue1.maxConcurrentOperationCount = 1;
    
    NSOperationQueue *queue2 = [[NSOperationQueue alloc]init];
    queue2.maxConcurrentOperationCount = 1;
    
    //卖票操作窗口1
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        //[self saleTicketNoSafeWithNum:1];
        
        [self saleTicketSafeWithNum:1];
    }];
    //卖票操作窗口1
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        // [self saleTicketNoSafeWithNum:2];
        [self saleTicketSafeWithNum:2];
    }];
    
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
 
}
- (void)saleTicketNoSafeWithNum:(NSInteger)num{
    while (1) {
        [self.lock lock];
        if (_ticketCont > 0) {
            _ticketCont --;
            NSLog(@"剩余票数:%ld 窗口:%ld",_ticketCont,num);
            [NSThread sleepForTimeInterval:0.5];
        }
        [self.lock unlock];
        if(_ticketCont <= 0){
            NSLog(@"票卖完了");
            break;
        }
    }
}

- (void)saleTicketSafeWithNum:(NSInteger)num{
    while (1) {
        NSInteger count = [self ticketCont];
        if (count > 0) {
            [self setTicketCont: --count];
             NSLog(@"剩余票数:%ld 窗口:%ld",count,num);
            [NSThread sleepForTimeInterval:0.2];
        }else{
            NSLog(@"票卖完了");
            break;
        }
    }
}
- (void)setTicketCont:(NSInteger)ticketCont{
    dispatch_sync(_queue, ^{
        _ticketCont = ticketCont;
    });
}
- (NSInteger)ticketCont{
    __block NSInteger count = 0;
    dispatch_sync(_queue, ^{
        count = _ticketCont;
    });
    return count;
}
@end
