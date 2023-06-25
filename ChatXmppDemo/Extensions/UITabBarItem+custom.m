//
//  UITabBarItem+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "UITabBarItem+custom.h"

@implementation UITabBarItem (custom)

+ (UITabBarItem *)makeItemWithTitle:(NSString *)title imageName:(NSString *)imageName {
    if (!title && !imageName) {
        return nil;
    }
    UITabBarItem *item = [[UITabBarItem alloc] init];
    if (title) {
        item.title = title;
    }
    if (imageName) {
        UIImage *normalImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@_nor", imageName]];
        normalImg = [normalImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [item setImage: normalImg];
       
        UIImage *selectImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@_sel", imageName]];
        selectImg = [selectImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                        
        [item setImage: selectImg];
    }
    return item;
}

+ (UITabBarItem *)setItem:(UITabBarItem *)item color:(UIColor *)color font:(CGFloat)font forState:(UIControlState)state {
    if (!item) {
        return item;
    }
    NSMutableDictionary<NSAttributedStringKey,id> *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[UIFont systemFontOfSize:font] forKey:NSFontAttributeName];
    if (color) {
        [attributes setObject:color forKey:NSForegroundColorAttributeName];
    }
    
    [item setTitleTextAttributes:[attributes copy]
                        forState:state];
    return item;
}

+ (UITabBarItem *)makeItemWithTitle:(NSString *)title imageName:(NSString *)imageName normalColor:(UIColor *)nColor selectedColor:(UIColor *)sColor normalFont:(CGFloat)nFont selectedFont:(CGFloat)sFont {
    UITabBarItem *item = [UITabBarItem makeItemWithTitle:title
                                               imageName:imageName];

    [UITabBarItem setItem:item
                    color:nColor
                     font:nFont
                 forState:UIControlStateNormal];
    [UITabBarItem setItem:item
                    color:sColor
                     font:sFont
                 forState:UIControlStateSelected];
    return item;
}

@end
