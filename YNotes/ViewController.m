//
//  ViewController.m
//  YNotes
//
//  Created by Prince on 4/29/16.
//  Copyright © 2016 Prince. All rights reserved.
//

#import "ViewController.h"
#import "ViewControllerB.h"
#import "ConstantsClass.h"

@import UIKit;

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UIButton *addOrSave;

@end

@implementation ViewController

@synthesize desc, table, userDefaults, userFile, title,edit;

 edit=false;

bool didBeganEditing=false;

int currentIndex=0;

NSMutableArray *tempTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    title = [[NSMutableArray alloc] init];
    
    desc = [[NSMutableArray alloc] init];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    userFile = [[NSMutableDictionary alloc]init];
    
    tempTitle = [[NSMutableArray alloc]init];
    
    if([userDefaults objectForKey:userDefaultKey]!=nil){
        [self getInfo];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self getInfo];
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)add:(id)sender {
    NSLog(@"add button clicked");
    
    //[self performSegueWithIdentifier:@"addOrEditSegue" sender:self];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //_noteTitle.text = title[indexPath.row];
    
    edit = true;
    
    currentIndex = indexPath.row;
    
    [self performSegueWithIdentifier:@"addOrEditSegue" sender:nil];
    
    
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [title count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *SimpleIdentifier = @"Simple Indentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleIdentifier];
    }
    
    cell.textLabel.text = title[indexPath.row];
    
    return cell;
}

-(void) getInfo{
    //NSLog(@"%@", [userDefaults objectForKey:userDefaultKey]);
    userFile = [[userDefaults objectForKey:userDefaultKey]mutableCopy];//add mutable copy to retrieve properly. User default always returns immutable copy
    title = [[userDefaults objectForKey:userTitleKey]mutableCopy];
    desc = [[userDefaults objectForKey:userDescriptionKey]mutableCopy];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"addOrEditSegue"]){
        
        //NSLog(@"Got addOrEditSegue %@",[segue identifier]);
        
        ViewControllerB *vc = [segue destinationViewController];
        
        NSIndexPath *path = [self.table indexPathForSelectedRow];
        vc.isEditing = true;
        vc.titleString = [title objectAtIndex:path.row];
        vc.messageData = [desc objectAtIndex:path.row];
        vc.indexForTable = path.row;
        //ViewControllerB *detail = [self detailForIndexPath:path];
        //[segue.destinationViewController setDetail:detail];
        
    }
    
}

@end
