//
//  ESQQPluginSettingViewController.m
//  QQDylib
//
//  Created by 晨风 on 2018/5/10.
//  Copyright © 2018年 晨风. All rights reserved.
//

#import "ESQQPluginSettingViewController.h"
#import "ESQQRedEnvelope.h"

@interface ESQQPluginSettingViewController ()
<UITextFieldDelegate>

@end

@implementation ESQQPluginSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self setupUI];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Action

- (void)didTapAutoOpenRedEnvelopeEnableSwitch:(UISwitch *)object {
    [ESQQRedEnvelope shareInstance].autoOpenRedEnvelopeEnable = object.on;
}

- (void)tapBackgroundAction {
    for (UIView *view in self.view.subviews) {
        if (view.isFirstResponder) {
            [view resignFirstResponder];
            return;
        }
    }
    [self dismissViewControllerAnimated:YES completion:self.dismissComplectionBlock];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [ESQQRedEnvelope shareInstance].openRedEnvelopeDelay = [textField.text integerValue];
}

#pragma mark - View

- (void)setupUI {
    
    {
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = @"自动抢红包";
        titleLabel.frame = CGRectMake(40, 100, 100, 60);
        [self.view addSubview:titleLabel];
        
        UISwitch *_switch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 40 - 100, titleLabel.frame.origin.y, 100, 60)];
        _switch.on = [ESQQRedEnvelope shareInstance].autoOpenRedEnvelopeEnable;
        [_switch addTarget:self action:@selector(didTapAutoOpenRedEnvelopeEnableSwitch:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_switch];
    }
    
    {
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = @"延迟(毫秒)";
        titleLabel.frame = CGRectMake(40, 160, 100, 60);
        [self.view addSubview:titleLabel];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 40 - 100, titleLabel.frame.origin.y, 100, 60)];
        textField.text = [NSString stringWithFormat:@"%ld", [ESQQRedEnvelope shareInstance].openRedEnvelopeDelay];
        textField.textAlignment = NSTextAlignmentRight;
        textField.keyboardType = UIKeyboardTypeNamePhonePad;
        textField.delegate = self;
        [self.view addSubview:textField];
        
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundAction)];
    [self.view addGestureRecognizer:tap];
}



@end
