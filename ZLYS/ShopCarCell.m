//
//  ShopCarCell.m
//  WHDLife
//
//  Created by Seven on 15-1-18.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "ShopCarCell.h"
#import "ShopCarItem.h"
#import "ShopCarItemCell.h"
#import "SSCheckBoxView.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"
#import "UIImageView+WebCache.h"

@implementation ShopCarCell
{
    NSMutableArray *commoditys;
    int rowIndex;
    ShopCar *cellShop;
}

- (void)awakeFromNib {
    self.commodityTable.dataSource = self;
    self.commodityTable.delegate = self;
    self.commodityTable.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.commodityTable.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)loadShopCommoditys:(ShopCar *)shopCar andRow:(int)indexRow
{
    rowIndex = indexRow;
    cellShop = shopCar;
    commoditys = shopCar.commodityList;
    [self.commodityTable reloadData];
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return commoditys.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShopCarItemCell *cell = [tableView dequeueReusableCellWithIdentifier:ShopCarItemCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ShopCarItemCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[ShopCarItemCell class]]) {
                cell = (ShopCarItemCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    ShopCarItem *item = [commoditys objectAtIndex:row];
    cell.priceLb.text = [NSString stringWithFormat:@"￥%0.2f", item.price];
    cell.nameLb.text = item.name;
    cell.properyLb.text = item.properyStr;
    cell.numberTf.text = [NSString stringWithFormat:@"%d", item.number];
    NSString *imageUrl = [NSString stringWithFormat:@"%@_200",item.imagefull];
    [cell.imageIv sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"loadpic.png"]];
    
    [cell.delBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.delBtn.tag = row;
    
    if (item.number <= 1) {
        cell.minBtn.enabled = NO;
    }
    else
    {
        cell.minBtn.enabled = YES;
    }
    [cell.minBtn addTarget:self action:@selector(minusAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.minBtn.tag = row;
    
    [cell.addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.addBtn.tag = row;
    
    SSCheckBoxView *cb = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(2, 20, 30, 30) style:kSSCheckBoxViewStyleGlossy checked:[item.ischeck isEqualToString:@"1"]];
    [cb setStateChangedBlock:^(SSCheckBoxView *cbv) {
        if (cbv.checked) {
            FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
            if (![database open]) {
                NSLog(@"Open database failed");
                return;
            }
            if (![database tableExists:@"shoppingcar"]) {
                [database executeUpdate:createshoppingcar];
            }
            
            [database executeUpdate:@"update shoppingcar set ischeck = '1' where id= ?", [NSNumber numberWithInt:item.dbid]];
            item.ischeck = @"1";
            [database close];
        }
        else
        {
            FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
            if (![database open]) {
                NSLog(@"Open database failed");
                return;
            }
            if (![database tableExists:@"shoppingcar"]) {
                [database executeUpdate:createshoppingcar];
            }
            
            [database executeUpdate:@"update shoppingcar set ischeck = '0' where id= ?", [NSNumber numberWithInt:item.dbid]];
            item.ischeck = @"0";
            [database close];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_RefreshShopCarTable object:nil];
    }];
    [cell addSubview:cb];
    
    return cell;
}

- (IBAction)minusAction:(id)sender {
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        ShopCarItem *item = [commoditys objectAtIndex:tap.tag];
        
        FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
        if (![database open]) {
            NSLog(@"Open database failed");
            return;
        }
        if (![database tableExists:@"shoppingcar"]) {
            [database executeUpdate:createshoppingcar];
        }
        BOOL updateItem = [database executeUpdate:@"update shoppingcar set number = number - 1 where id= ?", [NSNumber numberWithInt:item.dbid]];
        [database close];
        if (updateItem) {
            item.number -= 1;
            cellShop.commodityCount -= 1;
            cellShop.total -= item.price;
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_RefreshShopCarTable object:nil];
        }
    }
}

- (IBAction)addAction:(id)sender {
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        ShopCarItem *item = [commoditys objectAtIndex:tap.tag];
        
        FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
        if (![database open]) {
            NSLog(@"Open database failed");
            return;
        }
        if (![database tableExists:@"shoppingcar"]) {
            [database executeUpdate:createshoppingcar];
        }
        BOOL updateItem = [database executeUpdate:@"update shoppingcar set number = number + 1 where id= ?", [NSNumber numberWithInt:item.dbid]];
        [database close];
        if (updateItem) {
            item.number += 1;
            cellShop.commodityCount += 1;
            cellShop.total += item.price;
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_RefreshShopCarTable object:nil];
        }
    }
}

- (IBAction)deleteAction:(id)sender {
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        ShopCarItem *item = [commoditys objectAtIndex:tap.tag];
        
        FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
        if (![database open]) {
            NSLog(@"Open database failed");
            return;
        }
        if (![database tableExists:@"shoppingcar"]) {
            [database executeUpdate:createshoppingcar];
        }
        BOOL detele = [database executeUpdate:@"delete from shoppingcar where id = ?", [NSNumber numberWithInt:item.dbid]];
        [database close];
        if (detele) {
            [commoditys removeObjectAtIndex:tap.tag];
            if ([commoditys count] == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_RefreshShopCarTable object:[NSString stringWithFormat:@"%d", rowIndex]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_RefreshShopCarTable object:nil];
        }
    }
}

@end
