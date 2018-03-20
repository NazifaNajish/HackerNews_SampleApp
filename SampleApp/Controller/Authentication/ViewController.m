//
//  ViewController.m
//  SampleApp
//
//  Created by Nazifa Najish on 3/14/18.
//  Copyright © 2018 nazifa. All rights reserved.
//

#import "ViewController.h"
#import "RootViewController.h"
#import "Helper.h"
@import Firebase;
@import GoogleSignIn;

@interface ViewController ()<GIDSignInUIDelegate,GIDSignInDelegate> {
    RootViewController * RootVC;
}
@property (weak, nonatomic) IBOutlet GIDSignInButton *GSignInButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [Helper colorWithHexString:PrimaryColor alpha:1.0];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    _GSignInButton.style = kGIDSignInButtonStyleStandard;
    
    // To automatically sign in the user.
    //[[GIDSignIn sharedInstance] signInSilently];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Google SignIn

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (error == nil) {
        
        // Perform any operations on signed in user here.
        NSString *userId = user.userID;                  // For client-side use only!
        NSString *idToken = user.authentication.idToken; // Safe to send to the server
        NSString *fullName = user.profile.name;
        NSString *givenName = user.profile.givenName;
        NSString *familyName = user.profile.familyName;
        NSString *email = user.profile.email;
        // ...
        
        NSLog(@"VC: userId: %@ \n idToken: %@ \n FullName: %@ \n Given Name: %@ \n Family Name: %@ \n EmailId: %@ \n",userId,idToken,fullName,givenName,familyName,email);
        
        RootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RootViewController"];
        [RootVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:RootVC animated:NO completion:nil];
    }
}
@end
