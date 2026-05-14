#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

static BOOL mActive = NO;
static BOOL aActive = NO;
static UIView *mainMenu;
static UIButton *eagleIcon;

void patchAll(uint64_t offset, uint32_t hex) {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    uintptr_t addr = base + offset;
    if (addr > 0x100000000) {
        vm_protect(mach_task_self(), (vm_address_t)addr, 4, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        *(uint32_t *)addr = hex;
        vm_protect(mach_task_self(), (vm_address_t)addr, 4, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

@interface MustafaGodMode : NSObject
+ (void)pM; + (void)pA; + (void)tg;
@end

@implementation MustafaGodMode
+ (void)tg { mainMenu.hidden = !mainMenu.hidden; }
+ (void)pM {
    mActive = !mActive;
    uint64_t offs[] = {0x1A4F8C0, 0x1A4F8C4, 0x1A52B10, 0x1A52B14, 0x1A3A450, 0x1A3A454};
    for (int i=0; i<6; i++) patchAll(offs[i], mActive ? 0xD2800020 : 0xFF8300D1);
}
+ (void)pA {
    aActive = !aActive;
    uint64_t offs[] = {0x1B8A120, 0x1B8A124, 0x1B8A128, 0x1B89000, 0x1B8B000};
    for (int i=0; i<5; i++) patchAll(offs[i], aActive ? 0xD2807CE0 : 0xFF8300D1);
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win) win = [UIApplication sharedApplication].windows.firstObject;
        
        eagleIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eagleIcon.frame = CGRectMake(20, 200, 60, 60);
        [eagleIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eagleIcon.titleLabel.font = [UIFont systemFontOfSize:40];
        [eagleIcon addTarget:[MustafaGodMode class] action:@selector(tg) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:eagleIcon];

        mainMenu = [[UIView alloc] initWithFrame:CGRectMake(90, 200, 200, 160)];
        mainMenu.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
        mainMenu.layer.cornerRadius = 20; mainMenu.layer.borderWidth = 2;
        mainMenu.layer.borderColor = [UIColor yellowColor].CGColor;
        mainMenu.hidden = YES; [win addSubview:mainMenu];

        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200, 30)];
        t.text = @"MUSTAFA VIP 🦅"; t.textColor = [UIColor whiteColor];
        t.textAlignment = NSTextAlignmentCenter; [mainMenu addSubview:t];

        UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom];
        b1.frame = CGRectMake(20, 50, 160, 40); [b1 setTitle:@"Mining Boost" forState:UIControlStateNormal];
        b1.backgroundColor = [UIColor darkGrayColor]; b1.layer.cornerRadius = 10;
        [b1 addTarget:[MustafaGodMode class] action:@selector(pM) forControlEvents:UIControlEventTouchUpInside];
        [mainMenu addSubview:b1];

        UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom];
        b2.frame = CGRectMake(20, 100, 160, 40); [b2 setTitle:@"Infinite Ammo" forState:UIControlStateNormal];
        b2.backgroundColor = [UIColor darkGrayColor]; b2.layer.cornerRadius = 10;
        [b2 addTarget:[MustafaGodMode class] action:@selector(pA) forControlEvents:UIControlEventTouchUpInside];
        [mainMenu addSubview:b2];
    });
}
