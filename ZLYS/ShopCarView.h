//
//  ShopCarView.h
//  WHDLife
//
//  Created by Seven on 15-1-18.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopCarView : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
{
    NSMutableArray *shopData;
    float total;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *checkAllView;
@property (weak, nonatomic) IBOutlet UILabel *totalLb;

@property (weak, nonatomic) IBOutlet UIButton *balanceBtn;
- (IBAction)balanceAction:(id)sender;

@end
