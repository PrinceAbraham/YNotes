//
//  Note.m
//  YNotes
//
//  Created by Prince on 5/16/16.
//  Copyright © 2016 Prince. All rights reserved.
//

#import "Note.h"

@implementation Note

//@synthesize noteTitle, noteMessage, noteCreated, noteModified;

-(void)setNoteTitle:(NSMutableString *)noteTitle{
    
    _noteTitle = noteTitle;
    
}

-(NSMutableString *) getNoteTitle{
    
    return _noteTitle;
}

-(void)setNoteMessage:(NSMutableAttributedString *)message{
    
    _noteMessage = message;
    
}

-(NSMutableAttributedString *) getNoteMessage{
    
    return _noteMessage;
}

-(void)setNoteCreated:(NSDate *)created{
    _noteCreated = created;
}

-(NSDate *)getNoteCreated{
    return _noteCreated;
}

-(void)setNoteModified:(NSDate *)modified{
    
    _noteModified = modified;
}

-(NSDate *)getNoteModified{
    return _noteModified;
}

@end
