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

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UIButton *addOrSave;

@property EKEventStore *eStore;

@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end

@implementation ViewController

@synthesize desc, table, userDefaults, userFile, title,edit, eStore, picker;

bool didBeganEditing=false;

int currentIndex=0;

NSMutableArray *displayArr, *dateCreatedArr, *dateModifiedArr;

NSMutableArray *dict;

NSMutableArray *tempTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    title = [[NSMutableArray alloc] init];
    
    desc = [[NSMutableArray alloc] init];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    userFile = [[NSMutableDictionary alloc]init];
    
    tempTitle = [[NSMutableArray alloc]init];
    
    eStore = [[EKEventStore alloc] init];
    
    displayArr = [[NSMutableArray alloc]init];
    
    dateCreatedArr = [[NSMutableArray alloc]init];
    
    dateModifiedArr = [[NSMutableArray alloc]init];
    
    dict = [[NSMutableArray alloc]init];
    
    //User has info stored in the User Defaults
    if([userDefaults objectForKey:userDefaultKey]!=nil){
        [self getInfo];
    }
    
    //Get Access To Reminders
    [self.eStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        NSLog(@"%@", error);
    }];
    
    picker.delegate = self;
    picker.dataSource = self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    //Retrieves Data and Loads the Table
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 3;
}

- (IBAction)sortAlphabetical:(id)sender {
    
    displayArr = title;
    [displayArr sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.table reloadData];
}
- (IBAction)sortDateCreated:(id)sender {
    [dateCreatedArr sortUsingSelector:@selector(compare:)];
    [displayArr removeAllObjects];
    for(int i=0; i < [dict count]; i++){
        for( int j=0; j < [dict count]; j++){
        if([[dateCreatedArr objectAtIndex:i] isEqual: [[dict objectAtIndex:j] objectForKey:@"Date Created"]]){
            [displayArr addObject: [[dict objectAtIndex:i] objectForKey:@"Title"]];
        }
        }
    }
    [self.table reloadData];
}
- (IBAction)sortDateModified:(id)sender {
    [dateModifiedArr sortUsingSelector:@selector(compare:)];
    [displayArr removeAllObjects];
    for(int i=0; i < [dict count]; i++){
        for( int j=0; j < [dict count]; j++){
            if([[dateModifiedArr objectAtIndex:i] isEqual: [[dict objectAtIndex:j] objectForKey:@"Date Modified"]]){
                [displayArr addObject: [[dict objectAtIndex:j] objectForKey:@"Title"]];
            }
        }
    }
    [self.table reloadData];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Gets the index number of the selected table
    currentIndex = indexPath.row;
    
    [self performSegueWithIdentifier:@"addOrEditSegue" sender:nil];

}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    
//    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
//    
//    return [self.sectionDateFormatter stringFromDate:dateRepresentingThisDay];
//    
//}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //Sets the number of rows
    return [title count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *SimpleIdentifier = @"Simple Indentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleIdentifier];
    }
    
    cell.textLabel.text = displayArr[indexPath.row];
    
    return cell;
}

-(void) getInfo{
    //NSLog(@"%@", [userDefaults objectForKey:userDefaultKey]);
    userFile = [[userDefaults objectForKey:userDefaultKey]mutableCopy];//add mutable copy to retrieve properly. User default always returns immutable copy
    title = [[userDefaults objectForKey:userTitleKey]mutableCopy];
    desc = [[userDefaults objectForKey:userDescriptionKey]mutableCopy];
    displayArr = title;
    dateCreatedArr = [[userDefaults objectForKey:userDateCreatedKey]mutableCopy];
    dict = [[userDefaults objectForKey:userAllInfoKey]mutableCopy];
    dateModifiedArr = [[userDefaults objectForKey:userDateModifiedKey]mutableCopy];
}

//Sends info while the segue is prepared
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //Required to have segue identifier
    if([[segue identifier] isEqualToString:@"addOrEditSegue"]){
        
        ViewControllerB *vc = [segue destinationViewController];
        
        NSInteger *path = [displayArr indexOfObject:[displayArr objectAtIndex:currentIndex]];
        vc.isEditing = true;
        vc.titleString = [title objectAtIndex:path];
        vc.messageData = [desc objectAtIndex:path];
        vc.indexForTable = path;
        
        NSPredicate *predicate = [eStore predicateForRemindersInCalendars:nil];
        //Checks for any reminder with the name == title
        [eStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *rem){
            for(EKReminder *reminder in rem){
                if([reminder.title isEqualToString: [title objectAtIndex:path]]){
                    NSLog(@"matched");
                    vc.reminderIsSet = true;
                }
            }
        }];
    }
    
}

@end
