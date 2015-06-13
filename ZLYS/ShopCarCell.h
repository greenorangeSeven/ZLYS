//
//  ShopCarCell.h
//  WHDLife
//
//  Created by Seven on 15-1-18.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopCar.h"

@interface ShopCarCell : UITableViewCell<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *shopName;
@property (weak, nonatomic) IBOutlet UITableView *commodityTable;
@property (weak, nonatomic) IBOutlet UIView *subTotalView;
@property (weak, nonatomic) IBOutlet UILabel *subTotalLb;

- (void)loadShopCommoditys:(ShopCar *)shopCar andRow:(int)indexRow;

@end
