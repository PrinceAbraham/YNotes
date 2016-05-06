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

@end

@implementation ViewControllerB

@synthesize messageArr, titleArr , userFile, userDefaults,titleField,messageField;

bool isEditing = false, beganEditing=false;

int indexForTable=0;

NSMutableArray *stringTitleArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    titleArr = [[NSMutableArray alloc] init];
    
    messageArr = [[NSMutableArray alloc] init];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    userFile = [[NSMutableDictionary alloc]init];
    
    stringTitleArr = [[NSMutableArray alloc]init];
    
    if([userDefaults objectForKey:userDefaultKey]!=nil){
        [self getInfo];
    }
    
    messageField.delegate = self;
    if(self.isEditing){
    self.titleField.text = self.titleString;
    self.messageField.text = self.messageString;
    isEditing = self.isEditing;
    indexForTable = self.indexForTable;
    }
}


- (IBAction)save:(id)sender {
    
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
                                                               int tempInt = (int) [stringTitleArr indexOfObject:[titleField.text lowercaseString]];
                                                               //[titleArr  replaceObjectAtIndex:tempInt withObject:titleField.text];
                                                               [messageArr replaceObjectAtIndex:tempInt withObject:messageField.text];
                                                               [userFile removeObjectForKey:[titleArr objectAtIndex:tempInt]];
                                                               [userFile setValue:[messageArr objectAtIndex:tempInt] forKey:[titleArr objectAtIndex:tempInt]];
                                                               [userDefaults setObject:userFile forKey:userDefaultKey];
                                                               [userDefaults setObject:titleArr forKey:userTitleKey];
                                                               [userDefaults setObject:messageArr forKey:userDescriptionKey];
                                                               titleField.text = @"";
                                                               messageField.text = @"Add Message:";
                                                               messageField.textColor = [UIColor grayColor];
                                                               [self.view endEditing:true];
                                                               [self callDismiss];
                                                           }];
    
    for(int i=0; i<[titleArr count]; i++){
        [stringTitleArr addObject:[[titleArr objectAtIndex:i] lowercaseString]];
    }
    
    //If it's edting
    if(isEditing){
        //if titleArr and description is not empty
        if(![messageField.text isEqualToString:@""] && ![titleField.text isEqualToString:@""]){
            //if titleArr hasn't been changed
            if([titleField.text isEqualToString:[titleArr objectAtIndex:indexForTable]]){
                [messageArr replaceObjectAtIndex:indexForTable withObject:messageField.text];
                [userFile setValue:[messageArr objectAtIndex:indexForTable] forKey:[titleArr objectAtIndex:indexForTable]];
                [self.view endEditing:true];
                NSLog(@"%@",userFile);
                //store in User Defaults
                [userDefaults setObject:userFile forKey:userDefaultKey];
                [userDefaults setObject:titleArr forKey:userTitleKey];
                [userDefaults setObject:messageArr forKey:userDescriptionKey];
                messageField.text = @"Add Message:";
                messageField.textColor = [UIColor grayColor];
                [self callDismiss];
                titleField.text = @"";
            }else{
                [userFile removeObjectForKey:[titleArr objectAtIndex:indexForTable]];
                [titleArr replaceObjectAtIndex:indexForTable withObject: titleField.text];
                [messageArr replaceObjectAtIndex:indexForTable withObject:messageField.text];
                [userFile setValue:[messageArr objectAtIndex:indexForTable] forKey:[titleArr objectAtIndex:indexForTable]];
                [self.view endEditing:true];
                NSLog(@"%@",userFile);
                titleField.text = @"";
                messageField.text = @"Add Message:";
                messageField.textColor = [UIColor grayColor];
                [titleField endEditing:true];
                [userDefaults setObject:userFile forKey:userDefaultKey];
                [userDefaults setObject:titleArr forKey:userTitleKey];
                [userDefaults setObject:messageArr forKey:userDescriptionKey];
                [self callDismiss];
            }
        }else{
            //[alertController addAction:cancel];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        isEditing = false;
    }else{//since its not editing
        //if the string is not empty after being touched
        if(((![messageField.text isEqualToString:@""] && ![titleField.text isEqualToString:@""]) && beganEditing)){
            //if it the titleArr is unique
            if(![stringTitleArr containsObject:[titleField.text lowercaseString]]){
                [(NSMutableArray *) titleArr insertObject:titleField.text atIndex:0];
                [(NSMutableArray *) messageArr insertObject:messageField.text atIndex:0];
                [(NSDictionary *) userFile setValue:messageField.text forKey:titleField.text];
                [self.view endEditing:true];
                NSLog(@"%@",userFile);
                titleField.text = @"";
                messageField.text = @"Add Message:";
                messageField.textColor = [UIColor grayColor];
                [titleField endEditing:true];
                [userDefaults setObject:userFile forKey:userDefaultKey];
                [userDefaults setObject:titleArr forKey:userTitleKey];
                [userDefaults setObject:messageArr forKey:userDescriptionKey];
                [self callDismiss];
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

-(void) textViewDidBeginEditing:(UITextView *)textView{
    
    beganEditing = true;
    
    textView.textColor = [UIColor blackColor];
    if(!isEditing && [[textView text] isEqualToString:@"Add Message:"]){
        [textView setText:@""];
    }
}

-(void) textViewDidEndEditing:(UITextView *)textView{
    beganEditing = false;
}

-(void) callDismiss{
    
    //self.ViewController.title = titleArr;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) getInfo{
    NSLog(@"%@", [userDefaults objectForKey:userDefaultKey]);
    userFile = [[userDefaults objectForKey:userDefaultKey]mutableCopy];//add mutable copy to retrieve properly. User default always returns immutable copy
    titleArr = [[userDefaults objectForKey:userTitleKey]mutableCopy];
    messageArr = [[userDefaults objectForKey:userDescriptionKey]mutableCopy];
}

@end
