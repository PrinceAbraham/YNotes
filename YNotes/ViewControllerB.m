//
//  ViewControllerB.m
//  YNotes
//
//  Created by Prince on 5/5/16.
//  Copyright © 2016 Prince. All rights reserved.
//

#import "ViewControllerB.h"
#import "ConstantsClass.h"



@import UIKit;


@interface ViewControllerB ()

@property (nonatomic, assign) CGFloat animatedDistance;

@property (weak, nonatomic) IBOutlet UIButton *reminderButton;

@property (weak, nonatomic) IBOutlet UILabel *reminderTime;

@end

@implementation ViewControllerB


@synthesize messageArr, titleArr , userFile, userDefaults,titleField, messageField, messageStringWAttachments, messageData, animatedDistance, nReminder, reminderTime, dateCreated, dateModified, totalNoteInfo, notesInfo, note, noteData;

bool isEditing = false, didEdit=false, reminderIsSet=false, tempCheckReminder=false;

int indexForTable=0;

UIDatePicker *datePicker;

NSAttributedString *tempAttributedString;

NSMutableArray *stringTitleArr, *reminderList;

EKCalendar *newCalendar;

NSDate *date;

EKAlarm *newAlarm;

NSDateFormatter *outputFormatter;

NSString *tempStringCheckTIme;

NSDate *dateForCreationandModification;

NSMutableArray *arrayOfNoteOBJ;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    note= [[Note alloc]init];
    
    noteData = [[NSData alloc]init];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    arrayOfNoteOBJ = [[NSMutableArray alloc]init];
    
    stringTitleArr = [[NSMutableArray alloc]init];
    
    titleArr = [[NSMutableArray alloc]init];
    
    outputFormatter = [[NSDateFormatter alloc] init];
    
    datePicker = [[UIDatePicker alloc]init];
    
    notesInfo = [[NSMutableArray alloc]init];
    
    date = [[NSDate alloc]init];
    
    dateForCreationandModification = [[NSDate alloc]init];
    
    self.eventStoreInstance = [[EKEventStore alloc]init];
    
    newAlarm = [[EKAlarm alloc]init];
    
    reminderIsSet =false;
    
    //sets the calendar to the default calendar for reminders
    newCalendar = [_eventStoreInstance defaultCalendarForNewReminders];
    
    //connects the event store with the reminder
    nReminder =  [EKReminder reminderWithEventStore:self.eventStoreInstance];
    
    //Formats the date and time format for the label
    [outputFormatter setDateStyle:NSDateFormatterShortStyle];
    [outputFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    //set the delegate of the textview to self
    messageField.delegate = self;
    
    //if it is editing then load data
    if(self.isEditing){
        note.noteTitle = self.titleString;
        
        self.titleField.text = self.titleString;
        
        messageStringWAttachments = self.messageStringWAttachments;
        
        self.messageField.attributedText = messageStringWAttachments;
        
        isEditing = self.isEditing;
        reminderIsSet = self.reminderIsSet;
        indexForTable = self.indexForTable;
        tempAttributedString = messageStringWAttachments;
    }else{
        messageStringWAttachments = [[NSMutableAttributedString alloc]init];
    }
    
    //checks if theres a user defaults so that info could be retrived
    if([userDefaults objectForKey:userAllInfoKey]!=nil){
        [self getInfo];
        
        dateForCreationandModification = [[note decodeData:[notesInfo objectAtIndex:indexForTable]] noteCreated];
    }
    
    //if a reminder is set
    if(reminderIsSet){
        NSPredicate *predicate = [_eventStoreInstance predicateForRemindersInCalendars:nil];
        
        [_eventStoreInstance fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
            //Gets all the reminders in the reminder app
            for (EKReminder *reminder in reminders) {
                //If reminder exists
                if([reminder.title isEqualToString:titleField.text]){
                    //Get info for the reminder, Alarm and the reminderTime label
                    nReminder = reminder;
                    newAlarm = [[nReminder alarms ] objectAtIndex:0];
                    reminderTime.text = [outputFormatter stringFromDate:[newAlarm absoluteDate]];
                }
            }
            //sets tempStringCheckTIme to check if the user has changed the time of the reminder
            tempStringCheckTIme=reminderTime.text;
        }];
        [_reminderButton setImage:[UIImage imageNamed:@"reminderSelected"] forState:UIControlStateNormal];
    }else{
        [_reminderButton setImage:[UIImage imageNamed:@"reminderNotSelected"] forState:UIControlStateNormal];
        reminderTime.text = @"No Alarm Set!";
        tempStringCheckTIme = reminderTime.text;
    }
    tempCheckReminder=reminderIsSet;
    
    //Makes an array of title in lowercase to check if titles exist
    for(int i=0; i<[titleArr count]; i++){
        [stringTitleArr addObject:[[titleArr objectAtIndex:i] lowercaseString]];
    }
    //Prompts for Access to reminders if not allowed already
    [self.eventStoreInstance requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        
    }];
    
}

-(void)viewWillAppear:(BOOL)animated{
    if([messageField.text isEqualToString:@"Add Message:"]){
        
        //didEdit = false means the messageField hasn't been touched yet
        didEdit = false;
    }
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //Dismiss keyboard
    [self.view endEditing:true];
    
}


-(void) textViewDidBeginEditing:(UITextView *)textView{
    
    //The messageField is touched
    didEdit = true;
    
    //sets the text color
    textView.textColor = [UIColor blackColor];
    
    //Empties the messageField if it's a new note
    if(!isEditing && [[textView text] isEqualToString:@"Add Message:"]){
        [textView setText:@""];
    }
    
    //KEYBOARD SIZING FOR TEXT (NEED SOME WORK. THIS METHOD SINCE IT'S NOT A SCROLL VIEW)
    CGRect textFieldRect =
    [self.view.window convertRect:messageField.bounds fromView:messageField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    
    //KEYBOARD IS SET NORMAL WHEN DISMISSED
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

-(void) textViewDidChange:(UITextView *)textView{
    //Keeps the font and size consistant
    messageField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
    
    //Keeps a track of attributeText in messageField
    messageStringWAttachments = messageField.attributedText;
}

- (IBAction)back:(id)sender {
    
    int matchedInt = (int) [stringTitleArr indexOfObject:[titleField.text lowercaseString]];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Empty Note"
                                          message:@"Description cannot be empty!"
                                          preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   NSLog(@"Ok");
                                               }];
    
    
    NSString *tempOverwriteTitle = [NSString stringWithFormat: @"Overwrite %@",titleField.text ];
    
    UIAlertController *overwriteController = [UIAlertController
                                              alertControllerWithTitle:tempOverwriteTitle
                                              message:@"Adding this will Overwrite the body"
                                              preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okForOverWrite = [UIAlertAction actionWithTitle:@"Ok"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               if(!isEditing){
                                                                   [self overwriteMatchedWithoutEditing];
                                                               }else{
                                                                   [self overwriteMatchedWithEditing];
                                                               }
                                                           }];
    UIAlertController *backController = [UIAlertController
                                         alertControllerWithTitle:@"Save Changes?"
                                         message:@"Clicking Ok will save the changes."
                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action) {
                                                       NSLog(@"Cancel");
                                                       [self callDismiss];
                                                   }];
    UIAlertAction *okToChanges = [UIAlertAction
                                  actionWithTitle:@"Ok"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action) {
                                      //if unique title
                                      if(![stringTitleArr containsObject:[titleField.text lowercaseString]]){
                                          if(isEditing){
                                              [self savingEditWithUniqueTitle];
                                          }else{
                                              [self savingWithUniqueTitle];
                                          }
                                      }else{
                                          if(matchedInt==indexForTable){
                                              [self overwriteMatchedWithEditing];
                                          }else{
                                          [overwriteController addAction:cancel];
                                          [overwriteController addAction:okForOverWrite];
                                          [self presentViewController:overwriteController animated:YES completion:nil];
                                          }
                                      }
                                  }];
    
    
    
    
    if(!isEditing){
        //if title or message is empty
        if([titleField.text isEqualToString:@""] || [[NSString stringWithFormat:@"%@",messageStringWAttachments] isEqualToString:@""]){
            [self callDismiss];
        }else{
            //message was touched
            if(didEdit){
                [backController addAction:cancel];
                [backController addAction:okToChanges];
                [self presentViewController:backController animated:YES completion:nil];
            }else{
                [self callDismiss];
            }
        }
    }else{
        if([titleField.text isEqualToString:[titleArr objectAtIndex:indexForTable]] && [messageStringWAttachments isEqualToAttributedString:tempAttributedString] && ([tempStringCheckTIme isEqualToString:reminderTime.text] && (tempCheckReminder==reminderIsSet))){
            [self callDismiss];
        }else{
            if(!([titleField.text isEqualToString:@""] || [[NSString stringWithFormat:@"%@",messageStringWAttachments] isEqualToString:@""])){
                [backController addAction:cancel];
                [backController addAction:okToChanges];
                [self presentViewController:backController animated:YES completion:nil];
            }else{
                //change it
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}
- (IBAction)save:(id)sender {
    
    int matchedInt = (int) [stringTitleArr indexOfObject:[titleField.text lowercaseString]];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Empty Note"
                                          message:@"Description cannot be empty!"
                                          preferredStyle:(UIAlertControllerStyleAlert)];
    NSString *tempOverwriteTitle = [NSString stringWithFormat: @"Overwrite %@",titleField.text ];
    
    UIAlertController *overwriteController = [UIAlertController
                                              alertControllerWithTitle:tempOverwriteTitle
                                              message:@"Adding this will Overwrite the body"
                                              preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action) {
                                                       NSLog(@"Cancel");
                                                   }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   NSLog(@"Ok");
                                               }];
    UIAlertAction *okForOverWrite = [UIAlertAction actionWithTitle:@"Ok"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               if(!isEditing){
                                                                   [self overwriteMatchedWithoutEditing];
                                                               }else{
                                                                   [self overwriteMatchedWithEditing];
                                                               }
                                                           }];
    
    [self.view endEditing:YES];
    
    //If it's edting
    if(isEditing){
        //if titleArr and description is not empty
        if( ![[NSString stringWithFormat:@"%@",messageStringWAttachments] isEqualToString:@""] && ![titleField.text isEqualToString:@""]){
            //if titleArr hasn't been changed
            if([titleField.text isEqualToString:[titleArr objectAtIndex:indexForTable]]){
                [self savingEditWithUnchangedTitle];
            }else{
                if(![stringTitleArr containsObject:[titleField.text lowercaseString]]){
                    [self savingEditWithUniqueTitle];
                }else{
                    if(matchedInt == indexForTable){
                        [self overwriteMatchedWithEditing];
                    }else{
                    //overwrite alert
                    [overwriteController addAction:cancel];
                    [overwriteController addAction:okForOverWrite];
                    [self presentViewController:overwriteController animated:YES completion:nil];
                    }
                }
            }
        }else{
            //[alertController addAction:cancel];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }else{//since its not editing
        //if the string is not empty after being touched
        if((![[NSString stringWithFormat:@"%@",messageStringWAttachments] isEqualToString:@""] && ![titleField.text isEqualToString:@""]) && didEdit){
            //if it the titleArr is unique
            if(![stringTitleArr containsObject:[titleField.text lowercaseString]]){
                [self savingWithUniqueTitle];
            }else{
                //overwrite alert
                [overwriteController addAction:cancel];
                [overwriteController addAction:okForOverWrite];
                [self presentViewController:overwriteController animated:YES completion:nil];
            }
        }else{
            //[alertController addAction:cancel];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    
    
}

- (IBAction)deleteNote:(id)sender {
    
    if(isEditing){
        //[desc removeObjectAtIndex:currentIndex];
        
        [userFile removeObjectForKey:[titleArr objectAtIndex:indexForTable]];
        
        [titleArr removeObjectAtIndex:indexForTable];
        [messageArr removeObjectAtIndex:indexForTable];
        
        //[userFile setValue:[desc objectAtIndex:currentIndex] forKeyPath:[title objectAtIndex:currentIndex]];
        
        [userDefaults setObject:userFile forKey:userDefaultKey];
        [userDefaults setObject:titleArr forKey:userTitleKey];
        [userDefaults setObject:messageArr forKey:userDescriptionKey];
        isEditing = false;
        
        [self deleteReminder];
        
        [self callDismiss];
    }
    
}
- (IBAction)cameraButton:(id)sender {
    
    UIImagePickerController *imageController = [[UIImagePickerController alloc]init];
    imageController.delegate = self;
    imageController.allowsEditing = true;
    imageController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imageController animated:YES completion:nil];
    
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *unImg = info[UIImagePickerControllerEditedImage];
    UIImage *img = [UIImage imageWithCGImage:[unImg CGImage]
                                       scale:(unImg.scale * 2.5)
                                 orientation:unImg.imageOrientation];
    
    UIGraphicsBeginImageContext( CGSizeMake(320, 320));
    [unImg drawInRect:CGRectMake(0,0,320,320)];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSTextAttachment *imgAttachment = [[NSTextAttachment alloc]init];
    imgAttachment.image = img;
    //had to initialize another NSMutableAttributedString
    NSMutableAttributedString *originString = [[[NSAttributedString alloc]initWithAttributedString:messageStringWAttachments]mutableCopy];
    
    NSAttributedString *atString  = [NSAttributedString attributedStringWithAttachment:imgAttachment];
    
    [originString appendAttributedString:atString];
    
    messageStringWAttachments = originString;
    
    messageField.attributedText = originString;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //Adding a picture is triggering didEdit = true
    didEdit = true;
    
}

- (IBAction)reminder:(id)sender {
    
    UIAlertController *actionSheetForDate = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action) {
                                                       NSLog(@"Cancel");
                                                       //reminderIsSet = false;
                                                   }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       NSLog(@"Delete");
                                                       reminderIsSet = false;
                                                       [_reminderButton setImage:[UIImage imageNamed:@"reminderNotSelected"] forState:UIControlStateNormal];
                                                       reminderTime.text = @"No Alarm Set!";
                                                   }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   NSLog(@"Ok");
                                                   
                                               }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePicker setTimeZone:[NSTimeZone defaultTimeZone]];
    [alertController addAction:cancel];
    if(reminderIsSet){
        [alertController addAction:delete];
    }
    [alertController.view addSubview:datePicker];
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            reminderIsSet = true;
            NSLog(@"OK");
            reminderTime.text = [outputFormatter stringFromDate:[datePicker date]];
            [_reminderButton setImage:[UIImage imageNamed:@"reminderSelected"] forState:UIControlStateNormal];
        }];
        action;
    })];
    [self presentViewController:alertController  animated:YES completion:nil];
}
-(void) callDismiss{
    
    isEditing =false;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void) getInfo{

    notesInfo = [[userDefaults objectForKey:userAllInfoKey]mutableCopy];

    for(int i=0; i< [notesInfo count]; i++){
        [arrayOfNoteOBJ addObject:[note decodeData:[notesInfo objectAtIndex:i]]];
        [titleArr addObject:[[arrayOfNoteOBJ objectAtIndex:i] noteTitle]];
    }
}

-(void) savingWithUniqueTitle{
    
    [note setNoteTitle:titleField.text];
    
    [note setNoteMessage:messageStringWAttachments];
    
    [self createDate];
    
    if(reminderIsSet){
        [self createReminder];
    }else{
        [self deleteReminder];
    }
    noteData = [note changeToData:note];
    [notesInfo insertObject:noteData atIndex:0];
    //store in User Defaults
    [userDefaults setObject:notesInfo forKey:userAllInfoKey];
    [self.view endEditing:true];
    [self callDismiss];
    
}

-(void) savingEditWithUnchangedTitle{

    [self saveOrUpdateNote];
    [notesInfo replaceObjectAtIndex:indexForTable withObject:noteData];
    //store in User Defaults
    [userDefaults setObject:notesInfo forKey:userAllInfoKey];
    [self.view endEditing:true];
    [self callDismiss];
}

-(void) savingEditWithUniqueTitle{

    [self saveOrUpdateNote];
    
    [notesInfo replaceObjectAtIndex:indexForTable withObject:noteData];
    
    [userDefaults setObject:notesInfo forKey:userAllInfoKey];
    
    [self callDismiss];
}
-(void) overwriteMatchedWithEditing{
    int matchedInt = (int) [stringTitleArr indexOfObject:[titleField.text lowercaseString]];
    
    [self saveOrUpdateNote];
    
    [notesInfo replaceObjectAtIndex:matchedInt withObject:noteData];
    
    if(indexForTable!=matchedInt){
        [notesInfo removeObjectAtIndex:indexForTable];
    }
    
    [userDefaults setObject:notesInfo forKey:userAllInfoKey];
    
    [self.view endEditing:true];
    [self callDismiss];
}

-(void) overwriteMatchedWithoutEditing{
    int matchedInt = (int) [stringTitleArr indexOfObject:[titleField.text lowercaseString]];
    [self saveOrUpdateNote];
    [notesInfo replaceObjectAtIndex:matchedInt withObject:noteData];
    [userDefaults setObject:notesInfo forKey:userAllInfoKey];
    [self.view endEditing:true];
    [self callDismiss];
}

//All Calls for saving and editing are same except the index their storing
-(void)saveOrUpdateNote{
    
    [note setNoteTitle:titleField.text];
    
    [note setNoteMessage:messageStringWAttachments];
    
    [self modifyDate];
    
    if(reminderIsSet){
        [self createReminder];
    }else{
        [self deleteReminder];
    }
    
    noteData = [note changeToData:note];
    
}

-(void)createReminder{
    
    [newAlarm setAbsoluteDate:[datePicker date]];
    nReminder.title = titleField.text;
    EKCalendar *newCalendar = [_eventStoreInstance defaultCalendarForNewReminders];
    //newCalendar.title = @"Reminders";
    nReminder.calendar = newCalendar;
    nReminder.notes = messageField.text;
    [nReminder addAlarm:newAlarm];
    NSError *error = nil;
    [self.eventStoreInstance saveReminder:nReminder commit:YES error:&error];
    NSLog(@"%@",error);
    
    
}
-(void)deleteReminder{
    NSError *error = nil;
    
    NSLog(@"%@",nReminder.title);
    
    BOOL success = [_eventStoreInstance removeReminder:nReminder commit:YES error:&error];
    
    NSLog(@"success, %d",success);
    NSLog(@"%@", error);
}
-(NSMutableData *) getDataForAttributedString:(NSMutableAttributedString *) attrString{
    NSMutableData *msgData = [[NSMutableData alloc]init];
    msgData = [[NSKeyedArchiver archivedDataWithRootObject:attrString]mutableCopy];
    return msgData;
}

-(NSMutableAttributedString *) getAttributeForData:(NSMutableData *) data{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]init];
    attrString = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return attrString;
}

-(void) createDate{
    date = [NSDate date];
    
    [note setNoteCreated:date];
    [note setNoteModified:date];
    
    //[dateCreated insertObject:date atIndex:0];
    //[dateModified insertObject:date atIndex:0];
}
-(void) modifyDate{
    
    date = [NSDate date];
    
    [note setNoteModified:date];
    [note setNoteCreated:dateForCreationandModification];
    //[dateModified replaceObjectAtIndex:index withObject:date];

}

@end
