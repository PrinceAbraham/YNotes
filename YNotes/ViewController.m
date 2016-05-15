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

@interface ViewController ()<APParallaxViewDelegate>{
    BOOL parallaxWithView;
}

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UIButton *addOrSave;

@property EKEventStore *eStore;

@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIImageView *parralaximg;

@end

@implementation ViewController

@synthesize desc, table, userDefaults, userFile, title,edit, eStore, picker, searchBar, parralaximg;

bool didBeganEditing=false, searchIsEmpty=true;

int currentIndex=0;
NSString *pickedData;

NSMutableArray *displayArr, *dateCreatedArr, *dateModifiedArr;

NSMutableArray *dict;

NSMutableArray *tempTitle, *pickerData;

NSMutableString *searchText;

NSMutableArray *pickerDropDown;

IGLDropDownItem *pickerItem[3];

IGLDropDownMenu *pickerMenu;

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
    
    pickedData = [[NSString alloc]init];
    
    searchText = [[NSMutableString alloc] init];
    
    pickedData = @"Alphabetical";
    pickerItem[0] = [[IGLDropDownItem alloc]init];
    pickerItem[1] = [[IGLDropDownItem alloc]init];
    pickerItem[2] = [[IGLDropDownItem alloc]init];
    
    pickerMenu = [[IGLDropDownMenu alloc]init];
    
    pickerDropDown = [[NSMutableArray alloc]init];
    
    [pickerItem[0] setText:@"Alphabetical"];
    [pickerDropDown addObject:pickerItem[0]];
    [pickerItem[1] setText:@"Date Created"];
    [pickerDropDown addObject:pickerItem[1]];
    [pickerItem[2] setText:@"Date Modified"];
    [pickerDropDown addObject:pickerItem[2]];
    
    [pickerMenu setFrame:CGRectMake(100, 120, 200, 45)];
    pickerMenu.menuText = @"Sort";
    //[pickerMenu setMenuIconImage:[UIImage imageNamed:@"sort.png"]];
    pickerMenu.paddingLeft = 15;
    pickerMenu.backgroundColor = [UIColor grayColor];
    pickerMenu.type = IGLDropDownMenuTypeStack;
    pickerMenu.gutterY = 5;
    pickerMenu.itemAnimationDelay = 0.1;
    //pickerMenu.rotate = IGLDropDownMenuRotateRandom;
    [pickerMenu setDropDownItems:pickerDropDown];
    
    dict = [[NSMutableArray alloc]init];
    
    //User has info stored in the User Defaults
    if([userDefaults objectForKey:userDefaultKey]!=nil){
        [self getInfo];
    }
    
    //Get Access To Reminders
    [self.eStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        NSLog(@"%@", error);
    }];
    //searchText = @"";
//    picker.delegate = self;
//    picker.dataSource = self;
    searchBar.delegate = self;
    pickerMenu.delegate = self;
//    picker.hidden = true;
    [self.view addSubview:pickerMenu];
    [pickerMenu reloadView];
    [self toggle:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    //Retrieves Data and Loads the Table
    [self getInfo];
    [self.table reloadData];
    if([pickedData isEqualToString:@"Alphabetical"]){
        [self sortAlphabetical];
    }else if ([pickedData isEqualToString:@"Date Created"]){
        [self sortDateCreated];
    }else{
        [self sortDateModified];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)add:(id)sender {
    NSLog(@"add button clicked");
    
    //[self performSegueWithIdentifier:@"addOrEditSegue" sender:self];
}

#pragma mark - Search Functionality

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)sText{
    searchText = searchBar.text;
    searchIsEmpty = false;
    NSLog(@"Search Begins");
    NSArray *tempDisplayArr = [[NSArray alloc]initWithArray:displayArr];
    [displayArr removeAllObjects];
    for(int i=0; i <[tempDisplayArr count]; i++){
        if([[[tempDisplayArr objectAtIndex:i]lowercaseString] hasPrefix:[searchBar.text lowercaseString]]){
            [displayArr addObject:[tempDisplayArr objectAtIndex:i]];
        }
    }
    if([searchBar.text isEqualToString:@""]){
        [self getInfo];
        searchText = @"";
        searchIsEmpty = true;
    }
    [self.table reloadData];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    searchBar.text = @"";
    searchText = @"";
    searchIsEmpty = true;
}

-(void)dropDownMenu:(IGLDropDownMenu *)dropDownMenu selectedItemAtIndex:(NSInteger)index{
    pickedData = pickerItem[index];
    if(index==0){
        [self sortAlphabetical];
    }else if (index==1){
        [self sortDateCreated];
    }else{
        [self sortDateModified];
    }
    NSLog(@"DFDFFD");
    
}

#pragma mark - Sorting Functions

- (void)sortAlphabetical{
    
    [displayArr sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.table reloadData];
}
- (void)sortDateCreated{
    [dateCreatedArr sortUsingSelector:@selector(compare:)];
    [displayArr removeAllObjects];
    for(int i=0; i < [dict count]; i++){
        NSLog(@"%d",i);
        for( int j=0; j < [dict count]; j++){
            NSLog(@"%d",j);
            //if the dates match and the title is unique
            NSLog(@"%@ = %@",[dateCreatedArr objectAtIndex:i],[[dict objectAtIndex:j] objectForKey:@"Date Created"]);
            if(([[dateCreatedArr objectAtIndex:i] isEqual: [[dict objectAtIndex:j] objectForKey:@"Date Created"]]) && ![displayArr containsObject:[[dict objectAtIndex:j] objectForKey:@"Title"]] && ([[[[dict objectAtIndex:j] objectForKey:@"Title"] lowercaseString] hasPrefix:[searchText lowercaseString]] || searchIsEmpty)){
                [displayArr addObject: [[dict objectAtIndex:j] objectForKey:@"Title"]];
                NSLog(@"%@", [[dict objectAtIndex:j] objectForKey:@"Title"]);
            }
        }
    }
    [self.table reloadData];
}
- (void)sortDateModified{
    [dateModifiedArr sortUsingSelector:@selector(compare:)];
    [displayArr removeAllObjects];
    for(int i=0; i < [dict count]; i++){
        for( int j=0; j < [dict count]; j++){
            if(([[dateModifiedArr objectAtIndex:i] isEqual: [[dict objectAtIndex:j] objectForKey:@"Date Modified"]]) && ![displayArr containsObject:[[dict objectAtIndex:j] objectForKey:@"Title"]] && ([[[[dict objectAtIndex:j] objectForKey:@"Title"]lowercaseString] hasPrefix:[searchText lowercaseString]] || searchIsEmpty)){
                [displayArr addObject: [[dict objectAtIndex:j] objectForKey:@"Title"]];
            }
        }
    }
    [self.table reloadData];
    
}

#pragma mark - Table functions

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Gets the index number of the selected table
    currentIndex = indexPath.row;
    
    [self performSegueWithIdentifier:@"addOrEditSegue" sender:nil];
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //Sets the number of rows
    return [displayArr count];
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

#pragma mark - Picker functionality
//- (IBAction)sortButtonAction:(id)sender {
//    picker.hidden = !picker.hidden;
//}
//
//-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
//    return 1;
//}
//-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
//    return 3;
//}
//
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    return [pickerData objectAtIndex:row];
//}
//-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    pickedData = [pickerData objectAtIndex:row];
//    if([pickedData isEqualToString:@"Alphabetical"]){
//        [self sortAlphabetical];
//    }else if ([pickedData isEqualToString:@"Date Created"]){
//        [self sortDateCreated];
//    }else{
//        [self sortDateModified];
//    }
//    NSLog(@"%@", [pickerData objectAtIndex:row]);
//}

-(void) getInfo{
    //NSLog(@"%@", [userDefaults objectForKey:userDefaultKey]);
    userFile = [[userDefaults objectForKey:userDefaultKey]mutableCopy];//add mutable copy to retrieve properly. User default always returns immutable copy
    title = [[userDefaults objectForKey:userTitleKey]mutableCopy];
    desc = [[userDefaults objectForKey:userDescriptionKey]mutableCopy];
    displayArr = [[userDefaults objectForKey:userTitleKey]mutableCopy];
    dateCreatedArr = [[userDefaults objectForKey:userDateCreatedKey]mutableCopy];
    dict = [[userDefaults objectForKey:userAllInfoKey]mutableCopy];
    dateModifiedArr = [[userDefaults objectForKey:userDateModifiedKey]mutableCopy];
}

//Sends info while the segue is prepared
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //Required to have segue identifier
    if([[segue identifier] isEqualToString:@"addOrEditSegue"]){
        
        ViewControllerB *vc = [segue destinationViewController];
        //Genius LOL
        NSInteger *path = [title indexOfObject:[displayArr objectAtIndex:currentIndex]];
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


#pragma mark - APParallaxViewDelegate

- (void)parallaxView:(APParallaxView *)view willChangeFrame:(CGRect)frame {
    // Do whatever you need to do to the parallaxView or your subview before its frame changes
    NSLog(@"parallaxView:willChangeFrame: %@", NSStringFromCGRect(frame));
}

- (void)parallaxView:(APParallaxView *)view didChangeFrame:(CGRect)frame {
    // Do whatever you need to do to the parallaxView or your subview after its frame changed
    NSLog(@"parallaxView:didChangeFrame: %@", NSStringFromCGRect(frame));
}

- (void)toggle:(id)sender {
    /**
     *  For demo purposes this view controller either adds a parallaxView with a custom view
     *  or a parallaxView with an image.
     */
    if(parallaxWithView == NO) {
        
        [self.table addParallaxWithView:parralaximg andHeight:240];
        
        parallaxWithView = YES;
    }
    else {
        // add parallax with image
        [self.table addParallaxWithImage:[UIImage imageNamed:@"parralaxImg.jpg"] andHeight:160 andShadow:YES];
        parallaxWithView = NO;
        
        // Update the toggle button
        //        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"with view" style:UIBarButtonItemStylePlain target:self action:@selector(toggle:)];
        //        [self.navigationItem setRightBarButtonItem:barButton];
    }
    
    /**
     *  Setting a delegate for the parallaxView will allow you to get callbacks for when the
     *  frame of the parallaxView changes.
     *  Totally optional thou.
     */
    self.table.parallaxView.delegate = self;
    
}

@end
