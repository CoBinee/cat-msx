; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_TYPE                     =   0x00
PLAYER_STATE                    =   0x01
PLAYER_FLAG                     =   0x02
PLAYER_POSITION_X               =   0x03
PLAYER_POSITION_Y               =   0x04
PLAYER_FIRE                     =   0x05
PLAYER_DAMAGE                   =   0x06
PLAYER_LENGTH                   =   0x08

; 種類
PLAYER_TYPE_NULL                =   0x00
PLAYER_TYPE_DORAEMON            =   0x00
PLAYER_TYPE_NOBY                =   0x01
PLAYER_TYPE_BIG_G               =   0x02
PLAYER_TYPE_SNEECH              =   0x03
PLAYER_TYPE_LENGTH              =   0x04

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_PLAY               =   0x10
PLAYER_STATE_DEAD               =   0x20
PLAYER_STATE_CLEAR              =   0x30

; フラグ
PLAYER_FLAG_NULL                =   0x00

; 位置
PLAYER_POSITION_NULL            =   0x00
PLAYER_POSITION_LEFT            =   0x08
PLAYER_POSITION_RIGHT           =   0xf8
PLAYER_POSITION_TOP             =   0x10
PLAYER_POSITION_BOTTOM          =   0xB8

; 速度
PLAYER_SPEED_MOVE               =   0x03

; 発射
PLAYER_FIRE_NULL                =   0x00
PLAYER_FIRE_OFFSET_X            =   0x00
PLAYER_FIRE_OFFSET_Y            =   0x01
PLAYER_FIRE_SHOT_TYPE           =   0x02
PLAYER_FIRE_LENGTH              =   0x04

; ダメージ
PLAYER_DAMAGE_NULL              =   0x00
PLAYER_DAMAGE_FRAME             =   0x30

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender

; 外部変数宣言
;

    .globl  _player

