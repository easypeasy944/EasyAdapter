//
//  ObjcHelpers.h
//  TableAdapter
//
//  Created by Aynur Galiev on 4.февраля.2017.
//  Copyright © 2017 Aynur Galiev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DefaultBlock)(void);
typedef void (^ExceptionBlock)(NSException * _Nonnull exception);

typedef DefaultBlock TryBlock;
typedef DefaultBlock FinallyBlock;

@interface ObjcHelpers : NSObject

+ (void) exceptionHandler: (_Nonnull  TryBlock) tryBlock
                    catch: (_Nullable ExceptionBlock) catchBlock
                  finally: (_Nullable FinallyBlock) finallyBlock;

@end
