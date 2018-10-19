//
//  DownloadTableViewCell.h
//  Downloader
//
//  Created by 高春阳 on 2018/3/19.
//  Copyright © 2018年 gao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *__nullable nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *__nullable stateLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *__nullable progress;
@end
