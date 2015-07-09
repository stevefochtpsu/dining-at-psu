//
//  PostsModel.h
//  CheeseShoppePrototype
//
//  Created by MTSS on 12/12/12.
//  Copyright (c) 2012 rrb5068. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostsModel : NSObject <NSXMLParserDelegate>
+(id)sharedInstance;
-(NSInteger)count;
-(NSString*)titleForRow:(NSInteger)row;
-(NSString*)descriptionForRow:(NSInteger)row;
-(NSString*)dateForRow:(NSInteger)row;


-(void)refetchPosts;
-(void)refetchPostsIfStale;
@end
