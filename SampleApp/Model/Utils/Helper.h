//
//  Helper.h
//  AuthTest
//
//  Created by Nazifa Najish on 2/15/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include<netdb.h>

@interface Helper : NSObject

#define NO_INTERNET             @"No Internet Connection!"
#define ENTER_MOBILE_NUMBER     @"Please enter mobile number"
#define ENTER_OTP               @"Please enter OTP"
#define MO_NUMBER_CHARACTERS    @"0123456789+"
#define NUMBER_CHARACTERS       @"0123456789"
#define USER_KEY                @"d07a82b00b30c5813e943f24557d4c73"
#define RES_DOMAIN              @"https://hacker-news.firebaseio.com/v0"

#define PrimaryColor            @"FF9300" //Orange Color//

-(BOOL)NetworkConnection;
+(NSString *)getListUrl:(NSString*)parameter;
-(NSDictionary *)GetHandler:(NSString *)url Parameters:(NSString *)parameter;
+(UIColor*)colorWithHexString:(NSString*)hex alpha:(float)alpha;
+(NSString *)TopStoryURL;
+(NSString*)getTimeFromTimestamp:(id)timestamp;
+(NSString*)getTimeDuration:(double)timestamp;

@end
