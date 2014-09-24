//
//  DiscussionDetailViewController.m
//  sportsbuddy
//
//  Created by Wenting Shi on 7/26/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "DiscussionDetailViewController.h"
#import "ReplyTableViewCell.h"
#import "AddReplyViewController.h"
#import <Parse/Parse.h>

@interface DiscussionDetailViewController ()

@property (nonatomic, strong) NSArray *sourceData;
@property (strong, nonatomic) ReplyTableViewCell *prototypeCell;

@end

@implementation DiscussionDetailViewController

- (NSArray *)sourceData
{
    if (!_sourceData)
    {
        _sourceData = [NSArray arrayWithObjects:@"This is a very long reply! This is a very long reply! This is a very long reply! This is a very long reply! This is a very long reply! This is a very long reply!", @"This is a short reply" ,nil];
    }
    return _sourceData;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    
    // populate replyMsgs array
    self.replyMsgs = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"DiscussionReply"];
    [query whereKey:@"postID" equalTo:[self.post objectId]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@, %@", error ,[error userInfo]);
        } else {
            self.replyMsgs = [NSMutableArray arrayWithArray: objects];
            [self.tableView reloadData];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // set post info
    self.postTitle.text = self.post[@"title"];
    [self.postTitle setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [self.postTitle setTextColor:[UIColor whiteColor]];
    self.postContent.text = self.post[@"content"];
    [self.postContent setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [self.postContent setTextColor:[UIColor whiteColor]];
    self.authorName.text = self.post[@"author"];
    [self.authorName setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    [self.authorImage setImage:self.userImage];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonAddReplyPressed:(UIButton *)sender {
    // Present modal view
    [self performSegueWithIdentifier:@"addReply" sender:self];
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.replyMsgs count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

// calculate height for each row using prototype cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
    [self.prototypeCell layoutIfNeeded];
    
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+15;
}

- (ReplyTableViewCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"ReplyCell"];
    }
    return _prototypeCell;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReplyCell" forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
    
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ReplyTableViewCell class]]) {
        ReplyTableViewCell *tablecell = (ReplyTableViewCell *)cell;
        
        // configure cell
        
        PFObject *reply = [self.replyMsgs objectAtIndex:indexPath.row];
        
        // reply
        tablecell.replyMsg.text = [reply objectForKey:@"replyMessage"];
        UIFont *contentFont = [UIFont systemFontOfSize:15.0];
        [tablecell.replyMsg setFont:contentFont];
        [tablecell.replyMsg setTextColor:[UIColor whiteColor]];
        
        // username
        tablecell.userName.text = [reply objectForKey:@"userName"];
        
        // date (with formatting)
        NSDate *date = [reply createdAt];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd"];
        tablecell.replyDate.text = [formatter stringFromDate:date];
        
        // user thumbnail
        NSString *authorID = reply[@"userID"];
        PFUser *author = [PFQuery getUserObjectWithId:authorID];
        PFFile *authorImageFile = author[@"avatar"];
        NSURL *imageUrl = [[NSURL alloc] initWithString:authorImageFile.url];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        [tablecell.userImage setImage:[UIImage imageWithData:imageData]];
        
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addReply"]) {
        AddReplyViewController *destinationVC = (AddReplyViewController *) [[segue.destinationViewController viewControllers] objectAtIndex:0] ;
        destinationVC.postID = [self.post objectId];
    }
}


@end
