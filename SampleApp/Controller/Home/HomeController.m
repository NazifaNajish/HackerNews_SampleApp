//
//  HomeController.m
//  SampleApp
//
//  Created by Nazifa Najish on 3/14/18.
//  Copyright © 2018 nazifa. All rights reserved.
//

#import "HomeController.h"
#import "Helper.h"
#import <SVProgressHUD.h>
#import "StoryCell.h"
#import "DetailRootController.h"
#import <Realm/Realm.h>
#import "TopStories.h"

@import Firebase;

@interface HomeController ()<UITableViewDelegate,UITableViewDataSource>{
    Helper *helperObj;
    DetailRootController * detailRootVC;
    NSNumber *UpdateDuration;
    NSTimer *timer;
    UIRefreshControl *refreshControl;
    
    // Database Objects
    RLMRealm *realm;
    RLMResults<TopStories *> *topStories;
}
@property (weak, nonatomic) IBOutlet UITableView *storyTable;
@property (weak, nonatomic) IBOutlet UILabel *UpdateDurationLabel;

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Global Initialization
    helperObj = [[Helper alloc]init];
    self.storyTable.delegate = self;
    realm = [RLMRealm defaultRealm];
    
    // Appearance
    self.UpdateDurationLabel.backgroundColor = [Helper colorWithHexString:PrimaryColor alpha:1.0];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title = @"Top Stories";
    [self getUpdatedDuration];
    
    // Add Pull To Refresh
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor lightGrayColor];
    [refreshControl addTarget:self action:@selector(getTopStories) forControlEvents:UIControlEventValueChanged];
    [self.storyTable addSubview:refreshControl];
    
    // Query Realm
    topStories = [TopStories allObjects];
    NSLog(@"Stories Count: %d",(int)topStories.count);
    if (topStories.count > 0) {
        [self.storyTable reloadData];
    } else {
        [self getTopStories];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!timer)
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(getUpdatedDuration) userInfo:nil repeats:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([timer isValid])
        [timer invalidate];
    
    timer = nil;
}

#pragma mark - Update time Info
-(void)getUpdatedDuration {
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"UpdateDuration"] != nil) {
        UpdateDuration = [[NSUserDefaults standardUserDefaults]objectForKey:@"UpdateDuration"];
        self.UpdateDurationLabel.text = [NSString stringWithFormat:@"     Updated %@",[Helper getTimeDuration:[UpdateDuration doubleValue]]];
    } else {
        self.UpdateDurationLabel.text = @"";
    }
}

#pragma mark - Get data from Server
-(void)getTopStories {
    
    self.storyTable.hidden = YES;
    [self.storyTable reloadData];
    
    if (topStories.count > 0)
        self.storyTable.hidden = NO;
    else
        [SVProgressHUD showWithStatus:@"Please wait a moment!"];
    
    if (![helperObj NetworkConnection]) {
        [SVProgressHUD showInfoWithStatus:NO_INTERNET];
        [SVProgressHUD dismissWithDelay:0.6];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __block NSDictionary * response = [helperObj GetHandler:[Helper TopStoryURL] Parameters:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [SVProgressHUD dismiss];
            [refreshControl endRefreshing];
            
            if (response != nil && response) {
                @try {
                    NSArray * idArray = (NSArray *)response;
                    NSLog(@"Total: %d", (int)idArray.count);
                    
                    NSMutableArray *newStories = [[NSMutableArray alloc]init];
                    for (int i=0; i < idArray.count; i++) {
                        RLMResults<TopStories *> *stories = [topStories objectsWhere:@"Id == %@",idArray[i]];
                        if (stories.count<=0) {
                            [newStories addObject:idArray[i]];
                        }
                    }
                    
                    NSLog(@"New Stories: %d", (int)newStories.count);
                    if (idArray.count != newStories.count) {
                        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%d New Story!",(int)newStories.count]];
                        [SVProgressHUD dismissWithDelay:1.2];
                    }
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        for (int i=0; i < newStories.count; i++) {
                            [self getStoryDetail:newStories[i]];
                        }
                    });
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"ExceptionName: %@ Reason: %@ ",exception.name,exception.reason);
                }
                
            }
            topStories = [TopStories allObjects];
            [self reloadList];
            self.UpdateDurationLabel.text = @"     Updated just now";
            UpdateDuration = [NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]];
            [[NSUserDefaults standardUserDefaults] setObject:UpdateDuration forKey:@"UpdateDuration"];
            response = nil;
        });
    });
}

-(void)getStoryDetail:(NSString*)storyId {
    
        __block NSDictionary * response = [helperObj GetHandler:[Helper getListUrl:storyId] Parameters:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if (response != nil && response) {
                
                // Realm
                TopStories *story = [[TopStories alloc]init];
                story.Id = [[response objectForKey:@"id"] longValue];
                story.title = [response objectForKey:@"title"];
                story.score = [[response objectForKey:@"score"] intValue];
                
                NSArray* kidsIdArray = [response objectForKey:@"kids"];
                
                for (int i =0; i<kidsIdArray.count; i++) {
                    Kids *kidsObject = [[Kids alloc]init];
                    kidsObject.Id = [kidsIdArray[i] longValue];
                    [story.kidsArray addObject:kidsObject];
                }
                
                story.url = [response objectForKey:@"url"];
                story.by = [response objectForKey:@"by"];
                story.time = [[response objectForKey:@"time"] doubleValue];
                
                // Save data
                [realm transactionWithBlock:^{
                    [realm addObject:story];
                }];
                
            }
            [self reloadList];
        });
}

-(void)reloadList {
    
    if (topStories.count > 0)
        self.storyTable.hidden = NO;
    [self.storyTable reloadData];
}

#pragma mark - TableView delegates & DataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return topStories.count;
}

- (StoryCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"ListCell";
    
    StoryCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[StoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
   
    @try {
        // From table
        TopStories *story = topStories[indexPath.row];
        if (story.title != nil)
            cell.TitleLabel.text = story.title;
        else
            cell.TitleLabel.text = @"";
        
        if (story.score)
            cell.ScoreLabel.text = [NSString stringWithFormat:@"%d",story.score];
        else
            cell.ScoreLabel.text = @"";
        
        if (story.url != nil)
            cell.SourceLabel.text = story.url;
        else
            cell.SourceLabel.text = @"";
        
        if (story.kidsArray != nil ) {
            cell.CommentLabel.text = [NSString stringWithFormat:@"%d",(int)story.kidsArray.count];
        } else {
            cell.CommentLabel.text = @"";
        }
        
        if (story.by != nil && story.time) {
            cell.SubmitterDetail.text = [NSString stringWithFormat:@"by %@ | %@",story.by, [Helper getTimeDuration:story.time]];
        } else {
            cell.SubmitterDetail.text = @"";
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ExceptionName: %@ Reason: %@ ",exception.name,exception.reason);
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @try {
        detailRootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailRootController"];
        
        TopStories *story = topStories[indexPath.row];
        if (story.title != nil)
            detailRootVC.StoryTitle = story.title;
        else
            detailRootVC.StoryTitle = @"";
        
        if (story.url != nil)
            detailRootVC.ArticleUrl = story.url;
        else
            detailRootVC.ArticleUrl = @"";
        
        NSMutableArray * kidsIdArr = [[NSMutableArray alloc]init];
        for (int i=0; i<story.kidsArray.count; i++) {
            Kids *obj = story.kidsArray[i];
            [kidsIdArr addObject:[NSNumber numberWithLong:obj.Id]];
        }
        
        detailRootVC.CommentIdArray = [NSArray arrayWithArray:kidsIdArr];
        
        [[self navigationController] pushViewController:detailRootVC animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"ExceptionName: %@ Reason: %@ ",exception.name,exception.reason);
    }
}

#pragma mark - Sign Out
- (IBAction)SignOut:(id)sender {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:@"Do you want to logout?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        NSError *signOutError;
        BOOL status = [[FIRAuth auth] signOut:&signOutError];
        if (!status) {
            NSLog(@"Error signing out: %@", signOutError);
            return;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
