#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

static BOOL mActive = NO;
static BOOL aActive = NO;
static UIView *mainMenu;
static UIButton *eagleIcon;

// دالة البحث عن بصمة الكود وتعديلها تلقائياً
void patchByBytes(uint64_t offset, uint32_t originalHex, uint32_t replaceHex) {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    uintptr_t addr = base + offset;
    
    // فحص بسيط: لو العنوان يحتوي على الكود الأصلي، عدله
    if (*(uint32_t *)addr == originalHex || originalHex == 0) {
        vm_protect(mach_task_self(), (vm_address_t)addr, 4, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        *(uint32_t *)addr = replaceHex;
        vm_protect(mach_task_self(), (vm_address_t)addr, 4, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

@interface MustafaVipX : NSObject
+ (void)tM; + (void)tA; + (void)show;
@end

@implementation MustafaVipX
+ (void)show { mainMenu.hidden = !mainMenu.hidden; }

+ (void)tM {
    mActive = !mActive;
    // تعديل المنجم (بنجرب العنوان الأصلي والبديل المباشر)
    patchByBytes(0x1A4F8C0, 0, mActive ? 0xD2800020 : 0xFF8300D1);
    patchByBytes(0x1A52B10, 0, mActive ? 0xD2800000 : 0xFF8300D1);
    [UIView animateWithDuration:0.3 animations:^{
        mainMenu.backgroundColor = mActive ? [UIColor colorWithRed:0 green:0.3 blue:0 alpha:0.9] : [UIColor blackColor];
    }];
}

+ (void)tA {
    aActive = !aActive;
    // تعديل الرصاص
    patchByBytes(0x1B8A120, 0, aActive ? 0xD2807CE0 : 0xFF8300D1);
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win) win = [UIApplication sharedApplication].windows.firstObject;

        // الصقر 🦅
        eagleIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eagleIcon.frame = CGRectMake(30, 150, 60, 60);
        [eagleIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eagleIcon.titleLabel.font = [UIFont systemFontOfSize:40];
        [eagleIcon addTarget:[MustafaVipX class] action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:eagleIcon];

        // المنيو
        mainMenu = [[UIView alloc] initWithFrame:CGRectMake(50, 150, 200, 170)];
        mainMenu.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
        mainMenu.layer.cornerRadius = 20; mainMenu.layer.borderWidth = 2;
        mainMenu.layer.borderColor = [UIColor yellowColor].CGColor;
        mainMenu.hidden = YES; [win addSubview:mainMenu];

        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200, 30)];
        t.text = @"MUSTAFA VIP 🦅"; t.textColor = [UIColor whiteColor];
        t.textAlignment = NSTextAlignmentCenter; [mainMenu addSubview:t];

        UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom];
        b1.frame = CGRectMake(20, 50, 160, 45); [b1 setTitle:@"MINE/BAG ON" forState:UIControlStateNormal];
        b1.backgroundColor = [UIColor darkGrayColor]; b1.layer.cornerRadius = 10;
        [b1 addTarget:[MustafaVipX class] action:@selector(tM) forControlEvents:UIControlEventTouchUpInside];
        [mainMenu addSubview:b1];

        UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom];
        b2.frame = CGRectMake(20, 105, 160, 45); [b2 setTitle:@"AMMO ON" forState:UIControlStateNormal];
        b2.backgroundColor = [UIColor darkGrayColor]; b2.layer.cornerRadius = 10;
        [b2 addTarget:[MustafaVipX class] action:@selector(tA) forControlEvents:UIControlEventTouchUpInside];
        [mainMenu addSubview:b2];
    });
}
