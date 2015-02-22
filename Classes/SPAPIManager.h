//
//  SPAPIManager.h
//  Superpoints
//
//  Created by Allen Wu on 5/5/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@class SPUser;

@interface SPAPIManager : AFHTTPRequestOperationManager

+ (SPAPIManager *)sharedManager;

// REST helper methods

- (void)sp_GET:(NSString *)path
    parameters:(id)parameters
       success:(void (^)(id json))successBlock
       failure:(void (^)(NSString* message))failureBlock
       network:(void (^)(NSError* error))networkBlock;

- (void)sp_POST:(NSString *)path
     parameters:(id)parameters
        success:(void (^)(id json))successBlock
        failure:(void (^)(NSString* message))failureBlock
        network:(void (^)(NSError* error))networkBlock;

- (void)sp_PUT:(NSString *)path
    parameters:(id)parameters
       success:(void (^)(id json))successBlock
       failure:(void (^)(NSString* message))failureBlock
       network:(void (^)(NSError* error))networkBlock;


// API methods
// TODO: rearchitect network layer.. break this class up, approaching "god class"

- (void)tokenForUser:(NSString*)username
        successBlock:(void (^)(NSString *))successBlock
        failureBlock:(void (^)(NSString *))failureBlock
        networkBlock:(void (^)(NSError *))networkBlock;

//- (void)userWithId:(NSUInteger)userId
//      successBlock:(void (^)(SPUser *))successBlock
//      failureBlock:(void (^)(NSString *))failureBlock
//      networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)currentUserSuccessBlock:(void (^)(SPUser *))successBlock
//                   failureBlock:(void (^)(NSString *))failureBlock
//                   networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)createUserWithFirstName:(NSString *)firstName
//                       lastName:(NSString *)lastname
//                          email:(NSString *)email
//                       password:(NSString *)password
//                   successBlock:(void (^)(SPUser *))successBlock
//                   failureBlock:(void (^)(NSString *))failureBlock
//                   networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)connectCurrentUserWithFacebookId:(NSString *)facebookId
//                            successBlock:(void (^)(void))successBlock
//                            failureBlock:(void (^)(NSString *))failureBlock
//                            networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)resetPasswordForEmail:(NSString *)email
//                 successBlock:(void (^)(void))successBlock
//                 failureBlock:(void (^)(NSString *))failureBlock
//                 networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)eventBlueprintsSuccessBlock:(void (^)(void))successBlock
//                       failureBlock:(void (^)(NSString *))failureBlock
//                       networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)membershipLevelsSuccessBlock:(void (^)(NSDictionary *))successBlock
//                        failureBlock:(void (^)(NSString *))failureBlock
//                        networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)pointsHistorySuccessBlock:(void (^)(NSArray *))successBlock
//                     failureBlock:(void (^)(NSString *))failureBlock
//                     networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)sponsorshipOpportunitiesSuccessBlock:(void (^)(NSArray *))successBlock
//                                failureBlock:(void (^)(NSString *))failureBlock
//                                networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)rewardsDetailed:(void (^)(NSArray *))successBlock
//           failureBlock:(void (^)(NSString *))failureBlock
//           networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)rewardsAimable:(void (^)(NSArray *))successBlock
//          failureBlock:(void (^)(NSString *))failureBlock
//          networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)redeemRewardId:(NSInteger)rewardId
//          successBlock:(void (^)(void))successBlock
//          failureBlock:(void (^)(NSString *))failureBlock
//          networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)aimForRewardId:(NSInteger)rewardId
//          successBlock:(void (^)(void))successBlock
//          failureBlock:(void (^)(NSString *))failureBlock
//          networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)childrenSuccessBlock:(void (^)(NSArray *))successBlock
//                failureBlock:(void (^)(NSString *))failureBlock
//                networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)sponsorUserId:(NSInteger)userId
//         successBlock:(void (^)(void))successBlock
//         failureBlock:(void (^)(NSString *))failureBlock
//         networkBlock:(void (^)(NSError *))networkBlock;
//
//- (void)superLuckyButtonSuccessBlock:(void (^)(void))successBlock
//                        failureBlock:(void (^)(NSString *))failureBlock
//                        networkBlock:(void (^)(NSError *))networkBlock;

@end
