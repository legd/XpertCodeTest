//
//  ContactListViewController.m
//  XpertCodeTest
//
//  Created by Luis Guzman on 10/7/26.
//

#import "ContactListViewController.h"
#import "CoreDataManager.h"

static NSString * const kContactCellIdentifier = @"ContactCell";

@interface ContactListViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) NSArray<Contact *> *allContacts;
@property (nonatomic, strong) NSArray<Contact *> *filteredContacts;
@property (nonatomic, strong) UISearchController *searchController;
// TODO:
@property (nonatomic, strong) UIBarButtonItem *deleteBarButtonItem;

@end

@implementation ContactListViewController

- (instancetype)init {
    return [super initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Contactos";
    self.allContacts = @[];
    self.filteredContacts = @[];

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ContactViewCell class]) bundle:nil] forCellReuseIdentifier:kContactCellIdentifier];
    self.tableView.rowHeight = 120;

    // Button to add new contact
    UIBarButtonItem *addContactButton = [[UIBarButtonItem alloc] initWithTitle:@"Nuevo"
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(newContactTapped)];
    self.navigationItem.rightBarButtonItem = addContactButton;

    // Button to delete a contact
    self.deleteBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Borrar"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(deleteButtonTapped)];
    self.navigationItem.leftBarButtonItem = self.deleteBarButtonItem;

    // Search bar
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Buscar por nombre, apellido o teléfono";
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.definesPresentationContext = YES;

    self.tableView.allowsMultipleSelectionDuringEditing = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

#pragma mark - Data

- (void)reloadData {
    self.allContacts = [[CoreDataManager shared] fetchAllContacts];
    [self.tableView reloadData];
}

- (BOOL)isSearchActive {
    NSString *text = self.searchController.searchBar.text;
    return self.searchController.isActive && text.length > 0;
}

- (NSArray<Contact *> *)currentContacts {
    return self.isSearchActive ? self.filteredContacts : self.allContacts;
}

#pragma mark - Acciones de la barra de navegación

// TODO:-
- (void)newContactTapped {

}

- (void)deleteButtonTapped {
    if (!self.tableView.isEditing) {
        // Editing mode
        [self.tableView setEditing:YES animated:YES];
        self.deleteBarButtonItem.title = @"Listo";
        self.navigationItem.rightBarButtonItem.enabled = NO;
        return;
    }

    // Deletes the selected contacts
    NSArray<NSIndexPath *> *selectedPaths = [self.tableView indexPathsForSelectedRows];
    if (selectedPaths.count > 0) {
        NSMutableArray<Contact *> *toDelete = [NSMutableArray array];
        for (NSIndexPath *indexPath in selectedPaths) {
            [toDelete addObject:self.currentContacts[indexPath.row]];
        }
        [[CoreDataManager shared] deleteContacts:toDelete];
    }

    [self.tableView setEditing:NO animated:YES];
    self.deleteBarButtonItem.title = @"Borrar";
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellIdentifier forIndexPath:indexPath];
//    Contact *contact = self.currentContacts[indexPath.row];
//
//    NSString *fullName = [NSString stringWithFormat:@"%@ %@", contact.firstName ?: @"", contact.lastName ?: @""];
//    UIListContentConfiguration *contactCell = [cell defaultContentConfiguration];
//    contactCell.text = fullName;
//    contactCell.secondaryText = contact.phone;
//    cell.contentConfiguration = contactCell;
    ContactViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kContactCellIdentifier forIndexPath:indexPath];
    Contact *contact = self.currentContacts[indexPath.row];
    [cell setContact:contact];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Contact *contact = self.currentContacts[indexPath.row];
        [[CoreDataManager shared] deleteContact:contact];
        [self reloadData];
    }
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *text = searchController.searchBar.text ?: @"";
    self.filteredContacts = [[CoreDataManager shared] searchContactsWithText:text];
    [self.tableView reloadData];
}
@end
