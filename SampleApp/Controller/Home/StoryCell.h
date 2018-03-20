//
//  StoryCell.h
//  SampleApp
//
//  Created by Nazifa Najish on 3/14/18.
//  Copyright © 2018 nazifa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *SourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *SubmitterDetail;
@property (weak, nonatomic) IBOutlet UILabel *CommentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *CommentIcon;

@end
