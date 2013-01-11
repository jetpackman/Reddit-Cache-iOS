//
//  MasterViewController.h
//  secondreddit
//
//  Created by Aaron Lee on 2013-01-11.
//  Copyright (c) 2013 Aaron Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
