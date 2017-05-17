//
//  BFRefreshHeader.m
//  BigFan
//
//  Created by leo on 16/8/31.
//  Modify  by wans on 16/11/23.
//  Copyright © 2016年 QuanYan. All rights reserved.
//

#import "LARefreshHeader.h"

#define  BF_SCREEN_WIDTH                                        ([UIScreen mainScreen].bounds.size.width)
#define  BF_SCREEN_HEIGHT                                       ([UIScreen mainScreen].bounds.size.height)
#define  CONTENVIEW_HEIGH  54.0f
#define  SLOGANVIEW_HEIGH  45.0f

@interface LARefreshHeader()

/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;
/** 所有状态对应的动画时间 */
@property (strong, nonatomic) NSMutableDictionary *stateDurations;

@property (strong, nonatomic) UIView              *contentView;
@property (strong, nonatomic) UIImageView         *gifView;
@property (strong, nonatomic) UILabel             *stateLabel;

@property (assign, nonatomic) BOOL                isFirstRefesh;
@property (assign, nonatomic) BFRefreshHeaderStyle style;

@end

@implementation LARefreshHeader

- (instancetype)initWithStyle:(BFRefreshHeaderStyle)style {
    self = [super init];
    if ( self ) {
        self.style = style;
    }
    return self;
}

+ (instancetype)bf_headerWithRefreshingAtTopBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock {
    LARefreshHeader *cmp = [[LARefreshHeader alloc] initWithStyle:BFRefreshHeaderStyleAtTop];
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}

#pragma mark - 公共方法
- (void)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(MJRefreshState)state {
    if (images == nil) return;
    
    self.stateImages[@(state)] = images;
    self.stateDurations[@(state)] = @(duration);
}

- (void)setImages:(NSArray *)images forState:(MJRefreshState)state {
    [self setImages:images duration:images.count * 0.1 forState:state];
}

/**
 设置滑动进度
 
 @param pullingPercent 进度
 */
- (void)setPullingPercent:(CGFloat)pullingPercent {
    [super setPullingPercent:pullingPercent];
    
//    NSArray *images = self.stateImages[@(MJRefreshStateRefreshing)];
    if ( self.style == BFRefreshHeaderStyleDefault ) {
        NSArray *images = self.stateImages[@(MJRefreshStatePulling)];
        if( pullingPercent <= 1){
            self.gifView.image = images.firstObject;
        }else if ( pullingPercent > 1 && pullingPercent < 2) {
            NSInteger index = (pullingPercent - 1) * images.count;
            self.gifView.image = images[index];
        }else if ( pullingPercent > 2 ){
            self.gifView.image = images.lastObject;
        }
    }
}

#pragma mark - 实现父类的方法

static NSMutableArray *pullingImages;
static NSMutableArray *refreshingImages;

/**
 初始化
 */
- (void)prepare{
    [super prepare];
    
    self.mj_h = CONTENVIEW_HEIGH;
    
    if ( pullingImages && refreshingImages ) {
        
        [self setImages:[pullingImages mutableCopy] duration:1.5 forState:MJRefreshStatePulling];
        [self setImages:[refreshingImages mutableCopy] duration:1.18 forState:MJRefreshStateRefreshing];

        return ;
    }

    [self loadImagesFromBundle:nil];
    
}

/**
 加载图片资源
 
 @param finishBlock 加载完成回调
 */
- (void)loadImagesFromBundle:(void(^)())finishBlock {

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        @synchronized ( self ) {
    
            //即将刷新图片
            NSMutableArray *tempArray = [NSMutableArray array];
            
            int i = 0;
            UIImage *image;
            while ( image = [UIImage imageNamed:[NSString stringWithFormat:@"LARefresh.bundle/l_red_0%02d",i]] ) {
                [tempArray addObject:image];
                i++;
            }
            
            pullingImages = [tempArray mutableCopy];
            
            [self setImages:pullingImages duration:1.5 forState:MJRefreshStatePulling];
            
            //正在刷新图片
            [tempArray removeAllObjects];
            i = 0;
            while ( image = [UIImage imageNamed:[NSString stringWithFormat:@"LARefresh.bundle/loading_red_s_0%02d",i]] ) {
                [tempArray addObject:image];
                i++;
            }
            
            refreshingImages = [tempArray mutableCopy];
            
            [self setImages:refreshingImages duration:1.18 forState:MJRefreshStateRefreshing];
            
//        }
    
//        dispatch_sync(dispatch_get_main_queue(), ^{
//           if ( finishBlock ) {
//               finishBlock();
//           }
//        });
//        
//    });

}

- (void)beginRefreshing {
    
//    if ( pullingImages && refreshingImages ) {
        [super beginRefreshing];
//        return;
//    }
    
//    [self loadImagesFromBundle:^{
        [super beginRefreshing];
//    }];

}

/**
 摆放子控件frame
 */
- (void)placeSubviews{
    [super placeSubviews];
    
    if ( self.style == BFRefreshHeaderStyleAtTop ) {
        self.gifView.center = self.contentView.center;
        [self bringSubviewToFront:self.contentView];
        self.stateLabel.hidden = YES;
    }else{
//        self.gifView.center = self.contentView.center;
//        CGRect gframe = self.gifView.frame;
//        gframe.origin.x -= 20;
//        self.gifView.frame = gframe;
//        
//        self.stateLabel.center = self.contentView.center;
//        CGRect sframe = self.stateLabel.frame;
//        sframe.origin.x = CGRectGetMaxX(self.gifView.frame) + 10;
//        self.stateLabel.frame = sframe;
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

- (void)setState:(MJRefreshState)state{
    MJRefreshCheckState
    NSArray *images = self.stateImages[@(state)];
    switch ( state ) {
        case MJRefreshStateIdle:
            if ( self.style == BFRefreshHeaderStyleDefault ){
                if ( !self.isFirstRefesh ) {
                    [self.gifView stopAnimating];
                    [self setCenterLabelWithText: @"下拉刷新"];
                }else{
                    self.isFirstRefesh = NO;
                    MJWeakSelf
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf setCenterLabelWithText: @"下拉刷新"];
                        [weakSelf.gifView stopAnimating];
                    });
                }
            }else if ( self.style == BFRefreshHeaderStyleAtTop ) {
                [self.gifView stopAnimating];
                self.gifView.hidden = YES;
            }
            
            break;
        case MJRefreshStatePulling:
        {
            if ( self.style == BFRefreshHeaderStyleDefault ){
                [self.gifView stopAnimating];
                
                [self setCenterLabelWithText: @"松开看看"];
            }else if ( self.style == BFRefreshHeaderStyleAtTop ) {
                [self.gifView stopAnimating];
                self.gifView.hidden = YES;
            }
        }
            break;
        case MJRefreshStateRefreshing:
        {
            self.gifView.animationImages = images;
            self.gifView.animationDuration = [self.stateDurations[@(state)] doubleValue];
            [self.gifView startAnimating];
            
            if ( self.style == BFRefreshHeaderStyleDefault ){
                self.isFirstRefesh = YES;
                
                [self setCenterLabelWithText: @"正在刷新"];
            }else if ( self.style == BFRefreshHeaderStyleAtTop ) {
                MJWeakSelf
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.gifView.hidden = NO;
                });
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 公共方法
- (void)endRefreshing {
    
    if ( self.scrollView.mj_offsetY == 0 ) {
        return;
    }
    
    if ( self.style == BFRefreshHeaderStyleDefault && self.isFirstRefesh ) {
        [self setCenterLabelWithText: @"刷新成功"];
    }
    
    CGFloat animationDuration = 0.5;
    if ( self.scrollView.mj_offsetY != -self.mj_h ) {
        animationDuration = 1.0;
    }
    
    MJWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.state = MJRefreshStateIdle;
    });
    
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change {
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change {
    [super scrollViewPanStateDidChange:change];
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
        [self.contentView addSubview:_stateLabel];
    }
    return _stateLabel;
}

@end

@implementation UIScrollView (headerRefreshOnImage)

#pragma mark - header
static const char BFRefreshHeaderKey = '0';
static const char BFRefreshingKey = '1';
static const char BFRefreshGifViewKey = '2';
static const char BFRefreshImagesKey = '3';
static const char BFRefreshBlockKey = '4';
static const char BFRefreshHeightKey = '5';
static const char BFRefreshParamsKey = '6';

static NSMutableArray *gifImages;

- (void)setBf_header:(UIView *)bf_header
{
    if ( !bf_header ) {
        [self removeObservers];
        
        return;
    }
    
    if (bf_header != self.bf_header) {
        // 删除旧的，添加新的
        if ( self.bf_header ) {
            [self.bf_header removeFromSuperview];
            
            [self removeObservers];
        }
        
        [self addSubview:bf_header];
        
        CGFloat headerHeight = CGRectGetHeight(bf_header.frame);
        self.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
        
        //设置放大区域高度
        self.bf_h = headerHeight;
        
        //获取子控件原始frame
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for (int i = 0; i < bf_header.subviews.count; i++) {
            UIView *subView = bf_header.subviews[i];
            tempDic[@(i)] = NSStringFromCGRect(subView.frame);
        }
        self.params = tempDic;
        
        UIImageView *_gifView = [[UIImageView alloc] init];
        _gifView.backgroundColor = [UIColor clearColor];
        _gifView.contentMode = UIViewContentModeCenter;
        _gifView.animationDuration = 1.18;
        _gifView.frame = CGRectMake((CGRectGetWidth(self.bf_header.frame) - 24)/2 + 2, 40 + 5, 24, 24);
        self.gifView = _gifView;
        
        if ( gifImages ) {
            
            self.gifView.animationImages = [gifImages mutableCopy];

        }else {
        
            NSMutableArray *tempArray = [NSMutableArray array];
            
            int i = 0;
            UIImage *image;
            while ( image = [UIImage imageNamed:[NSString stringWithFormat:@"LARefresh.bundle/loading_white_s_0%02d",i]] ) {
                [tempArray addObject:image];
                i++;
            }
            
            gifImages = [tempArray mutableCopy];
            
            self.gifView.animationImages = gifImages;
        }

        [bf_header addSubview:self.gifView];

        [self addObservers];
        // 存储新的
        [self willChangeValueForKey:@"mj_header"]; // KVO
        objc_setAssociatedObject(self, &BFRefreshHeaderKey,
                                 bf_header, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"mj_header"]; // KVO
    }
}

- (void)bf_beginRefreshing{
    self.gifView.alpha = 1.f;
    [self.gifView startAnimating];
    
    if ( self.refreshingBlock ) {
        self.refreshingBlock ();
    }
}

- (void)bf_endRefreshing{
    [UIView animateWithDuration:0.3f animations:^{
        self.gifView.alpha = .0f;
    } completion:^(BOOL finished) {
        [self.gifView stopAnimating];
        self.isRefreshing = NO;
    }];
}

- (MJRefreshComponentRefreshingBlock )refreshingBlock {
    return objc_getAssociatedObject(self, &BFRefreshBlockKey);

}
- (void)setRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock{
    objc_setAssociatedObject(self, &BFRefreshBlockKey,
                             refreshingBlock, OBJC_ASSOCIATION_COPY);
}

#pragma mark - KVO监听
- (void)addObservers
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self addObserver:self forKeyPath:MJRefreshKeyPathContentOffset options:options context:nil];
}

- (void)removeObservers
{
    [self removeObserver:self forKeyPath:MJRefreshKeyPathContentOffset];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled) return;
    
    // 看不见
    if (self.hidden) return;
    if ([keyPath isEqualToString:MJRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    }
}

#pragma mark Private Method

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    CGPoint old = [change[@"old"] CGPointValue];
    CGPoint new = [change[@"new"] CGPointValue];
//    NSLog(@"scrollViewContentOffsetDidChange offset >> %f",new.y);

    [self zoomWhenOffsetDidChange:new];

    if ( !self.isRefreshing && new.y < -(self.bf_h + 64) && new.y > old.y ) {
//        NSLog(@"开始下拉刷新 offset >> %f",new.y);

        self.isRefreshing = YES;
        [self bf_beginRefreshing];
    }
    
    self.gifView.frame = CGRectMake((CGRectGetWidth(self.bf_header.frame) - 24)/2 + 2, 40 + 5, 24, 24);;
}

/**
 放大图片

 @param point scrollview的偏移量
 */
- (void)zoomWhenOffsetDidChange:(CGPoint)point{
    CGFloat yoffset = point.y;
    CGFloat imageOriginalHeight = self.bf_h;
    CGFloat imageOriginalWidth = self.frame.size.width;

    CGFloat xoffset = ( imageOriginalHeight + yoffset ) / 2 ;
    if ( yoffset < -imageOriginalHeight ) {
        CGRect rect = self.bf_header.frame;
        rect.origin.y = yoffset;
        rect.size.height = -yoffset;
        rect.origin.x = xoffset;
        rect.size.width = imageOriginalWidth + fabs(xoffset) * 2;
        self.bf_header.frame = rect;
        
        for (int i = 0; i < self.bf_header.subviews.count; i++) {
            UIView *subView = self.bf_header.subviews[i];
            if ( subView.tag != bf_IgnoreSubViewTag ) {
                CGRect originalFrame = CGRectFromString(self.params[@(i)]);
                
                CGRect frame = subView.frame;
                frame.origin.x = fabs(xoffset);
                frame.origin.y = fabs(yoffset) - imageOriginalHeight + CGRectGetMinY(originalFrame);
                subView.frame = frame;
            }else{
                subView.frame = self.bf_header.bounds;
            }
        }
    }
}

#pragma mark Setter && Getter

- (void)setBf_h:(CGFloat)bf_h {
    objc_setAssociatedObject(self, &BFRefreshHeightKey,
                             @(bf_h), OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)bf_h
{
    return [objc_getAssociatedObject(self, &BFRefreshHeightKey) floatValue];
}

- (void)setParams:(NSMutableDictionary *)params{
    objc_setAssociatedObject(self, &BFRefreshParamsKey,
                             params, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableDictionary *)params{
    return objc_getAssociatedObject(self, &BFRefreshParamsKey);
}

- (UIView *)bf_header
{
    return objc_getAssociatedObject(self, &BFRefreshHeaderKey);
}

- (void)setIsRefreshing:(BOOL)isRefreshing {
    objc_setAssociatedObject(self, &BFRefreshingKey,
                             @(isRefreshing), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isRefreshing{
    return [objc_getAssociatedObject(self, &BFRefreshingKey) boolValue];
}

- (void)setGifView:(UIImageView *)gifView{
    objc_setAssociatedObject(self, &BFRefreshGifViewKey,
                             gifView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIImageView *)gifView {
    return objc_getAssociatedObject(self, &BFRefreshGifViewKey);
}
@end
