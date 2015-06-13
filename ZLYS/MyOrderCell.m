//
//  MyOrderCell.m
//  WHDLife
//
//  Created by Seven on 15-1-28.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "MyOrderCell.h"
#import "OrderCommodityCell.h"
#import "CommodityDetailView.h"
#import "UIImageView+WebCache.h"
#import "MyOrderCommodity.h"

@implementation MyOrderCell
{
    NSMutableArray *commoditys;
    int rowIndex;
    MyOrder *cellOrder;
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

- (void)loadShopCommoditys:(MyOrder *)order andRow:(int)indexRow
{
    rowIndex = indexRow;
    cellOrder = order;
    commoditys = order.commodityObjectList;
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
    OrderCommodityCell *cell = [tableView dequeueReusableCellWithIdentifier:OrderCommodityCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"OrderCommodityCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[OrderCommodityCell class]]) {
                cell = (OrderCommodityCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    MyOrderCommodity *item = [commoditys objectAtIndex:row];
    cell.priceLb.text = [NSString stringWithFormat:@"单价:￥%0.2f", item.price];
    cell.nameLb.text = item.commodityName;
    cell.properyLb.text = item.skuName;
    cell.numberLb.text = [NSString stringWithFormat:@"数量:%d", item.num];
    NSString *imageUrl = [NSString stringWithFormat:@"%@_200",item.imgUrlFull];
    [cell.imageIv sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"loadpic.png"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyOrderCommodity *item = [commoditys objectAtIndex:[indexPath row]];
    CommodityDetailView *detailView = [[CommodityDetailView alloc] init];
    detailView.commodityId = item.commodityId;
    [self.navigationController pushViewController:detailView animated:YES];
}

@end
