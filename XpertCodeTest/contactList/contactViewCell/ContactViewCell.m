//
//  ContactViewCell.m
//  XpertCodeTest
//
//  Created by Luis Guzman on 11/7/26.
//

#import "ContactViewCell.h"

@implementation ContactViewCell
@synthesize contactImage;
@synthesize nameLabel;
@synthesize phoneLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setContact: (Contact*) contact {
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    self.phoneLabel.text = contact.phone;
}

@end
