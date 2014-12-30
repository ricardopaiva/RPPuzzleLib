//
//  RPPuzzleView.h
//  RPPuzzle
//
//  Created by Ricardo Paiva on 28/12/14.
//  Copyright (c) 2014 Ricardo Paiva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPBaseCustomView.h"

@protocol RPPuzzleViewDelegate <NSObject>
- (void)didFinishPuzzle;
@end

@interface RPPuzzleView : RPBaseCustomView <UIGestureRecognizerDelegate>
@property (nonatomic, strong) IBOutlet id<RPPuzzleViewDelegate> delegate;

- (void)setWord:(NSString *)word image:(UIImage *)image;
- (void)setHorizontalPieces:(NSInteger)horizPieces verticalPieces:(NSInteger)vertPieces;

- (void)refresh;
- (void)shuffle;

@end
