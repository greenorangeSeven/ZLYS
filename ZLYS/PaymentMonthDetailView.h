//
//  PaymentMonthDetailView.h
//  BBK
//
//  Created by Seven on 14-12-20.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentMonthDetailView : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *items;
}

@property (weak, nonatomic) NSString *month;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
