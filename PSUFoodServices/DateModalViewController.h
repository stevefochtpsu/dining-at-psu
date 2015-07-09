//
//  DateModalViewController.h
//  PSUFoodServices
//
//  Created by MTSS MTSS on 12/14/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModalHelp <NSObject>

- (void)dismissModalWithDate:(NSDate *)newDate;
- (void)dismissModal;

@end

@interface DateModalViewController : UIViewController

- (id)initWithDate:(NSDate *)aDate;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@property (nonatomic,retain) id <ModalHelp> delegate;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end
