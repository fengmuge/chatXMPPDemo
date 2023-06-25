//
//  UITabBarItem+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBarItem (custom)

+ (UITabBarItem *)makeItemWithTitle:(NSString * _Nullable)title
                          imageName:(NSString * _Nullable)imageName;

+ (UITabBarItem *)makeItemWithTitle:(NSString * _Nullable)title
                          imageName:(NSString * _Nullable)imageName
                        normalColor:(UIColor * _Nullable)nColor
                      selectedColor:(UIColor * _Nullable)sColor
                         normalFont:(CGFloat)nFont
                       selectedFont:(CGFloat)sFont;

+ (UITabBarItem *)setItem:(UITabBarItem * _Nullable)item
                    color:(UIColor * _Nullable)color
                     font:(CGFloat)font
                 forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
