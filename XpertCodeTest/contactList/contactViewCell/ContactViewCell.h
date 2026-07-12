//
//  ContactViewCell.h
//  XpertCodeTest
//
//  Created by Luis Guzman on 11/7/26.
//

#ifndef ContactViewCell_h
#define ContactViewCell_h

#import <UIKit/UIKit.h>
#import "Contact+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *contactImage;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;

- (void)setContact:(Contact *) contact;

@end

NS_ASSUME_NONNULL_END

#endif /* ContactViewCell_h */
