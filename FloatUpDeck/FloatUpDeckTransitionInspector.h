//
//  FloatUpDeckTransitionInspector.h
//  FloatUpDeck
//
//  Created by syshen on 1/8/14.
//  Copyright (c) 2014 syshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FloatUpDeckTransitionInspector : UIPercentDrivenInteractiveTransition <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) UIViewController *parentViewController;
@property (nonatomic, strong) UIViewController *childViewController;

- (id) initWithParentViewController:(UIViewController*)viewController childViewController:(UIViewController*)child;
- (void)userDidPan:(UIScreenEdgePanGestureRecognizer *)recognizer;

@end
