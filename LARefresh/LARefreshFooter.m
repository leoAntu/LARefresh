//
//  BFRefreshFooter.m
//  Pods
//
//  Created by leo on 16/11/24.
//
//

#import "LARefreshFooter.h"

#define  BF_SCREEN_WIDTH                                        ([UIScreen mainScreen].bounds.size.width)
#define  BF_SCREEN_HEIGHT                                       ([UIScreen mainScreen].bounds.size.height)
#define  CONTENVIEW_HEIGH  60.0f
#define  SLOGANVIEW_HEIGH  45.0f

typedef NS_ENUM(NSUInteger, BFRefreshState) {
    BFRefreshStateDidRefresh = 6,//收起加载更多
};

@interface LARefreshFooter()

/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;
/** 所有状态对应的动画时间 */
@property (strong, nonatomic) NSMutableDictionary *stateDurations;

@property (strong, nonatomic) UIView              *contentView;
@property (strong, nonatomic) UIImageView         *gifView;
@property (strong, nonatomic) UILabel             *stateLabel;

@end

@implementation LARefreshFooter

#pragma mark - 公共方法
- (void)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(MJRefreshState)state{
    if (images == nil) return;
    
    self.stateImages[@(state)] = images;
    self.stateDurations[@(state)] = @(duration);
}

- (void)setImages:(NSArray *)images forState:(MJRefreshState)state{
    [self setImages:images duration:images.count * 0.1 forState:state];
}

#pragma mark - 实现父类的方法
/**
 初始化
 */
- (void)prepare
{
    [super prepare];
    self.mj_h = CONTENVIEW_HEIGH;
    
    self.triggerAutomaticallyRefreshPercent = 0.5f;
    
    self.scrollView.mj_insetB = CONTENVIEW_HEIGH;

    /**
     *  正在刷新图片
     */
    
    static NSMutableArray *gifImages;
    
    if ( gifImages ) {
        
        [self setImages:[gifImages mutableCopy] duration:1.18 forState:MJRefreshStateRefreshing];
        
        return ;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //即将刷新图片
        NSMutableArray *tempArray = [NSMutableArray array];
        
        int i = 0;
        UIImage *image;
        while ( image = [UIImage imageNamed:[NSString stringWithFormat:@"LARefresh.bundle/loading_gray_0%02ld",i]] ) {
            [tempArray addObject:image];
            i++;
        }
        
        gifImages = [tempArray mutableCopy];
        
        [self setImages:gifImages duration:1.18 forState:MJRefreshStateRefreshing];
        
    });
    
}

/**
 摆放子控件frame
 */
- (void)placeSubviews
{
    [super placeSubviews];

    if ( self.state != MJRefreshStateNoMoreData ) {
        self.stateLabel.frame = CGRectMake(24 + 10, 0, 100, CONTENVIEW_HEIGH);
    }else{
        self.stateLabel.frame = self.contentView.bounds;
    }
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    NSArray *images = self.stateImages[@(state)];
    switch ( state ) {
        case MJRefreshStateRefreshing:
        {
            self.scrollView.mj_insetB = CONTENVIEW_HEIGH;

            self.gifView.animationImages = images;
            self.gifView.animationDuration = [self.stateDurations[@(state)] doubleValue];
            [self.gifView startAnimating];
        
            self.stateLabel.textAlignment = NSTextAlignmentLeft;
            [self setCenterLabelWithText:@"正在加载..."];
        }
            break;
        case MJRefreshStateNoMoreData:
        {
            MJWeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [UIView animateWithDuration:.5f animations:^{
                    weakSelf.scrollView.mj_insetB = 0;
               }];
            });

            [self.gifView stopAnimating];
            
            self.stateLabel.textAlignment = NSTextAlignmentCenter;
            [self setCenterLabelWithText:@"无更多内容"];
        }
            break;
        case BFRefreshStateDidRefresh:
        {
            super.state = MJRefreshStateIdle;
        }
            break;
        case MJRefreshStateIdle:
        {
            MJWeakSelf
            [UIView animateWithDuration:.5f animations:^{
                weakSelf.scrollView.mj_insetB = 0;
            }completion:^(BOOL finished) {
                weakSelf.gifView.hidden = YES;
                [weakSelf.gifView stopAnimating];
            }];
        }
            break;
        default:
            break;
    }
}


/**
 设置图片 文字居中

 @param text 文字
 */
- (void)setCenterLabelWithText:(NSString *)text {
    self.stateLabel.text = text;
    
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:self.stateLabel.font}];
    CGFloat contentWidth = size.width + 24 + 10;
    
    self.stateLabel.frame = CGRectMake(24 + 10, 0, size.width + 2, CONTENVIEW_HEIGH);
    self.contentView.frame = CGRectMake((BF_SCREEN_WIDTH - contentWidth)/2, 0, contentWidth, CONTENVIEW_HEIGH);
}

#pragma mark - 公共方法
- (void)endRefreshingWithNoMoreData
{
    MJWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.state = MJRefreshStateNoMoreData;
    });
}


/**
 高度变化回调

 @param change
 */
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
    // 内容的高度
    CGFloat contentHeight = self.scrollView.mj_contentH + self.ignoredScrollViewContentInsetBottom;
    // 表格的高度
    CGFloat scrollHeight = self.scrollView.mj_h - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom + self.ignoredScrollViewContentInsetBottom;
    // 设置位置和尺寸
    if ( contentHeight < scrollHeight ) {
        self.stateLabel.hidden = YES;
        self.gifView.hidden = YES;
    }else{
        self.stateLabel.hidden = NO;
        self.gifView.hidden = NO;
    }
}

- (void)resetNoMoreData {
    self.state = BFRefreshStateDidRefresh;

}

#pragma mark - getter setter
- (UIView *)contentView {
    if( !_contentView ){
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];

    }
    return _contentView;
}

- (UIImageView *)gifView {
    if (!_gifView) {
        _gifView = [[UIImageView alloc] init];
        _gifView.backgroundColor = [UIColor clearColor];
        _gifView.contentMode = UIViewContentModeCenter;
        _gifView.frame = CGRectMake(0, (CONTENVIEW_HEIGH - 24)/2, 24, 24);
        [self.contentView addSubview:_gifView];
    }
    return _gifView;
}

- (NSMutableDictionary *)stateImages {
    if (!_stateImages) {
        _stateImages = [NSMutableDictionary dictionary];
    }
    return _stateImages;
}

- (NSMutableDictionary *)stateDurations {
    if (!_stateDurations) {
        _stateDurations = [NSMutableDictionary dictionary];
    }
    return _stateDurations;
}

- (UILabel *)stateLabel {
    if( !_stateLabel ){
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont systemFontOfSize:12.f];
        _stateLabel.textColor = [UIColor lightGrayColor];
        _stateLabel.textAlignment = NSTextAlignmentLeft;
        _stateLabel.backgroundColor = [UIColor clearColor];
        _stateLabel.hidden = YES;
        [self.contentView addSubview:_stateLabel];
    }
    return _stateLabel;
}

@end
