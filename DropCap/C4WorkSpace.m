//
//  C4WorkSpace.m
//  DropCap
//
//  Created by moi on 13-01-31.
//  Copyright (c) 2013 moi. All rights reserved.
//

#import "C4WorkSpace.h"
#import "DropCapView.h"

@implementation C4WorkSpace {
    DropCapView *stl;
}

-(void)setup {
    stl = [[DropCapView alloc] initWithFrame:self.canvas.frame];
    [self.canvas addSubview:stl];
}

@end
