//
//  ViewController.m
//  Demo
//
//  Created by leo on 2017/5/17.
//  Copyright © 2017年 leo. All rights reserved.
//

#import "ViewController.h"
#import "LARefreshHeader.h"
#import "LARefreshFooter.h"

#define LAWeakSelf __weak typeof(self) weakSelf = self;

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger pageNum;  //分页参数
@property (nonatomic, assign) NSInteger rows;  //模拟table 行数

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.rows = 20;
    [self createTableView];
//    [self.tableView.mj_header beginRefreshing];
}

- (void)loadData {
    
    // 模拟网络加载成功,延迟3s调用,
    LAWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.rows += 10;
        if (weakSelf.pageNum == 0) {
            [weakSelf.tableView.mj_header endRefreshing];
        } else if (weakSelf.pageNum > 0) {
            [weakSelf.tableView.mj_footer resetNoMoreData]; //footer为自动加载，当数据没有完全加载完不能使用endRefreshing
        }
        
        //假设数据已经全部加载完
        if (weakSelf.rows > 60) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];  //当数据加载完了，显示已经没数据加载。
        }
        
        [weakSelf.tableView reloadData];
    });
    
    //网络 出错情况为：
//    if (self.pageNum > 0) {
//        [self.tableView.mj_footer endRefreshing];
//        self.pageNum--;
//    }else {
//        [self.tableView.mj_header endRefreshing];
//    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return .01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}

- (void)createTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    LAWeakSelf
    self.tableView.mj_header = [LARefreshHeader headerWithRefreshingBlock:^{
        weakSelf.pageNum = 0;
        weakSelf.rows = 20;
        weakSelf.tableView.mj_footer.state = MJRefreshStateIdle;
        [weakSelf loadData];
    }];
    self.tableView.mj_footer = [LARefreshFooter footerWithRefreshingBlock:^{
        weakSelf.pageNum++;
        [weakSelf loadData];
    }];
}


@end
