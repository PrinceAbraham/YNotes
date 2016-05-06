//
//  ViewController.h
//  YNotes
//
//  Created by Prince on 4/29/16.
//  Copyright © 2016 Prince. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property NSMutableArray *desc;

@property NSMutableArray *title;

@property NSMutableDictionary *userFile;

@property (nonatomic, weak) NSUserDefaults *userDefaults;

@property bool edit;


@end
