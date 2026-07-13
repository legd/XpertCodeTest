//
//  ContactViewCell.m
//  XpertCodeTest
//
//  Created by Luis Guzman on 11/7/26.
//

#import "ContactViewCell.h"

@interface ContactViewCell ()
@property (nonatomic, weak) NSURLSessionDataTask *currentTask;
@property (nonatomic, strong) NSURL *currentURL;
@end

@implementation ContactViewCell
@synthesize contactImage;
@synthesize nameLabel;
@synthesize phoneLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.currentTask cancel];
    self.currentTask = nil;
    self.contactImage.image = [UIImage imageNamed:@"person.crop.circle.fill"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setContact: (Contact*) contact {
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    self.phoneLabel.text = contact.phone;
}

- (void)setImageURL:(NSURL *)url {
    
    NSString *urlString = [url absoluteString];

    // Check if URL is valid or not
    if (urlString == nil || urlString.length == 0) {
        self.contactImage.image = [UIImage systemImageNamed:@"person.crop.circle.fill"];
    } else {
        // Cancel any in-flight load for the previous content of this cell
        [self.currentTask cancel];
        self.currentURL = url;
        self.contactImage.image = [UIImage imageNamed:@"person.crop.circle.fill"];

        __weak typeof(self) weakSelf = self;
        self.currentTask = [[ImageLoader sharedLoader] loadImageFromURL:url completion:^(UIImage *image) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            // Guard: only apply if this cell hasn't been reused for a different row since
            if (![strongSelf.currentURL isEqual:url]) return;
            if (image) {
                strongSelf.contactImage.image = image;
            }
        }];
    }
}

@end
