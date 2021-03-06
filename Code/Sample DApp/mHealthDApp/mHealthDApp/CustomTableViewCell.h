//
//  CustomTableViewCell.h
//  MHealthApp
//
/*
 * Copyright 2018 BBM Health, LLC - All rights reserved
 * Confidential & Proprietary Information of BBM Health, LLC - Not for disclosure without written permission
 * FHIR is registered trademark of HL7 Intl
 *
 */

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *checkBtn;

@property (strong, nonatomic) IBOutlet UILabel *cell_title;
@property (strong, nonatomic) IBOutlet UILabel *cell_subtitle;

@property (weak, nonatomic) IBOutlet UIView *viewOptionalLine;


@end
