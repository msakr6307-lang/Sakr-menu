#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

static BOOL mActive = NO;
static BOOL aActive = NO;
static UIView *mainMenu;
static UIButton *eagleIcon;

// دالة تعديل الذاكرة "الخارقة" لنسخة 1.0.3
void patchOneState(uint64_t offset, uint32_t hex) {
    // بنجيب عنوان ملف الـ Framework نفسه عشان نضمن الدقة
    const struct mach_header* header = _dyld_get_image_header(0);
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), "UnityFramework")) {
            header = _dyld_get_image_header(i);
            break;
        }
    }
    
    uintptr_t base = (uintptr_t)header;
    uintptr_t addr = base + offset;
    
    if (addr > 0x100) {
        vm_protect(mach_task_self(), (vm_address_t)addr, 4, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        *(uint32_t *)addr = hex;
        vm_protect(mach_task_self(), (vm_address_t)addr, 4, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
    }
}

@interface MustafaVip103 : NSObject
+ (void)mine; + (void)ammo; + (void)tg;
@end

@implementation MustafaVip103
+ (void)tg { mainMenu.hidden = !mainMenu.hidden; }

+ (void)mine {
    mActive = !mActive;
    // العناوين اللي طلعتها من نسخة 1.0.3
    patchOneState(0x1A4F8C0, mActive ? 0xD2800020 : 0xFF8300D1); // الجمع
    patchOneState(0x1A52B10, mActive ? 0xD2800000 : 0xFF8300D1); // الشنطة
    [UIView animateWithDuration:0.3 animations:^{
        mainMenu.layer.borderColor = mActive ? [UIColor greenColor].CGColor : [UIColor yellowColor].CGColor;
    }];
}

+ (void)ammo {
    aActive = !aActive;
    patchOneState(0x1B8A120, aActive ? 0xD2807CE0 : 0xFF8300D1); // الرصاص
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].windows.firstObject;

        eagleIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        eagleIcon.frame = CGRectMake(20, 150, 60, 60);
        [eagleIcon setTitle:@"🦅" forState:UIControlStateNormal];
        eagleIcon.titleLabel.font = [UIFont systemFontOfSize:40];
        [eagleIcon addTarget:[MustafaVip103 class] action:@selector(tg) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:eagleIcon];

        mainMenu = [[UIView alloc] initWithFrame:CGRectMake(80, 150, 200, 180)];
        mainMenu.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
        mainMenu.layer.cornerRadius = 20; mainMenu.layer.borderWidth = 3;
        mainMenu.layer.borderColor = [UIColor yellowColor].CGColor;
        mainMenu.hidden = YES; [win addSubview:mainMenu];

        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200, 30)];
        l.text = @"MUSTAFA 1.0.3 🦅"; l.textColor = [UIColor whiteColor];
        l.textAlignment = NSTextAlignmentCenter; [mainMenu addSubview:l];

        UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom];
        b1.frame = CGRectMake(20, 55, 160, 45); b1.backgroundColor = [UIColor darkGrayColor];
        [b1 setTitle:@"MINING ON" forState:UIControlStateNormal];
        b1.layer.cornerRadius = 10; [b1 addTarget:[MustafaVip103 class] action:@selector(mine) forControlEvents:UIControlEventTouchUpInside];
        [mainMenu addSubview:b1];

        UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom];
        b2.frame = CGRectMake(20, 115, 160, 45); b2.backgroundColor = [UIColor darkGrayColor];
        [b2 setTitle:@"AMMO ON" forState:UIControlStateNormal];
        b2.layer.cornerRadius = 10; [b2 addTarget:[MustafaVip103 class] action:@selector(ammo) forControlEvents:UIControlEventTouchUpInside];
        [mainMenu addSubview:b2];
    });
}
