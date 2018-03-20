//
//  DetailRootController.m
//  SampleApp
//
//  Created by Nazifa Najish on 3/15/18.
//  Copyright © 2018 nazifa. All rights reserved.
//

#import "DetailRootController.h"
#import "ArticleController.h"
@interface DetailRootController (){
}

@end

@implementation DetailRootController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.StoryTitle;
    
    if (self.ArticleUrl!= nil && ![self.ArticleUrl isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults]setObject:self.ArticleUrl forKey:@"ArticleUrl"];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ArticleUrl"];
   
        // Remove the second tab from a tab bar controlled by a tab bar controller
        NSMutableArray * vcs = [NSMutableArray arrayWithArray:[self viewControllers]];
        [vcs removeObjectAtIndex:1];
        [self setViewControllers:vcs];
    }
    
    [[[self.tabBar items] objectAtIndex:0] setTitle:[NSString stringWithFormat:@"%d Comments",(int)self.CommentIdArray.count]];
    
    if (self.CommentIdArray.count <= 0)
        [[[self.tabBar items] objectAtIndex:0] setTitle:[NSString stringWithFormat:@"0 Comment"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    // Notification for Comment Controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentControllerNotification" object:self.CommentIdArray];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // check if the back button was pressed
    if (self.isMovingFromParentViewController) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ArticleUrl"];
    }
}


@end
