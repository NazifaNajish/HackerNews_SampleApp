//
//  AppDelegate.h
//  SampleApp
//
//  Created by Nazifa Najish on 3/14/18.
//  Copyright © 2018 nazifa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@import Firebase;
@import GoogleSignIn;

@interface AppDelegate : UIResponder <UIApplicationDelegate,GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

