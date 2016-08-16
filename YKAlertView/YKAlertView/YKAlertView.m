//
//  YKAlertView.m
//  YKAlertView
//
//  Created by zhangyuanke on 16/8/13.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import "YKAlertView.h"

#pragma mark - custom define
static CGFloat const kYKDefaultContainerWidth = 280.0;
static CGFloat const kYKDefaultCommonSpace = 12;
static CGFloat const kYKDefaultSeparationLineWidth = 0.5;
static CGFloat const kYKDefaultAnimationDuration = 0.3;
static CGFloat const kYKDefaultAlertButtonHeight = 44.0;

#define kYKAlertViewTitleColor              [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]
#define kYKAlertViewTitleFont               [UIFont boldSystemFontOfSize:17.0f]
#define kYKAlertViewMessageColor            [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]
#define kYKAlertViewMessageFont             [UIFont systemFontOfSize:14.0f]
#define kYKAlertViewModalBackgroundColor    [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]
#define kYKAlertViewCancelButtonTitleColor  [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]
#define kYKAlertViewOtherButtonTitleColor   [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f]

CGSize YKAlertViewSizeOfLabel(NSString *text, UIFont *font, CGSize constraintSize){
    NSDictionary *attrs = @{NSFontAttributeName:font};
    CGSize aSize = [text boundingRectWithSize:constraintSize
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:attrs
                                      context:nil].size;
    return CGSizeMake(aSize.width, aSize.height + 1);
}

#define YKSizeForLabel(text, font, constraintSize) YKAlertViewSizeOfLabel(text, font, constraintSize)

#pragma mark - YKAlertViewQueue

@interface YKAlertViewQueue : NSObject
@property(nonatomic, strong) YKAlertView *currentAlertView;
+ (instancetype)sharedQueue;
- (BOOL)contains:(YKAlertView *)alertView;
- (YKAlertView *)dequeue;
- (void)enqueue:(YKAlertView *)alertView;
- (void)remove:(YKAlertView *)alertView;
@end

#pragma mark - YKAlertView

@interface YKAlertView ()

@property (nonatomic, weak) id<YKAlertViewDelegate> delegate;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, assign) CGFloat frameHeight;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

@end

@implementation YKAlertView

#pragma mark public method

// The init method
- (nonnull instancetype)initWithTitle:(nullable NSString *)title
                              message:(nullable NSString *)message
                             delegate:(nullable id)delegate
                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                    otherButtonTitles:(nullable NSArray *)otherButtonTitles
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        self.clipsToBounds = YES;
        _frameHeight = 0;
        _contentInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _delegate = delegate;
        [self setupUIWithTitle:title message:message];
        [self setupUIWithCancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
        [self doLayout];
    }
    return self;
}

// call this method to show the AlertView
- (void)show
{
    if (![[YKAlertViewQueue sharedQueue] contains:self]) {
        [[YKAlertViewQueue sharedQueue] enqueue:self];
    }
    if ([YKAlertViewQueue sharedQueue].currentAlertView) {
        return;
    }
    [YKAlertViewQueue sharedQueue].currentAlertView  = self;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    _backgroundView = [[UIView alloc] initWithFrame:window.bounds];
    _backgroundView.backgroundColor = kYKAlertViewModalBackgroundColor;
    [window addSubview:_backgroundView];
    [window addSubview:self];
    
    [self showWithAnimation:YES];
}

#pragma mark - private method

// The init method
- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithTitle:@"YKAlertView" message:@"YKAlertView message" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@[@"ok"]];
}

- (void)setupUIWithTitle:(NSString *)title message:(NSString *)message
{
    if ([title length] || [message length]) {
        _frameHeight += _contentInsets.top;
    }
    CGSize tempSize;
    CGFloat tempTextWidth = kYKDefaultContainerWidth - self.contentInsets.left - self.contentInsets.right;
    if ([title length]) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = kYKAlertViewTitleColor;
        _titleLabel.font = kYKAlertViewTitleFont;
        _titleLabel.text = title;
        tempSize = YKSizeForLabel(_titleLabel.text, _titleLabel.font, CGSizeMake(tempTextWidth, MAXFLOAT));
        _titleLabel.frame = CGRectMake(self.contentInsets.left, _frameHeight, tempTextWidth, tempSize.height);
        [self addSubview:_titleLabel];
        _frameHeight += tempSize.height;
        if ([message length] == 0) {
            _frameHeight += self.contentInsets.bottom;
        }
    }
    
    if ([message length]) {
        if ([title length]) {
            _frameHeight += kYKDefaultCommonSpace;
        }
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.text = message;
        _messageLabel.textColor = kYKAlertViewMessageColor;
        _messageLabel.font = kYKAlertViewMessageFont;
        tempSize = YKSizeForLabel(_messageLabel.text, _messageLabel.font, CGSizeMake(tempTextWidth, MAXFLOAT));
        _messageLabel.frame = CGRectMake(self.contentInsets.left, _frameHeight, tempTextWidth, tempSize.height);
        [self addSubview:_messageLabel];
        _frameHeight += tempSize.height;
        _frameHeight += self.contentInsets.bottom;
    }
}

- (void)setupUIWithCancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(nullable NSArray *)otherButtonTitles
{
    NSUInteger buttonCount = 0;
    if ([cancelButtonTitle length] == 0 && [otherButtonTitles count] == 0) {
        cancelButtonTitle = @"Cancel";
    }
    if ([cancelButtonTitle length]) {
        buttonCount += 1;
    }
    buttonCount += otherButtonTitles.count;
    if (buttonCount <= 2) {
        UIView *hSeparationLine = [[UIView alloc] initWithFrame:CGRectMake(0, _frameHeight, kYKDefaultContainerWidth, kYKDefaultSeparationLineWidth)];
        hSeparationLine.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [self addSubview:hSeparationLine];
        _frameHeight += kYKDefaultSeparationLineWidth;
        if ([cancelButtonTitle length]) {
            CGFloat buttonWidth = kYKDefaultContainerWidth / 2.0;
            if ([otherButtonTitles count] == 0) {
                buttonWidth = kYKDefaultContainerWidth;
            }
            UIButton *cancelButton = [self createCancelButtonWithCancelTitle:cancelButtonTitle];
            if ([otherButtonTitles count]) {
                cancelButton.frame  = CGRectMake(0, _frameHeight, buttonWidth - kYKDefaultSeparationLineWidth, kYKDefaultAlertButtonHeight);
            } else {
                cancelButton.frame  = CGRectMake(0, _frameHeight, buttonWidth, kYKDefaultAlertButtonHeight);
            }
            [self addSubview:cancelButton];
            if ([otherButtonTitles count]) {
                UIView *vSeparationLine = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth, _frameHeight - kYKDefaultSeparationLineWidth, kYKDefaultSeparationLineWidth, kYKDefaultAlertButtonHeight + kYKDefaultSeparationLineWidth)];
                vSeparationLine.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
                [self addSubview:vSeparationLine];
                
                UIButton *otherButton = [self createCommonButtonWithTitile:(NSString *)otherButtonTitles[0] andTag:1];
                otherButton.frame  = CGRectMake(buttonWidth + kYKDefaultSeparationLineWidth, _frameHeight, buttonWidth - kYKDefaultSeparationLineWidth, kYKDefaultAlertButtonHeight);
                [self addSubview:otherButton];
            }
        } else {
             if ([otherButtonTitles count] == 1)
             {
                 CGFloat buttonWidth = kYKDefaultContainerWidth;
                 UIButton *otherButton = [self createCommonButtonWithTitile:(NSString *)otherButtonTitles[0] andTag:0];
                 otherButton.frame  = CGRectMake(0, _frameHeight, buttonWidth, kYKDefaultAlertButtonHeight);
                 [self addSubview:otherButton];
             } else {
                 if ([otherButtonTitles count] >= 2) {
                     CGFloat buttonWidth = kYKDefaultContainerWidth / 2.0;
                     for (int i = 0; i < 2; i++) {
                         UIButton *otherButton = [self createCommonButtonWithTitile:(NSString *)otherButtonTitles[i] andTag:i];
                         otherButton.frame  = CGRectMake(buttonWidth * i + ((i > 0) ? kYKDefaultSeparationLineWidth : 0), _frameHeight, buttonWidth, kYKDefaultAlertButtonHeight);
                         [self addSubview:otherButton];
                     }
                     UIView *vSeparationLine = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth, _frameHeight - kYKDefaultSeparationLineWidth, kYKDefaultSeparationLineWidth, kYKDefaultAlertButtonHeight + kYKDefaultSeparationLineWidth)];
                     vSeparationLine.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
                     [self addSubview:vSeparationLine];
                 }
             }
        }
        _frameHeight += kYKDefaultAlertButtonHeight;
    } else {
        UIView *hSeparationLine = [[UIView alloc] initWithFrame:CGRectMake(0, _frameHeight, kYKDefaultContainerWidth, kYKDefaultSeparationLineWidth)];
        hSeparationLine.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [self addSubview:hSeparationLine];
        _frameHeight += kYKDefaultSeparationLineWidth;
        CGFloat buttonWidth = kYKDefaultContainerWidth;
        if ([cancelButtonTitle length]) {
            UIButton *cancelButton = [self createCancelButtonWithCancelTitle:cancelButtonTitle];
            cancelButton.frame  = CGRectMake(0, _frameHeight, buttonWidth, kYKDefaultAlertButtonHeight);
            [self addSubview:cancelButton];
            _frameHeight += kYKDefaultAlertButtonHeight;
        }
        for (int i = 0; i < [otherButtonTitles count]; i++) {
            UIView *hSeparationLine = [[UIView alloc] initWithFrame:CGRectMake(0, _frameHeight, kYKDefaultContainerWidth, kYKDefaultSeparationLineWidth)];
            hSeparationLine.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
            [self addSubview:hSeparationLine];
            _frameHeight += kYKDefaultSeparationLineWidth;
            UIButton *otherButton = [self createCommonButtonWithTitile:(NSString *)otherButtonTitles[i] andTag:[cancelButtonTitle length] ? i + 1 : i];
            otherButton.frame  = CGRectMake(0, _frameHeight, buttonWidth, kYKDefaultAlertButtonHeight);
            [self addSubview:otherButton];
             _frameHeight += kYKDefaultAlertButtonHeight;
        }
    }
}

- (UIButton *)createCancelButtonWithCancelTitle:(NSString *)cancelTitle
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.tag = 0;
    [cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    [cancelButton setTitleColor:kYKAlertViewCancelButtonTitleColor forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(buttonTouchUpInsideClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [cancelButton addTarget:self action:@selector(buttonTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    [cancelButton addTarget:self action:@selector(buttonTouchDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    return cancelButton;
}

- (UIButton *)createCommonButtonWithTitile:(NSString *)buttonTitle andTag:(NSUInteger)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = tag;
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [button setTitleColor:kYKAlertViewOtherButtonTitleColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTouchUpInsideClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(buttonTouchDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    return button;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self doLayout];
}

- (void)doLayout
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGFloat winHeight = window.bounds.size.height;
    CGFloat winWidth = window.bounds.size.width;
    self.backgroundView.frame = window.bounds;
    self.frame = CGRectMake((winWidth - kYKDefaultContainerWidth) / 2.0, (winHeight - self.frameHeight) / 2.0, kYKDefaultContainerWidth, self.frameHeight);
}

- (void)dismiss
{
    [self hideWithAnimation:YES completion:^{
        [YKAlertViewQueue sharedQueue].currentAlertView  = nil;
        [[YKAlertViewQueue sharedQueue] remove:self];
        YKAlertView *alertView = [[YKAlertViewQueue sharedQueue] dequeue];
        if (alertView) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertView show];
            });
        }
    }];
}

// animation
- (void)showWithAnimation:(BOOL)animated
{
    if(animated){
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [UIView animateWithDuration:kYKDefaultAnimationDuration
                         animations:^{
                             self.alpha = 1.0;
                             self.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

- (void)hideWithAnimation:(BOOL)animated completion:(dispatch_block_t)completion
{
    if(animated){
        [UIView animateWithDuration:kYKDefaultAnimationDuration
                         animations:^{
                             _backgroundView.backgroundColor = [UIColor clearColor];
                             self.alpha = 0;
                             self.transform = CGAffineTransformMakeScale(0.9,0.9);
                         }
                         completion:^(BOOL finished) {
                             [_backgroundView removeFromSuperview];
                             [self removeFromSuperview];
                             if (completion) {
                                 completion();
                             }
                         }];
    } else {
        [_backgroundView removeFromSuperview];
        [self removeFromSuperview];
        if (completion) {
            completion();
        }
    }
}


#pragma mark - event

- (void)buttonTouchUpInsideClicked:(UIButton *)button
{
    if ([[button titleForState:UIControlStateNormal] length]) {
        button.backgroundColor = [UIColor whiteColor];
    }
    // callback delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(YKAlertViewClickedButtonAtIndex:)]) {
        [self.delegate YKAlertViewClickedButtonAtIndex:button.tag];
    }
    // dismiss alertView
    [self dismiss];
}

- (void)buttonTouchDown:(UIButton *)button
{
    if ([[button titleForState:UIControlStateNormal] length]) {
        button.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    }
}

- (void)buttonTouchUpOutSide:(UIButton *)button
{
    if ([[button titleForState:UIControlStateNormal] length]) {
        button.backgroundColor = [UIColor whiteColor];
    }
}

- (void)buttonTouchDragOutside:(UIButton *)button
{
    if ([[button titleForState:UIControlStateNormal] length]) {
        button.backgroundColor = [UIColor whiteColor];
    }
}

@end


#pragma mark - YKAlertViewQueue

@implementation YKAlertViewQueue
{
    NSMutableArray *_allAlertViews;
}

+ (instancetype)sharedQueue {
    static YKAlertViewQueue *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YKAlertViewQueue alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if(self = [super init]){
        _allAlertViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)contains:(YKAlertView *)alertView
{
    return [_allAlertViews containsObject:alertView];
}

- (YKAlertView *)dequeue
{
    if(_allAlertViews.count>0){
        return [_allAlertViews firstObject];;
    }
    return nil;
}

- (void)enqueue:(YKAlertView *)alertView
{
    if (![self contains:alertView]) {
        [_allAlertViews addObject:alertView];
    }
}

- (void)remove:(YKAlertView *)alertView
{
    if(_allAlertViews.count>0){
        if([self contains:alertView]){
            [_allAlertViews removeObject:alertView];
        }
    }
}

@end
