//
//  Note.h
//  YNotes
//
//  Created by Prince on 5/16/16.
//  Copyright © 2016 Prince. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConstantsClass.h"

@interface Note : NSObject

@property (nonatomic, copy) NSMutableString *noteTitle;

@property (nonatomic, copy) NSMutableAttributedString *noteMessage;

@property (nonatomic, copy) NSDate *noteCreated;

@property (nonatomic, copy) NSDate *noteModified;


-(void) setNoteTitle:(NSMutableString *)noteTitle;
-(void) setNoteMessage:(NSMutableAttributedString *)noteMessage;
-(void) setNoteCreated:(NSDate *)noteCreated;
-(void) setNoteModified:(NSDate *)noteModified;

-(NSMutableString *) getNoteTitle;
-(NSMutableAttributedString *) getNoteMessage;
-(NSDate *)getNoteCreated;
-(NSDate *)getNoteModified;
-(NSMutableData *) changeToData:(Note *) n;
-(Note *) decodeData:(NSMutableData *)data;
@end
