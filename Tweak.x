#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

__attribute__((constructor))
static void init() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sakr Menu"
                                                                       message:@"Tweak Loaded Successfully!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        [root presentViewController:alert animated:YES completion:nil];
        
        NSLog(@"[SakrMenu] Loaded!");
    });
}
