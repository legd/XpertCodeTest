//
//  ImageLoader.m
//  XpertCodeTest
//
//  Created by Luis Guzman on 12/7/26.
//

#import "ImageLoader.h"

@interface ImageLoader ()
@property (nonatomic, strong) NSCache<NSURL *, UIImage *> *cache;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation ImageLoader

+ (instancetype)sharedLoader {
    static ImageLoader *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ImageLoader alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _cache = [[NSCache alloc] init];
        _cache.countLimit = 200; // tune as needed
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (nullable NSURLSessionDataTask *)loadImageFromURL:(NSURL *)url
                                          completion:(void (^)(UIImage * _Nullable))completion {
    if (!url) {
        completion(nil);
        return nil;
    }

    UIImage *cached = [self.cache objectForKey:url];
    if (cached) {
        completion(cached);
        return nil; // nothing to cancel, served from cache synchronously-ish
    }

    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url
        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error || !data) {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(nil); });
                return;
            }
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [self.cache setObject:image forKey:url];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image);
            });
        }];
    [task resume];
    return task;
}

@end
