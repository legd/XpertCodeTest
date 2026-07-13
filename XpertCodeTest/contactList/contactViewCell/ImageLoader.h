//
//  ImageLoader.h
//  XpertCodeTest
//
//  Created by Luis Guzman on 12/7/26.
//

#ifndef ImageLoader_h
#define ImageLoader_h

#import <UIKit/UIKit.h>

@interface ImageLoader : NSObject

+ (instancetype _Nonnull )sharedLoader;

- (nullable NSURLSessionDataTask *)loadImageFromURL:(NSURL *_Nonnull)url
                                         completion:(void (^_Nonnull)(UIImage * _Nullable image))completion;

@end

#endif /* ImageLoader_h */
