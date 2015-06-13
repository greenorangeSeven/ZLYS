//
//  Bill.h
//  WHDLife
//
//  Created by Seven on 15-1-21.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bill : NSObject

@property (nonatomic, retain) NSString *billId;
@property (nonatomic, retain) NSString *billName;
@property (nonatomic, retain) NSString *detailsId; //订单ID用于支付
@property double totalMoney; //应付
@property double totalFee;  //支付宝反馈用户实际支付金额
@property int stateId;  //0未缴，1已缴

@end
