#import <QuartzCore/QuartzCore.h>

@interface SBUIController : NSObject
- (id)wallpaperView;
- (BOOL)isOnAC;
@end

@interface SBAwayController : NSObject
{
    SBUIController *_uiController;
}
+ (id)sharedAwayController;
- (SBUIController *)uiController;
- (id)awayView;
@end

@class TPLCDTextView;
@interface SBAwayDateView :UIView
{
    UILabel *_nowPlayingTitleLabel;
    UILabel *_nowPlayingArtistLabel;
    UILabel *_nowPlayingAlbumLabel;
    TPLCDTextView *_dateAndTetheringLabel;
}
- (void)setInitializeLabelsState;
- (id)initWithFrame:(struct CGRect)arg1;
- (TPLCDTextView *)dateAndTetheringLabel;
- (UILabel *)nowPlayingTitleLabel;
- (UILabel *)nowPlayingArtistLabel;
- (UILabel *)nowPlayingAlbumLabel;
@end


@interface SBAwayView : UIView
- (BOOL)isPlaying;
- (id)currentAwayPluginController;
- (void)_setPluginController:(id)arg1;
- (BOOL)isShowingMediaControls;
- (void)setPluginControllerHidden:(BOOL)hidden;
- (id)backgroundView;
- (BOOL)isAnimatingOut;
- (id)chargingView;
@end


@interface NowPlayingArtPluginController : NSObject
- (id)view;
@end

@interface SBWallpaperView : UIImageView
@end

@interface SBAwayChargingView : UIView
@end

@interface TPLCDTextView : UIView
//- (void)setText:(NSString *)text;
@end


static BOOL TweakEnabled = NO;
static BOOL HiddenTitleInClockBar = NO;
static BOOL HiddenTitleInMusicControl = NO;
static BOOL HiddenArtistInMusicControl = NO;
static BOOL HiddenAlbumInMusicControl = NO;
static BOOL HIddenArtworkInClockBar = NO;
static BOOL HiddenArtworkInMusicControl = NO;



%hook SBAwayView

%new(v@:B)
- (void)setPluginControllerHidden:(BOOL)hidden
{
    if (!TweakEnabled) {
        hidden = NO;
    }
    id pluginController = [self currentAwayPluginController];
    if ([pluginController isMemberOfClass:NSClassFromString(@"NowPlayingArtPluginController")]){
        UIView *pluginView = [(NowPlayingArtPluginController *)pluginController view];
        
        for(UIView *obj in [[(NowPlayingArtPluginController *)pluginController view] subviews]){
            obj.hidden = hidden;
            obj.layer.hidden = hidden;
            obj.alpha = hidden? 0.0:1.0;
        }
        pluginView.hidden = hidden;
        pluginView.layer.hidden = hidden;
        pluginView.alpha = hidden? 0.0:1.0;
        SBAwayView *awayView = [(SBAwayController * )[%c(SBAwayController) sharedAwayController] awayView];
        if (!hidden){
            [pluginView setBackgroundColor:[UIColor blackColor]];
            if (![[[%c(SBAwayController) sharedAwayController] uiController] isOnAC]){
                [[awayView  backgroundView] setAlpha:0.0];
            }
        } else {
            [pluginView setBackgroundColor:[UIColor clearColor]];
            if (![[[%c(SBAwayController) sharedAwayController] uiController] isOnAC]){
                [[awayView  backgroundView] setAlpha:1.0];
            }
        }
    }
}


- (void)_setPluginController:(id)arg1
{ 
    %orig(arg1);
    if ([arg1 isMemberOfClass:NSClassFromString(@"NowPlayingArtPluginController")]){
        if([self isShowingMediaControls]){
            [self setPluginControllerHidden:HiddenArtworkInMusicControl];
        } else {
            [self setPluginControllerHidden:HIddenArtworkInClockBar];
        }
    }
}

%end


%hook SBAwayDateView

%new(v@:)
- (void)setInitializeLabelsState
{
    if (TweakEnabled) {
        if ([[(SBAwayController * )[%c(SBAwayController) sharedAwayController] awayView] isPlaying]){
            [[[self dateAndTetheringLabel] layer] setHidden:!HiddenTitleInClockBar];
            [[self nowPlayingTitleLabel]setHidden:HiddenTitleInClockBar];
        } else {
            [[[self dateAndTetheringLabel] layer] setHidden:NO];
            [[self nowPlayingTitleLabel]setHidden:YES];
        }
    } else {
        [[[self dateAndTetheringLabel] layer] setHidden:NO];
        [[self nowPlayingTitleLabel]setHidden:NO];
    }
}


- (id)initWithFrame:(struct CGRect)arg1
{
    self = %orig(arg1);
    [self setInitializeLabelsState];
    return self;
}


- (void)setIsShowingControls:(BOOL)arg1
{
    %orig(arg1);
    if(arg1){
        if(TweakEnabled){
            SBAwayView *awayView = [(SBAwayController *)[%c(SBAwayController) sharedAwayController] awayView];
            [[self nowPlayingTitleLabel]setHidden:HiddenTitleInMusicControl];
            [[self nowPlayingAlbumLabel]setHidden:HiddenAlbumInMusicControl];
            [[self nowPlayingArtistLabel]setHidden:HiddenArtistInMusicControl];
            [awayView setPluginControllerHidden:HiddenArtworkInMusicControl];
        } else {
            [[self nowPlayingArtistLabel]setHidden:NO];
            [[self nowPlayingAlbumLabel]setHidden:NO];
            [[self nowPlayingTitleLabel]setHidden:NO];
        }
    } else {
        SBAwayView *awayView = [(SBAwayController *)[%c(SBAwayController) sharedAwayController] awayView];
        if(TweakEnabled){
            [[self nowPlayingTitleLabel]setHidden:HiddenTitleInClockBar];
            [[self nowPlayingAlbumLabel]setHidden:YES];
            [[self nowPlayingArtistLabel]setHidden:YES];
            [awayView setPluginControllerHidden:HIddenArtworkInClockBar];
            if ([awayView isPlaying]){
                [[[self dateAndTetheringLabel] layer] setHidden:!HiddenTitleInClockBar];
            } else {
                [[[self dateAndTetheringLabel] layer] setHidden:NO];
            }
        } else {
            if ([awayView isPlaying]){
                [[[self dateAndTetheringLabel] layer] setHidden:YES];
                [[self nowPlayingTitleLabel] setHidden:NO];
            } else {
                [[[self dateAndTetheringLabel] layer] setHidden:NO];
            }
        }
    }
}


%new(@@:)
- (TPLCDTextView *)dateAndTetheringLabel
{
    return MSHookIvar<TPLCDTextView *>(self, "_dateAndTetheringLabel");
}

%new(@@:)
- (UILabel *)nowPlayingTitleLabel
{
    return MSHookIvar<UILabel *>(self, "_nowPlayingTitleLabel");
}

%new(@@:)
- (UILabel *)nowPlayingArtistLabel
{
    return  MSHookIvar<UILabel *>(self, "_nowPlayingArtistLabel");
}

%new(@@:)
- (UILabel *)nowPlayingAlbumLabel
{
	return MSHookIvar<UILabel *>(self, "_nowPlayingAlbumLabel");
}

%end


%hook SBWallpaperView

- (void)setAlpha:(float)alpha
{
    if (!TweakEnabled) {
        %orig(alpha); return;
    }
    
    SBAwayController *sharedController = [%c(SBAwayController) sharedAwayController];
    if (![[sharedController uiController] isOnAC]){
        SBAwayView *awayView = [sharedController awayView];
        if([awayView isPlaying]) {
            if([awayView isShowingMediaControls]){
                alpha = (HiddenArtworkInMusicControl)? 1.0f:0.0f;
            } else {
                alpha = (HIddenArtworkInClockBar)? 1.0f:0.0f;
            }
        } else {
            alpha = 1.0f;
        }
    }
    %orig(alpha);
}

%end


%hook SBAwayChargingView

- (void)setAlpha:(float)alpha
{
    SBAwayController *sharedController = [%c(SBAwayController) sharedAwayController];
    if(![(SBAwayView *)[sharedController awayView] isAnimatingOut] && [[sharedController uiController] isOnAC]){
        alpha = 1.0;
    }
    %orig(alpha);
}

+ (BOOL)shouldShowDeviceBattery
{
    if ([[[%c(SBAwayController) sharedAwayController] uiController] isOnAC]){
        return YES;
    }
	return %orig;
}

%end


static void EntryCheck(void)
{
    SBAwayView *awayView = [(SBAwayController * )[%c(SBAwayController) sharedAwayController] awayView];
    if([awayView isShowingMediaControls]){
        [awayView setPluginControllerHidden:HiddenArtworkInMusicControl];
    } else {
        [awayView setPluginControllerHidden:HIddenArtworkInClockBar];
    }
}


%hook SBAwayController

%new(@@:)
- (SBUIController *)uiController
{
    return MSHookIvar<SBUIController *>(self, "_uiController");
}

- (void)lock
{
    %orig;
    EntryCheck();
    SBAwayView *awayView = [(SBAwayController * )[%c(SBAwayController) sharedAwayController] awayView];
    [(SBAwayChargingView *)[awayView chargingView] setAlpha:1.0];
}

%end


%hook SBUIController

- (void)ACPowerChanged
{
    EntryCheck();
    %orig;
}

%end


static void ReloadSettings(void)
{
	NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.mkn0dat.secretnowplaying.plist"];
    TweakEnabled = [[settings objectForKey:@"Enabled"] boolValue];
    HiddenTitleInClockBar = [[settings objectForKey:@"TitleInClockBar"] boolValue];
    HIddenArtworkInClockBar = [[settings objectForKey:@"ArtworkInClockBar"] boolValue];
    HiddenTitleInMusicControl = [[settings objectForKey:@"TitleInMusicControl"] boolValue];
    HiddenArtistInMusicControl = [[settings objectForKey:@"ArtistInMusicControl"] boolValue];
    HiddenAlbumInMusicControl = [[settings objectForKey:@"AlbumInMusicControl"] boolValue];
    HiddenArtworkInMusicControl = [[settings objectForKey:@"ArtworkInMusicControl"] boolValue];
	[settings release];
}

static void SettingsChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	ReloadSettings();
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    ReloadSettings();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SettingsChangedCallback, CFSTR("com.mkn0dat.secretnowplaying.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    %init();
	[pool drain];
}