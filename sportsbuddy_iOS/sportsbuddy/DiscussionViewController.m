//
//  DiscussionViewController.m
//  sportsbuddy
//
//  Created by Wenting Shi on 7/24/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "DiscussionViewController.h"
#import "DiscussionDetailViewController.h"
#import <Parse/Parse.h>

@interface DiscussionViewController ()

@end

@implementation DiscussionViewController {
    PFObject *selectedPost;
    NSMutableArray *cachedImages;
    UIImage *selectedPostImage;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// launch modal view for creating new discussion post
- (IBAction)newPostButtonPressed:(UIBarButtonItem *)sender {
    // Present modal view
    [self performSegueWithIdentifier:@"newPost" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
    
}

// before tableview appears, retrieve most up-to-date content
- (void)viewWillAppear:(BOOL)animated {
    
    // retrieve discussion posts from back-end
    PFQuery *query = [PFQuery queryWithClassName:@"DiscussionPost"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@, %@", error ,[error userInfo]);
        } else {
            self.postsArray = objects;
            cachedImages = [[NSMutableArray alloc] initWithCapacity:[self.postsArray count]];
            // add placeholder object NUNull
            for (int i = 0; i < [self.postsArray count]; i++) {
                [cachedImages addObject:[NSNull null]];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.postsArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    cell.backgroundColor = [UIColor colorWithRed:205.0 / 255 green:0.0/255 blue:0.0/255 alpha:1];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TableCellID";
    DiscussionTableViewCell *tablecell = (DiscussionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    PFObject *post = [self.postsArray objectAtIndex:indexPath.row];
    UIImage *image = [cachedImages objectAtIndex:indexPath.row];
    
    // author
    tablecell.cellUsername.text = post[@"author"];
    
    // set default image when downloading
    [tablecell.cellImage setImage:[UIImage imageNamed:@"User.png"]];
    
    if (![image isEqual:[NSNull null]]) {
        tablecell.cellImage.image = cachedImages[indexPath.row];
    } else {
        // download the image asynchrnously
        NSString *authorID = post[@"authorID"];
        PFUser *author = [PFQuery getUserObjectWithId:authorID];
        PFFile *authorImageFile = author[@"avatar"];
        NSURL *imageUrl = [[NSURL alloc] initWithString:authorImageFile.url];
        
        // download the image asynchronously
        [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                // change the image in the cell
                tablecell.cellImage.image = image;
                // cache the image for use later (when scrolling up)
                cachedImages[indexPath.row] = image;
            }
        }];
    }
    
    // title
    tablecell.cellTitle.text = post[@"title"];
    UIFont *mainTitleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [tablecell.cellTitle setFont:mainTitleFont];
    [tablecell.cellTitle setTextColor:[UIColor whiteColor]];
    
    // content
    tablecell.cellContent.text = post[@"content"];
    UIFont *contentFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [tablecell.cellContent setFont:contentFont];
    [tablecell.cellContent setTextColor:[UIColor whiteColor]];

    // date
    NSDate *date = [post createdAt];
    // formattting
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd"];
    tablecell.cellDate.text = [formatter stringFromDate:date];
    
    return tablecell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedPost = [self.postsArray objectAtIndex:indexPath.row];
    selectedPostImage = [cachedImages objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showPostDetail" sender:self];
}

#pragma mark - Helper methods
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showPostDetail"]) {
        DiscussionDetailViewController *destinationVC = (DiscussionDetailViewController *)[segue destinationViewController];
        [destinationVC setPost:selectedPost];
        [destinationVC setUserImage:selectedPostImage];
    }
}


@end
