//
//  STKPacksDescriptionController.m
//  StickerPipe
//
//  Created by Vadim Degterev on 29.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKPackDescriptionController.h"
#import "STKStickersEntityService.h"
#import "STKStickerViewCell.h"
#import "STKPackDescriptionHeader.h"
#import "STKStickerPackObject.h"
#import "STKStickerObject.h"
#import <DFImageManagerKit.h>
#import <StoreKit/StoreKit.h>
#import "STKUtility.h"
#import "UIImage+Tint.h"
#import "STKPurchaseService.h"
#import "STKOrientationNavigationController.h"

@interface STKPackDescriptionController()<UICollectionViewDataSource, UICollectionViewDelegate, STKPackDescriptionHeaderDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) STKStickersEntityService *service;
@property (strong, nonatomic) STKStickerPackObject *stickerPack;
@property (nonatomic, strong) STKPurchaseService *purchaseEntity;
@property (nonatomic, strong) SKProduct *product;
@property (nonatomic, assign) BOOL needDisableDownloadButton;
@property (nonatomic, weak) UIImageView *bannerImageView;
@property (nonatomic, assign) CGRect cachedBannerImageViewFrame;

@end

@implementation STKPackDescriptionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[STKStickerViewCell class] forCellWithReuseIdentifier:@"STKStickerViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"STKPackDescriptionHeader" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"STKPackDescriptionHeader"];
    self.service = [STKStickersEntityService new];

    self.purchaseEntity = [STKPurchaseService new];

    self.collectionView.hidden = YES;
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidesWhenStopped = YES;
    [self reloadStickerPack];
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void) reloadStickerPack {
    
    __weak typeof(self) weakSelf = self;

    [self.service getPackWithMessage:self.stickerMessage completion:^(STKStickerPackObject *stickerPack, BOOL isDownloaded) {
        if (stickerPack) {
            if (self.stickerPack.productID) {
                [self.purchaseEntity requestProductsWithIdentifiers:[NSSet setWithObject:self.stickerPack.productID] completion:^(NSArray *products, NSArray *invalidProductsIdentifier) {
                    weakSelf.product = products.firstObject;
                    if (weakSelf.stickerPack) {
                        [weakSelf.collectionView reloadData];
                    }
                }];
            }
            weakSelf.stickerPack = stickerPack;
            weakSelf.collectionView.hidden = NO;
            [weakSelf.activityIndicator stopAnimating];
            [weakSelf.collectionView reloadData];
        }

    }];
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate {
    return YES;
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.cachedBannerImageViewFrame = self.bannerImageView.frame;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.stickerPack.stickers.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STKStickerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STKStickerViewCell" forIndexPath:indexPath];
    STKStickerObject *sticker = self.stickerPack.stickers[indexPath.item];
    [cell configureWithStickerMessage:sticker.stickerMessage placeholder:nil placeholderColor:nil];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        STKPackDescriptionHeader *stickerHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"STKPackDescriptionHeader" forIndexPath:indexPath];
        
        stickerHeader.artistLabel.text = self.stickerPack.artist;
        stickerHeader.packNameLabel.text = self.stickerPack.packTitle;
        [stickerHeader.packNameLabel setPreferredMaxLayoutWidth:collectionView.frame.size.width / 2.0];
        self.bannerImageView = stickerHeader.bannerImageView;
        self.cachedBannerImageViewFrame = stickerHeader.bannerImageView.frame;
        
        //TODO:Refactoring
        if (self.stickerPack.price.integerValue == 0 && self.product) {
            [stickerHeader.priceLoadingIndicator stopAnimating];
            stickerHeader.priceLabel.text = [NSString stringWithFormat:@"%@$", self.product.price];
        } else {
            if (self.stickerPack.productID) {
                [stickerHeader.priceLoadingIndicator startAnimating];

            }
            stickerHeader.priceLabel.text = nil;
        }
        [stickerHeader.statusButton setTitleColor:[UIColor colorWithRed:1 green:0.34 blue:0.13 alpha:1] forState:UIControlStateNormal];
        [stickerHeader.statusButton setTitleColor:[UIColor colorWithRed:1 green:0.34 blue:0.13 alpha:1] forState:UIControlStateHighlighted];
        if (self.stickerPack.disabled.boolValue) {
            [stickerHeader.statusButton setTitle:@"Download" forState:UIControlStateNormal];
            [stickerHeader.statusButton setTitle:@"Download" forState:UIControlStateHighlighted];

        } else {
            [stickerHeader.statusButton setTitle:@"Remove" forState:UIControlStateNormal];
            [stickerHeader.statusButton setTitle:@"Remove" forState:UIControlStateHighlighted];
        }
        stickerHeader.statusButton.enabled = !self.needDisableDownloadButton;
        
        stickerHeader.delegate = self;
        
        stickerHeader.descriptionLabel.text = self.stickerPack.packDescription;
        [stickerHeader.descriptionLabel invalidateIntrinsicContentSize];
        [stickerHeader.descriptionLabel setPreferredMaxLayoutWidth:collectionView.frame.size.width];
        if (self.stickerPack.bannerUrl) {
            __weak typeof(self) weakSelf = self;
            [stickerHeader removeConstraint:stickerHeader.topConstraint];
            DFImageRequest *request = [DFImageRequest requestWithResource:[NSURL URLWithString:self.stickerPack.bannerUrl]
                                                               targetSize:CGSizeZero
                                                              contentMode:DFImageContentModeAspectFill
                                                                  options:nil];
            DFImageTask *task = [[DFImageManager sharedManager] imageTaskForRequest:request completion:^(UIImage *image, NSDictionary *info) {
                if (image) {
                    stickerHeader.bannerImageView.image = image;
                    weakSelf.bannerImageView.image = image;
                    [stickerHeader setNeedsLayout];
                    [stickerHeader layoutIfNeeded];
                    [stickerHeader setNeedsUpdateConstraints];
                    weakSelf.cachedBannerImageViewFrame = weakSelf.bannerImageView.frame;
                }
            }];
            [task resume];

        } else if (self.stickerPack) {
            [stickerHeader.bannerImageView removeFromSuperview];
            [stickerHeader setNeedsLayout];
            [stickerHeader layoutIfNeeded];
        }
        
        UIImage *defaultPlaceholder = [UIImage imageNamed:@"STKStickerPlaceholder"];
        defaultPlaceholder = [defaultPlaceholder imageWithImageTintColor:[STKUtility defaultPlaceholderGrayColor]];
        stickerHeader.packImageView.image = defaultPlaceholder;
        [stickerHeader.packImageView df_setImageWithResource:[STKUtility mainImageUrlForPackName:self.stickerPack.packName]];
        [stickerHeader setNeedsLayout];
        [stickerHeader layoutIfNeeded];
        [stickerHeader setNeedsUpdateConstraints];
        
        return stickerHeader;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    STKPackDescriptionHeader *stickerHeader = [[NSBundle mainBundle] loadNibNamed:@"STKPackDescriptionHeader" owner:self options:nil].firstObject;
    stickerHeader.artistLabel.text = self.stickerPack.artist;
    stickerHeader.packNameLabel.text = self.stickerPack.packTitle;
    //TODO:Refactoring
    [stickerHeader.packNameLabel setPreferredMaxLayoutWidth:collectionView.frame.size.width / 2.0];
    stickerHeader.descriptionLabel.text = self.stickerPack.packDescription;
    [stickerHeader.descriptionLabel setPreferredMaxLayoutWidth:collectionView.frame.size.width];
    
    UIImage *defaultPlaceholder = [UIImage imageNamed:@"STKStickerPlaceholder"];
    defaultPlaceholder = [defaultPlaceholder imageWithImageTintColor:[STKUtility defaultPlaceholderGrayColor]];
    stickerHeader.packImageView.image = defaultPlaceholder;
    [stickerHeader.packImageView df_setImageWithResource:[STKUtility mainImageUrlForPackName:self.stickerPack.packName]];
    if (self.stickerPack.bannerUrl) {
        [stickerHeader removeConstraint:stickerHeader.topConstraint];
    } else {
        [stickerHeader.bannerImageView removeFromSuperview];
        [stickerHeader setNeedsLayout];
        [stickerHeader layoutIfNeeded];
    }
    
    stickerHeader.bounds = CGRectMake(0, 0, collectionView.frame.size.width, 0);
    
    [stickerHeader setNeedsLayout];
    [stickerHeader layoutIfNeeded];
    [stickerHeader setNeedsUpdateConstraints];
    
    CGSize size = [stickerHeader systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return CGSizeMake(collectionView.frame.size.width, size.height);
    
}

#pragma mark - Actions

- (IBAction)closeAction:(UIButton*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < 0) {
        CGFloat y = -scrollView.contentOffset.y;
        self.bannerImageView.frame = CGRectMake(0, scrollView.contentOffset.y, self.cachedBannerImageViewFrame.size.width+y, self.cachedBannerImageViewFrame.size.height+y);
        self.bannerImageView.center = CGPointMake(self.view.center.x, self.bannerImageView.center.y);
    } else {
        if (!CGRectEqualToRect(self.bannerImageView.frame, self.cachedBannerImageViewFrame)) {
            self.bannerImageView.frame = self.cachedBannerImageViewFrame;
        }
    }
    
}

#pragma mark - STKPackDescriptionHeaderDelegate

- (void)packDescriptionHeader:(STKPackDescriptionHeader *)header didTapDownloadButton:(UIButton*)button {
    //TODO:FIX ME
    if (self.stickerPack.productID && self.stickerPack.disabled.boolValue == YES && ![self.purchaseEntity isPurchasedProductWithIdentifier:self.stickerPack.productID]) {

        self.needDisableDownloadButton = YES;
        [self.collectionView reloadData];

        __weak typeof(self) wself = self;

        [self.purchaseEntity purchaseProductWithIdentifier:self.stickerPack.productID completion:^(SKPaymentTransaction *transaction) {
            //TODO: Buy product on server side
            [wself.service togglePackDisabling:self.stickerPack];
            wself.needDisableDownloadButton = NO;
            [wself reloadStickerPack];
        } failure:^(NSError *error) {
            wself.needDisableDownloadButton = NO;
            [wself.collectionView reloadData];
        }];
    } else {
        [self.service togglePackDisabling:self.stickerPack];
        [self reloadStickerPack];
        if ([self.delegate respondsToSelector:@selector(packDescriptionControllerDidChangePakcStatus:)]) {
            [self.delegate packDescriptionControllerDidChangePakcStatus:self];
        }
    }

}

@end
