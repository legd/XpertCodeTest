//
//  CoreDataManager.m
//  XpertCodeTest
//
//  Created by Luis Guzman on 11/7/26.
//

#import "CoreDataManager.h"

@interface CoreDataManager ()
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@end

@implementation CoreDataManager

+ (instancetype)shared {
    static CoreDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        sharedInstance = [[CoreDataManager alloc] initWithInMemoryStore:NO];
        sharedInstance = [[CoreDataManager alloc] initWithInMemoryStore:YES];
    });
    return sharedInstance;
}

- (instancetype)initWithInMemoryStore:(BOOL)inMemory {
    self = [super init];
    if (self) {
        _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"XpertCodeTest"];

        if (inMemory) {
            NSPersistentStoreDescription *description = [[NSPersistentStoreDescription alloc] init];
            description.type = NSInMemoryStoreType;
            _persistentContainer.persistentStoreDescriptions = @[description];
        }

        __block NSError *loadError = nil;
        [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * _Nonnull storeDescription, NSError * _Nullable error) {
            if (error) {
                loadError = error;
                NSLog(@"[CoreDataManager] Error loading PersistentContainer: %@", error);
            }
        }];
        NSAssert(loadError == nil, @"[CoreDataManager] The local persistence could not be initialize: %@", loadError);

        _persistentContainer.viewContext.automaticallyMergesChangesFromParent = YES;
        _persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

        // Sample data for quick tests
        if (inMemory) {
            [self seedTestData];
        }
    }
    return self;
}

- (void)seedTestData {
    Contact *testContact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                         inManagedObjectContext:self.viewContext]; // TODO:
    testContact.identifier = [[NSUUID UUID] UUIDString];
    testContact.firstName = @"John";
    testContact.lastName = @"Appleseed";
    testContact.phone = @"123-456-7890";
    testContact.imageURL = @"N/A";
    [self saveContext];
}

- (NSManagedObjectContext *)viewContext {
    return self.persistentContainer.viewContext;
}

#pragma mark - CRUD

- (void)createContactWithFirstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                             phone:(NSString *)phone
                          imageURL:(nullable NSString *)imageURL {
    Contact *contact = [[Contact alloc] initWithContext:self.viewContext];
    contact.identifier = [[NSUUID UUID] UUIDString];
    contact.firstName = firstName;
    contact.lastName = lastName;
    contact.phone = phone;
    contact.imageURL = imageURL;
    [self saveContext];
}

- (NSArray<Contact *> *)fetchAllContacts {
    NSFetchRequest<Contact *> *request = [Contact fetchRequest];
    request.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
        [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]
    ];

    NSError *error = nil;
    NSArray<Contact *> *results = [self.viewContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"[CoreDataManager] Error getting the contacts: %@", error);
        return @[];
    }
    return results;
}

- (NSArray<Contact *> *)searchContactsWithText:(NSString *)text {
    if (text.length == 0) {
        return [self fetchAllContacts];
    }

    NSFetchRequest<Contact *> *request = [Contact fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:
                          @"firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@ OR phone CONTAINS[cd] %@",
                          text, text, text];
    request.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
        [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]
    ];

    NSError *error = nil;
    NSArray<Contact *> *results = [self.viewContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"[CoreDataManager] Error searching for contacts: %@", error);
        return @[];
    }
    return results;
}

- (void)deleteContact:(Contact *)contact {
    [self.viewContext deleteObject:contact];
    [self saveContext];
}

- (void)deleteContacts:(NSArray<Contact *> *)contacts {
    for (Contact *contact in contacts) {
        [self.viewContext deleteObject:contact];
    }
    [self saveContext];
}

- (void)saveContext {
    NSManagedObjectContext *context = self.viewContext;
    if ([context hasChanges]) {
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"[CoreDataManager] Error trying to save context: %@", error);
        }
    }
}

@end
