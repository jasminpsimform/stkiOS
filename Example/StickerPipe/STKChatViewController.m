//
//  STKChatViewController.m
//  StickerFactory
//
//  Created by Vadim Degterev on 03.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKChatViewController.h"
#import "STKChatStickerCell.h"
#import "STKChatTextCell.h"
#import "AppDelegate.h"

@import Stickerpipe;

@interface STKChatViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, STKStickerControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UITextView* inputTextView;
@property (nonatomic, weak) IBOutlet UIView* textInputPanel;
@property (nonatomic, weak) IBOutlet UIButton* sendButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* textViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* bottomViewConstraint;
@property (nonatomic, weak) IBOutlet UIView* errorView;
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;

@property (nonatomic) NSMutableArray* dataSource;
@property (nonatomic) STKStickerController* stickerController;

@property (nonatomic, copy) NSString* packName;
@property (nonatomic, copy) NSString* packPrice;

- (IBAction)sendClicked: (id)sender;

@end

@implementation STKChatViewController

static NSString* const kChatCellId = @"Cell";
static NSString* const kTextCellId = @"textCell";

- (void)viewDidLoad {
	[super viewDidLoad];

	self.dataSource = [[@[@"[[1774]]", @"[[1778]]", @"[[1609]]", @"[[1624]]", @"[[1776]]", @"[[sonya45_1844]]"] mutableCopy] mutableCopy];
	self.inputTextView.layer.cornerRadius = 7.0;
	self.inputTextView.layer.borderWidth = 1.0;
	self.inputTextView.layer.borderColor = [UIColor colorWithRed: 0.84 green: 0.84 blue: 0.85 alpha: 1].CGColor;

	self.textInputPanel.layer.borderWidth = 1.0;
	self.textInputPanel.layer.borderColor = [UIColor colorWithRed: 0.82 green: 0.82 blue: 0.82 alpha: 1].CGColor;

	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(willHideKeyboard:)
												 name: UIKeyboardWillHideNotification
											   object: nil];

	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(didShowKeyboard:)
												 name: UIKeyboardWillShowNotification
											   object: nil];

	//tap gesture

	UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(textViewDidTap:)];
	[self.inputTextView addGestureRecognizer: tapGesture];

	[self scrollTableViewToBottom];

	self.stickerController = [STKStickerController new];
	self.stickerController.delegate = self;
	self.stickerController.textInputView = self.inputTextView;
	self.stickerController.suggestCollectionView = self.collectionView;

	self.tableView.rowHeight = UITableViewAutomaticDimension;

	[(AppDelegate*) [[UIApplication sharedApplication] delegate] checkForNotifications];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - UI Methods

- (void)scrollTableViewToBottom {
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow: self.dataSource.count - 1 inSection: 0];
	[self.tableView scrollToRowAtIndexPath: indexPath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
}


#pragma mark - Notifications

- (void)didShowKeyboard: (NSNotification*)notification {
	CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

	UIViewAnimationCurve curve = (UIViewAnimationCurve) [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
	CGFloat keyboardHeight = keyboardBounds.size.height;

	CGFloat animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

	self.bottomViewConstraint.constant = keyboardHeight;

	[UIView animateWithDuration: animationDuration animations: ^ {
		[UIView setAnimationCurve: curve];
		[self.view layoutIfNeeded];
	}];

	[self scrollTableViewToBottom];
}

- (void)willHideKeyboard: (NSNotification*)notification {

	CGFloat animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

	self.bottomViewConstraint.constant = 0;

	[UIView animateWithDuration: animationDuration animations: ^ {
		[self.view layoutIfNeeded];
	}];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView: (UITableView*)tableView numberOfRowsInSection: (NSInteger)section {
	return self.dataSource.count;
}

- (UITableViewCell*)tableView: (UITableView*)tableView cellForRowAtIndexPath: (NSIndexPath*)indexPath {
	NSString* message = self.dataSource[(NSUInteger) indexPath.row];

	if ([STKStickersManager isStickerMessage: message]) {
		STKChatStickerCell* cell = [self.tableView dequeueReusableCellWithIdentifier: kChatCellId];

		[cell fillWithStickerMessage: message downloaded: [self.stickerController isStickerPackDownloaded: message]];

		return cell;
	} else {
		STKChatTextCell* cell = [self.tableView dequeueReusableCellWithIdentifier: kTextCellId];

		[cell fillWithTextMessage: message];
		return cell;
	}
}


#pragma mark - UITableViewDelegate

- (void)tableView: (UITableView*)tableView didSelectRowAtIndexPath: (NSIndexPath*)indexPath {
	if ([[tableView cellForRowAtIndexPath: indexPath] isKindOfClass: [STKChatStickerCell class]]) {
		[self.stickerController showPackInfoControllerWithStickerMessage: self.dataSource[(NSUInteger) indexPath.row]];
	}
}

- (CGFloat)tableView: (UITableView*)tableView estimatedHeightForRowAtIndexPath: (NSIndexPath*)indexPath {
	return ([STKStickersManager isStickerMessage: self.dataSource[(NSUInteger) indexPath.row]]) ? 160 : 40;
}


#pragma mark - STKStickerControllerDelegate

- (void)didUpdateStickerCache {

}

- (void)stickerController: (STKStickerController*)stickerController didSelectStickerWithMessage: (NSString*)message {
	STKChatStickerCell* cell = [self.tableView dequeueReusableCellWithIdentifier: kChatCellId];
	[cell fillWithStickerMessage: message downloaded: [self.stickerController isStickerPackDownloaded: message]];

	[self addMessage: message];

	[self.stickerController stickerMessageSendStatistic];
}

- (UIViewController*)stickerControllerViewControllerForPresentingModalView {
	return self;
}

- (void)stickerControllerErrorHandle: (NSError*)error {
	self.errorView.hidden = NO;
}

- (void)addMessage: (NSString*)message {
	[self.tableView beginUpdates];
	[self.dataSource addObject: message];
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow: self.dataSource.count - 1 inSection: 0];
	[self.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationBottom];
	[self.tableView endUpdates];
	[self scrollTableViewToBottom];
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange: (UITextView*)textView {
	self.sendButton.enabled = textView.text.length > 0;
	self.textViewHeightConstraint.constant = textView.contentSize.height;

	[textView layoutSubviews];
}


#pragma mark - Gesture

- (void)textViewDidTap: (UITapGestureRecognizer*)gestureRecognizer {
	[self.inputTextView becomeFirstResponder];
}


#pragma mark - Actions

- (void)sendClicked: (id)sender {
	NSString* message = self.inputTextView.text;
	if (message.length > 0) {
		[self addMessage: message];
		[self.stickerController textMessageSendStatistic];
		self.inputTextView.text = @"";
		self.textViewHeightConstraint.constant = 33;
	}
}


#pragma mark - PurchasePack

- (void)packPurchasedWithName: (NSString*)packName price: (NSString*)packPrice {
	self.packName = packName;
	self.packPrice = packPrice;

	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"" message: @"Purchase this stickers pack?" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"OK", nil];
	alertView.delegate = self;
	dispatch_async(dispatch_get_main_queue(), ^ {
		[alertView show];
	});
}


#pragma mark - Alert controller delegate

- (void)alertView: (UIAlertView*)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[[STKStickersPurchaseService sharedInstance] purchaseFailedError: nil];
			break;
		case 1:
            [[STKStickersPurchaseService sharedInstance] purchasInternalPackName:self.packName andPackPrice:self.packPrice];
		default:
			break;
	}
}

@end
