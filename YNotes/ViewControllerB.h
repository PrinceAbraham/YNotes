//
//  ViewControllerB.h
//  YNotes
//
//  Created by Prince on 5/5/16.
//  Copyright © 2016 Prince. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewControllerB : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate>

@property NSMutableArray *messageArr;

@property NSMutableArray *titleArr;

@property NSMutableDictionary *userFile;

@property (nonatomic, weak) NSUserDefaults *userDefaults;

@property (weak, nonatomic) IBOutlet UITextField *titleField;

@property bool isEditing;

@property NSInteger indexForTable;

@property NSString *messageString;

@property NSString *titleString;

@property (weak, nonatomic) IBOutlet UITextView *messageField;

@end
