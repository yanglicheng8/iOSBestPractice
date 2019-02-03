//
//  UIImageView+GQImageDownloader.m
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import "UIImageView+GQImageDownloader.h"
#import "GQImageDownloaderConst.h"
#import <objc/runtime.h>

@implementation UIImageView (GQImageDownloader)

GQ_DYNAMIC_PROPERTY_OBJECT(imageUrl, setImageUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC, NSURL*);
GQ_DYNAMIC_PROPERTY_OBJECT(progressBlock, setProgressBlock, OBJC_ASSOCIATION_COPY_NONATOMIC, GQImageDownloaderProgressBlock);
GQ_DYNAMIC_PROPERTY_OBJECT(completeBlock, setCompleteBlock, OBJC_ASSOCIATION_COPY_NONATOMIC, GQImageDownloaderCompleteBlock);
GQ_DYNAMIC_PROPERTY_OBJECT(downloadOperation, setDownloadOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC, id<GQImageDownloaderOperationDelegate>);

- (void)dealloc
{
    [self cancelCurrentImageRequest];
}

- (void)cancelCurrentImageRequest
{
    [[self downloadOperation] cancel];
    [self setDownloadOperation:nil];
}

- (void)loadImage:(NSURL*)downloadUrl
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete
{
    [self loadImage:downloadUrl
        placeHolder:nil
           progress:progress
           complete:complete];
}

- (void)loadImage:(NSURL*)downloadUrl
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete
{
    [self loadImage:downloadUrl
   requestClassName:nil
        placeHolder:placeHolderImage
           progress:progress
           complete:complete];
}

- (void)loadImage:(NSURL*)downloadUrl
 requestClassName:(NSString *)className
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete {
    [self loadImage:downloadUrl
   requestClassName:className
          cacheType:GQImageDownloaderCacheTypeDisk
        placeHolder:placeHolderImage
           progress:progress
           complete:complete];
}

- (void)loadImage:(NSURL*)downloadUrl
 requestClassName:(NSString *)className
        cacheType:(GQImageDownloaderCacheType)cacheType
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete {
    
    self.image = placeHolderImage;
    [self cancelCurrentImageRequest];
    if(nil == downloadUrl || [@"" isEqualToString:downloadUrl.absoluteString] ) {
        return;
    }
    
    self.completeBlock = [complete copy];
    self.progressBlock = [progress copy];
    self.imageUrl = downloadUrl;
    
    GQWeakify(self);
    __strong id<GQImageDownloaderOperationDelegate> _downloadOperation = [[GQImageDownloaderOperationManager sharedManager]
                                                                          loadWithURL:self.imageUrl
                                                                          withURLRequestClassName:className
                                                                          progress:^(CGFloat progress) {
                                                                              GQStrongify(self);
                                                                              if (self.progressBlock) {
                                                                                  self.progressBlock(progress);
                                                                              }
                                                                          }complete:^(UIImage *image, NSURL *url, NSError *error) {
                                                                              GQStrongify(self);
                                                                              if (image && [url.absoluteString isEqualToString:downloadUrl.absoluteString]) {
                                                                                  self.image = image;
                                                                              }
                                                                              if (self.completeBlock) {
                                                                                  self.completeBlock(image,url,error);
                                                                              }
                                                                          }];
    [self setDownloadOperation:_downloadOperation];
}

@end