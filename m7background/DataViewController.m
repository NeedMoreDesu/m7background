//
//  DataViewController.m
//  m7background
//
//  Created by dev on 1/20/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController ()
{
    int newCells;
}

@property UIRefreshControl *refreshControl;

@end

@implementation DataViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        newCells = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl
     addTarget:self
     action:@selector(refreshInvoked:forState:)
     forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
//    if(!self.array)
//        self.array = [[LazyParseArray alloc]
//                      initWithClassName:@"Motion"
//                      finishedCountingHandler:^{
//                          [self.tableView reloadData];
//                      }];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    // Refresh table here...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int oldCount = self.array.count;
        int newCount = [self.array updateAndReturnCounter];
        newCells = newCount - oldCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = @"Loading...";
    cell.detailTextLabel.text = @" ";
    NSInteger randId = arc4random();
    cell.tag = randId;
    NSUInteger idx = self.array.count - indexPath.row - 1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFObject *obj = [self.array objectAtIndex:idx];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cell.tag == randId)
            {
                cell.textLabel.text = obj[@"string"];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", obj.createdAt];
                if (indexPath.row < newCells) {
                    cell.backgroundColor = [UIColor colorWithRed:100 green:255 blue:0 alpha:1.0];
                }
            }
//            [self.tableView beginUpdates];
//            [self.tableView
//             reloadRowsAtIndexPaths:@[indexPath]
//             withRowAnimation:UITableViewRowAnimationNone];
//            [self.tableView endUpdates];
        });
    });
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
