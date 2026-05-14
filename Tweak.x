#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// متغيرات التحكم
static BOOL autoFarm = NO;

// دالة تعديل الذاكرة (المحرك الأساسي)
void patchMemory(uint64_t offset, uint32_t instruction) {
    uint64_t address = (uint64_t)_dyld_get_image_header(0) + offset;
    mprotect((void *)(address & ~PAGE_MASK), PAGE_SIZE, PROT_READ | PROT_WRITE | PROT_EXEC);
    *(uint32_t *)address = instruction;
    mprotect((void *)(address & ~PAGE_MASK), PAGE_SIZE, PROT_READ | PROT_EXEC);
}

// الكود اللي هيظهر في المنيو
@interface MustafaFarm : NSObject
+ (void)toggleBot:(UIButton *)sender;
@end

@implementation MustafaFarm
+ (void)toggleBot:(UIButton *)sender {
    autoFarm = !autoFarm;
    [sender setTitle:(autoFarm ? @"BOT: ON ✅" : @"BOT: OFF ❌") forState:UIControlStateNormal];
    sender.backgroundColor = autoFarm ? [UIColor greenColor] : [UIColor redColor];
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win) win = [UIApplication sharedApplication].windows.firstObject;

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(50, 100, 150, 50);
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:@"BOT: OFF ❌" forState:UIControlStateNormal];
        btn.layer.cornerRadius = 10;
        
        [btn addTarget:[MustafaFarm class] action:@selector(toggleBot:) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:btn];
    });
}
