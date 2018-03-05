//
//  AppDelegate.m
//  mHealthDApp
//
//  Created by Sonam Agarwal on 11/17/17.
//  Copyright © 2017 Sonam Agarwal. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize finalFamilyDataArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    DebugLog(@"");
    if([[NSUserDefaults standardUserDefaults]valueForKey:FINALFAMILYDATAARRAY] == nil)
    {
        finalFamilyDataArray=[[NSMutableArray alloc]init];
        NSArray *imgFamilyArray=[[NSArray alloc]initWithObjects:@"Mother",@"Father",@"Brother",@"Sister", nil];
        NSArray *titleFamilyArray=[[NSArray alloc]initWithObjects:@"Worried Wendy",@"Hefty Harvey",@"Tricky Troy",@"Sports Susan", nil];
        NSArray *genderFamilyArray=[[NSArray alloc]initWithObjects:@"Female",@"Male",@"Male",@"Female", nil];
        NSArray *csiFamilyArray = [[NSArray alloc] initWithObjects:@"NA",@"NA",@"NA",@"NA", nil];
        
        for (int iCount=0; iCount<imgFamilyArray.count; iCount++)
        {
            NSArray *firstLastNameArr=[[titleFamilyArray objectAtIndex:iCount] componentsSeparatedByString:@" "];
            
            NSString *strData=[NSString stringWithFormat:@"%@#%@#%@#%@#%@",[firstLastNameArr objectAtIndex:0],[firstLastNameArr objectAtIndex:1],[genderFamilyArray objectAtIndex:iCount],[csiFamilyArray objectAtIndex:iCount],[imgFamilyArray objectAtIndex:iCount]];
            [finalFamilyDataArray addObject:strData];
            
        }
        [[NSUserDefaults standardUserDefaults] setObject:finalFamilyDataArray forKey:FINALFAMILYDATAARRAY];
    }
    else
    {
        finalFamilyDataArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]valueForKey:FINALFAMILYDATAARRAY]];

    }
    
    
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    DebugLog(@"");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
   DebugLog(@"");
    [[NSUserDefaults standardUserDefaults]setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"CurrentTime"] forKey:@"CurrentTime1"];
    [[NSUserDefaults standardUserDefaults]setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"LogArray"] forKey:@"LogArray1"];
     [[NSUserDefaults standardUserDefaults] synchronize];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    DebugLog(@"");
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    DebugLog(@"");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    DebugLog(@"");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    DebugLog(@"");
    NSString * query = url.query;
    NSArray * queriesArray = [query componentsSeparatedByString:@"&"];
    for (NSString * string in queriesArray) {
        NSArray * queryStringArray = [string componentsSeparatedByString:@"="];
        if([queryStringArray[0] isEqualToString:@"UniqueIdentifier"])
        {
            [[NSUserDefaults standardUserDefaults]setObject:queryStringArray[1] forKey:@"UniqueIdentifier"];
        }
        if([queryStringArray[0] isEqualToString:@"wcsi"])
        {
            [[NSUserDefaults standardUserDefaults]setObject:queryStringArray[1] forKey:@"wcsi"];
        }
        if([queryStringArray[0] isEqualToString:@"dpermissionshared"])
        {
            [[NSUserDefaults standardUserDefaults]setObject:queryStringArray[1] forKey:@"dpermissionshared"];
        }
    }
    
    if([url.query containsString:@"wcsi"])
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"WalletCsiPosted" object:nil];
    }
    if([url.query containsString:@"dpermissionshared"])
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"dpermissionsharedNotification" object:nil];
    }
    return true;
}

@end