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

@interface ViewController (){
    BOOL parallaxWithView;
}

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UIButton *addOrSave;

@property EKEventStore *eStore;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIImageView *parralaximg;

@end

@implementation ViewController

@synthesize desc, table, userDefaults, userFile, title,edit, eStore, searchBar, parralaximg, initialDisplayArr;

bool didBeganEditing=false, searchIsEmpty=true;

Note *note;

int currentIndex=0;
NSString *pickedData;

NSMutableArray *notes, *displayArr, *dateCreatedArr, *dateModifiedArr;

NSMutableArray *dict;

NSMutableArray *tempTitle, *pickerData;

NSMutableString *searchText;

NSMutableArray *pickerDropDown;

UIImageView *customView;

IGLDropDownItem *pickerItem[3];

IGLDropDownMenu *pickerMenu;

UIDevice * device;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    note = [[Note alloc]init];
    
    notes= [[NSMutableArray alloc]init];
    
    title = [[NSMutableArray alloc] init];
    
    desc = [[NSMutableArray alloc] init];
    
    initialDisplayArr = [[NSMutableArray alloc] init];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    userFile = [[NSMutableDictionary alloc]init];
    
    tempTitle = [[NSMutableArray alloc]init];
    
    eStore = [[EKEventStore alloc] init];
    
    displayArr = [[NSMutableArray alloc]init];
    
    dateCreatedArr = [[NSMutableArray alloc]init];
    
    dateModifiedArr = [[NSMutableArray alloc]init];
    
    pickedData = [[NSString alloc]init];
    
    customView = [[UIImageView alloc] init];
    
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
    
    dict = [[NSMutableArray alloc]init];
    
    //User has info stored in the User Defaults
    if([userDefaults objectForKey:userAllInfoKey]!=nil){
        [self getInfo];
    }
    
    //Get Access To Reminders
    [self.eStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        NSLog(@"%@", error);
    }];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    searchBar.delegate = self;
    pickerMenu.delegate = self;
    //    picker.hidden = true;
}

-(void)viewWillAppear:(BOOL)animated{
    //Reloads the Table
    
    [self getInfo];
    searchBar.text =@"";
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:true];
    self.searchBar.text = searchText;
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

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:true];
    self.searchBar.text = searchText;
}


#pragma mark - DropDown Sorting
-(void)dropDownMenu:(IGLDropDownMenu *)dropDownMenu selectedItemAtIndex:(NSInteger)index{
    pickedData = pickerItem[index].text;
    if(index==0){
        [self sortAlphabetical];
    }else if (index==1){
        [self sortDateCreated];
    }else{
        [self sortDateModified];
    }
    
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
            NSLog(@"%@ = %@",[dateCreatedArr objectAtIndex:i],[[dict objectAtIndex:j] noteCreated]);
            if(([[dateCreatedArr objectAtIndex:i] isEqual: [[dict objectAtIndex:j] noteCreated]]) && ![displayArr containsObject:[[dict objectAtIndex:j] noteTitle]] && ([[[[dict objectAtIndex:j] noteTitle] lowercaseString] hasPrefix:[searchText lowercaseString]] || searchIsEmpty)){
                [displayArr addObject: [[dict objectAtIndex:j] noteTitle]];
                NSLog(@"%@", [[dict objectAtIndex:j] noteTitle]);
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
            if(([[dateModifiedArr objectAtIndex:i] isEqual: [[dict objectAtIndex:j] noteModified]]) && ![displayArr containsObject:[[dict objectAtIndex:j] noteTitle]] && ([[[[dict objectAtIndex:j] noteTitle]lowercaseString] hasPrefix:[searchText lowercaseString]] || searchIsEmpty)){
                [displayArr addObject: [[dict objectAtIndex:j] noteTitle]];
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

-(void) getInfo{
    //add mutable copy to retrieve properly. User default always returns immutable copy
    notes = [[userDefaults objectForKey:userAllInfoKey]mutableCopy];
    
    [dict removeAllObjects];
    [displayArr removeAllObjects];
    [desc removeAllObjects];
    [dateCreatedArr removeAllObjects];
    [dateModifiedArr removeAllObjects];
    [initialDisplayArr removeAllObjects];
    
    for(int i=0; i< [notes count]; i++){
        [dict addObject:[note decodeData:[notes objectAtIndex:i]]];
        [initialDisplayArr addObject:[[dict objectAtIndex:i] noteTitle]];
        [displayArr addObject:[[dict objectAtIndex:i] noteTitle]];
        [desc addObject:[[dict objectAtIndex:i] noteMessage]];
        [dateCreatedArr addObject:[[dict objectAtIndex:i] noteCreated]];
        [dateModifiedArr addObject:[[dict objectAtIndex:i] noteModified]];
    }
//    displayArr = initialDisplayArr.copy;
    title = displayArr;
}

//Sends info while the segue is prepared
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //Required to have segue identifier
    if([[segue identifier] isEqualToString:@"addOrEditSegue"]){
        
        ViewControllerB *vc = [segue destinationViewController];
        //Genius LOL
        int path = [initialDisplayArr indexOfObject:[displayArr objectAtIndex:currentIndex]];
        vc.isEditing = true;
        vc.titleString = [initialDisplayArr objectAtIndex:path];
        vc.messageStringWAttachments = [desc objectAtIndex:path];
        vc.indexForTable = path;
        
        NSPredicate *predicate = [eStore predicateForRemindersInCalendars:nil];
        //Checks for any reminder with the name == title
        [eStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *rem){
            for(EKReminder *reminder in rem){
                if([reminder.title isEqualToString: [initialDisplayArr objectAtIndex:path]]){
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
    [self.view endEditing:YES];
}

- (void)parallaxView:(APParallaxView *)view didChangeFrame:(CGRect)frame {
    // Do whatever you need to do to the parallaxView or your subview after its frame changed
    NSLog(@"parallaxView:didChangeFrame: %@", NSStringFromCGRect(frame));
}


- (void) orientationChanged:(NSNotification *)note
{
    [pickerMenu selectItemAtIndex:[pickerMenu selectedIndex]];
    
    device = note.object;
    
    UIImageView *customView = [[UIImageView alloc] init];
    
    //[self toggle:nil];
    
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
    
        [customView setFrame:CGRectMake(0, 0, 480, 160)];
        customView.image = [UIImage imageNamed:@"parralaxImg.jpg"];
        [customView setContentMode:UIViewContentModeScaleAspectFill];
        [self.table addParallaxWithView:customView andHeight:160];
            
            [pickerMenu setFrame:CGRectMake(0, 120, self.view.frame.size.width, 45)];
            pickerMenu.menuText = @"       Sort";
            //[pickerMenu setMenuIconImage:[UIImage imageNamed:@"sort.png"]];
            pickerMenu.paddingLeft = self.view.frame.size.width/2.6;
            pickerMenu.backgroundColor = [UIColor clearColor];
            pickerMenu.type = IGLDropDownMenuTypeNormal;
            pickerMenu.gutterY = 5;
            pickerMenu.itemAnimationDelay = 0.05;
            pickerMenu.menuButtonStatic = NO;
            [pickerMenu setDropDownItems:pickerDropDown];
            [self.view addSubview:pickerMenu];
            [pickerMenu reloadView];
            break;
            
        case UIDeviceOrientationLandscapeLeft:

            [customView setFrame:CGRectMake(0, 0, 680, 240)];
            customView.image = [UIImage imageNamed:@"parralaxImg.jpg"];
            [customView setContentMode:UIViewContentModeScaleAspectFill];
            [self.table addParallaxWithView:customView andHeight:160];
            
            [pickerMenu setFrame:CGRectMake(0, 100, self.view.frame.size.width, 45)];
            pickerMenu.menuText = @"       Sort";
            //[pickerMenu setMenuIconImage:[UIImage imageNamed:@"sort.png"]];
            pickerMenu.paddingLeft = self.view.frame.size.width/2.28;
            pickerMenu.backgroundColor = [UIColor clearColor];
            pickerMenu.type = IGLDropDownMenuTypeNormal;
            pickerMenu.gutterY = 5;
            pickerMenu.itemAnimationDelay = 0.05;
            pickerMenu.menuButtonStatic = NO;
            [pickerMenu setDropDownItems:pickerDropDown];
            [self.view addSubview:pickerMenu];
            [pickerMenu reloadView];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            
            [customView setFrame:CGRectMake(0, 0, 680, 240)];
            customView.image = [UIImage imageNamed:@"parralaxImg.jpg"];
            [customView setContentMode:UIViewContentModeScaleAspectFill];
            [self.table addParallaxWithView:customView andHeight:160];
            
            [pickerMenu setFrame:CGRectMake(0, 100, self.view.frame.size.width, 45)];
            pickerMenu.menuText = @"       Sort";
            //[pickerMenu setMenuIconImage:[UIImage imageNamed:@"sort.png"]];
            pickerMenu.paddingLeft = self.view.frame.size.width/2.28;
            pickerMenu.backgroundColor = [UIColor clearColor];
            pickerMenu.type = IGLDropDownMenuTypeNormal;
            pickerMenu.gutterY = 5;
            pickerMenu.itemAnimationDelay = 0.05;
            pickerMenu.menuButtonStatic = NO;
            [pickerMenu setDropDownItems:pickerDropDown];
            [self.view addSubview:pickerMenu];
            [pickerMenu reloadView];
            break;
            
        default:
            
            break;
    };
}

@end
