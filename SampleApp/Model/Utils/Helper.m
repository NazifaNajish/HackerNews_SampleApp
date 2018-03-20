//
//  Helper.m
//  AuthTest
//
//  Created by Nazifa Najish on 2/15/18.
//

#import "Helper.h"

@implementation Helper

const NSString *topStories = @"topstories.json";

#pragma mark - Network Connection check
-(BOOL)NetworkConnection {
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
        NSLog(@"-> no connection!\n");
        return NO;
    }
    else{
        NSLog(@"-> connected!\n");
        return YES;
    }
}

#pragma mark - Make URL
+(NSString *)getListUrl:(NSString*)parameter {
    return [NSString stringWithFormat:@"%@/item/%@.json",RES_DOMAIN,parameter];
}

+(NSString *)TopStoryURL {
    return [NSString stringWithFormat:@"%@/%@",RES_DOMAIN,topStories];
}

#pragma mark - Web Service Connection
-(NSDictionary *)GetHandler:(NSString *)url Parameters:(NSString *)parameter {
    //responseDictionary local variable for Block if define any Block variable must be add prefix __block keyword
    __block NSDictionary *responseDictionary = nil;
    @try {
        
        NSDictionary *headers =     @{
                                      @"user-key":USER_KEY,
                                      @"content-type": @"application/x-www-form-urlencoded",
                                      @"accept": @"application/json",
                                      };
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
        [request setHTTPMethod:@"GET"];
        [request setAllHTTPHeaderFields:headers];
        
        if (parameter != nil) {
            NSData *postData = [parameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            [request setHTTPBody:postData];
        }
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0); //Semaphore block run synchronization way
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                          {
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                              
                                              if (([httpResponse statusCode] >=200 && [httpResponse statusCode] <300) && (!error))
                                              {
                                                  // convert NSData to NSDictionary type by JSONObjectWithData
                                                  responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                  dispatch_semaphore_signal(sema); //send sema signal
                                              }
                                              else
                                              {
                                                  NSLog(@"no data");
                                                  dispatch_semaphore_signal(sema); //send sema signal
                                              }
                                          }];
        [dataTask resume];
        // this method waitting sema signal if get sema signal than run further stuff..
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    @catch (NSException *exception) {
        NSLog(@"ExceptionName: %@ Reason: %@ ",exception.name,exception.reason);
    }
    return responseDictionary;
}

#pragma mark - Hex to RGB
+(UIColor*)colorWithHexString:(NSString*)hex alpha:(float)alpha
{
    // hex excluding '#' sign
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}


+(NSString*)getTimeFromTimestamp:(id)timestamp {

    NSTimeInterval timeInterval=[timestamp doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"dd MMM yyyy"];
    NSString *dateString=[dateformatter stringFromDate:date];
    return dateString;
}

+(NSString*)getTimeDuration:(double)timestamp {
    
    NSTimeInterval timeInterval = timestamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    formatter.allowedUnits = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    formatter.maximumUnitCount = 1;
    
    return [NSString stringWithFormat:@"%@ ago",[formatter stringFromDate:date toDate:[NSDate date]]];
}
@end
