//
//  NewFriendListHeadCell.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/29.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NewFriendListHeadCell.h"


@implementation NewFriendListHeadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        LGSearchBar *searchBar = [LGSearchBar searchBar];
        searchBar.placeholder = @"昵称/手机号";
        [self.contentView addSubview:searchBar];
        self.searchBar = searchBar;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
