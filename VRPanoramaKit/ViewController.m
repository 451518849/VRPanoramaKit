//
//  ViewController.m
//  VRPanoramaKit
//
//  Created by 小发工作室 on 2017/9/21.
//  Copyright © 2017年 小发工作室. All rights reserved.
//
#import "PanoramaController.h"
#import "ViewController.h"
#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) PanoramaController *panoVc;
@end

@implementation ViewController

- (UITableView *)tableView {
    
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (PanoramaController *)panoVc{
    
    if (_panoVc == nil) {
        _panoVc  = [[PanoramaController alloc] initWithImageName:@"park" type:@"jpg"];
        
    }
    return _panoVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.view addSubview:self.tableView];

    [self addChildViewController:self.panoVc];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    

    self.panoVc.view.frame = cell.frame;
    [cell addSubview:self.panoVc.view];
    
    
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
