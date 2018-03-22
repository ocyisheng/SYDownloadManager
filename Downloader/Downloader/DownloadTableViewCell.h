//
//  DownloadTableViewCell.h
//  Downloader
//
//  Created by 高春阳 on 2018/3/19.
//  Copyright © 2018年 gao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@end
