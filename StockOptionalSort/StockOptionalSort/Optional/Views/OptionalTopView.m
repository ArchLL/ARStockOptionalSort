//
//  OptionalTopView.m
//  TopMaster
//
//  Created by 中资北方 on 2017/6/5.
//  Copyright © 2017年 sun. All rights reserved.
//

#import "OptionalTopView.h"

#define leftButtonWidth 80
#define rightUnitViewWidth 100 //右边scrollView内部单元view的宽度

@interface OptionalTopView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIButton *lastClickButton;//上一次点击的Button(右边菜单栏的button);
@property (nonatomic, assign) BOOL isShowRightBtnImage;//是否显示右边菜单栏对应button的image

@end

@implementation OptionalTopView

- (UIButton *)lastClickButton {
    if (!_lastClickButton) {
        _lastClickButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    }
    return _lastClickButton;
}

- (instancetype)initWithFrame:(CGRect)frame withTitles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.isShowRightBtnImage = NO;
        self.backgroundColor = [UIColor whiteColor];
        //上分割线
        UIView *upline = [[UIView alloc]init];
        upline.backgroundColor = CellSeparator_Color;
        [self addSubview:upline];
        [upline mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self).offset(0);
            make.top.equalTo(self).offset(2);
            make.height.mas_offset(1);
        }];
        
        //左边部分 编辑按钮
        UIButton *editBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        editBtn.tag = 1000;
        editBtn.backgroundColor = [UIColor whiteColor];
        [editBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        //设置右视图
        [editBtn setImage:[UIImage imageNamed:@"Optional_edit"] forState:(UIControlStateNormal)];
        [editBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
        [editBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
        [editBtn addTarget:self action:@selector(buttonClick:) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:editBtn];
        [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self).offset(3);
            make.bottom.equalTo(self).offset(-3);
            make.width.mas_equalTo(leftButtonWidth);
        }];
        //取消排序按钮
        UIButton *cancelSortBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [cancelSortBtn setTitle:@"取消排序" forState:UIControlStateNormal];
        cancelSortBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        cancelSortBtn.tag = 1001;
        cancelSortBtn.backgroundColor = kRGB(115, 202, 245);
        [cancelSortBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [cancelSortBtn addTarget:self action:@selector(buttonClick:) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:cancelSortBtn];
        cancelSortBtn.hidden = YES;
        [cancelSortBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self).offset(3);
            make.bottom.equalTo(self).offset(-3);
            make.width.mas_equalTo(leftButtonWidth);
        }];

        //右边部分
        self.rightScrollView = [[UIScrollView alloc]init];
        _rightScrollView.backgroundColor = [UIColor whiteColor];
        _rightScrollView.contentSize = CGSizeMake(rightUnitViewWidth * titles.count, 0);
        _rightScrollView.showsHorizontalScrollIndicator = NO;
        _rightScrollView.delegate = self;
        [self addSubview:_rightScrollView];
        [_rightScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(leftButtonWidth + 10);
            make.top.equalTo(self).offset(3);
            make.right.equalTo(self.mas_right).offset(0);
            make.bottom.equalTo(self.mas_bottom).offset(-3);
        }];
        
        //在右边的scrollView上添加单元view
        for (int i = 0; i < titles.count; i++) {
            UIView * unitView = [[UIView alloc]init];
            unitView.backgroundColor = [UIColor whiteColor];
            unitView.frame = CGRectMake(i*rightUnitViewWidth, 0, rightUnitViewWidth, frame.size.height - 6);
            unitView.backgroundColor = [UIColor whiteColor];
            [_rightScrollView addSubview:unitView];
            
            //在unitView上创建button和右分割线
            UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            btn.tag = 100 + i;
            btn.backgroundColor = [UIColor whiteColor];
            [btn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
            //设置右视图
            [btn setImage:[UIImage imageNamed:@"Optional_blank"] forState:(UIControlStateNormal)];
            //计算title的宽度
            CGFloat titleWidth = [self getWidthWithContent:titles[i] height:20 font:15];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
            if (titleWidth > 40) {
                [btn setImageEdgeInsets:UIEdgeInsetsMake(0, (rightUnitViewWidth - titleWidth)/2 + titleWidth, 0, 0)];
            }else{
                [btn setImageEdgeInsets:UIEdgeInsetsMake(0, (rightUnitViewWidth - titleWidth)/2 + titleWidth - 5, 0, 0)];
            }
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:(UIControlEventTouchUpInside)];
            [unitView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(unitView).offset(0);
                make.top.bottom.equalTo(unitView).offset(0);
                make.width.mas_equalTo(rightUnitViewWidth);
            }];
            
            //右分割线
            if (i != titles.count - 1 ) {
                //最后一项不设置分割线
                UIView *rightLine = [[UIView alloc]init];
                rightLine.backgroundColor = CellSeparator_Color;
                [unitView addSubview:rightLine];
                [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(unitView).offset(rightUnitViewWidth-2);
                    make.top.equalTo(unitView).offset(8);
                    make.bottom.equalTo(unitView.mas_bottom).offset(-8);
                    make.width.mas_equalTo(2);
                }];
            }
        }
        //下分割线
        UIView *downLine = [[UIView alloc]init];
        downLine.backgroundColor = CellSeparator_Color;
        [self addSubview:downLine];
        [downLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self).offset(0);
            make.bottom.equalTo(self.mas_bottom).offset(-2);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}


//button的点击事件
- (void)buttonClick:(UIButton *)sender {
   
    //编辑按钮<->取消排序
    UIButton *cancelButton = [self viewWithTag:1001];
    UIButton *editButton = [self viewWithTag:1000];
    if (sender.tag == 1000) {
        //编辑按钮->进入排序界面
        if (self.buttonClickBlock) {
            self.buttonClickBlock(sender.tag);
        }
    }else if(sender.tag == 1001){
        //1.取消排序->编辑按钮
        cancelButton.hidden = YES;
        editButton.hidden = NO;
        //2.改变改变上一次点击button的状态(恢复初始状态)
        [self.lastClickButton setImage:[UIImage imageNamed:@"Optional_blank"] forState:(UIControlStateNormal)];
        self.lastClickButton.selected = NO;
        //3将上一次点击的button替换为一个新的button(非指向右边菜单里的button)
        self.lastClickButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        
        if (self.buttonClickBlock) {
            self.buttonClickBlock(sender.tag);
        }
    }else {
        //右边按钮
        //1.编辑按钮->取消排序
        if (!editButton.hidden) {
            editButton.hidden = YES;
            cancelButton.hidden = NO;
        }
        //2.改变上一次点击button的状态
        [self.lastClickButton setImage:[UIImage imageNamed:@"Optional_blank"] forState:(UIControlStateNormal)];
        //3.改变当前点击button的状态
        if (sender.selected == NO) {
            [sender setImage:[UIImage imageNamed:@"Optional_down"] forState:(UIControlStateNormal)];
            sender.selected = YES;
        }else {
            [sender setImage:[UIImage imageNamed:@"Optional_up"] forState:(UIControlStateNormal)];
            sender.selected = NO;
        }
        //4.更新上一次点击button
        self.lastClickButton = sender;
        if (self.buttonClickBlock) {
            self.buttonClickBlock(sender.tag);
        }
    }
    NSLog(@"%ld",sender.tag);
}


#pragma mark -- scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollViewBlock) {
        self.scrollViewBlock(scrollView.contentOffset);
    }
}

#pragma mark -- 根据文本的高度获取对应的宽度
- (CGFloat)getWidthWithContent:(NSString *)content height:(CGFloat)height font:(CGFloat)font {
    CGRect rect = [content boundingRectWithSize:CGSizeMake(999, height) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]
                                                  }
                                        context:nil
                   ];
    return rect.size.width;
}


@end
