//
//  ViewController.m
//  YNotes
//
//  Created by Prince on 4/29/16.
//  Copyright © 2016 Prince. All rights reserved.
//

#import "ViewController.h"
@import UIKit;

@interface ViewController () 

@property (weak, nonatomic) IBOutlet UITextView *noteDescription;

@property (strong, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UIButton *addOrSave;

@end

@implementation ViewController

@synthesize list, table, userDefaults;

bool *edit=false;

int *currentIndex=0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    list = [[NSMutableArray alloc] init];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    if([userDefaults objectForKey:@"listData"]!=nil){
    
    list = [[userDefaults objectForKey:@"listData"]mutableCopy];//add mutable copy to retrieve properly. User default always returns immutable copy
        
        
        NSLog(@"%@",list);
        
    }
    
    _noteDescription.delegate = self;


    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)deleteNote:(id)sender {
    
    [list removeObjectAtIndex:currentIndex];
    
    _noteDescription.text = @"";
    
    [self.table reloadData];
    
    [_addOrSave setImage:[UIImage imageNamed:@"addNote.png"] forState:UIControlStateNormal];
    
    edit = false;

    
}

- (IBAction)addNote:(id)sender {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Empty Note"
                                          message:@"Description cannot be empty!"
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
    
    if(edit){
        
        if(![_noteDescription.text isEqualToString:@""]){
            
            [list replaceObjectAtIndex:currentIndex withObject:_noteDescription.text];
            //currentIndex = [list count];
            [self.view endEditing:true];
            NSLog(@"%@",list);
            
            _noteDescription.text = @"";
            
            [self.table reloadData];
            
            [userDefaults setObject:list forKey:@"listData"];
            
            [_addOrSave setImage:[UIImage imageNamed:@"addNote.png"] forState:UIControlStateNormal];
            
            
        }else{

            //[alertController addAction:cancel];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            
        }

        edit = false;

        
        
    }else{
    
    if(![_noteDescription.text isEqualToString:@""]){
    
        
        
    [(NSMutableArray *) list insertObject:_noteDescription.text atIndex:0];
        //currentIndex = [list count];
    [self.view endEditing:true];
     NSLog(@"%@",list);
    
    _noteDescription.text = @"";
        
    [self.table reloadData];
    
    [userDefaults setObject:list forKey:@"listData"];
    
    }else{
        
        
        //[alertController addAction:cancel];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    }
    }
    

    
}

-(void) textViewDidBeginEditing:(UITextView *)textView{
    
    if(!edit){
    [textView setText:@""];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"%ld",(long) indexPath.row);
    
    _noteDescription.text = [list objectAtIndex:indexPath.row];
    
    edit = true;
    
    [_addOrSave setImage:[UIImage imageNamed:@"saveNote.png"] forState:UIControlStateNormal];
    
    currentIndex = indexPath.row;
    
    
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [list count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *SimpleIdentifier = @"SimpleIndentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleIdentifier];
    }
    
    cell.textLabel.text = list[indexPath.row];
    
    return cell;
}

@end
