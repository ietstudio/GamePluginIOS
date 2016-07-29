//
//  IETViewController.m
//  GamePluginIOS
//
//  Created by gaoyang on 06/11/2016.
//  Copyright (c) 2016 gaoyang. All rights reserved.
//

#import "IETViewController.h"
#import "IOSGamePlugin.h"
#import "IOSAnalyticHelper.h"
#import "IOSSystemUtil.h"
#import "NSString+MD5.h"

@interface IETViewController () <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) NSArray *dataList;

@end

@implementation IETViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initDataList];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame
                                                  style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initDataList {
    NSMutableArray* dataList = [NSMutableArray array];
#pragma mark common
    [dataList addObject:@{@"name":@"---------GamePlugin---------", @"func":^(){}}];
    [dataList addObject:@{@"name":@"setGenVerifyUrlCallFunc", @"func":^(){
        [[IOSGamePlugin getInstance] setGenVerifyUrlHandler:^NSString *(NSDictionary *dict) {
            NSString* userId    = [dict objectForKey:@"userId"];
            NSString* productId = [dict objectForKey:@"productId"];
            NSString* receipt   = [dict objectForKey:@"receipt"];
            NSString* sign      = [[NSString stringWithFormat:@"iet_studio%@%@%@", userId, productId, receipt] MD5Digest];
            NSString* url       = [NSString stringWithFormat:@"http://192.168.1.180:7999/mayaslots/iap_verify?user_id=%@&product_id=%@&receipt=%@&sign=%@", userId, productId, receipt, sign];
            return url;
        }];
    }}];
    [dataList addObject:@{@"name":@"setRestoreCallback", @"func":^(){
        [[IOSGamePlugin getInstance] setRestoreHandler:^(BOOL result, NSString *msg, NSArray* iapIds) {
            if (result) {
                [[IOSSystemUtil getInstance] showAlertDialogWithTitle:msg
                                                              message:[NSString stringWithFormat:@"%@", iapIds]
                                                       cancelBtnTitle:@"ok"
                                                       otherBtnTitles:nil
                                                             callback:nil];
            }
        }];
    }}];
    [dataList addObject:@{@"name":@"doIap", @"func":^(){
        [[IOSGamePlugin getInstance] doIap:@"mayaslot.coin2"
                                    userId:@"guest"
                                   handler:^(BOOL result, NSString *msg, NSArray* iapIds) {
                                       if (result) {
                                           [[IOSSystemUtil getInstance] showAlertDialogWithTitle:msg
                                                                                         message:[NSString stringWithFormat:@"%@", iapIds]
                                                                                  cancelBtnTitle:@"ok"
                                                                                  otherBtnTitles:nil
                                                                                        callback:nil];
                                       }
                                   }];
    }}];
    [dataList addObject:@{@"name":@"rate level=1", @"func":^(){
        [[IOSGamePlugin getInstance] rate:1];
    }}];
    [dataList addObject:@{@"name":@"rate level=2", @"func":^(){
        [[IOSGamePlugin getInstance] rate:2];
    }}];
    [dataList addObject:@{@"name":@"rate level=3", @"func":^(){
        [[IOSGamePlugin getInstance] rate:3];
    }}];
    [dataList addObject:@{@"name":@"gcIsAvailable", @"func":^(){
        NSLog(@"%@", NSStringFromBool([[IOSGamePlugin getInstance] gcIsAvailable]));
    }}];
    __block NSString *_playerId = nil;
    [dataList addObject:@{@"name":@"gcGetPlayerInfo", @"func":^(){
        NSDictionary *playerInfo = [[IOSGamePlugin getInstance] gcGetPlayerInfo];
        NSLog(@"%@", playerInfo);
        _playerId = [playerInfo objectForKey:@"playerId"];
    }}];
    __block NSArray *_friendIds = [NSArray array];
    [dataList addObject:@{@"name":@"gcGetPlayerFriends", @"func":^(){
        [[IOSGamePlugin getInstance] gcGetPlayerFriends:^(NSArray *friendIDs) {
            NSLog(@"%@", friendIDs);
            _friendIds = friendIDs;
        }];
    }}];
    [dataList addObject:@{@"name":@"gcGetPlayerAvatar", @"func":^(){
        [[IOSGamePlugin getInstance] gcGetPlayerAvatarWithId:_playerId handler:^(NSString *filePath) {
            NSLog(@"%@", filePath);
        }];
        for (NSString *friendId in _friendIds) {
            [[IOSGamePlugin getInstance] gcGetPlayerAvatarWithId:friendId handler:^(NSString *filePath) {
                NSLog(@"%@", filePath);
            }];
        }
    }}];
    [dataList addObject:@{@"name":@"gcGetPlayerInfoWithIds", @"func":^(){
        [[IOSGamePlugin getInstance] gcGetPlayerInfoWithIds:_friendIds handler:^(NSArray *playerInfos) {
            NSLog(@"%@", playerInfos);
        }];
    }}];
    [dataList addObject:@{@"name":@"gcGetPlayerInfoWithId", @"func":^(){
        [[IOSGamePlugin getInstance] gcGetPlayerInfoWithId:_playerId handler:^(NSDictionary *playerInfo) {
            NSLog(@"%@", playerInfo);
        }];
    }}];
    [dataList addObject:@{@"name":@"gcGetChallenge", @"func":^(){
        [[IOSGamePlugin getInstance] gcGetChallengesWithhandler:^(NSArray *challenges) {
            NSLog(@"%@", challenges);
        }];
    }}];
    [dataList addObject:@{@"name":@"gcGetScore", @"func":^(){
        NSLog(@"%d", [[IOSGamePlugin getInstance] gcGetScore:@"level"]);
    }}];
    [dataList addObject:@{@"name":@"gcReportScore", @"func":^(){
        [[IOSGamePlugin getInstance] gcReportScore:200 leaderboard:@"level" sortH2L:YES];
    }}];
    [dataList addObject:@{@"name":@"gcGetAchievement", @"func":^(){
        NSLog(@"%f", [[IOSGamePlugin getInstance] gcGetAchievement:@"millionaire"]);
    }}];
    [dataList addObject:@{@"name":@"gcReportAchievement", @"func":^(){
        [[IOSGamePlugin getInstance] gcReportAchievement:@"millionaire" percentComplete:80];
    }}];
    [dataList addObject:@{@"name":@"gcShowLeaderBoard", @"func":^(){
        [[IOSGamePlugin getInstance] gcShowLeaderBoard];
    }}];
    [dataList addObject:@{@"name":@"gcShowArchievement", @"func":^(){
        [[IOSGamePlugin getInstance] gcShowArchievement];
    }}];
    [dataList addObject:@{@"name":@"gcShowChallenge", @"func":^(){
        [[IOSGamePlugin getInstance] gcShowChallenge];
    }}];
    [dataList addObject:@{@"name":@"gcReset", @"func":^(){
        [[IOSGamePlugin getInstance] gcReset];
    }}];
#pragma mark analytic
    [dataList addObject:@{@"name":@"---------Analytic---------", @"func":^(){}}];
    [dataList addObject:@{@"name":@"setAccoutInfo", @"func":^(){
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:@"0000001" forKey:@"userId"];
        [dict setObject:@"male" forKey:@"gender"];
        [dict setObject:@"15" forKey:@"age"];
        [[IOSAnalyticHelper getInstance] setAccoutInfo:dict];
    }}];
    [dataList addObject:@{@"name":@"onEvent", @"func":^(){
        [[IOSAnalyticHelper getInstance] onEvent:@"dead"];
    }}];
    [dataList addObject:@{@"name":@"onEventLabel", @"func":^(){
        [[IOSAnalyticHelper getInstance] onEvent:@"dead" Label:@"10"];
    }}];
    [dataList addObject:@{@"name":@"onEventData", @"func":^(){
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:@"10" forKey:@"level"];
        [dict setObject:@"100" forKey:@"coin"];
        [[IOSAnalyticHelper getInstance] onEvent:@"dead" eventData:dict];
    }}];
    [dataList addObject:@{@"name":@"setLevel", @"func":^(){
        [[IOSAnalyticHelper getInstance] setLevel:10];
    }}];
    [dataList addObject:@{@"name":@"charge", @"func":^(){
        [[IOSAnalyticHelper getInstance] charge:@"coin1" :10 :100 :1000];
    }}];
    [dataList addObject:@{@"name":@"reward", @"func":^(){
        [[IOSAnalyticHelper getInstance] reward:100 :1000];
    }}];
    [dataList addObject:@{@"name":@"purchase", @"func":^(){
        [[IOSAnalyticHelper getInstance] purchase:@"helmet" :1 :10];
    }}];
    [dataList addObject:@{@"name":@"use", @"func":^(){
        [[IOSAnalyticHelper getInstance] use:@"helmet" :1 :10];
    }}];
#pragma mark advertise
    [dataList addObject:@{@"name":@"---------Advertise---------", @"func":^(){}}];
#pragma mark facebook
    [dataList addObject:@{@"name":@"---------Facebook---------", @"func":^(){}}];
#pragma mark amazonaws
    [dataList addObject:@{@"name":@"---------AmazonAWS---------", @"func":^(){}}];
    self.dataList = dataList;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellWithIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellWithIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellWithIdentifier];
    }
    NSDictionary* data = [self.dataList objectAtIndex:[indexPath row]];
    cell.textLabel.text = [data objectForKey:@"name"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* data = [self.dataList objectAtIndex:[indexPath row]];
    ((void(^)())[data objectForKey:@"func"])();
}

@end
