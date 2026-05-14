#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// حالة الميزات
static BOOL miningActive = NO;
static BOOL ammoActive = NO;
static UIView *mainMenu;
static UIButton *eagleIcon;

// دالة تعديل الذاكرة الاحترافية (تمنع الكراش)
void patchSafe(uint64_t offset, uint32_t hex) {
    uintptr_t addr = (uintptr_t)_dyld_get_image_header(0) + offset;
    if (addr > 0x100000000) {
        vm_protect(mach_task_self(), (vm_address_t)addr, 4, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        *(uint32_t *)addr = hex;
        vm_protect(mach_task_self(), (vm_address_t)addr, 4, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

@interface MustafaVIPManager : NSObject
+ (void)toggleMining:(UIButton *)s;
+ (void)toggleAmmo:(UIButton *)s;
+ (void)showHideMenu;
+ (void)handleIconPan:(UIPanGestureRecognizer *)p;
@end

@implementation MustafaVIPManager

// إظهار وإخفاء القائمة
+ (void)showHideMenu {
    [UIView animateWithDuration:0.3 animations:^{
        mainMenu.hidden = !mainMenu.hidden;
        mainMenu.alpha = mainMenu.hidden ? 0.0 : 1.0;
    }];
}

// تحريك الأيقونة والمنيو يلحقها
+ (void)handleIconPan:(UIPanGestureRecognizer *)p {
    CGPoint translation = [p translationInView:eagleIcon.superview];
    CGPoint newCenter = CGPointMake(eagleIcon.center.x + translation.x, eagleIcon.center.y + translation.y);
    
    eagleIcon.center = newCenter;
    mainMenu.center = CGPointMake(newCenter.x + 130, newCenter.y + 65);
    
    [p setTranslation:CGPointZero inView:eagleIcon.superview];
}

// ميزة المنجم (تجميع + شنطة + مدى)
+ (void)toggleMining:(UIButton *)s {
    miningActive = !miningActive;
    if (miningActive) {
        patchSafe(0x1A4F8C0, 0xD2800020); // Instant Mine
        patchSafe(0x1A52B10, 0xD2800000); // Infinite Bag
        patchSafe(0x1A3A450, 0x52800C80); // 100m Range
        [s setTitle:@"Mining: ACTIVE ✅" forState:UIControlStateNormal];
        s.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:0.8];
    } else {
        patchSafe(0x1A4F8C0, 0xFF8300D1); // Return Original
        patchSafe(0x1A52B10, 0xFF8300D1);
        patchSafe(0x1A3A450, 0xFF8300D1);
        [s setTitle:@"Mining: OFF ❌" forState:UIControlStateNormal];
        s.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
    }
}

// ميزة الرصاص اللا نهائي
+ (void)toggleAmmo:(UIButton *)s {
    ammoActive = !ammoActive;
    if (ammoActive) {
        patchSafe(0x1B8A120, 0xD2807CE0); // 999 Ammo
        [s setTitle:@"Ammo: ACTIVE ✅" forState:UIControlStateNormal];
        s.backgroundColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.8 alpha:0.8];
    } else {
        patchSafe(0x1B8A120, 0xFF8300D1);
        [s setTitle:@"Ammo: OFF ❌" forState:UIControlStateNormal];
        s.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
    }
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        if (!win) win = [UIApplication sharedApplication].windows.firstObject;

        // 🦅 إنشاء أيقونة الصقر
        eagleIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eagleIcon.frame = CGRectMake(20, 200, 60, 60);
        [eagleIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eagleIcon.titleLabel.font = [UIFont systemFontOfSize:40];
        eagleIcon.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        eagleIcon.layer.cornerRadius = 30;
        [eagleIcon addTarget:[MustafaVIPManager class] action:@selector(showHideMenu) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[MustafaVIPManager class] action:@selector(handleIconPan:)];
        [eagleIcon addGestureRecognizer:pan];
        [win addSubview:eagleIcon];

        // 📋 إنشاء القائمة الرئيسية
        mainMenu = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 200, 180)];
        mainMenu.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.95];
        mainMenu.layer.cornerRadius = 15;
        mainMenu.layer.borderWidth = 2;
        mainMenu.layer.borderColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0].CGColor;
        mainMenu.hidden = YES;
        mainMenu.alpha = 0.0;
        [win addSubview:mainMenu];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200, 25)];
        title.text = @"Welcome, MUSTAFA 🦅";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:15];
        [mainMenu addSubview:title];

        UIButton *mBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        mBtn.frame = CGRectMake(20, 55, 160, 45);
        mBtn.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
        [mBtn setTitle:@"Mining: OFF ❌" forState:UIControlStateNormal];
        mBtn.layer.cornerRadius = 10;
        [mBtn addTarget:[MustafaVIPManager class] action:@selector(toggleMining:) forControlEvents:UIControlEventTouchUpInside];
        [mainMenu addSubview:mBtn];

        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        aBtn.frame = CGRectMake(20, 115, 160, 45);
        aBtn.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
        [aBtn setTitle:@"Ammo: OFF ❌" forState:UIControlStateNormal];
        aBtn.layer.cornerRadius = 10;
        [aBtn addTarget:[MustafaVIPManager class] action:@selector(toggleAmmo:) forControlEvents:UIControlEventTouchUpInside];
        [mainMenu addSubview:aBtn];
    });
}
