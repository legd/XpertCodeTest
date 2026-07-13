//
//  ContactListViewController.h
//  XpertCodeTest
//
//  Created by Luis Guzman on 10/7/26.
//

#ifndef ContactListViewController_h
#define ContactListViewController_h

#import <UIKit/UIKit.h>
#import "ContactViewCell.h"
#import "CoreDataManager.h"
#import "XpertCodeTest-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactListViewController : UITableViewController <AddContactDelegate>

@end

NS_ASSUME_NONNULL_END

#endif /* ContactListViewController_h */
