//
//  SelectMemberTableViewCell.h
//  mHealthDApp
//
//  Created by Sonam Agarwal on 11/17/17.
//  Copyright © 2017 Sonam Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectMemberTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitle_Label;
@property (strong, nonatomic) IBOutlet UIImageView *radioImage;
@property (strong, nonatomic) IBOutlet UILabel *fromtolabel;

@end