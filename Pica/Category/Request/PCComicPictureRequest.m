//
//  PCComicPictureRequest.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComicPictureRequest.h"
#import <YYModel/YYModel.h>
#import <SDWebImage/SDWebImage.h>

@interface PCComicPictureRequest ()
  
@end

@implementation PCComicPictureRequest

- (instancetype)initWithComicId:(NSString *)comicId
                          order:(NSInteger)order  {
    if (self = [super init]) {
        _comicId = [comicId copy];
        _order = order;
        _page = 1;
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
//    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCEpisodePicture *picture = [PCEpisodePicture yy_modelWithJSON:request.responseJSONObject[@"data"][@"pages"]];
        picture.ep = [PCEpisode yy_modelWithJSON:request.responseJSONObject[@"data"][@"ep"]];
        !success ? : success(picture);
        NSMutableArray *URLs = [NSMutableArray array];
        [picture.docs enumerateObjectsUsingBlock:^(PCPicture * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSURL *url = [NSURL URLWithString:obj.media.imageURL];
            if (url) {
                [URLs addObject:url];
            }
        }];
        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:URLs];
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    NSMutableString *requestUrl = [NSMutableString stringWithFormat:PC_API_COMICS_IMAGE, self.comicId, @(self.order)];
    [requestUrl appendFormat:@"?page=%@", @(self.page)];
    return requestUrl;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 60 * 24 * 30;
}

- (BOOL)ignoreCache {
    return NO;
}

@end
