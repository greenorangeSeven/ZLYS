//
//  MyOrderCell.h
//  WHDLife
//
//  Created by Seven on 15-1-28.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyOrder.h"

@interface MyOrderCell : UITableViewCell<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UINavigationController *navigationController;

@property (weak, nonatomic) IBOutlet UILabel *orderNumberLb;
@property (weak, nonatomic) IBOutlet UILabel *stateNameLb;
@property (weak, nonatomic) IBOutlet UILabel *receivingInfoLb;
@property (weak, nonatomic) IBOutlet UILabel *receivingAddressLb;
@property (weak, nonatomic) IBOutlet UIButton *payOrderBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeOrderBtn;
@property (weak, nonatomic) IBOutlet UILabel *shopName;
@property (weak, nonatomic) IBOutlet UITableView *commodityTable;
@property (weak, nonatomic) IBOutlet UIView *subTotalView;
@property (weak, nonatomic) IBOutlet UILabel *subTotalLb;

- (void)loadShopCommoditys:(MyOrder *)order andRow:(int)indexRow;

@end
