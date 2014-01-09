//
//  ViewController.m
//  FloatUpDeck
//
//  Created by syshen on 1/8/14.
//  Copyright (c) 2014 syshen. All rights reserved.
//

#import "ViewController.h"
#import "FloatUpDeckTransitionInspector.h"
#import "ToViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePanGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) FloatUpDeckTransitionInspector *inspector;
@property (nonatomic, strong) UIViewController *toViewController;
@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  UIViewController *childViewController = [[ToViewController alloc] initWithNibName:@"ToViewController" bundle:nil];
  self.toViewController = [[UINavigationController alloc] initWithRootViewController:childViewController];
  childViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissChildVC)];
  
  self.inspector = [[FloatUpDeckTransitionInspector alloc] initWithParentViewController:self childViewController:self.toViewController];
//  self.edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.inspector action:@selector(userDidPan:)];
//  self.edgePanGesture.edges = UIRectEdgeBottom | UIRectEdgeRight;
//  [self.view addGestureRecognizer:self.edgePanGesture];
  self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.inspector action:@selector(userDidPan:)];
  [self.view addGestureRecognizer:self.panGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissChildVC {
  [self.toViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
