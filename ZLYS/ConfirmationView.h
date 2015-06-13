//
//  ConfirmationView.h
//  WHDLife
//
//  Created by Seven on 15-1-20.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmationView : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (copy, nonatomic) NSMutableArray *commodityItems;
@property bool fromShopCar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *totalLb;

@property (weak, nonatomic) IBOutlet UITextField *recipientsTf;
@property (weak, nonatomic) IBOutlet UITextField *telphoneTf;
@property (weak, nonatomic) IBOutlet UITextView *addressTv;
@property (weak, nonatomic) IBOutlet UITextView *remarkTv;
- (IBAction)doOrder:(id)sender;

@end
