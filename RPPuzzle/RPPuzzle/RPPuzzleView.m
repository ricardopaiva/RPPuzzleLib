//
//  RPPuzzleView.m
//  RPPuzzle
//
//  Created by Ricardo Paiva on 28/12/14.
//  Copyright (c) 2014 Ricardo Paiva. All rights reserved.
//

#import "RPPuzzleView.h"
#import "RPPuzzlePiece.h"
#import "NSString+Additions.h"
#import "NSMutableArray+Shuffle.h"

static NSString *const nibNameKey = @"RPPuzzleView";
static NSTimeInterval const puzzleAnimationDuration = 0.20f;

@interface RPPuzzleView()
@property (nonatomic, strong) NSString *word;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) NSInteger peaceHCount_;
@property (nonatomic) NSInteger peaceVCount_;
@property (nonatomic, strong) NSMutableArray *piecesArray;
@property (nonatomic, strong) NSMutableArray *shuffledPiecesArray;
@property (nonatomic, strong) NSMutableArray *piecesPositionArray;

@property (nonatomic) NSInteger cubeHeightValue_;
@property (nonatomic) NSInteger cubeWidthValue_;
@property (nonatomic) NSInteger deepnessH_;
@property (nonatomic) NSInteger deepnessV_;
@property (nonatomic) CGFloat lastScale_;
@property (nonatomic) CGFloat lastRotation_;
@property (nonatomic) CGFloat firstX_;
@property (nonatomic) CGFloat firstY_;
@property (nonatomic) NSInteger touchedViewTag_;
@property (nonatomic) NSMutableArray *pieceTypeValueArray_;
@property (nonatomic) NSMutableArray *pieceRotationValuesArray_;
@property (nonatomic) NSMutableArray *pieceCoordinateRectArray_;
@property (nonatomic) NSMutableArray *pieceBezierPathsMutArray_;
@property (nonatomic) NSMutableArray *pieceBezierPathsWithoutHolesMutArray_;
@end

@implementation RPPuzzleView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (NSString *)nibName
{
    return nibNameKey;
}

- (void)dealloc
{
    self.pieceCoordinateRectArray_ = nil;
    self.pieceBezierPathsMutArray_ = nil;
    self.pieceRotationValuesArray_ = nil;
    self.pieceTypeValueArray_ = nil;
}

#pragma mark - Public methods

- (void)setWord:(NSString *)word image:(UIImage *)image
{
    self.word = word;
    self.image = image;
}

- (void)setHorizontalPieces:(NSInteger)horizPieces verticalPieces:(NSInteger)vertPieces
{
    self.peaceHCount_ = horizPieces;
    self.peaceVCount_ = vertPieces;
}

- (void)refresh
{
    
    NSAssert(self.image != nil, @"Image is not set");
    NSAssert(self.word != nil, @"Word is not set");
    
    NSAssert(self.peaceHCount_ != 0, @"Horizontal pieces set to 0");
    NSAssert(self.peaceVCount_ != 0, @"Vertical pieces set to 0");

    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[RPPuzzlePiece class]])
        {
            NSLog(@"%@", [v class]);
            [v removeFromSuperview];
        }
    }
    
    self.cubeHeightValue_ = self.image.size.height/self.peaceVCount_;
    self.cubeWidthValue_ = self.image.size.width/self.peaceHCount_;
    self.deepnessH_ = -(self.cubeHeightValue_ / 4);
    self.deepnessV_ = -(self.cubeWidthValue_ / 4);
    
    [self setUpPeaceCoordinatesTypesAndRotationValuesArrays];
    [self setUpPeaceBezierPaths];
    [self setUpPuzzlePeaceImages];
    
    [self shuffle];
    
    for (RPPuzzlePiece *piece in self.shuffledPiecesArray)
    {
        [self addSubview:piece];
    }
}

- (void)shuffle
{
    self.shuffledPiecesArray = [self.piecesArray mutableCopy];
    while ([self.piecesArray isEqualToArray:self.shuffledPiecesArray])
    {
        [self.shuffledPiecesArray shuffle];
    }
    
    //Updates shuffledPieces with the original frame position.
    for (int i = 0; i < [self.shuffledPiecesArray count]; i++)
    {
        RPPuzzlePiece *shuffledPiece = [self.shuffledPiecesArray objectAtIndex:i];
        CGRect newFrame = [[self.piecesPositionArray objectAtIndex:i] CGRectValue];
        [shuffledPiece setFrame:newFrame];
    }
}

#pragma mark -
#pragma mark autorotate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Private methods

- (void)setup
{
    self.piecesArray = [NSMutableArray new];
    self.shuffledPiecesArray = [NSMutableArray new];
    self.piecesPositionArray = [NSMutableArray new];
}

/**
 *  Enumerates a pieces array
 *
 *  @param array     pieces array
 *  @param mView     the view being dragged
 *  @param ascending if user is moving is finger to the left (NO) or to the right (YES)
 */
- (void)enumeratePiecesArray:(NSMutableArray *)array view:(UIView *)mView ascending:(BOOL)ascending
{
    NSInteger draggedViewIndex = [array indexOfObject:mView];
    CGFloat draggedViewX = mView.frame.origin.x;
    CGFloat draggedViewX2 = mView.frame.origin.x + mView.frame.size.width;

    if (ascending)
    {
        //If is the last piece of the puzzle
        if (draggedViewIndex == [array count] - 1)
            return;
        
        for (NSInteger pieceIndex = draggedViewIndex + 1; pieceIndex < [array count]; pieceIndex++)
        {
            UIView *v = (UIView *)[array objectAtIndex:pieceIndex];
            CGFloat x2 = v.frame.origin.x + v.frame.size.width;
            if (draggedViewX2 > x2)
            {
                [self updatePiece:v withFrameAtIndex:draggedViewIndex withDuration:puzzleAnimationDuration];
                [array exchangeObjectAtIndex:draggedViewIndex withObjectAtIndex:pieceIndex];
            }
        }
    } else {
        //If is the last piece of the puzzle
        if (draggedViewIndex == 0)
            return;
        
        for (NSInteger pieceIndex = draggedViewIndex - 1; pieceIndex >= 0; pieceIndex--)
        {
            UIView *v = (UIView *)[array objectAtIndex:pieceIndex];
            CGFloat x = [v frame].origin.x;
            if (draggedViewX < x)
            {
                [self updatePiece:v withFrameAtIndex:draggedViewIndex withDuration:puzzleAnimationDuration];
                [array exchangeObjectAtIndex:draggedViewIndex withObjectAtIndex:pieceIndex];
            }
        }
    }
}

- (void)updatePiece:(UIView *)pieceView withFrameAtIndex:(NSInteger)newFrameIndex
{
    [self updatePiece:pieceView withFrameAtIndex:newFrameIndex withDuration:0.0f];
}

- (void)updatePiece:(UIView *)pieceView withFrameAtIndex:(NSInteger)newFrameIndex withDuration:(NSTimeInterval)duration
{
    CGRect newFrame = [[self.piecesPositionArray objectAtIndex:newFrameIndex] CGRectValue];
    
    //restore the original transform
    [UIView animateWithDuration:duration
                          delay:0.00
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [pieceView setFrame:newFrame];
                     } completion:nil];
}

- (void)checkPiecesAreOk
{
    BOOL finished = [self.shuffledPiecesArray isEqualToArray:self.piecesArray];
    if (finished)
    {
        [self.delegate didFinishPuzzle];
    }
}

#pragma mark -
#pragma mark set up elements

- (void)setUpPeaceCoordinatesTypesAndRotationValuesArrays
{
    //--- rotations  (currently commented out so that at the beginning would be generated picture, where each peace is in its correct place)
    NSArray *mRotationTypeArray = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:M_PI/2],
                                   [NSNumber numberWithFloat:M_PI],
                                   [NSNumber numberWithFloat:M_PI + M_PI/2],
                                   [NSNumber numberWithFloat:M_PI*2],
                                   nil];
    //===
    
    
    //---
    self.pieceTypeValueArray_ = [NSMutableArray new]; //0: empty side /  1: outside  / -1: inside
    self.pieceCoordinateRectArray_ = [NSMutableArray new];
    self.pieceRotationValuesArray_ = [NSMutableArray new];
    int mSide1 = 0;
    int mSide2 = 0;
    int mSide3 = 0;
    int mSide4 = 0;
    int mCounter = 0;
    NSInteger mCubeWidth = 0;
    NSInteger mCubeHeight = 0;
    int mXPoint = 0;
    int mYPoint = 0;
    
    for(int i = 0; i < self.peaceVCount_; i++)
    {
        for(int j = 0; j < self.peaceHCount_; j++)
        {
            if(j != 0)
            {
                mSide1 = ([[[self.pieceTypeValueArray_ objectAtIndex:mCounter-1] objectAtIndex:2] intValue] == 1)?-1:1;
            }
            
            if(i != 0)
            {
                mSide4 = ([[[self.pieceTypeValueArray_ objectAtIndex:mCounter-self.peaceHCount_] objectAtIndex:1] intValue] == 1)?-1:1;
            }
            
            mSide2 = ((arc4random() % 2) == 1)?1:-1;
            mSide3 = ((arc4random() % 2) == 1)?1:-1;
            
            if(i == 0)
            {
                mSide4 = 0;
            }
            if(j == 0)
            {
                mSide1 = 0;
            }
            if(i == self.peaceVCount_-1)
            {
                mSide2 = 0;
            }
            if(j == self.peaceHCount_-1)
            {
                mSide3 = 0;
            }
            //--- calculate cube width and height
            mCubeWidth = self.cubeWidthValue_;
            mCubeHeight = self.cubeHeightValue_;
            if(mSide1 == 1)
            {
                mCubeWidth -= self.deepnessV_;
            }
            if(mSide3 == 1)
            {
                mCubeWidth -= self.deepnessV_;
            }
            if(mSide2 == 1)
            {
                mCubeHeight -= self.deepnessH_;
            }
            if(mSide4 == 1)
            {
                mCubeHeight -= self.deepnessH_;
            }
            //===
            
            //--- piece side types
            [self.pieceTypeValueArray_ addObject:[NSArray arrayWithObjects:
                                             [NSString stringWithFormat:@"%i", mSide1],
                                             [NSString stringWithFormat:@"%i", mSide2],
                                             [NSString stringWithFormat:@"%i", mSide3],
                                             [NSString stringWithFormat:@"%i", mSide4],
                                             nil]];
            //===
            
            //--- frames for cropping and imageviews
            mXPoint = MAX(mCubeWidth, MIN(arc4random() % MAX(1,(int)(self.frame.size.width - mCubeWidth*2)) + mCubeWidth, self.frame.size.width - mCubeWidth*2));
            
            mYPoint = MAX(mCubeHeight, MIN(arc4random() % MAX(1,(int)(self.frame.size.height - mCubeHeight*2)) + mCubeHeight, self.frame.size.height - mCubeHeight*2));
            
            [self.pieceCoordinateRectArray_ addObject:[NSArray arrayWithObjects:
                                                  [NSValue valueWithCGRect:CGRectMake(j*self.cubeWidthValue_,i*self.cubeHeightValue_,mCubeWidth,mCubeHeight)],
                                                  [NSValue valueWithCGRect:CGRectMake(j*self.cubeWidthValue_-(mSide1==1?-self.deepnessV_:0),i*self.cubeHeightValue_-(mSide4==1?-self.deepnessH_:0), mCubeWidth, mCubeHeight)], nil]];
            //[NSValue valueWithCGRect:CGRectMake(mXPoint, mYPoint, mCubeWidth, mCubeHeight)], nil]];
            //===
            
            // Rotation
            [self.pieceRotationValuesArray_ addObject:[NSNumber numberWithFloat:0]];//[mRotationTypeArray objectAtIndex:(arc4random() % 4)]];
            
            mCounter++;
        }
    }
}


- (void)setUpPeaceBezierPaths
{
    //---
    self.pieceBezierPathsMutArray_ = [NSMutableArray new];
    self.pieceBezierPathsWithoutHolesMutArray_ = [NSMutableArray new];
    //===
    
    float mYSideStartPos = 0;
    float mXSideStartPos = 0;
    float mCustomDeepness = 0;
    float mCurveHalfVLength = self.cubeWidthValue_ / 10;
    float mCurveHalfHLength = self.cubeHeightValue_ / 10;
    float mCurveStartXPos = self.cubeWidthValue_ / 2 - mCurveHalfVLength;
    float mCurveStartYPos = self.cubeHeightValue_ / 2 - mCurveHalfHLength;
    float mTotalHeight = 0;
    float mTotalWidth = 0;
    
    for(int i = 0; i < [self.pieceTypeValueArray_ count]; i++)
    {
        mXSideStartPos = ([[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:0] intValue] == 1)?-self.deepnessV_:0;
        mYSideStartPos = ([[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:3] intValue] == 1)?-self.deepnessH_:0;
        
        mTotalHeight = mYSideStartPos + mCurveStartYPos*2 + mCurveHalfHLength * 2;
        mTotalWidth = mXSideStartPos + mCurveStartXPos*2 + mCurveHalfVLength * 2;
        
        //--- bezierPath begins
        UIBezierPath* mPieceBezier = [UIBezierPath bezierPath];
        [mPieceBezier moveToPoint: CGPointMake(mXSideStartPos, mYSideStartPos)];
        //===
        
        //--- bezier for touches begins
        UIBezierPath* mTouchPieceBezier = [UIBezierPath bezierPath];
        [mTouchPieceBezier moveToPoint: CGPointMake(mXSideStartPos, mYSideStartPos)];
        //===
        
        //--- left side
        [mPieceBezier addLineToPoint: CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos)];
        if(![[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:0] isEqualToString:@"0"])
        {
            mCustomDeepness = self.deepnessV_ * [[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:0] intValue];
            
            [mPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos+mCurveHalfHLength) controlPoint1: CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos) controlPoint2: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength - mCurveStartYPos)];//25
            
            [mPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength*2) controlPoint1: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength + mCurveStartYPos) controlPoint2: CGPointMake(mXSideStartPos, mYSideStartPos+mCurveStartYPos + mCurveHalfHLength*2)]; //156
        }
        [mPieceBezier addLineToPoint: CGPointMake(mXSideStartPos, mTotalHeight)];
        [mTouchPieceBezier addLineToPoint: CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos)];
        
        if([[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:0] isEqualToString:@"1"])
        {
            mCustomDeepness = self.deepnessV_;
            
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos+mCurveHalfHLength) controlPoint1: CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos) controlPoint2: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength - mCurveStartYPos)];//25
            
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength*2) controlPoint1: CGPointMake(mXSideStartPos + mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength + mCurveStartYPos) controlPoint2: CGPointMake(mXSideStartPos, mYSideStartPos+mCurveStartYPos + mCurveHalfHLength*2)]; //156
        }
        
        [mTouchPieceBezier addLineToPoint: CGPointMake(mXSideStartPos, mTotalHeight)];
        //===
        
        //--- bottom
        [mPieceBezier addLineToPoint: CGPointMake(mXSideStartPos+ mCurveStartXPos, mTotalHeight)];
        
        if(![[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:1] isEqualToString:@"0"])
        {
            mCustomDeepness = self.deepnessH_ * [[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:1] intValue];
            
            [mPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength, mTotalHeight - mCustomDeepness) controlPoint1: CGPointMake(mXSideStartPos + mCurveStartXPos, mTotalHeight) controlPoint2: CGPointMake(mXSideStartPos + mCurveHalfVLength, mTotalHeight - mCustomDeepness)];
            
            [mPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength+mCurveHalfVLength, mTotalHeight) controlPoint1: CGPointMake(mTotalWidth - mCurveHalfVLength, mTotalHeight - mCustomDeepness) controlPoint2: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength + mCurveHalfVLength, mTotalHeight)];
        }
        
        [mPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mTotalHeight)];
        [mTouchPieceBezier addLineToPoint: CGPointMake(mXSideStartPos+ mCurveStartXPos, mTotalHeight)];
        
        if([[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:1] isEqualToString:@"1"])
        {
            mCustomDeepness = self.deepnessH_;
            
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength, mTotalHeight - mCustomDeepness) controlPoint1: CGPointMake(mXSideStartPos + mCurveStartXPos, mTotalHeight) controlPoint2: CGPointMake(mXSideStartPos + mCurveHalfVLength, mTotalHeight - mCustomDeepness)];
            
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength+mCurveHalfVLength, mTotalHeight) controlPoint1: CGPointMake(mTotalWidth - mCurveHalfVLength, mTotalHeight - mCustomDeepness) controlPoint2: CGPointMake(mXSideStartPos + mCurveStartXPos + mCurveHalfVLength + mCurveHalfVLength, mTotalHeight)];
        }
        
        [mTouchPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mTotalHeight)];
        //===
        
        //--- right
        [mPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mTotalHeight - mCurveStartYPos)];
        
        if(![[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:2] isEqualToString:@"0"])
        {
            mCustomDeepness = self.deepnessV_ * [[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:2] intValue];
            
            [mPieceBezier addCurveToPoint: CGPointMake(mTotalWidth - mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength) controlPoint1: CGPointMake(mTotalWidth, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength * 2) controlPoint2: CGPointMake(mTotalWidth - mCustomDeepness, mTotalHeight - mCurveHalfHLength)];
            
            [mPieceBezier addCurveToPoint: CGPointMake(mTotalWidth, mYSideStartPos + mCurveStartYPos) controlPoint1: CGPointMake(mTotalWidth - mCustomDeepness, mYSideStartPos + mCurveHalfHLength) controlPoint2: CGPointMake(mTotalWidth, mCurveStartYPos + mYSideStartPos)];
        }
        
        [mPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mYSideStartPos)];
        [mTouchPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mTotalHeight - mCurveStartYPos)];
        
        if([[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:2] isEqualToString:@"1"])
        {
            mCustomDeepness = self.deepnessV_;
            
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mTotalWidth - mCustomDeepness, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength) controlPoint1: CGPointMake(mTotalWidth, mYSideStartPos + mCurveStartYPos + mCurveHalfHLength * 2) controlPoint2: CGPointMake(mTotalWidth - mCustomDeepness, mTotalHeight - mCurveHalfHLength)];
            
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mTotalWidth, mYSideStartPos + mCurveStartYPos) controlPoint1: CGPointMake(mTotalWidth - mCustomDeepness, mYSideStartPos + mCurveHalfHLength) controlPoint2: CGPointMake(mTotalWidth, mCurveStartYPos + mYSideStartPos)];
        }
        
        [mTouchPieceBezier addLineToPoint: CGPointMake(mTotalWidth, mYSideStartPos)];
        //===
        
        //--- top
        [mPieceBezier addLineToPoint: CGPointMake(mTotalWidth - mCurveStartXPos, mYSideStartPos)];
        
        if(![[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:3] isEqualToString:@"0"])
        {
            mCustomDeepness = self.deepnessH_ * [[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:3] intValue];
            
            [mPieceBezier addCurveToPoint: CGPointMake(mTotalWidth - mCurveStartXPos - mCurveHalfVLength, mYSideStartPos + mCustomDeepness) controlPoint1: CGPointMake(mTotalWidth - mCurveStartXPos, mYSideStartPos) controlPoint2: CGPointMake(mTotalWidth - mCurveHalfVLength, mYSideStartPos + mCustomDeepness)];
            
            [mPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos, mYSideStartPos) controlPoint1: CGPointMake(mXSideStartPos + mCurveHalfVLength, mYSideStartPos + mCustomDeepness) controlPoint2: CGPointMake(mXSideStartPos + mCurveStartXPos, mYSideStartPos)];
        }
        
        [mPieceBezier addLineToPoint: CGPointMake(mXSideStartPos, mYSideStartPos)];
        [mTouchPieceBezier addLineToPoint: CGPointMake(mTotalWidth - mCurveStartXPos, mYSideStartPos)];
        
        if([[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:3] isEqualToString:@"1"])
        {
            mCustomDeepness = self.deepnessH_;
            
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mTotalWidth - mCurveStartXPos - mCurveHalfVLength, mYSideStartPos + mCustomDeepness) controlPoint1: CGPointMake(mTotalWidth - mCurveStartXPos, mYSideStartPos) controlPoint2: CGPointMake(mTotalWidth - mCurveHalfVLength, mYSideStartPos + mCustomDeepness)];
            
            [mTouchPieceBezier addCurveToPoint: CGPointMake(mXSideStartPos + mCurveStartXPos, mYSideStartPos) controlPoint1: CGPointMake(mXSideStartPos + mCurveHalfVLength, mYSideStartPos + mCustomDeepness) controlPoint2: CGPointMake(mXSideStartPos + mCurveStartXPos, mYSideStartPos)];
        }
        
        [mTouchPieceBezier addLineToPoint: CGPointMake(mXSideStartPos, mYSideStartPos)];
        //===
        
        //---
        [self.pieceBezierPathsMutArray_ addObject:mPieceBezier];
        [self.pieceBezierPathsWithoutHolesMutArray_ addObject:mTouchPieceBezier];
        //===
    }
}


- (void)setUpPuzzlePeaceImages
{
    float mXAddableVal = 0;
    float mYAddableVal = 0;
    for(int i = 0; i < [self.pieceBezierPathsMutArray_ count]; i++)
    {
        CGRect mCropFrame = [[[self.pieceCoordinateRectArray_ objectAtIndex:i] objectAtIndex:0] CGRectValue];
        CGRect mImageFrame = [[[self.pieceCoordinateRectArray_ objectAtIndex:i] objectAtIndex:1] CGRectValue];
        
        //--- puzzle peace image.
        RPPuzzlePiece *mPeace = [RPPuzzlePiece new];
        [mPeace.letterLabel setText:[NSString stringFromString:self.word characterAtIndex:i]];
        
//        UIImageView *mPeace = [UIImageView new];
        [mPeace setFrame:mImageFrame];
        [mPeace setTag:i+100];
        [mPeace setUserInteractionEnabled:YES];
        [mPeace setContentMode:UIViewContentModeTopLeft];
        //===
        
        //--- addable value
        mXAddableVal = ([[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:0] intValue] == 1)?self.deepnessV_:0;
        mYAddableVal = ([[[self.pieceTypeValueArray_ objectAtIndex:i] objectAtIndex:3] intValue] == 1)?self.deepnessH_:0;
        mCropFrame.origin.x += mXAddableVal;
        mCropFrame.origin.y += mYAddableVal;
        //===

        //--- crop and clip and add to self view
//        [mPeace setImage:[self cropImage:self.image
//                                withRect:mCropFrame]];
        [mPeace.pieceImageView setImage:[self cropImage:self.image
                                withRect:mCropFrame]];
        [self setClippingPath:[self.pieceBezierPathsMutArray_ objectAtIndex:i]:mPeace];
//        [self addSubview:mPeace];
        [mPeace setTransform:CGAffineTransformMakeRotation([[self.pieceRotationValuesArray_ objectAtIndex:i] floatValue])];
        [self.piecesArray addObject:mPeace];
        [self.piecesPositionArray addObject:[NSValue valueWithCGRect:mPeace.frame]];
        //===
        
        //--- border line
        CAShapeLayer *mBorderPathLayer = [CAShapeLayer layer];
        [mBorderPathLayer setPath:[[self.pieceBezierPathsMutArray_ objectAtIndex:i] CGPath]];
        [mBorderPathLayer setFillColor:[UIColor clearColor].CGColor];
        [mBorderPathLayer setStrokeColor:[UIColor blackColor].CGColor];
        [mBorderPathLayer setLineWidth:2];
        [mBorderPathLayer setFrame:CGRectZero];
        [[mPeace layer] addSublayer:mBorderPathLayer];
        //===
        
        //--- secret border line for touch recognition
        CAShapeLayer *mSecretBorder = [CAShapeLayer layer];
        [mSecretBorder setPath:[[self.pieceBezierPathsWithoutHolesMutArray_ objectAtIndex:i] CGPath]];
        [mSecretBorder setFillColor:[UIColor clearColor].CGColor];
        [mSecretBorder setStrokeColor:[UIColor blackColor].CGColor];
        [mSecretBorder setLineWidth:0];
        [mSecretBorder setFrame:CGRectZero];
        [[mPeace layer] addSublayer:mSecretBorder];
        //===
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:2];
        [panRecognizer setDelegate:self];
        [mPeace addGestureRecognizer:panRecognizer];
        //===
        
        //===
    }
}

#pragma mark -
#pragma mark help functions

//- (void) setClippingPath:(UIBezierPath *)clippingPath : (UIImageView *)imgView;
- (void) setClippingPath:(UIBezierPath *)clippingPath : (UIView *)imgView;
{
    if (![[imgView layer] mask])
    {
        [[imgView layer] setMask:[CAShapeLayer layer]];
    }
    [(CAShapeLayer*) [[imgView layer] mask] setPath:[clippingPath CGPath]];
}

- (UIImage *) cropImage:(UIImage*)originalImage withRect:(CGRect)rect
{
    return [UIImage imageWithCGImage:CGImageCreateWithImageInRect([originalImage CGImage], rect)];
}

#pragma mark -
#pragma mark gesture functions

- (void)move:(id)sender
{
    UIPanGestureRecognizer *gestureRecognizer = (UIPanGestureRecognizer *)sender;
    if(gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [sender velocityInView:self];
        
        CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
        if(self.touchedViewTag_ == 0 || self.touchedViewTag_ == 99)
        {
            return;
        }
        
        UIView *mView = (UIView *)[self viewWithTag:self.touchedViewTag_];
        translatedPoint = CGPointMake(self.firstX_+translatedPoint.x, self.firstY_+translatedPoint.y);
        [mView setCenter:translatedPoint];
        
        BOOL ascending = (velocity.x > 0 ? YES : NO);
        [self enumeratePiecesArray:self.shuffledPiecesArray view:mView ascending:ascending];
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateFailed || gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        UIView *mView = (UIView *)[self viewWithTag:self.touchedViewTag_];
        NSInteger index = [self.shuffledPiecesArray indexOfObject:mView];
        [self updatePiece:mView withFrameAtIndex:index withDuration:puzzleAnimationDuration];
        
        [self checkPiecesAreOk];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;//![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if(self.touchedViewTag_ == 0)
//    {
//        return;
//    }
//    
//    UIView *mView = (UIView *)[self viewWithTag:self.touchedViewTag_];
//    if(!mView || ![mView isKindOfClass:[UIView class]])
//    {
//        return;
//    }
//    
//    CGFloat mRotation = [[self.pieceRotationValuesArray_ objectAtIndex:mView.tag-100] floatValue];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.25];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    if(mRotation >= 0  && mRotation < M_PI/2)
//    {
//        [mView setTransform:CGAffineTransformMakeRotation(M_PI/2)];
//        mRotation = M_PI/2;
//    }
//    else if(mRotation >= M_PI/2 && mRotation < M_PI)
//    {
//        [mView setTransform:CGAffineTransformMakeRotation(M_PI)];
//        mRotation = M_PI;
//    }
//    else if(mRotation >= M_PI && mRotation < M_PI + M_PI/2)
//    {
//        [mView setTransform:CGAffineTransformMakeRotation(M_PI + M_PI/2)];
//        mRotation = M_PI + M_PI/2;
//    }
//    else
//    {
//        [mView setTransform:CGAffineTransformMakeRotation(M_PI*2)];
//        mRotation = 0;
//    }
//    
//    [UIView commitAnimations];
//    
//    [self.pieceRotationValuesArray_ replaceObjectAtIndex:mView.tag-100 withObject:[NSNumber numberWithFloat:mRotation]];
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchedViewTag_ = 0;
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    
    //--- get imageview
    UIView *mView = nil;
    self.touchedViewTag_ = 0;
    
    for(NSInteger i = [[self subviews] count]-1; i > -1 ; i--)
    {
        mView = (UIImageView *)[[self subviews] objectAtIndex:i];
        location = [touch locationInView:mView];
        if(CGPathContainsPoint([(CAShapeLayer*) [[[mView layer] sublayers] objectAtIndex:1] path], nil, location, NO))
        {
            self.touchedViewTag_ = mView.tag;
            [self bringSubviewToFront:mView];
            self.firstX_ = mView.center.x;
            self.firstY_ = mView.center.y;
            break;
        }
    }
}

@end
