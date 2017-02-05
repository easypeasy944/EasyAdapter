//
//  ObjcHelpers.m
//  TableAdapter
//
//  Created by Aynur Galiev on 4.февраля.2017.
//  Copyright © 2017 Aynur Galiev. All rights reserved.
//

#import "ObjcHelpers.h"


@implementation ObjcHelpers

+ (void) exceptionHandler: (_Nonnull  TryBlock) tryBlock
                    catch: (_Nullable ExceptionBlock) catchBlock
                  finally: (_Nullable FinallyBlock) finallyBlock {
    
    @try {
        tryBlock();
    } @catch (NSException *exception) {
        if (catchBlock != NULL) {
            catchBlock(exception);
        }
    } @finally {
        if (finallyBlock != NULL) {
            finallyBlock();
        }
    }
    
}

@end
