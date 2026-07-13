//
//  CoreDataManager.h
//  XpertCodeTest
//
//  Created by Luis Guzman on 11/7/26.
//

#ifndef CoreDataManager_h
#define CoreDataManager_h

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Contact+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataManager : NSObject

/// Singlenton instance to access core data
@property (class, nonatomic, readonly) CoreDataManager *shared;

/// Main context to be use in meain thread
// TODO:- 
@property (nonatomic, strong, readonly) NSManagedObjectContext *viewContext;

/// Designated initializer, ready to be use as part of Unit Tests
- (instancetype)initWithInMemoryStore:(BOOL)inMemory NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(inMemoryStore:));
- (instancetype)init NS_UNAVAILABLE;

- (void)createContactWithFirstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                             phone:(NSString *)phone
                          imageURL:(nullable NSString *)imageURL
                        completion:(void (^)(int, NSError * _Nullable))completion
    NS_SWIFT_NAME(createContact(withFirstName:lastName:phone:imageURL:completion:));

- (NSArray<Contact *> *)fetchAllContacts;

/// Search by any field
- (NSArray<Contact *> *)searchContactsWithText:(NSString *)text
    NS_SWIFT_NAME(searchContacts(withText:));

- (void)deleteContact:(Contact *)contact NS_SWIFT_NAME(delete(_:));

/// Delete multiple contatcs at the same time
- (void)deleteContacts:(NSArray<Contact *> *)contacts NS_SWIFT_NAME(delete(_:));

///  Save changes
- (void)saveContext:(nonnull void (^)(int result, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END

#endif /* CoreDataManager_h */
