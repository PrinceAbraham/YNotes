//
//  ViewController.m
//  YNotes
//
//  Created by Prince on 4/29/16.
//  Copyright © 2016 Prince. All rights reserved.
//

#import "ViewController.h"
#import "ViewControllerB.h"

@import UIKit;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *noteTitle;

@property (weak, nonatomic) IBOutlet UITextView *noteDescription;

@property (strong, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UIButton *addOrSave;

@end

@implementation ViewController

@synthesize desc, table, userDefaults, userFile, title;

bool edit=false;

bool didBeganEditing=false;

int currentIndex=0;

NSMutableArray *tempTitle;

NSString *userDefaultKey = @"UserFileData";
NSString *userTitleKey = @"UserTitleData";
NSString *userDescriptionKey= @"UserDescData";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    title = [[NSMutableArray alloc] init];
    
    desc = [[NSMutableArray alloc] init];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    userFile = [[NSMutableDictionary alloc]init];
    
    tempTitle = [[NSMutableArray alloc]init];
    
    if([userDefaults objectForKey:userDefaultKey]!=nil){
        NSLog(@"%@", [userDefaults objectForKey:userDefaultKey]);
        userFile = [[userDefaults objectForKey:userDefaultKey]mutableCopy];//add mutable copy to retrieve properly. User default always returns immutable copy
        title = [[userDefaults objectForKey:userTitleKey]mutableCopy];
        desc = [[userDefaults objectForKey:userDescriptionKey]mutableCopy];
    }
    
    _noteDescription.delegate = self;
    

    
}

-(void) restoreUserActivityState:(NSUserActivity *)activity{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)deleteNote:(id)sender {
    
    if(edit){
        //[desc removeObjectAtIndex:currentIndex];
        
        [userFile removeObjectForKey:[title objectAtIndex:currentIndex]];
        
        [title removeObjectAtIndex:currentIndex];
        [desc removeObjectAtIndex:currentIndex];
        
        //[userFile setValue:[desc objectAtIndex:currentIndex] forKeyPath:[title objectAtIndex:currentIndex]];
        
        _noteTitle.text = @"";
        
        _noteDescription.text = @"";
        
        [self.table reloadData];
        
        [_addOrSave setImage:[UIImage imageNamed:@"addNote.png"] forState:UIControlStateNormal];
        
        [userDefaults setObject:userFile forKey:userDefaultKey];
        [userDefaults setObject:title forKey:userTitleKey];
        [userDefaults setObject:desc forKey:userDescriptionKey];
        edit = false;
        
    }
    
}

- (IBAction)addNote:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Empty Note"
                                          message:@"Description cannot be empty!"
                                          preferredStyle:(UIAlertControllerStyleAlert)];
    NSString *tempOverwriteTitle = [NSString stringWithFormat: @"Overwrite %@",_noteTitle.text ];
    
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
                                                               int tempInt = (int) [tempTitle indexOfObject:[_noteTitle.text lowercaseString]];
                                                               //[title replaceObjectAtIndex:tempInt withObject:_noteTitle.text];
                                                               [desc replaceObjectAtIndex:tempInt withObject:_noteDescription.text];
                                                               [userFile removeObjectForKey:[title objectAtIndex:tempInt]];
                                                               [userFile setValue:[desc objectAtIndex:tempInt] forKey:[title objectAtIndex:tempInt]];
                                                               [userDefaults setObject:userFile forKey:userDefaultKey];
                                                               [userDefaults setObject:title forKey:userTitleKey];
                                                               [userDefaults setObject:desc forKey:userDescriptionKey];
                                                               _noteTitle.text = @"";
                                                               _noteDescription.text = @"Add Message:";
                                                               _noteDescription.textColor = [UIColor grayColor];
                                                               [self.view endEditing:true];
                                                           }];
    
    for(int i=0; i<[title count]; i++){
        [tempTitle addObject:[[title objectAtIndex:i] lowercaseString]];
    }
    
    //If it's edting
    if(edit){
        //if title and description is not empty
        if(![_noteDescription.text isEqualToString:@""] && ![_noteTitle.text isEqualToString:@""]){
            //if title hasn't been changed
            if([_noteTitle.text isEqualToString:[title objectAtIndex:currentIndex]]){
                [desc replaceObjectAtIndex:currentIndex withObject:_noteDescription.text];
                [userFile setValue:[desc objectAtIndex:currentIndex] forKey:[title objectAtIndex:currentIndex]];
                [self.view endEditing:true];
                NSLog(@"%@",userFile);
                //store in User Defaults
                [userDefaults setObject:userFile forKey:userDefaultKey];
                [userDefaults setObject:title forKey:userTitleKey];
                [userDefaults setObject:desc forKey:userDescriptionKey];
                _noteDescription.text = @"Add Message:";
                _noteDescription.textColor = [UIColor grayColor];
                _noteTitle.text = @"";
                [_addOrSave setImage:[UIImage imageNamed:@"addNote.png"] forState:UIControlStateNormal];
                
                [self.table reloadData];
            }else{
                [userFile removeObjectForKey:[title objectAtIndex:currentIndex]];
                [title replaceObjectAtIndex:currentIndex withObject: _noteTitle.text];
                [desc replaceObjectAtIndex:currentIndex withObject:_noteDescription.text];
                [userFile setValue:[desc objectAtIndex:currentIndex] forKey:[title objectAtIndex:currentIndex]];
                [self.view endEditing:true];
                NSLog(@"%@",userFile);
                _noteTitle.text = @"";
                _noteDescription.text = @"Add Message:";
                _noteDescription.textColor = [UIColor grayColor];
                [_noteTitle endEditing:true];
                [self.table reloadData];
                [userDefaults setObject:userFile forKey:userDefaultKey];
                [userDefaults setObject:title forKey:userTitleKey];
                [userDefaults setObject:desc forKey:userDescriptionKey];           }
        }else{
            //[alertController addAction:cancel];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        edit = false;
    }else{//since its not editing
        //if the string is not empty after being touched
        if(((![_noteDescription.text isEqualToString:@""] && ![_noteTitle.text isEqualToString:@""]) && didBeganEditing)){
            //if it the title is unique
                if(![tempTitle containsObject:[_noteTitle.text lowercaseString]]){
                [(NSMutableArray *) title insertObject:_noteTitle.text atIndex:0];
                [(NSMutableArray *) desc insertObject:_noteDescription.text atIndex:0];
                [(NSDictionary *) userFile setValue:_noteDescription.text forKey:_noteTitle.text];
                [self.view endEditing:true];
                NSLog(@"%@",userFile);
                _noteTitle.text = @"";
                _noteDescription.text = @"Add Message:";
                _noteDescription.textColor = [UIColor grayColor];
                [_noteTitle endEditing:true];
                [self.table reloadData];
                [userDefaults setObject:userFile forKey:userDefaultKey];
                [userDefaults setObject:title forKey:userTitleKey];
                [userDefaults setObject:desc forKey:userDescriptionKey];
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
    
    didBeganEditing = true;

    textView.textColor = [UIColor blackColor];
    if(!edit && [[textView text] isEqualToString:@"Add Message:"]){
        [textView setText:@""];
    }
    
    [_addOrSave setImage:[UIImage imageNamed:@"saveNote.png"] forState:UIControlStateNormal];
}

-(void) textViewDidEndEditing:(UITextView *)textView{
    [_addOrSave setImage:[UIImage imageNamed:@"addNote.png"] forState:UIControlStateNormal];
    didBeganEditing = false;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _noteTitle.text = title[indexPath.row];
    _noteDescription.text = [userFile valueForKey:title[indexPath.row]];
    edit = true;
    [_addOrSave setImage:[UIImage imageNamed:@"saveNote.png"] forState:UIControlStateNormal];
    
    currentIndex = indexPath.row;
    
    
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [title count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *SimpleIdentifier = @"SimpleIndentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleIdentifier];
    }
    
    cell.textLabel.text = title[indexPath.row];
    
    return cell;
}

@end
