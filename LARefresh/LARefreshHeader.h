//
//  LARefreshHeader.h
//  BigFan
//
//  Created by leo on 16/8/31.
//  Copyright © 2016年 QuanYan. All rights reserved.
//

#import "MJRefreshHeader.h"

typedef enum {
    BFRefreshHeaderStyleDefault        = 0,
    BFRefreshHeaderStyleAtTop          = 1,//图片置顶时，下拉放大图片刷新
}BFRefreshHeaderStyle;

@interface LARefreshHeader : MJRefreshHeader

+ (instancetype)bf_headerWithRefreshingAtTopBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock;

@end

//不随图片放大改变图片尺寸
static NSInteger bf_IgnoreSubViewTag = 1000002;

@interface UIScrollView (headerRefreshOnImage)
/** 下拉刷新控件 */
@property (strong, nonatomic) UIView                             *bf_header;

@property (assign, nonatomic) CGFloat                            bf_h;

@property (strong, nonatomic) UIImageView                        *gifView;

@property (assign, nonatomic) BOOL                               isRefreshing;

@property (strong, nonatomic) NSMutableDictionary                *params;

@property (copy,   nonatomic) MJRefreshComponentRefreshingBlock   refreshingBlock;

- (void)bf_beginRefreshing;
- (void)bf_endRefreshing;

- (void)removeObservers;
@end
