//
//  ViewControllerB.h
//  YNotes
//
//  Created by Prince on 5/5/16.
//  Copyright © 2016 Prince. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "Note.h"


@interface ViewControllerB : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate>

@property NSMutableArray *messageArr;

@property NSMutableArray *titleArr;

@property NSMutableDictionary *userFile;

@property NSMutableDictionary *totalNoteInfo;

@property NSMutableArray *notesInfo;

@property (nonatomic, weak) NSUserDefaults *userDefaults;

@property (weak, nonatomic) IBOutlet UITextField *titleField;

@property bool isEditing, reminderIsSet;

@property NSInteger indexForTable;

@property NSString *titleString;

@property (weak, nonatomic) IBOutlet UITextView *messageField;

@property NSMutableAttributedString *messageStringWAttachments;

@property NSMutableData *messageData;

@property NSDate *date;

@property EKReminder *nReminder;

@property EKEventStore *eventStoreInstance;

@property NSMutableArray *dateCreated, *dateModified;

@property Note *note;



@end
