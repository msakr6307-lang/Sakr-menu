#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

static BOOL miningActive = NO;
static BOOL ammoActive = NO;

// دالة التعديل
void applyPatch(uint64_t offset, uint32_t hexCode) {
    uintptr_t baseAddress = (uintptr_t)_dyld_get_image_header(0) + offset;
    mprotect((void *)(baseAddress & ~PAGE_MASK), PAGE_SIZE, PROT_READ | PROT_WRITE | PROT_EXEC);
    *(uint32_t *)baseAddress = hexCode;
}

@interface MustafaMenu : NSObject
+ (void)toggleMining:(UIButton *)sender;
+ (void)toggleAmmo:(UIButton *)sender;
@end

@implementation MustafaMenu
// الزرار الأول: المنجم
+ (void)toggleMining:(UIButton *)sender {
    miningActive = !miningActive;
    if (miningActive) {
        applyPatch(0x1A4F8C0, 0xD2800020); // تجميع فوري
        applyPatch(0x1A52B10, 0xD2800000); // شنطة لا نهائية
        applyPatch(0x1A3A450, 0x52800C80); // مدى 100 متر
        [sender setTitle:@"MINING: ON ✅" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:0.9];
    } else {
        applyPatch(0x1A4F8C0, 0xFF8300D1); 
        applyPatch(0x1A52B10, 0xFF8300D1);
        applyPatch(0x1A3A450, 0xFF8300D1);
        [sender setTitle:@"MINING: OFF ❌" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.9];
    }
}

// الزرار الثاني: الرصاص
+ (void)toggleAmmo:(UIButton *)sender {
    ammoActive = !ammoActive;
    if (ammoActive) {
        applyPatch(0x1B8A120, 0xD2807CE0); // رصاص 999
        [sender setTitle:@"AMMO: ON ✅" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.6 alpha:0.9];
    } else {
        applyPatch(0x1B8A120, 0xFF8300D1);
        [sender setTitle:@"AMMO: OFF ❌" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.9];
    }
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) window = [UIApplication sharedApplication].windows.firstObject;

        if (window) {
            // حاوية للأزرار عشان يتحركوا مع بعض
            UIView *container = [[UIView alloc] initWithFrame:CGRectMake(20, 150, 160, 110)];
            container.backgroundColor = [UIColor clearColor];
            
            // زرار المنجم
            UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
            btn1.frame = CGRectMake(0, 0, 160, 45);
            btn1.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.9];
            [btn1 setTitle:@"MINING: OFF ❌" forState:UIControlStateNormal];
            btn1.layer.cornerRadius = 10;
            [btn1 addTarget:[MustafaMenu class] action:@selector(toggleMining:) forControlEvents:UIControlEventTouchUpInside];
            [container addSubview:btn1];
            
            // زرار الرصاص
            UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
            btn2.frame = CGRectMake(0, 55, 160, 45);
            btn2.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.9];
            [btn2 setTitle:@"AMMO: OFF ❌" forState:UIControlStateNormal];
            btn2.layer.cornerRadius = 10;
            [btn2 addTarget:[MustafaMenu class] action:@selector(toggleAmmo:) forControlEvents:UIControlEventTouchUpInside];
            [container addSubview:btn2];
            
            // ميزة سحب المنيو بالكامل
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:container action:@selector(handlePan:)];
            [container addGestureRecognizer:pan];
            
            [window addSubview:container];
        }
    });
}

@implementation UIView (Draggable)
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.superview];
}
@end
