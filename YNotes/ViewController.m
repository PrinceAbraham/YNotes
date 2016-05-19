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
#import "headerForTable.h"
#import "BFPaperTableViewCell.h"
#import "UIColor+BFPaperColors.h"

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
    
    UIImage *I = [UIImage imageNamed:@"parralaxImg.jpg"];
    
    NSDictionary * d = [self mainColorsInImage:I detail:1];
    
    UIColor *c = [UIColor colorWithRed:0.494118 green:0.258824 blue:0.121569 alpha:1];
    
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
    self.table.backgroundColor= [UIColor paperColorGray50];

    //    GRADIENT BUT LANDSCAPE ISSUE
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.view.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor paperColorDeepOrange] CGColor], (id)[[UIColor paperColorGray50] CGColor], nil];
//    [self.view.layer insertSublayer:gradient atIndex:0];
    
    self.view.backgroundColor = [UIColor paperColorDeepOrange];
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
    currentIndex = indexPath.row-1;
    
    [self performSegueWithIdentifier:@"addOrEditSegue" sender:nil];
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //Sets the number of rows
    return [displayArr count]+1;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int i = indexPath.row;
    
    BFPaperTableViewCell *bfCell = [tableView dequeueReusableCellWithIdentifier:@"BFPaperCell"];
    
    bfCell.rippleFromTapLocation = NO; // Will always ripple from center if NO.
    bfCell.tapCircleColor = [[UIColor paperColorDeepOrange] colorWithAlphaComponent:0.5f];
    bfCell.backgroundFadeColor = [UIColor whiteColor];
    bfCell.backgroundColor = [UIColor paperColorGray200];
    bfCell.letBackgroundLinger = NO;
    bfCell.tapCircleDiameter = bfPaperTableViewCell_tapCircleDiameterSmall;
    bfCell.textLabel.textColor = [UIColor paperColorDeepOrange];
    bfCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
    //bfCell.textLabel.text =@"What";
    if (!bfCell) {
        bfCell = [[BFPaperTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BFPaperCell"];
    }
    i--;
//    
//    NSString *SimpleIdentifier = @"cell";
//    
//    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    
    //test
    
    NSString *SimpleIdentifierh = @"headerForTable";
    
    
    headerForTable *hcell = (headerForTable *)[tableView dequeueReusableCellWithIdentifier:SimpleIdentifierh];
    if(i>=0){
        bfCell.textLabel.text = displayArr[i];
    }
    
    if (indexPath.row == 0) {
        return hcell;
    }else{
        return bfCell;
    }
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
    
    device = note.object;
    
    UIImageView *customView = [[UIImageView alloc] init];
    
    //[self toggle:nil];
    
    [pickerMenu reloadView];
    
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
        [pickerMenu selectItemAtIndex:[pickerMenu selectedIndex]];
        [customView setFrame:CGRectMake(0, 0, 480, 160)];
        customView.image = [UIImage imageNamed:@"parralaxImg.jpg"];
        [customView setContentMode:UIViewContentModeScaleAspectFill];
        [self.table addParallaxWithView:customView andHeight:160];
            
            pickerMenu.menuText = @"       Sort";
            //[pickerMenu setMenuIconImage:[UIImage imageNamed:@"sort.png"]];
            pickerMenu.paddingLeft = self.view.frame.size.width/2.6;
            pickerMenu.backgroundColor = [UIColor clearColor];
            pickerMenu.type = IGLDropDownMenuTypeNormal;
            pickerMenu.gutterY = 5;
            pickerMenu.itemAnimationDelay = 0.05;
            pickerMenu.menuButtonStatic = NO;
            [pickerMenu setDropDownItems:pickerDropDown];
            [pickerMenu setFrame:CGRectMake(0, 120, self.view.frame.size.width, 45)];
            [self.view addSubview:pickerMenu];
            [pickerMenu reloadView];
            break;
            
        case UIDeviceOrientationLandscapeLeft:

            [pickerMenu selectItemAtIndex:[pickerMenu selectedIndex]];
            [customView setFrame:CGRectMake(0, 0, 680, 240)];
            customView.image = [UIImage imageNamed:@"parralaxImg.jpg"];
            [customView setContentMode:UIViewContentModeScaleAspectFill];
            [self.table addParallaxWithView:customView andHeight:160];
            
            pickerMenu.menuText = @"       Sort";
            pickerMenu.paddingLeft = self.view.frame.size.width/2.28;
            pickerMenu.backgroundColor = [UIColor clearColor];
            pickerMenu.type = IGLDropDownMenuTypeNormal;
            pickerMenu.gutterY = 5;
            pickerMenu.itemAnimationDelay = 0.05;
            pickerMenu.menuButtonStatic = NO;
            [pickerMenu setFrame:CGRectMake(0, 100, self.view.frame.size.width, 45)];
            [pickerMenu setDropDownItems:pickerDropDown];
            [self.view addSubview:pickerMenu];
            [pickerMenu reloadView];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            
            [customView setFrame:CGRectMake(0, 0, 680, 240)];
            customView.image = [UIImage imageNamed:@"parralaxImg.jpg"];
            [customView setContentMode:UIViewContentModeScaleAspectFill];
            [self.table addParallaxWithView:customView andHeight:160];
            
            [pickerMenu selectItemAtIndex:[pickerMenu selectedIndex]];
            pickerMenu.menuText = @"       Sort";
            pickerMenu.paddingLeft = self.view.frame.size.width/2.28;
            pickerMenu.backgroundColor = [UIColor clearColor];
            pickerMenu.type = IGLDropDownMenuTypeNormal;
            pickerMenu.gutterY = 5;
            pickerMenu.itemAnimationDelay = 0.05;
            pickerMenu.menuButtonStatic = NO;
            [pickerMenu setDropDownItems:pickerDropDown];
            [pickerMenu setFrame:CGRectMake(0, 100, self.view.frame.size.width, 45)];
            [self.view addSubview:pickerMenu];
            [pickerMenu reloadView];
            break;
            
        default:
            
            break;
    };
}


-(NSDictionary*)mainColorsInImage:(UIImage *)image detail:(int)detail {
    
    //1. determine detail vars (0==low,1==default,2==high)
    //default detail
    float dimension = 10;
    float flexibility = 2;
    float range = 60;
    
    //low detail
    if (detail==0){
        dimension = 4;
        flexibility = 1;
        range = 100;
        
        //high detail (patience!)
    } else if (detail==2){
        dimension = 100;
        flexibility = 10;
        range = 20;
    }
    
    //2. determine the colours in the image
    NSMutableArray * colours = [NSMutableArray new];
    CGImageRef imageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(dimension * dimension * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * dimension;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, dimension, dimension, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, dimension, dimension), imageRef);
    CGContextRelease(context);
    
    float x = 0;
    float y = 0;
    for (int n = 0; n<(dimension*dimension); n++){
        
        int index = (bytesPerRow * y) + x * bytesPerPixel;
        int red   = rawData[index];
        int green = rawData[index + 1];
        int blue  = rawData[index + 2];
        int alpha = rawData[index + 3];
        NSArray * a = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",red],[NSString stringWithFormat:@"%i",green],[NSString stringWithFormat:@"%i",blue],[NSString stringWithFormat:@"%i",alpha], nil];
        [colours addObject:a];
        
        y++;
        if (y==dimension){
            y=0;
            x++;
        }
    }
    free(rawData);
    
    //3. add some colour flexibility (adds more colours either side of the colours in the image)
    NSArray * copyColours = [NSArray arrayWithArray:colours];
    NSMutableArray * flexibleColours = [NSMutableArray new];
    
    float flexFactor = flexibility * 2 + 1;
    float factor = flexFactor * flexFactor * 3; //(r,g,b) == *3
    for (int n = 0; n<(dimension * dimension); n++){
        
        NSArray * pixelColours = copyColours[n];
        NSMutableArray * reds = [NSMutableArray new];
        NSMutableArray * greens = [NSMutableArray new];
        NSMutableArray * blues = [NSMutableArray new];
        
        for (int p = 0; p<3; p++){
            
            NSString * rgbStr = pixelColours[p];
            int rgb = [rgbStr intValue];
            
            for (int f = -flexibility; f<flexibility+1; f++){
                int newRGB = rgb+f;
                if (newRGB<0){
                    newRGB = 0;
                }
                if (p==0){
                    [reds addObject:[NSString stringWithFormat:@"%i",newRGB]];
                } else if (p==1){
                    [greens addObject:[NSString stringWithFormat:@"%i",newRGB]];
                } else if (p==2){
                    [blues addObject:[NSString stringWithFormat:@"%i",newRGB]];
                }
            }
        }
        
        int r = 0;
        int g = 0;
        int b = 0;
        for (int k = 0; k<factor; k++){
            
            int red = [reds[r] intValue];
            int green = [greens[g] intValue];
            int blue = [blues[b] intValue];
            
            NSString * rgbString = [NSString stringWithFormat:@"%i,%i,%i",red,green,blue];
            [flexibleColours addObject:rgbString];
            
            b++;
            if (b==flexFactor){ b=0; g++; }
            if (g==flexFactor){ g=0; r++; }
        }
    }
    
    //4. distinguish the colours
    //orders the flexible colours by their occurrence
    //then keeps them if they are sufficiently disimilar
    
    NSMutableDictionary * colourCounter = [NSMutableDictionary new];
    
    //count the occurences in the array
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:flexibleColours];
    for (NSString *item in countedSet) {
        NSUInteger count = [countedSet countForObject:item];
        [colourCounter setValue:[NSNumber numberWithInteger:count] forKey:item];
    }
    
    //sort keys highest occurrence to lowest
    NSArray *orderedKeys = [colourCounter keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj2 compare:obj1];
    }];
    
    //checks if the colour is similar to another one already included
    NSMutableArray * ranges = [NSMutableArray new];
    for (NSString * key in orderedKeys){
        NSArray * rgb = [key componentsSeparatedByString:@","];
        int r = [rgb[0] intValue];
        int g = [rgb[1] intValue];
        int b = [rgb[2] intValue];
        bool exclude = false;
        for (NSString * ranged_key in ranges){
            NSArray * ranged_rgb = [ranged_key componentsSeparatedByString:@","];
            
            int ranged_r = [ranged_rgb[0] intValue];
            int ranged_g = [ranged_rgb[1] intValue];
            int ranged_b = [ranged_rgb[2] intValue];
            
            if (r>= ranged_r-range && r<= ranged_r+range){
                if (g>= ranged_g-range && g<= ranged_g+range){
                    if (b>= ranged_b-range && b<= ranged_b+range){
                        exclude = true;
                    }
                }
            }
        }
        
        if (!exclude){ [ranges addObject:key]; }
    }
    
    //return ranges array here if you just want the ordered colours high to low
    NSMutableArray * colourArray = [NSMutableArray new];
    for (NSString * key in ranges){
        NSArray * rgb = [key componentsSeparatedByString:@","];
        float r = [rgb[0] floatValue];
        float g = [rgb[1] floatValue];
        float b = [rgb[2] floatValue];
        UIColor * colour = [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f];
        [colourArray addObject:colour];
    }
    
    //if you just want an array of images of most common to least, return here
    //return [NSDictionary dictionaryWithObject:colourArray forKey:@"colours"];
    
    
    //if you want percentages to colours continue below
    NSMutableDictionary * temp = [NSMutableDictionary new];
    float totalCount = 0.0f;
    for (NSString * rangeKey in ranges){
        NSNumber * count = colourCounter[rangeKey];
        totalCount += [count intValue];
        temp[rangeKey]=count;
    }
    
    //set percentages
    NSMutableDictionary * colourDictionary = [NSMutableDictionary new];
    for (NSString * key in temp){
        float count = [temp[key] floatValue];
        float percentage = count/totalCount;
        NSArray * rgb = [key componentsSeparatedByString:@","];
        float r = [rgb[0] floatValue];
        float g = [rgb[1] floatValue];
        float b = [rgb[2] floatValue];
        UIColor * colour = [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f];
        colourDictionary[colour]=[NSNumber numberWithFloat:percentage];
    }
    
    return colourDictionary;
    
}

@end
