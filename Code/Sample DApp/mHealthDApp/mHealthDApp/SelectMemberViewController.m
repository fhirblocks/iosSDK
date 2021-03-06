//
//  SelectMemberViewController.m
//  mHealthDApp
//
/*
 * Copyright 2018 BBM Health, LLC - All rights reserved
 * Confidential & Proprietary Information of BBM Health, LLC - Not for disclosure without written permission
 * FHIR is registered trademark of HL7 Intl
 *
 */

#import "SelectMemberViewController.h"
#import "SelectMemberTableViewCell.h"
#import "HeaderView.h"
#import "UICKeyChainStore.h"
#import "Constants.h"
#import "AddCSIViewController.h"
//#import "APIhandler.h"
#import "ServerSingleton.h"
#import "DejalActivityView.h"
#import "DocCollectionViewCell.h"
#import "DocCollectionViewCell_Ipad.h"


@interface SelectMemberViewController ()<HeaderViewDelegate>
{
    NSArray *imgFamilyArray;
    NSArray *titleFamilyArray;
    NSArray *namesArray;
    NSArray *fromDateArray;
    NSArray *toDateArray;
    NSArray * publicClaims;
    int selectedIndex;
    NSMutableArray *existingCaregiverDataArray;
    NSMutableString *strBecomeFriendData;
    
    SecKeyRef privateKey;
    SecKeyAlgorithm algorithm;
    NSDictionary *request_dic;
    
    NSMutableArray *caregiverPermissionDataArray;
    BOOL isCaregiverBool;
    
    int collectionTwoIndex;
}
@property (strong, nonatomic) IBOutlet UIView *viewForBtn;
@property (strong, nonatomic) IBOutlet UIView *backgroundVw;
@property (strong, nonatomic) IBOutlet UITableView *permissionDataTableView;
@property (strong, nonatomic) IBOutlet UIButton *updateBtn;
@property (strong, nonatomic) IBOutlet UIButton *btnBecomeFriend;
@property (strong, nonatomic) IBOutlet UIButton *btnInviteFriend;
//added changes for fetch permission call
@property (nonatomic) BOOL isFetchPermissions;
@property(nonatomic) NSString *endpoint;

@end

@implementation SelectMemberViewController
@synthesize permissionDataTableView;
@synthesize backgroundVw;
@synthesize userCollectionView;
@synthesize lblFromText,lblFromDate,lblToText,lblToDate;
@synthesize viewAppIcon;
@synthesize leadingToViewAppIcon;
- (IBAction)copyLink:(id)sender {
    DebugLog(@"");
    [UIPasteboard generalPasteboard].string =@"hello";
}

- (void)viewDidLoad {
    DebugLog(@"");
    [super viewDidLoad];
    collectionTwoIndex=0;
    existingCaregiverDataArray=[[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]valueForKey:FINALFAMILYDATAARRAY]];
    publicClaims = [[NSUserDefaults standardUserDefaults]valueForKey:@"PublicClaims"];
    caregiverPermissionDataArray=[[NSMutableArray alloc] init];

    
    strBecomeFriendData = [[NSMutableString alloc] initWithString:@""];
    [strBecomeFriendData appendString:[NSString stringWithFormat:@"%@",[[publicClaims objectAtIndex:1] objectForKey:@"value"]]];
    [strBecomeFriendData appendString:[NSString stringWithFormat:@"%@%@",COMPONENTS_SEPERATED_STRING,[[publicClaims objectAtIndex:3] objectForKey:@"value"]]];
    [strBecomeFriendData appendString:[NSString stringWithFormat:@"%@%@",COMPONENTS_SEPERATED_STRING,[[publicClaims objectAtIndex:4] objectForKey:@"value"]]];
    [strBecomeFriendData appendString:[NSString stringWithFormat:@"%@%@",COMPONENTS_SEPERATED_STRING,[[NSUserDefaults standardUserDefaults]valueForKey:@"dcsi"]]];
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor=[UIColor clearColor];
    self.modalPresentationStyle=UIModalPresentationCurrentContext;
    _updateBtn.layer.cornerRadius=5.0;
    
    
    
    selectedIndex=-1;
    NSNumber *isCaregiver;//= [[NSUserDefaults standardUserDefaults]valueForKey:@"isCaregiver"];
    NSString *isCaregiverFlow=[[NSUserDefaults standardUserDefaults]valueForKey:@"Flow"];
    
    if([isCaregiverFlow isEqualToString:@"Caregiver"])
    {
        isCaregiver=[NSNumber numberWithInt:1];
    }
    else
    {
        isCaregiver=[NSNumber numberWithInt:0];
    }
    isCaregiverBool=[isCaregiver boolValue];
    if(!isCaregiverBool)
    {
        if (imgFamilyArray == nil)
        {
            imgFamilyArray=[[NSArray alloc]initWithObjects:@"Patient",@"Mother",@"Father",@"Brother",@"Sister", nil];
        }
        if (titleFamilyArray == nil)
        {
            titleFamilyArray=[[NSArray alloc]initWithObjects:@"      ",@"Daughter",@"Father",@"Brother",@"Sister", nil];
        }
        namesArray=[NSArray arrayWithObjects:@"Hefty Harvey",@"Worried Wendy",@"Tim Watson",@"Michael Watson",@"Jenny Watson", nil];
        fromDateArray=[NSArray arrayWithObjects:@"",@"11/18/17",@"11/19/17",@"11/20/17",@"11/21/17", nil];
        toDateArray=[NSArray arrayWithObjects:@"",@"12/18/17",@"12/19/17",@"12/20/17",@"12/21/17", nil];
    }
    else{
        if (imgFamilyArray == nil)
        {
            imgFamilyArray=[[NSArray alloc]initWithObjects:@"Mother",@"Father",@"Brother",@"Sister", nil];
        }
        if (titleFamilyArray == nil)
        {
            titleFamilyArray=[[NSArray alloc]initWithObjects:@"Mother",@"Father",@"Brother",@"Sister", nil];
        }
        namesArray=[NSArray arrayWithObjects:@"Crystal Watson",@"Tim Watson",@"Michael Watson",@"Jenny Watson", nil];
        fromDateArray=[NSArray arrayWithObjects:@"11/18/17",@"11/19/17",@"11/20/17",@"11/21/17", nil];
        toDateArray=[NSArray arrayWithObjects:@"12/18/17",@"12/19/17",@"12/20/17",@"12/21/17", nil];
    }
    _viewForBtn.layer.shadowColor=[UIColor lightGrayColor].CGColor;
    _viewForBtn.layer.shadowOffset=CGSizeMake(0.0f, 0.0f);
    _viewForBtn.layer.shadowRadius=4.5f;
    _viewForBtn.layer.shadowOpacity=0.9f;
    _viewForBtn.layer.masksToBounds=NO;
     UIEdgeInsets shadowInset=UIEdgeInsetsMake(0, 0, -1.5f, 0);
    UIBezierPath *shadowPath1=[UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(_viewForBtn.bounds, shadowInset)];
    _viewForBtn.layer.shadowPath=shadowPath1.CGPath;
    
    
    
    if(isCaregiverBool)
    {
        [self fetchPermission];
    }
    else
    {
        if(caregiverPermissionDataArray.count == 0)
        {
            [self showNoDataPopup];
            self.viewFromToDate.hidden=YES;
        }
    }
    
     [self.userCollectionView registerNib:[UINib nibWithNibName:@"DocCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Doc"];
    
   /*CATransform3D perspectiveTransform = CATransform3DIdentity;
    perspectiveTransform.m34 = 1.0 / -300;
    self.userCollectionView.layer.transform =
    CATransform3DRotate(perspectiveTransform, (1.2 * M_PI / 180), 0.0f, -0.2f, 0.0f);*/
    // 5.5 , -0.2
    // Code for FromTo date view
    
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    perspectiveTransform.m34 = 1.0 / -100;
    
   
    self.viewFromToDate.layer.transform = CATransform3DRotate(perspectiveTransform, (40 * M_PI / 180), 10.0f, 0.0f, 0.0f);
    self.viewFromToDate.transform = CGAffineTransformMakeRotation(M_PI/22);
    self.viewFromToDate.layer.cornerRadius = 5; // this value vary as per your desire
    self.viewFromToDate.clipsToBounds = YES;
    self.viewFromToDate.backgroundColor=[UIColor clearColor];
    
    self.viewAppIcon.layer.cornerRadius = 10;
    self.viewAppIcon.clipsToBounds = YES;
    
    perspectiveTransform.m34 = 1.0 / -100;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        perspectiveTransform.m34 = 1.0 / -600;
    }
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        self.viewAppIcon.layer.transform =  CATransform3DRotate(perspectiveTransform, (1 * M_PI / 180), 0.0f, 1.5f, 0.0f);
    } else {
        self.viewAppIcon.layer.transform =  CATransform3DRotate(perspectiveTransform, (7 * M_PI / 180), 0.0f, 1.5f, 0.0f);
    }
   
    CGRect applicationFrame=[[UIScreen mainScreen] bounds];
    if(applicationFrame.size.height <= 480)
    {
        self.leadingToViewAppIcon.constant = 3;
    }
    
//    perspectiveTransform.m34 = 1.0 / 500;
//    self.userCollectionView.layer.transform = CATransform3DRotate(perspectiveTransform, (4 * M_PI / 180), 0.0f, -0.1f, 100.0f);
//    self.userCollectionView.layer.cornerRadius = 5; // this value vary as per your desire
//    self.userCollectionView.clipsToBounds = YES;

    perspectiveTransform.m34 = 1.0 / -300;

    self.userCollectionView.layer.transform = CATransform3DRotate(perspectiveTransform, (20 * M_PI / 180), 0.0f, -0.2f, 0.0f);
    //self.userCollectionView.transform = CGAffineTransformMakeRotation(M_PI/50);

    
    self.userCollectionView.backgroundColor=[UIColor clearColor];
    [self.userCollectionView reloadData];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden=NO;
    self.title=@"mHealthDApp";
    
    
}
-(void)showNoDataPopup
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"mHealthDApp" message:@"No Data Found" preferredStyle:UIAlertControllerStyleAlert];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self.navigationController popViewControllerAnimated:YES];
        
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    DebugLog(@"");
    [super viewWillAppear:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
-(IBAction)btnBackClicked:(id)sender
{
    DebugLog(@"");
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)fetchPermission
{
    DebugLog(@"");
    [self showBusyActivityView];
    _isFetchPermissions = YES;
    
    //APIhandler *h=[[APIhandler alloc]init];
    //h.delegate = self;
    
    mHealthApiHandler *apiHandler = [[mHealthApiHandler alloc]init];
    apiHandler.delegate = self;
    
    _endpoint=@"fetchPermissionsGivenToMe";
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    dateformatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    time_t currentTime = [[ServerSingleton sharedServerSingleton]time];
    
    NSString *currentDate  = [dateformatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:currentTime]];
    NSString *guid = [[NSUserDefaults standardUserDefaults]valueForKey:@"dcsi"];
    NSString *nonce = [self genRandStringLength:36];
    
    NSLog(@"current Date :%@ ",currentDate);
    NSLog(@"%@",guid);
    NSLog(@"%@", nonce);
    
    NSString *payload=[NSString stringWithFormat:@"%@%@%@%@%@"
                       //                       %@%@"
                       //                       ,@"|",guid,
                       ,@"|",currentDate,@"|",nonce,@"|"];
    
    NSLog(@"%@", payload);
    
    NSData * dataForSignature = [payload dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData * privateKeyData = [[NSUserDefaults standardUserDefaults]valueForKey:@"PrivateKey"];
    NSDictionary* options = @{(id)kSecAttrKeyType: (id)kSecAttrKeyTypeEC,
                              (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPrivate,
                              (id)kSecAttrKeySizeInBits: @256,
                              };
    CFErrorRef error = NULL;
    privateKey = SecKeyCreateWithData((__bridge CFDataRef)privateKeyData,
                                      (__bridge CFDictionaryRef)options,
                                      &error);
    if (!privateKey) {
        NSError *err = CFBridgingRelease(error);  // ARC takes ownership
        // Handle the error. . .
    } else {  }
    // Creation of Signature
    NSData *signature=[self createSignature:dataForSignature withKey:privateKey];
    NSString *signatureString = [signature base64EncodedStringWithOptions:0];
    request_dic=[[NSDictionary alloc]initWithObjectsAndKeys:@"ecdsa",@"cipher",guid,@"csiGuid",currentDate,@"dateTime",nonce,@"nonce",signatureString,@"signature" ,nil];
    //picker
    
    //#if ISDEBUG
    //
    //#if ISENDSCREEN
    NSLog(@"in end screen debug mode");
    NSMutableArray * array1 = (NSMutableArray *)[[NSUserDefaults standardUserDefaults] valueForKey:@"PermissionsLogArray"];
    NSMutableArray * array2 = [NSMutableArray arrayWithArray:array1];
    
    [[NSUserDefaults standardUserDefaults]setObject:array2 forKey:@"PermissionsLogArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //    [debugView setHidden:true];
    //[h createSessionforPermissionEndPoint:_endpoint withModelDictionary:request_dic];
    [apiHandler createSessionforPermissionEndPoint:_endpoint withModelDictionary:request_dic];

}
- (NSString *)genRandStringLength:(int)len {
    DebugLog(@"");
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        if(i==8||i==13||i==18||i==23)
        {
            [randomString appendString:@"-"];
            continue;
        }
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}
-(NSData*)createSignature:(NSData*)data2sign withKey:(SecKeyRef)privateKey
{
    DebugLog(@"");
    // Algorithm for keys Generation
    algorithm = kSecKeyAlgorithmECDSASignatureMessageX962SHA256;
    
    BOOL canSign = SecKeyIsAlgorithmSupported(privateKey,
                                              kSecKeyOperationTypeSign,
                                              algorithm);
    
    
    NSLog(@"Can You sign: %@",canSign ? @"YES" : @"NO");
    
    NSData* signature = nil;
    if (canSign) {
        CFErrorRef error = NULL;
        signature = (NSData*)CFBridgingRelease(       // ARC takes ownership
                                               SecKeyCreateSignature(privateKey,
                                                                     algorithm,
                                                                     (__bridge CFDataRef)data2sign,
                                                                     &error));
        if (!signature) {
            NSError *err = CFBridgingRelease(error);  // ARC takes ownership
            NSLog(@"%@", err);
            // Handle the error. . .
        }
    }
    
    return signature;
}
-(void)handleData :(NSData*)data errr:(NSError*)error
{
    DebugLog(@"");
    if(error)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                       message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                              }];
        
        [alert addAction:firstAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        //        [NSException raise:@"Exception downloading data " format:@"%@",error.localizedDescription];
#if ISDEBUG
        
#if ISENDSCREEN
        NSLog(@"in end screen debug mode");
        NSMutableArray * array1 = (NSMutableArray *)[[NSUserDefaults standardUserDefaults] valueForKey:@"PermissionsLogArray"];
        NSMutableArray * array2 = [NSMutableArray arrayWithArray:array1];
        [array2 addObject:[NSString stringWithFormat:@"%@%@%@",Permission_Base_URL,_endpoint,request_dic]];
        //    [[NSUserDefaults standardUserDefaults]setObject:array2 forKey:@"LogArray"];
        [[NSUserDefaults standardUserDefaults]setObject:array2 forKey:@"PermissionsLogArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            //    [_debugView setHidden:true];
            //    [_debugContainerView setHidden:true];
        });
        
#else
        dispatch_async(dispatch_get_main_queue(), ^{
            [_debugView setHidden:true];
            [_responseView setHidden:false];
            //[_debugContainerView setHidden:false];
            [_responseLabel setText:[NSString stringWithFormat:@"error: %@",error.localizedDescription]];
        });
#endif
#else
        NSLog(@"not in debug mode");
        dispatch_async(dispatch_get_main_queue(), ^{
            [_debugView setHidden:true];
            //    [_debugContainerView setHidden:true];
        });
#endif
        return;
    }
    NSError *jsonError;
    //    indexArray = [[NSMutableArray alloc]init];
    //    indexFamilyArray = [[NSMutableArray alloc]init];
    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    NSMutableArray *Array = [self fetchPermissionDataParsing:data];
    
    /*NSArray *arrData =[dict objectForKey:@"permissions"];
    for (int iCount=0; iCount<[arrData count]; iCount++)
    {
        NSDictionary *dictData=arrData[iCount];
        NSString *strGrantingGUID = [dictData objectForKey:@"grantingCsiGuid"];
        NSString *startTime=[dictData objectForKey:@"startTime"];
        NSString *endTime=[dictData objectForKey:@"endTime"];

        for (int jCount=0; jCount<[existingCaregiverDataArray count]; jCount++)
        {
            NSMutableString *strPermission =[[NSMutableString alloc] initWithString:existingCaregiverDataArray[jCount]];
            [strPermission appendString:[NSString stringWithFormat:@"#%@",startTime]];
            [strPermission appendString:[NSString stringWithFormat:@"#%@",endTime]];
            
            
            NSArray *arrPermission =[strPermission componentsSeparatedByString:COMPONENTS_SEPERATED_STRING];
          
            if([strGrantingGUID isEqualToString:arrPermission[3]])
            {
                [caregiverPermissionDataArray addObject:strPermission];
                break;
                
            }
            
        }
        
    }
    NSLog(@"%@",caregiverPermissionDataArray);
    dispatch_async(dispatch_get_main_queue(), ^{
        [permissionDataTableView reloadData];
        [userCollectionView reloadData];
        [self hideBusyActivityView];
       // backgroundVw.backgroundColor=[UIColor greenColor];
        backgroundVw.alpha=0.4;
        if(caregiverPermissionDataArray.count == 0)
        {
            [self showNoDataPopup];
            self.viewFromToDate.hidden=YES;
        }
 });
    */
    
}
-(NSMutableArray*)fetchPermissionDataParsing:(NSData*)responseData
{
    DebugLog(@"");
    NSMutableArray *CSIdataArray = [[NSMutableArray alloc] init];
    NSString *responseStr = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    DebugLog(@"response string==> %@",responseStr);
    NSError *jsonError;
    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
    
    if ([dict objectForKey:@"permissionNodess"] != [NSNull null])
    {
        NSArray *arrData = [dict objectForKey:@"permissionNodess"];
        dict = arrData[0];
        arrData = [dict objectForKey:@"permissionNodes"];
        
        if(arrData.count>0)
        {
            dict = arrData[0];
            //arrData = [dict objectForKey:@"permissionNodes"];
            
            for (NSDictionary *dictCSI in arrData) {
                NSLog(@"dictDoctor %@",dictCSI);
                NSDictionary *permissionDictData = [dictCSI objectForKey:@"permission"];
                NSString *strPermissionedCsiGuid = [permissionDictData objectForKey:@"permissionedCsiGuid"];
                NSString *startTime=[permissionDictData objectForKey:@"startTime"];
                NSString *endTime=[permissionDictData objectForKey:@"endTime"];
                
                for (int jCount=0; jCount<[existingCaregiverDataArray count]; jCount++)
                {
                    NSMutableString *strPermission =[[NSMutableString alloc] initWithString:existingCaregiverDataArray[jCount]];
                    [strPermission appendString:[NSString stringWithFormat:@"#%@",startTime]];
                    [strPermission appendString:[NSString stringWithFormat:@"#%@",endTime]];
                    
                    
                    NSArray *arrPermission =[strPermission componentsSeparatedByString:COMPONENTS_SEPERATED_STRING];
                    
                    if([strPermissionedCsiGuid isEqualToString:arrPermission[3]])
                    {
                        [caregiverPermissionDataArray addObject:strPermission];
                        break;
                    }
                    
                }
                
                [CSIdataArray addObject:strPermissionedCsiGuid];
            }
            NSLog(@"final csi Array %@",CSIdataArray);
            NSLog(@"%@",caregiverPermissionDataArray);

        }
        else
        {
            DebugLog(@"no data array found");
        }
        
    }
    else
    {
        DebugLog(@"no permission nodes present");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [permissionDataTableView reloadData];
        [userCollectionView reloadData];
        [self hideBusyActivityView];
        // backgroundVw.backgroundColor=[UIColor greenColor];
        backgroundVw.alpha=0.4;
        if(caregiverPermissionDataArray.count == 0)
        {
            [self showNoDataPopup];
            self.viewFromToDate.hidden=YES;
        }
    });
    
    return CSIdataArray;
}
-(void)closeButtonTapped
{
    DebugLog(@"");
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)resetButtonTapped:(id)sender {
    DebugLog(@"");
    [UICKeyChainStore setString:nil forKey:@"dcsi" service:@"MyService"];
    [UICKeyChainStore setString:nil forKey:@"dSharedPermissions" service:@"MyService"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"UniqueIdentifier"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"dcsi"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"dpermissionshared"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"wcsi"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"Flow"];
}
- (IBAction)logoutButtonTapped:(id)sender {
    DebugLog(@"");
    exit (0);
}
- (IBAction)btnInviteFriendClicked:(id)sender {
    DebugLog(@"");
    [self performSegueWithIdentifier:@"SelectMemberToAddCSI" sender:self];//PermissionViewToViewController

}
- (IBAction)btnBecomeFriendClicked:(id)sender {
    DebugLog(@"");
    [UIPasteboard generalPasteboard].string = strBecomeFriendData;

}


- (void)didReceiveMemoryWarning {
    DebugLog(@"");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)updateBtnTapped:(id)sender {
    DebugLog(@"");
    if(!isCaregiverBool)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Selected_Index" object:[NSNumber numberWithInt:selectedIndex]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

#pragma mark -
#pragma mark ==============================
#pragma mark UItableview Delegates
#pragma mark ==============================
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if(caregiverPermissionDataArray.count>0)
//        return 2;
//    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(section == 0)
//    {
//        return 1;
//    }
//    else
//    {
        return caregiverPermissionDataArray.count;
//    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!isCaregiverBool)
    {
       NSString *identifier=@"Cell";
       NSString *firstName = [(NSDictionary *)[publicClaims objectAtIndex:1] valueForKey:@"value"];
       NSString *lastName = [(NSDictionary *)[publicClaims objectAtIndex:3] valueForKey:@"value"];
       SelectMemberTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
       cell.titleLabel.text=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
       cell.subtitle_Label.text=[titleFamilyArray objectAtIndex:indexPath.row];
       
       BOOL isDataExisted=NO;
       NSString *gender;
       for (int iCount=0; iCount<existingCaregiverDataArray.count; iCount++)
       {
           NSString *strData=existingCaregiverDataArray[iCount];
           NSArray *arrData=[strData componentsSeparatedByString:COMPONENTS_SEPERATED_STRING];
           //if([firstName.lowercaseString isEqualToString:[NSString stringWithFormat:@"%@",arrData[0]].lowercaseString] && [lastName.lowercaseString isEqualToString:[NSString stringWithFormat:@"%@",arrData[1]].lowercaseString])
           if([firstName.lowercaseString isEqualToString:[NSString stringWithFormat:@"%@",arrData[0]].lowercaseString] && [lastName.lowercaseString isEqualToString:[NSString stringWithFormat:@"%@",arrData[1]].lowercaseString])
           {
               //set image for existing
               if(![arrData[4] isEqualToString:@"NA"])
               {
                   cell.image.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",arrData[4]]];
               }
               else
               {
                   gender = arrData[2];
                   
               }
               isDataExisted=YES;
               break;
           }
           
           
       }
       if(!isDataExisted)
       {
           gender = [(NSDictionary *)[publicClaims objectAtIndex:4] valueForKey:@"value"];
       }
       
       if([gender.lowercaseString isEqualToString:@"male"])
       {
           cell.image.image=[UIImage imageNamed:@"maledefault.png"];
       }
       else if([gender.lowercaseString isEqualToString:@"female"])
       {
           cell.image.image=[UIImage imageNamed:@"femaledefault.png"];
       }
       
    
       
       NSString *myString = [NSString stringWithFormat:@"From: %@  To: %@",fromDateArray[indexPath.row],toDateArray[indexPath.row]];
       //Create mutable string from original one
       NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:myString];
       
       //Fing range of the string you want to change colour
       //If you need to change colour in more that one place just repeat it
       NSRange range = [myString rangeOfString:fromDateArray[indexPath.row]];
       [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1] range:range];
       [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0f] range:range];
       NSRange range1 = [myString rangeOfString:toDateArray[indexPath.row]];
       [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1] range:range1];
       [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0f] range:range1];
       
       //Add it to the label - notice its not text property but it's attributeText
       cell.fromtolabel.attributedText = attString;
       
       if(selectedIndex==indexPath.row)
       {
           cell.radioImage.image=[UIImage imageNamed:@"radio_btn"];
       }
       else
       {
           cell.radioImage.image=[UIImage imageNamed:@"radio_uncheck"];
       }
       if(indexPath.row == 0 && !(isCaregiverBool))
       {
           cell.fromtolabel.text = @"Me-Patient";
       }
       if(selectedIndex==-1 && indexPath.row==0)
       {
           cell.radioImage.image=[UIImage imageNamed:@"radio_btn"];
           
           return cell;
       }
       //    NSString *myString = [NSString stringWithFormat:@"From: %@  To: %@",fromDateArray[indexPath.row],toDateArray[indexPath.row]];
       //    //Create mutable string from original one
       //    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:myString];
       //
       //    //Fing range of the string you want to change colour
       //    //If you need to change colour in more that one place just repeat it
       //    NSRange range = [myString rangeOfString:fromDateArray[indexPath.row]];
       //    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1] range:range];
       //    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0f] range:range];
       //    NSRange range1 = [myString rangeOfString:toDateArray[indexPath.row]];
       //    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1] range:range1];
       //    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0f] range:range1];
       //
       //    //Add it to the label - notice its not text property but it's attributeText
       //    cell.fromtolabel.attributedText = attString;
       return cell;
   }
    else
    {
        NSString *identifier=@"Cell";
        SelectMemberTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        NSString *strData = caregiverPermissionDataArray[indexPath.row];
        NSArray *arrData = [strData componentsSeparatedByString:COMPONENTS_SEPERATED_STRING];
        
        cell.titleLabel.text=[NSString stringWithFormat:@"%@ %@",arrData[0],arrData[1]];
       if(![arrData[4] isEqualToString:@"NA"])
           cell.subtitle_Label.text=arrData[4];
        
        NSString *startTime=arrData[5];
        NSString *endTime=arrData[6];
        
        if(![arrData[4] isEqualToString:@"NA"])
        {
            cell.image.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",arrData[4]]];
        }
        else
        {
            NSString *gender = arrData[2];
            if([gender.lowercaseString isEqualToString:@"male"])
            {
                cell.image.image=[UIImage imageNamed:@"maledefault.png"];
            }
            else if([gender.lowercaseString isEqualToString:@"female"])
            {
                cell.image.image=[UIImage imageNamed:@"femaledefault.png"];
            }
        }
        
        NSDateFormatter *dateformatter1 = [[NSDateFormatter alloc] init];
        [dateformatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        dateformatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        NSDate *startDateInDate = [dateformatter1 dateFromString:startTime];
        NSDate *endDateInDate = [dateformatter1 dateFromString:endTime];
        
        [dateformatter1 setDateFormat:@"dd/MM/yy"];
        [dateformatter1 setTimeZone:[NSTimeZone localTimeZone]];
        NSString *formattedStartTime = [dateformatter1 stringFromDate:startDateInDate];
        NSString *formattedEndTime = [dateformatter1 stringFromDate:endDateInDate];

        
        NSString *myString = [NSString stringWithFormat:@"From: %@  To: %@",formattedStartTime,formattedEndTime];
        //Create mutable string from original one
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:myString];
        
        //Fing range of the string you want to change colour
        //If you need to change colour in more that one place just repeat it
        NSRange range = [myString rangeOfString:fromDateArray[indexPath.row]];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1] range:range];
        [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0f] range:range];
        NSRange range1 = [myString rangeOfString:toDateArray[indexPath.row]];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1] range:range1];
        [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0f] range:range1];
        
        //Add it to the label - notice its not text property but it's attributeText
        cell.fromtolabel.attributedText = attString;
        
        if(selectedIndex==indexPath.row)
        {
            cell.radioImage.image=[UIImage imageNamed:@"radio_btn"];
        }
        else
        {
            cell.radioImage.image=[UIImage imageNamed:@"radio_uncheck"];
        }
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 71.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *viewArray=[[NSBundle mainBundle]loadNibNamed:@"HeaderView" owner:self options:nil];
    HeaderView *view=(HeaderView *)[viewArray objectAtIndex:0];
    view.delegate = self;
    return view;
    
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    NSArray *viewArray=[[NSBundle mainBundle]loadNibNamed:@"FooterView" owner:self options:nil];
//    UIView *view=[viewArray objectAtIndex:0];
//    return view;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DebugLog(@"");
    if(!isCaregiverBool)
    {
        selectedIndex=(int)indexPath.row;
        [permissionDataTableView reloadData];
        [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithInt:selectedIndex] forKey:@"Selected_Index"];
    }
    else
    {
        
        selectedIndex=(int)indexPath.row;
        [permissionDataTableView reloadData];
         [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithInt:selectedIndex] forKey:@"Selected_Index"];
        
        [[NSUserDefaults standardUserDefaults] setObject:caregiverPermissionDataArray[indexPath.row] forKey:@"ProfileImageData"];
        
    }
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 70;
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DebugLog(@"");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SelectMemberToAddCSI"])
    {
        AddCSIViewController *addCSIViewController = segue.destinationViewController;
        addCSIViewController.strFromScreen=@"PatientFlow";
        
    }
}

-(void) showBusyActivityView
{
    DebugLog(@"");
    [DejalBezelActivityView activityViewForView:self.view];
}

-(void) hideBusyActivityView
{
    DebugLog(@"");
    [DejalBezelActivityView removeViewAnimated:YES];
}
#pragma mark -
#pragma mark ==============================
#pragma mark Collection View Delegates
#pragma mark ==============================
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return caregiverPermissionDataArray.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if ([[UIScreen mainScreen] bounds].size.height == 568.0)
    {
        return UIEdgeInsetsMake(12,15,0,15);
    }
    else if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        return UIEdgeInsetsMake(10, 60, 10, 60);
    }
    else{
        return UIEdgeInsetsMake(-10, 60, 0, 60);
    }
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        NSString *strData = caregiverPermissionDataArray[indexPath.row];
        NSArray *arrData = [strData componentsSeparatedByString:COMPONENTS_SEPERATED_STRING];
        
        DocCollectionViewCell_Ipad *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"Doc" forIndexPath:indexPath];
        cell.backgroundColor=[UIColor whiteColor];
        cell.docName.textColor = [UIColor colorWithRed:78.0f/255 green:88.0f/255 blue:90.0f/255 alpha:1.0f];
        cell.docType.textColor = [UIColor colorWithRed:121.0f/255 green:131.0f/255 blue:133.0f/255 alpha:1.0f];
       // cell.docImg.image=[UIImage imageNamed:@"Doc1.png"];
        cell.docName.text =[NSString stringWithFormat:@"%@ %@",arrData[0],arrData[1]];
        //cell.docType.text =@"Cardio";
        cell.docName.numberOfLines = 2;
        
        if(![arrData[4] isEqualToString:@"NA"])
        {
            cell.docImg.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",arrData[4]]];
        }
        else
        {
            NSString *gender = arrData[2];
            if([gender.lowercaseString isEqualToString:@"male"])
            {
                cell.docImg.image=[UIImage imageNamed:@"maledefault.png"];
            }
            else if([gender.lowercaseString isEqualToString:@"female"])
            {
                cell.docImg.image=[UIImage imageNamed:@"femaledefault.png"];
            }
        }
        
        cell.alpha=0.5;
        
        cell.backgroundColor=[UIColor clearColor];
        cell.layer.shadowOpacity = 0;
        cell.layer.shadowRadius = 0.0;
        
        if(indexPath.row==collectionTwoIndex)
        {
            cell.layer.shadowColor = [UIColor lightGrayColor].CGColor;
            cell.layer.shadowOffset = CGSizeMake(5,5);
            cell.layer.shadowOpacity = 1;
            cell.layer.shadowRadius = 5.0;
            cell.clipsToBounds = false;
            cell.layer.masksToBounds = false;
        }
        return cell;
    }
    else
    {
        
        NSString *strData = caregiverPermissionDataArray[indexPath.row];
        NSArray *arrData = [strData componentsSeparatedByString:COMPONENTS_SEPERATED_STRING];

        
        DocCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"Doc" forIndexPath:indexPath];
        cell.backgroundColor=[UIColor whiteColor];
        cell.docName.textColor = [UIColor colorWithRed:78.0f/255 green:88.0f/255 blue:90.0f/255 alpha:1.0f];
        cell.docType.textColor = [UIColor colorWithRed:121.0f/255 green:131.0f/255 blue:133.0f/255 alpha:1.0f];
        //cell.docImg.image=[UIImage imageNamed:@"Doc1.png"];
        cell.docName.text =[NSString stringWithFormat:@"%@ %@",arrData[0],arrData[1]];
        
        if(![arrData[4] isEqualToString:@"NA"])
        {
            cell.docImg.image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",arrData[4]]];
        }
        else
        {
            NSString *gender = arrData[2];
            if([gender.lowercaseString isEqualToString:@"male"])
            {
                cell.docImg.image=[UIImage imageNamed:@"maledefault.png"];
            }
            else if([gender.lowercaseString isEqualToString:@"female"])
            {
                cell.docImg.image=[UIImage imageNamed:@"femaledefault.png"];
            }
        }
        
        
        cell.alpha=0.5;
        
        cell.backgroundColor=[UIColor clearColor];
        cell.layer.shadowOpacity = 0;
        cell.layer.shadowRadius = 0.0;
        
        if(indexPath.row==collectionTwoIndex)
        {
            cell.layer.shadowColor = [UIColor lightGrayColor].CGColor;
            cell.layer.shadowOffset = CGSizeMake(5,5);
            cell.layer.shadowOpacity = 1;
            cell.layer.shadowRadius = 5.0;
            cell.clipsToBounds = false;
            cell.layer.masksToBounds = false;
        }
        return cell;
    }
    return nil;
}
-(void)selectCenterCell{
    DebugLog(@"");
    NSIndexPath *indexPath;
    if([[self.userCollectionView visibleCells] count] == 0)
    {
        return;
    }
    UICollectionViewCell *closestCell = [self.userCollectionView visibleCells][0];
    for (UICollectionViewCell *cell in [self.userCollectionView visibleCells]) {
        
        int closestCellDelta = fabs(closestCell.center.x - self.userCollectionView.bounds.size.width/2.0 - self.userCollectionView.contentOffset.x);
        int cellDelta = fabs(cell.center.x - self.userCollectionView.bounds.size.width/2.0 - self.userCollectionView.contentOffset.x);
        if (cellDelta < closestCellDelta){
            closestCell = cell;
        }
        
        indexPath = [self.userCollectionView indexPathForCell:closestCell];
        NSLog(@"%@",indexPath);
    }
    collectionTwoIndex=(int)indexPath.row;
   
    
    NSString *strData = caregiverPermissionDataArray[collectionTwoIndex];
    NSArray *arrData = [strData componentsSeparatedByString:COMPONENTS_SEPERATED_STRING];
    
    NSString *startTime=arrData[5];
    NSString *endTime=arrData[6];
    
    NSDateFormatter *dateformatter1 = [[NSDateFormatter alloc] init];
    [dateformatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    dateformatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    NSDate *startDateInDate = [dateformatter1 dateFromString:startTime];
    NSDate *endDateInDate = [dateformatter1 dateFromString:endTime];
    
    [dateformatter1 setDateFormat:@"dd/MM/yy"];
    [dateformatter1 setTimeZone:[NSTimeZone localTimeZone]];
    NSString *formattedStartTime = [dateformatter1 stringFromDate:startDateInDate];
    NSString *formattedEndTime = [dateformatter1 stringFromDate:endDateInDate];
    
    //NSString *myString = [NSString stringWithFormat:@"From:%@ \nTo:%@",formattedStartTime,formattedEndTime];
    
    lblFromDate.text=formattedStartTime;
    lblToDate.text=formattedEndTime;
    //Create mutable string from original one
   
   /* NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:myString];
    
    //Fing range of the string you want to change colour
    //If you need to change colour in more that one place just repeat it
    NSRange range = [myString rangeOfString:fromDateArray[indexPath.row]];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1] range:range];
    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0f] range:range];
    NSRange range1 = [myString rangeOfString:toDateArray[indexPath.row]];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:133.0/255.0 green:133.0/255.0 blue:133.0/255.0 alpha:1] range:range1];
    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0f] range:range1];*/
        
    NSLog(@"caregiver permission array %@",caregiverPermissionDataArray[collectionTwoIndex]);
    
    
    
    // [self.collectionOne reloadData];
    [self.userCollectionView reloadData];
    [self.userCollectionView layoutIfNeeded]; // imp line
    // [self.collectionOne scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    [self.userCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //Center Align and Auto Select Center Cell in Doctor Collection View
    DebugLog(@"");
            [self selectCenterCell];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate{
            DebugLog(@"");
          //  [self selectCenterCell];
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DebugLog(@"");
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        return CGSizeMake(270, 461);
    }
    else
    {
        return CGSizeMake(180, 300);
    }
}
@end
