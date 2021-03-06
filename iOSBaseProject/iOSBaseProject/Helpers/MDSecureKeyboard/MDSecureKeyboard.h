//
//  MDSecureKeyboard.h
//  QMainProject
//
//  Created by Leo on 2018/9/18.
//  Copyright © 2018年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MDSecureKeyboardDelegate

- (void)MDSecureKeyboardOutputPwd:(NSString *)pwd;

@end

@interface MDSecureKeyboard : UIView

@property (nonatomic, weak) id<MDSecureKeyboardDelegate> delegate;

- (void)showKeyboard;

- (void)hideKeyboard;

@end
