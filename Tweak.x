#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

%ctor {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sakr Menu"
                                                    message:@"Tweak Loaded Successfully!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    NSLog(@"[SakrMenu] Loaded!");
}
