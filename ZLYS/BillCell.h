//
//  BillCell.h
//  WHDLife
//
//  Created by Seven on 15-1-21.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *nofeeIv;
@property (weak, nonatomic) IBOutlet UILabel *billNameLb;
@property (weak, nonatomic) IBOutlet UILabel *totalMoneyLb;
@property (weak, nonatomic) IBOutlet UILabel *totalFeeLb;

@end
