//
//  RPPuzzlePiece.h
//  Jogo das Palavras
//
//  Created by Ricardo Paiva on 20/12/14.
//
//

#import <UIKit/UIKit.h>
#import "RPBaseCustomView.h"

@protocol RPPuzzlePieceDataSource <NSObject>
//-(BOOL)showLevelLockerInViewWithTag:(NSUInteger)tag;
@end

@protocol RPPuzzlePieceDelegate <NSObject>
//-(void)didPressButtonWithTag:(NSUInteger)tag;
@end

IB_DESIGNABLE
@interface RPPuzzlePiece : RPBaseCustomView

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *letterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pieceImageView;

@property (strong, nonatomic) IBOutlet id<RPPuzzlePieceDelegate> delegate;
@property (strong, nonatomic) IBOutlet id<RPPuzzlePieceDataSource> dataSource;

- (void)refresh;

@end
