//
//  UITextView+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/14.
//

#import "UITextView+custom.h"
#import <objc/runtime.h>

@implementation UITextView (custom)

- (void)setMaxTextLength:(NSInteger)maxTextLength {
    objc_setAssociatedObject(self,
                             @selector(maxTextLength),
                             [NSNumber numberWithInteger:maxTextLength],
                             OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)maxTextLength {
    NSNumber *number = objc_getAssociatedObject(self, @selector(maxTextLength));
    if (!number) {
        return NSIntegerMax;
    }
    return [number integerValue];
}

// 示例代码，正常应该是添加通知或者写在控制器等
- (void)lxTextDidChanged {
    UITextRange *markedRange = [self markedTextRange];
    // 获取高亮部分，中文联想
    UITextPosition *position = [self positionFromPosition:markedRange.start offset:0];
    // 如果是高亮部分在变，就不要计算字符
    if (markedRange && position) {
        return;
    }
    // 实际总长度
    NSInteger realLength = [self.text length];
    
    UITextPosition *beginning = self.beginningOfDocument;
    UITextRange *selectedRange = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    // 获取光标位置
    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    // 获取光标后的文本
    NSString *tailText = [self.text substringFromIndex:location];
    // 光标前允许输入的最大值
    NSInteger restLength = self.maxTextLength - tailText.length;
    
    if (realLength > self.maxTextLength) {
        // 解决半个emoji表情定位到index位置时候，返回在此位置的完整字符的range
        NSRange range = [self.text rangeOfComposedCharacterSequenceAtIndex:restLength];
        NSString *subHeaderText = @"";
        // 防止字符串截取越界导致的闪退
        if (range.location > self.text.length || range.location < 0) {
            subHeaderText = [self.text substringToIndex:self.maxTextLength];
        } else {
            subHeaderText = [self.text substringToIndex:range.location];
        }
        self.text = subHeaderText;
        // 解决粘贴过多后，撤销粘贴崩溃问题，
        [self.undoManager removeAllActions];
    }
}

@end
