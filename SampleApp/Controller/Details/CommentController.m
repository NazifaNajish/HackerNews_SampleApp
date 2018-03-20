//
//  CommentController.m
//  SampleApp
//
//  Created by Nazifa Najish on 3/15/18.
//  Copyright © 2018 nazifa. All rights reserved.
//

#import "CommentController.h"
#import "CommentCell.h"
#import "Helper.h"
#import <SVProgressHUD.h>

@interface CommentController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *commentArray;
    Helper *helperObj;
}

@property (weak, nonatomic) IBOutlet UITableView *CommentList;
@end

@implementation CommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    helperObj = [[Helper alloc]init];
    self.CommentList.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCommentId:) name:@"CommentControllerNotification" object:nil];
}

- (void)handleCommentId:(id)object {
    
    self.CommentIdArray = [object object];
    
    if (self.CommentIdArray.count > 0) {
        self.CommentList.hidden = NO;
        [self getTopLevelComments];
    }else {
        self.CommentList.hidden = YES;
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get data
-(void)getTopLevelComments {
    
    commentArray = [[NSMutableArray alloc]init];
    [self.CommentList reloadData];
    
    if (![helperObj NetworkConnection]) {
        [SVProgressHUD showInfoWithStatus:NO_INTERNET];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }
    
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i=0; i < self.CommentIdArray.count; i++) {
                [self getCommentDetail:self.CommentIdArray[i]];
            }
        });
    }
    @catch (NSException *exception) {
        NSLog(@"ExceptionName: %@ Reason: %@ ",exception.name,exception.reason);
    }
}

-(void)getCommentDetail:(NSString*)commentId {
    
    __block NSDictionary * response = [helperObj GetHandler:[Helper getListUrl:commentId] Parameters:nil];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (response != nil && response)
            [commentArray addObject:response];
        [self.CommentList reloadData];
    });
}

#pragma mark - Calculate Row height
- (CGFloat)getLabelHeight:(UILabel*)label String:(NSString*)string {
    CGFloat maxLabelWidth = [UIScreen mainScreen].bounds.size.width - 10;
    CGSize constraint = CGSizeMake(maxLabelWidth, 700);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    return size.height;
}

#pragma mark - TableView delegates & DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * rowInfo = commentArray[indexPath.row];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5,27,[UIScreen mainScreen].bounds.size.width - 10, 10)];
    label.attributedText = [[NSAttributedString alloc] initWithData:[[rowInfo objectForKey:@"text"] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding], NSFontAttributeName : [UIFont fontWithName:@"Arial" size:15.0]} documentAttributes:nil error:nil];
    
    
    return [@([self getLabelHeight:label String:rowInfo[@"text"]] + 60) floatValue];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return commentArray.count;
}

- (CommentCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"CommentCell";
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    @try {
        NSDictionary * dataSet = commentArray[indexPath.row];
        
        if ([dataSet objectForKey:@"text"] != nil && [dataSet objectForKey:@"text"] != [NSNull null]) {
            
            cell.CommentLabel.attributedText = [[NSAttributedString alloc] initWithData:[[self parseHTMLString:[dataSet objectForKey:@"text"]] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding], NSFontAttributeName : [UIFont fontWithName:@"Arial" size:9.0]} documentAttributes:nil error:nil];
            
        } else {
            cell.CommentLabel.text = @"";
        }
        
        NSString *commentdetail = @"";
        
        if ([dataSet objectForKey:@"by"] != nil && [dataSet objectForKey:@"by"] != [NSNull null]) {
            commentdetail = [dataSet objectForKey:@"by"];
        } else {
            commentdetail = @"Anonymous";
        }
            
        if ([dataSet objectForKey:@"time"] != nil && [dataSet objectForKey:@"time"] != [NSNull null]) {
            commentdetail = [commentdetail stringByAppendingString:[NSString stringWithFormat:@" | %@",[Helper getTimeDuration:[[dataSet objectForKey:@"time"] doubleValue]]]];
        }
        cell.commentDetailtext.text = commentdetail;
        
        dataSet = nil;
        commentdetail = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"ExceptionName: %@ Reason: %@ ",exception.name,exception.reason);
    }
    return cell;
}

#pragma mark - Parse HTML String
-(NSString *)parseHTMLString:(NSString*)string {
    
    NSMutableString * mutableString = [[NSMutableString alloc] initWithString:string];
    if (mutableString.length > 0) {
        [mutableString replaceOccurrencesOfString:@"\n" withString:@" " options:NSCaseInsensitiveSearch  range:NSMakeRange(0, mutableString.length)];
        [mutableString replaceOccurrencesOfString:@"<p>" withString:@"\n" options:NSCaseInsensitiveSearch  range:NSMakeRange(0, mutableString.length)];
        [mutableString replaceOccurrencesOfString:@"</p>" withString:@" " options:NSCaseInsensitiveSearch  range:NSMakeRange(0, mutableString.length)];
        [mutableString replaceOccurrencesOfString:@"<br/>" withString:@" " options:NSCaseInsensitiveSearch  range:NSMakeRange(0, mutableString.length)];
        [mutableString replaceOccurrencesOfString:@"<br />" withString:@" " options:NSCaseInsensitiveSearch  range:NSMakeRange(0, mutableString.length)];
    }
    return [NSString stringWithString:mutableString];
}
@end
