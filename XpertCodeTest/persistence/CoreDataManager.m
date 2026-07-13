//
//  CoreDataManager.m
//  XpertCodeTest
//
//  Created by Luis Guzman on 11/7/26.
//

#import "CoreDataManager.h"

static int const SUCCESS = 0;
static int const FAIL = 1;

@interface CoreDataManager ()
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@end

@implementation CoreDataManager

+ (instancetype)shared {
    static CoreDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        sharedInstance = [[CoreDataManager alloc] initWithInMemoryStore:NO];
        sharedInstance = [[CoreDataManager alloc] initWithInMemoryStore:YES]; // TIP: For quick testing purposes only.
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
                                                         inManagedObjectContext:self.viewContext]; 
    testContact.identifier = [[NSUUID UUID] UUIDString];
    testContact.firstName = @"John";
    testContact.lastName = @"Appleseed";
    testContact.phone = @"123-456-7890";
    testContact.imageURL = @"https://randomuser.me/api/portraits/med/men/5.jpg";
    [self saveContext:^(int result, NSError *error){ }];
}

- (NSManagedObjectContext *)viewContext {
    return self.persistentContainer.viewContext;
}

#pragma mark - CRUD

- (void)createContactWithFirstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                             phone:(NSString *)phone
                          imageURL:(nullable NSString *)imageURL
                        completion:(nonnull void (^)(int result, NSError * _Nullable))completion {
    Contact *contact = [[Contact alloc] initWithContext:self.viewContext];
    contact.identifier = [[NSUUID UUID] UUIDString];
    contact.firstName = firstName;
    contact.lastName = lastName;
    contact.phone = phone;
    contact.imageURL = imageURL;
    [self saveContext:completion];
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
    [self saveContext:^(int result, NSError *error){
        if (result == FAIL) {
            NSLog(@"[CoreDataManager] Error while deleting a contact: %@", error);
        }
    }];
}

- (void)deleteContacts:(NSArray<Contact *> *)contacts {
    for (Contact *contact in contacts) {
        [self.viewContext deleteObject:contact];
    }
    [self saveContext:^(int result, NSError *error){
        if (result == FAIL) {
            NSLog(@"[CoreDataManager] Error while deleting multiple contacts: %@", error);
        }
    }];
}

- (void)saveContext:(nonnull void (^)(int result, NSError * _Nullable))completion {
    NSManagedObjectContext *context = self.viewContext;
    if ([context hasChanges]) {
        NSError *error = nil;
        if (![context save:&error]) {
            completion(FAIL,error);
        }
        completion(SUCCESS, nil);
    }
}

@end
