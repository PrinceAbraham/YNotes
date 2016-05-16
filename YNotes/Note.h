//
//  Note.h
//  YNotes
//
//  Created by Prince on 5/16/16.
//  Copyright © 2016 Prince. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Note : NSObject

@property (nonatomic, weak) NSMutableString *noteTitle;

@property (nonatomic, weak) NSMutableAttributedString *noteMessage;

@property (nonatomic, weak) NSDate *noteCreated;

@property (nonatomic, weak) NSDate *noteModified;


-(void) setNoteTitle:(NSMutableString *)noteTitle;
-(void) setNoteMessage:(NSMutableAttributedString *)noteMessage;
-(void) setNoteCreated:(NSDate *)noteCreated;
-(void) setNoteModified:(NSDate *)noteModified;

-(NSMutableString *) getNoteTitle;
-(NSMutableAttributedString *) getNoteMessage;
-(NSDate *)getNoteCreated;
-(NSDate *)getNoteModified;

@end
