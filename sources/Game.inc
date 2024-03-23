; Game.inc : ゲーム
;


; マクロの定義
;

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_START                =   0x10
GAME_STATE_PLAY                 =   0x20
GAME_STATE_OVER                 =   0x30
GAME_STATE_RESULT               =   0x40

; スプライト
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_PLAYER_TOP          =   0x00
GAME_SPRITE_PLAYER_BOTTOM       =   0x5c
GAME_SPRITE_SHOT                =   0x60
GAME_SPRITE_ENEMY               =   0x3c
GAME_SPRITE_BULLET              =   0x0c

; ゲーム
GAME_REQUEST                    =   0x00
GAME_FRAME                      =   0x01
GAME_RANDOM_L                   =   0x02
GAME_RANDOM_H                   =   0x03
GAME_TIME_1000                  =   0x04
GAME_TIME_0100                  =   0x05
GAME_TIME_0010                  =   0x06
GAME_TIME_0001                  =   0x07
GAME_SCORE_10000000             =   0x08
GAME_SCORE_01000000             =   0x09
GAME_SCORE_00100000             =   0x0a
GAME_SCORE_00010000             =   0x0b
GAME_SCORE_00001000             =   0x0c
GAME_SCORE_00000100             =   0x0d
GAME_SCORE_00000010             =   0x0e
GAME_SCORE_00000001             =   0x0f
GAME_RATE_10_00                 =   0x10
GAME_RATE_01_00                 =   0x11
GAME_RATE_00_10                 =   0x12
GAME_RATE_00_01                 =   0x13
GAME_INPUT                      =   0x14
GAME_INPUT_FIRE_REPEAT          =   0x15
GAME_LENGTH                     =   0x16

; リクエスト
GAME_REQUEST_NULL               =   0x00
GAME_REQUEST_BACK_OUT_BIT       =   0x00
GAME_REQUEST_BACK_OUT           =   (1 << GAME_REQUEST_BACK_OUT_BIT)
GAME_REQUEST_BOSS_BIT           =   0x01
GAME_REQUEST_BOSS               =   (1 << GAME_REQUEST_BOSS_BIT)
GAME_REQUEST_OVER_BIT           =   0x07
GAME_REQUEST_OVER               =   (1 << GAME_REQUEST_OVER_BIT)

; フレーム
GAME_FRAME_NULL                 =   0x00

; 乱数
GAME_RANDOM_SEED                =   0x1985

; 時間
GAME_TIME_NULL                  =   0x00
GAME_TIME_LENGTH                =   0x04

; 得点
GAME_SCORE_NULL                 =   0x00
GAME_SCORE_LENGTH               =   0x08

; 倍率
GAME_RATE_NULL                  =   0x00
GAME_RATE_LENGTH                =   0x04

; 入力
GAME_INPUT_NULL                 =   0x00
GAME_INPUT_UP_BIT               =   0x00
GAME_INPUT_UP                   =   (1 << GAME_INPUT_UP_BIT)
GAME_INPUT_DOWN_BIT             =   0x01
GAME_INPUT_DOWN                 =   (1 << GAME_INPUT_DOWN_BIT)
GAME_INPUT_LEFT_BIT             =   0x02
GAME_INPUT_LEFT                 =   (1 << GAME_INPUT_LEFT_BIT)
GAME_INPUT_RIGHT_BIT            =   0x03
GAME_INPUT_RIGHT                =   (1 << GAME_INPUT_RIGHT_BIT)
GAME_INPUT_FIRE_BIT             =   0x04
GAME_INPUT_FIRE                 =   (1 << GAME_INPUT_FIRE_BIT)
GAME_INPUT_CHANGE_BIT           =   0x05
GAME_INPUT_CHANGE               =   (1 << GAME_INPUT_CHANGE_BIT)
GAME_INPUT_FIRE_REPEAT_NULL     =   0x00
GAME_INPUT_FIRE_REPEAT_INTERVAL =   0x04

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate
    .globl  _GameGetRandom
    .globl  _GameAddScore

; 外部変数宣言
;

    .globl  _game
