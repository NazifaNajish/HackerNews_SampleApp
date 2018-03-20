//
//  StoryCell.m
//  SampleApp
//
//  Created by Nazifa Najish on 3/14/18.
//  Copyright © 2018 nazifa. All rights reserved.
//

#import "StoryCell.h"
#import "Helper.h"

@implementation StoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.ScoreLabel.backgroundColor = [Helper colorWithHexString:PrimaryColor alpha:0.35];
    self.CommentIcon.tintColor = [Helper colorWithHexString:PrimaryColor alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
