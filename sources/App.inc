; App.inc : アプリケーション
;


; マクロの定義
;

; ビデオ
APP_COLOR_TABLE                 =   0x2000
APP_PATTERN_NAME_TABLE          =   0x1800
APP_PATTERN_GENERATOR_TABLE     =   0x0000
APP_SPRITE_ATTRIBUTE_TABLE      =   0x1b00
APP_SPRITE_GENERATOR_TABLE      =   0x3800

; 状態
APP_STATE_NULL                  =   0x00
APP_STATE_TITLE_INITIALIZE      =   0x01
APP_STATE_TITLE_UPDATE          =   0x02
APP_STATE_GAME_INITIALIZE       =   0x03
APP_STATE_GAME_UPDATE           =   0x04

; スコア
APP_SCORE_NULL                  =   0x00
APP_SCORE_10000000              =   0x00
APP_SCORE_01000000              =   0x01
APP_SCORE_00100000              =   0x02
APP_SCORE_00010000              =   0x03
APP_SCORE_00001000              =   0x04
APP_SCORE_00000100              =   0x05
APP_SCORE_00000010              =   0x06
APP_SCORE_00000001              =   0x07
APP_SCORE_LENGTH                =   0x08

; 操作
APP_OPERATE_STATE               =   0x00
APP_OPERATE_HEAD_L              =   0x01
APP_OPERATE_HEAD_H              =   0x02
APP_OPERATE_PLAY_L              =   0x03
APP_OPERATE_PLAY_H              =   0x04
APP_OPERATE_LENGTH              =   0x05
APP_OPERATE_BUFFER_LENGTH       =   0x0c00
APP_OPERATE_STATE_NULL          =   0x00
APP_OPERATE_STATE_RECORD        =   0x01
APP_OPERATE_STATE_REPLAY        =   0x02

; 外部関数宣言
;

    .globl  _AppInitialize
    .globl  _AppUpdate
    .globl  _AppNull
    .globl  _AppUpdateScore
    .globl  _AppIsOperate
    .globl  _AppStartRecordOperate
    .globl  _AppStartReplayOperate
    .globl  _AppRecordOperate
    .globl  _AppReplayOperate
    .globl  _AppIsRecordOperate
    .globl  _AppIsReplayOperate

; 外部変数宣言
;

    .globl  _appState
    .globl  _appDebug
    .globl  _appScore
    