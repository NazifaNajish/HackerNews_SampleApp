//
//  TopStories.h
//  SampleApp
//
//  Created by Nazifa Najish on 3/19/18.
//  Copyright © 2018 nazifa. All rights reserved.
//

#import <Realm/Realm.h>

@interface Kids: RLMObject
@property long Id;
@end
RLM_ARRAY_TYPE(Kids)

@interface TopStories : RLMObject
@property long Id;
@property NSString *title;
@property int score;
@property NSString *url;
@property RLMArray<Kids> *kidsArray;
@property NSString *by;
@property double time;
@end

