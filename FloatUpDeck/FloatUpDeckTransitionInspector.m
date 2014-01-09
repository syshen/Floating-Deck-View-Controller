//
//  FloatUpDeckTransitionInspector.m
//  FloatUpDeck
//
//  Created by syshen on 1/8/14.
//  Copyright (c) 2014 syshen. All rights reserved.
//

#import "FloatUpDeckTransitionInspector.h"
#import <QuartzCore/QuartzCore.h>

@interface FloatUpDeckTransitionInspector()

@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, assign) CGFloat startLocation;
@end

@implementation FloatUpDeckTransitionInspector {
  CGFloat _currentShadowOpacity;
}

- (id) initWithParentViewController:(UIViewController*)viewController childViewController:(UIViewController*)child {
  self = [super init];
  if (self) {
    self.parentViewController = viewController;
    self.childViewController = child;
    self.interactive = NO;
    self.presenting = NO;
  }
  return self;
}

#pragma mark - PanGesturesRecognizer
- (void)userDidPan:(UIScreenEdgePanGestureRecognizer *)recognizer {
  CGPoint location = [recognizer locationInView:nil]; // to get the location of touch on the screen
  CGPoint velocity = [recognizer velocityInView:nil];
  
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    self.interactive = YES;
    self.presenting = YES;
    
    self.startLocation = location.y;
    self.childViewController.modalPresentationStyle = UIModalPresentationCustom;
    self.childViewController.transitioningDelegate = self;
    [self.parentViewController presentViewController:self.childViewController
                                            animated:YES completion:nil];
  } else if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGFloat height = CGRectGetHeight(self.parentViewController.view.bounds);
    CGFloat ratio = MAX(MIN((height + (location.y - self.startLocation)) / height, 1.0), 0.0);
    [self updateInteractiveTransition:ratio];
    
  } else if (recognizer.state == UIGestureRecognizerStateEnded) {
    
    self.interactive = NO;
    if (velocity.y < 0) {
      [self finishInteractiveTransition];
    } else {
      [self cancelInteractiveTransition];
    }
    
  }
  
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
  return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
  return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
  if (self.interactive)
    return self;
  return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
  if (self.interactive)
    return self;
  return nil;
}

- (CATransform3D) transformForRotationDegree:(CGFloat)degree {

  CATransform3D transform = CATransform3DIdentity;
  transform.m34 = 1.0/-900;
  transform = CATransform3DRotate(transform, degree * M_PI / 180, 1, 0, 0);
  return transform;
  
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return 0.5f;
}

- (void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  
  if (self.interactive) {
    // it is on the progress of user interaction, we don't do animation. [self updateInteractiveTransition] will take care of the animation
  } else
  if (!self.presenting) { // Dismiss
    
    // to dismiss the view controller, 'from' is the second view controller, and 'to' is the parent view controller
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    [transitionContext.containerView addSubview:fromViewController.view];
    [transitionContext.containerView addSubview:toViewController.view];
    
    CGRect frame = [transitionContext containerView].bounds;

    // init the parent view controller's frame, it should be off the screen before dismiss
    CGRect toFrame = frame;
    toFrame.origin.y -= CGRectGetHeight(frame);
    toViewController.view.frame = toFrame;

    // drop shadow
    toViewController.view.clipsToBounds = NO;
    toViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    toViewController.view.layer.shadowRadius = 40.0f;
    CGRect shadowFrame = toViewController.view.bounds;
    shadowFrame.origin.x -= 80;
    shadowFrame.size.width += 160;
    toViewController.view.layer.shadowPath = [[UIBezierPath
                                               bezierPathWithRect:shadowFrame] CGPath];
    toViewController.view.layer.shadowOffset = CGSizeMake(0, 0);
    toViewController.view.layer.shadowOpacity = 0.5f;
    
    // shadow animation
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    anim.fromValue = [NSNumber numberWithFloat:0.2f];
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.duration = [self transitionDuration:transitionContext];
    [toViewController.view.layer addAnimation:anim forKey:@"shadowOpacity"];
    toViewController.view.layer.shadowOpacity = 1.0f;
    
    anim = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
    anim.fromValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
    anim.toValue = [NSValue valueWithCGSize:CGSizeMake(0, 100)];
    anim.duration = [self transitionDuration:transitionContext];
    [toViewController.view.layer addAnimation:anim forKey:@"shadowOffset"];
    toViewController.view.layer.shadowOffset = CGSizeMake(0, 100);
    
    // init the second view controller's frame, it should be on the screen before dismiss
    CGRect fromFrame = frame;
    fromFrame.origin.y += CGRectGetHeight(frame);
    fromViewController.view.frame = frame;
  
    __weak FloatUpDeckTransitionInspector *wSelf = self;
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{

                       toViewController.view.frame = frame;
                       
                       fromViewController.view.layer.transform = [wSelf transformForRotationDegree:15];
                       fromViewController.view.frame = fromFrame;

                     } completion:^(BOOL finished) {
    
                       toViewController.view.clipsToBounds = YES;
                       [transitionContext completeTransition:YES]; // notify the context we are done with the transition
                       
                     }];

    
  }
  
}

#pragma mark - UIViewControllerInteractiveTransitioning
- (void) startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  self.transitionContext = transitionContext;
  
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

  [transitionContext.containerView addSubview:toViewController.view];
  [transitionContext.containerView addSubview:fromViewController.view];

  // drop shadow
  fromViewController.view.clipsToBounds = NO;
  fromViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
  fromViewController.view.layer.shadowRadius = 40.0f;
  CGRect shadowFrame = fromViewController.view.bounds;
  shadowFrame.origin.x -= 80;
  shadowFrame.size.width += 160;
  fromViewController.view.layer.shadowPath = [[UIBezierPath
                                               bezierPathWithRect:shadowFrame] CGPath];
  fromViewController.view.layer.shadowOpacity = 0.8f;
 
}

- (void) updateInteractiveTransition:(CGFloat)percentComplete {
  id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
  
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  
  // Presenting goes from 0...1 and dismissing goes from 1...0
  CGRect fromFrame = CGRectOffset([[transitionContext containerView] bounds], 0, -CGRectGetHeight([[transitionContext containerView] bounds]) * (1.0f - percentComplete));
  CGRect outsideFrame = [transitionContext containerView].bounds;
  outsideFrame.origin.y += CGRectGetHeight(outsideFrame);
  CGRect toFrame = CGRectOffset(outsideFrame, 0, -CGRectGetHeight([[transitionContext containerView] bounds]) * (1.0f - percentComplete));
  
  fromViewController.view.frame = fromFrame;
  
  // update the shadow offset
  fromViewController.view.layer.shadowOffset = CGSizeMake(0, 100 * percentComplete);
  
  toViewController.view.frame = toFrame;
  
  CGFloat angle = percentComplete * 15;
  toViewController.view.layer.transform = [self transformForRotationDegree:angle];

}

- (void) cancelInteractiveTransition {

  id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
  
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

  CGRect frame = [transitionContext containerView].bounds;
  
  CGRect toFrame = frame;
  toFrame.origin.y += CGRectGetHeight(frame);

  // shadow animation
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
  anim.fromValue = [NSValue valueWithCGSize:fromViewController.view.layer.shadowOffset];
  anim.toValue = [NSValue valueWithCGSize:CGSizeMake(0, 100)];
  anim.duration = [self transitionDuration:transitionContext];
  [fromViewController.view.layer addAnimation:anim forKey:@"shadowOffset"];
  fromViewController.view.layer.shadowOffset = CGSizeMake(0, 100);

  
  [UIView animateWithDuration:[self transitionDuration:transitionContext]
                   animations:^{

                     fromViewController.view.frame = frame;
                     toViewController.view.frame = toFrame;
                     
                   } completion:^(BOOL finished) {
                     
                     [transitionContext completeTransition:NO];
                     
                   }];
  
}

- (void) finishInteractiveTransition {
  
  id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
  
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

  CGRect frame = [transitionContext containerView].bounds;
  
  CGRect fromFrame = frame;
  fromFrame.origin.y -= CGRectGetHeight(frame);
  
  // shadow animation
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
  anim.fromValue = [NSNumber numberWithFloat:0.8f];
  anim.toValue = [NSNumber numberWithFloat:0.0f];
  anim.duration = [self transitionDuration:transitionContext];
  [fromViewController.view.layer addAnimation:anim forKey:@"shadowOpacity"];
  fromViewController.view.layer.shadowOpacity = 0.0f;
  
  anim = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
  anim.fromValue = [NSValue valueWithCGSize:fromViewController.view.layer.shadowOffset];
  anim.toValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
  anim.duration = [self transitionDuration:transitionContext];
  [fromViewController.view.layer addAnimation:anim forKey:@"shadowOffset"];
  fromViewController.view.layer.shadowOffset = CGSizeMake(0, 0);
  
  __weak FloatUpDeckTransitionInspector *wSelf = self;
  [UIView animateWithDuration:[self transitionDuration:transitionContext]
                   animations:^{

                     fromViewController.view.frame = fromFrame;
 
                     toViewController.view.frame = frame;
                     toViewController.view.layer.transform = [wSelf transformForRotationDegree:0];
                     
                   } completion:^(BOOL finished) {
                     fromViewController.view.clipsToBounds = YES;
                     
                     [transitionContext completeTransition:YES];
                     _presenting = NO;
                   
                   }];
  
}
@end
