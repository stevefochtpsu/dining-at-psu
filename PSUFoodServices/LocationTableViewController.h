//
//  LocationTableViewController.h
//  PennStateFoodServices
//
//  Created by MTSS MTSS on 12/12/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//

#import "Model.h"
#import "CampusTableViewController.h"

@interface LocationTableViewController : UITableViewController 

- (id)initWithModel:(Model *)aModel;
- (void)chooseFavoriteCampus;


@end

