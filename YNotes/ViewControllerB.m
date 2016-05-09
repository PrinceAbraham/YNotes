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

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewControllerB

@synthesize messageArr, titleArr , userFile, userDefaults,titleField,messageField;

bool isEditing = false, didEdit=false;

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

-(void)viewWillAppear:(BOOL)animated{
    didEdit = false;
}

- (IBAction)back:(id)sender {
    UIAlertController *backController = [UIAlertController
                                         alertControllerWithTitle:@"Save Changes?"
                                         message:@"Clicking ok will save the changes."
                                         preferredStyle:UIAlertControllerStyleAlert];
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
                                          //if title exists
                                          if(isEditing){
                                              [self overwriteMatchedWithEditing];
                                          }else{
                                              [self overwriteMatchedWithoutEditing];
                                          }
                                      }
                                  }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action) {
                                                       NSLog(@"Cancel");
                                                       [self callDismiss];
                                                   }];
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Empty Note"
                                          message:@"Description cannot be empty!"
                                          preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   NSLog(@"Ok");
                                               }];
    if(!isEditing){
        if([titleField.text isEqualToString:@""] || [messageField.text isEqualToString:@""]){
            [self callDismiss];
        }else{
            if(didEdit){
                [backController addAction:cancel];
                [backController addAction:okToChanges];
                [self presentViewController:backController animated:YES completion:nil];
            }else{
                [self callDismiss];
            }
        }
    }else{
        if([titleField.text isEqualToString:[titleArr objectAtIndex:indexForTable]] && [messageField.text isEqualToString:[messageArr objectAtIndex:indexForTable]]){
            [self callDismiss];
        }else{
            if(!([titleField.text isEqualToString:@""] || [messageField.text isEqualToString:@""])){
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
    
    for(int i=0; i<[titleArr count]; i++){
        [stringTitleArr addObject:[[titleArr objectAtIndex:i] lowercaseString]];
    }
    //If it's edting
    if(isEditing){
        //if titleArr and description is not empty
        if(![messageField.text isEqualToString:@""] && ![titleField.text isEqualToString:@""]){
            //if titleArr hasn't been changed
            if([titleField.text isEqualToString:[titleArr objectAtIndex:indexForTable]]){
                [self savingEditWithUnchangedTitle];
            }else{
                if(![stringTitleArr containsObject:[titleField.text lowercaseString]]){
                    [self savingEditWithUniqueTitle];
                }else{
                    //overwrite alert
                    [overwriteController addAction:cancel];
                    [overwriteController addAction:okForOverWrite];
                    [self presentViewController:overwriteController animated:YES completion:nil];
                }
            }
        }else{
            //[alertController addAction:cancel];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }else{//since its not editing
        //if the string is not empty after being touched
        if((![messageField.text isEqualToString:@""] && ![titleField.text isEqualToString:@""]) && didEdit){
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
    
    UIImage *img = info[UIImagePickerControllerEditedImage];
    self.imageView.image = img;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) textViewDidBeginEditing:(UITextView *)textView{
    
    didEdit = true;
    
    textView.textColor = [UIColor blackColor];
    if(!isEditing && [[textView text] isEqualToString:@"Add Message:"]){
        [textView setText:@""];
    }
}

-(void) callDismiss{
    
    isEditing =false;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) getInfo{
    NSLog(@"%@", [userDefaults objectForKey:userDefaultKey]);
    userFile = [[userDefaults objectForKey:userDefaultKey]mutableCopy];//add mutable copy to retrieve properly. User default always returns immutable copy
    titleArr = [[userDefaults objectForKey:userTitleKey]mutableCopy];
    messageArr = [[userDefaults objectForKey:userDescriptionKey]mutableCopy];
}

-(void) savingWithUniqueTitle{
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
}

-(void) savingEditWithUnchangedTitle{
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
}

-(void) savingEditWithUniqueTitle{
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
-(void) overwriteMatchedWithEditing{
    int matchedInt = (int) [stringTitleArr indexOfObject:[titleField.text lowercaseString]];
    //[titleArr  replaceObjectAtIndex:matchedInt withObject:titleField.text];
    [messageArr replaceObjectAtIndex:matchedInt withObject:messageField.text];
    [messageArr removeObjectAtIndex:indexForTable];
    [titleArr removeObjectAtIndex:indexForTable];
    
    [userFile removeObjectForKey:[titleArr objectAtIndex:matchedInt]];
    [userFile setValue:[messageArr objectAtIndex:matchedInt] forKey:[titleArr objectAtIndex:matchedInt]];
    [userDefaults setObject:userFile forKey:userDefaultKey];
    [userDefaults setObject:titleArr forKey:userTitleKey];
    [userDefaults setObject:messageArr forKey:userDescriptionKey];
    titleField.text = @"";
    messageField.text = @"Add Message:";
    messageField.textColor = [UIColor grayColor];
    [self.view endEditing:true];
    [self callDismiss];
}

-(void) overwriteMatchedWithoutEditing{
    int matchedInt = (int) [stringTitleArr indexOfObject:[titleField.text lowercaseString]];
    //[titleArr  replaceObjectAtIndex:matchedInt withObject:titleField.text];
    [messageArr replaceObjectAtIndex:matchedInt withObject:messageField.text];
    [userFile removeObjectForKey:[titleArr objectAtIndex:matchedInt]];
    [userFile setValue:[messageArr objectAtIndex:matchedInt] forKey:[titleArr objectAtIndex:matchedInt]];
    [userDefaults setObject:userFile forKey:userDefaultKey];
    [userDefaults setObject:titleArr forKey:userTitleKey];
    [userDefaults setObject:messageArr forKey:userDescriptionKey];
    titleField.text = @"";
    messageField.text = @"Add Message:";
    messageField.textColor = [UIColor grayColor];
    [self.view endEditing:true];
    [self callDismiss];
}

@end
