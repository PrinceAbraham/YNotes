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

@synthesize messageArr, titleArr , userFile, userDefaults,titleField, messageField, messageStringWAttachments, messageData;


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
    
    messageStringWAttachments = [[NSMutableAttributedString alloc]init];
    
    if([userDefaults objectForKey:userDefaultKey]!=nil){
        [self getInfo];
    }
    messageField.delegate = self;
    if(self.isEditing){
        self.titleField.text = self.titleString;
        self.messageField.attributedText = [self getAttributeForData: self.messageData];
        messageStringWAttachments = self.messageField.attributedText;
        isEditing = self.isEditing;
        indexForTable = self.indexForTable;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    didEdit = false;
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:true];
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
        if([titleField.text isEqualToString:@""] || [[NSString stringWithFormat:@"%@",messageStringWAttachments] isEqualToString:@""]){
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
        if([titleField.text isEqualToString:[titleArr objectAtIndex:indexForTable]] && [[NSString stringWithFormat:@"%@",messageStringWAttachments] isEqualToString:[messageArr objectAtIndex:indexForTable]]){
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
        if( ![[NSString stringWithFormat:@"%@",messageStringWAttachments] isEqualToString:@""] && ![titleField.text isEqualToString:@""]){
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

-(void) textViewDidChange:(UITextView *)textView{
    messageField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
    messageStringWAttachments = messageField.attributedText;
}

-(void) getInfo{
    //NSLog(@"%@", [userDefaults objectForKey:userDefaultKey]);
    userFile = [[userDefaults objectForKey:userDefaultKey]mutableCopy];//add mutable copy to retrieve properly. User default always returns immutable copy
    titleArr = [[userDefaults objectForKey:userTitleKey]mutableCopy];
    messageArr = [[userDefaults objectForKey:userDescriptionKey]mutableCopy];
}

-(void) savingWithUniqueTitle{
    messageData = [self getDataForAttributedString:messageStringWAttachments];
    [(NSMutableArray *) titleArr insertObject:titleField.text atIndex:0];
    [(NSMutableArray *) messageArr insertObject:messageData atIndex:0];
    [(NSDictionary *) userFile setValue:messageData forKey:titleField.text];
    [self.view endEditing:true];
    [titleField endEditing:true];
    [userDefaults setObject:userFile forKey:userDefaultKey];
    [userDefaults setObject:titleArr forKey:userTitleKey];
    [userDefaults setObject:messageArr forKey:userDescriptionKey];
    [self callDismiss];
}

-(void) savingEditWithUnchangedTitle{
    messageData = [self getDataForAttributedString:messageStringWAttachments];
    [messageArr replaceObjectAtIndex:indexForTable withObject:messageData];
    [userFile setValue:[messageArr objectAtIndex:indexForTable] forKey:[titleArr objectAtIndex:indexForTable]];
    [self.view endEditing:true];
    //NSLog(@"%@",userFile);
    //store in User Defaults
    [userDefaults setObject:userFile forKey:userDefaultKey];
    [userDefaults setObject:titleArr forKey:userTitleKey];
    [userDefaults setObject:messageArr forKey:userDescriptionKey];
    [self callDismiss];
    titleField.text = @"";
}

-(void) savingEditWithUniqueTitle{
    [userFile removeObjectForKey:[titleArr objectAtIndex:indexForTable]];
    [titleArr replaceObjectAtIndex:indexForTable withObject: titleField.text];
    messageData = [self getDataForAttributedString:messageStringWAttachments];
    [messageArr replaceObjectAtIndex:indexForTable withObject:messageData];
    [userFile setValue:[messageArr objectAtIndex:indexForTable] forKey:[titleArr objectAtIndex:indexForTable]];
    [self.view endEditing:true];
    //NSLog(@"%@",userFile);
    [titleField endEditing:true];
    [userDefaults setObject:userFile forKey:userDefaultKey];
    [userDefaults setObject:titleArr forKey:userTitleKey];
    [userDefaults setObject:messageArr forKey:userDescriptionKey];
    [self callDismiss];
}
-(void) overwriteMatchedWithEditing{
    int matchedInt = (int) [stringTitleArr indexOfObject:[titleField.text lowercaseString]];
    messageData = [self getDataForAttributedString:messageStringWAttachments];
    [messageArr replaceObjectAtIndex:matchedInt withObject:messageData];
    [messageArr removeObjectAtIndex:indexForTable];
    [titleArr removeObjectAtIndex:indexForTable];
    
    [userFile removeObjectForKey:[titleArr objectAtIndex:matchedInt]];
    [userFile setValue:[messageArr objectAtIndex:matchedInt] forKey:[titleArr objectAtIndex:matchedInt]];
    [userDefaults setObject:userFile forKey:userDefaultKey];
    [userDefaults setObject:titleArr forKey:userTitleKey];
    [userDefaults setObject:messageArr forKey:userDescriptionKey];
    [self.view endEditing:true];
    [self callDismiss];
}

-(void) overwriteMatchedWithoutEditing{
    int matchedInt = (int) [stringTitleArr indexOfObject:[titleField.text lowercaseString]];
    messageData = [self getDataForAttributedString:messageStringWAttachments];
    [messageArr replaceObjectAtIndex:matchedInt withObject:messageData];
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

-(NSAttributedString *) messageDecoder:(NSData*) data{
    NSAttributedString *s;
    
    
    return s;
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
@end
