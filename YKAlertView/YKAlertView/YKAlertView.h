//
//  YKAlertView.h
//  YKAlertView
//
//  Created by zhangyuanke on 16/8/13.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import <UIKit/UIKit.h>

// The delegate for YKAlertView
@protocol YKAlertViewDelegate <NSObject>

@optional
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)YKAlertViewClickedButtonAtIndex:(NSInteger)buttonIndex;

@end

// YKAlertView
@interface YKAlertView : UIView

// The init method
- (nonnull instancetype)initWithTitle:(nullable NSString *)title
                              message:(nullable NSString *)message
                             delegate:(nullable id)delegate
                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                    otherButtonTitles:(nullable NSArray *)otherButtonTitles;

// call this method to show the AlertView
- (void)show;

@end
