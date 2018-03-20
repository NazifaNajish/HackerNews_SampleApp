//
//  CommentCell.m
//  SampleApp
//
//  Created by Nazifa Najish on 3/15/18.
//  Copyright © 2018 nazifa. All rights reserved.
//

#import "CommentCell.h"
#import "Helper.h"
@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.commentDetailtext.textColor = [Helper colorWithHexString:PrimaryColor alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
