//
//  Note.m
//  YNotes
//
//  Created by Prince on 5/16/16.
//  Copyright © 2016 Prince. All rights reserved.
//

#import "Note.h"

@implementation Note

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.noteTitle forKey:@"PROPERTY_KEY"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        self.noteTitle = [aDecoder decodeObjectForKey:@"PROPERTY_KEY"];
    }
    return self;
}

//@synthesize noteTitle, noteMessage, noteCreated, noteModified;

-(void)setNoteTitle:(NSMutableString *)Title{
    
    _noteTitle = Title;
    
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

-(NSMutableData *) changeToData:(Note *) n{
    NSMutableData *msgData = [[NSMutableData alloc]init];
    msgData = [[NSKeyedArchiver archivedDataWithRootObject:n]mutableCopy];
    return msgData;
}


@end
