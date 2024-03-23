; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_FLAG                      =   0x02
ENEMY_LIFE                      =   0x03
ENEMY_POSITION_X                =   0x04
ENEMY_POSITION_Y                =   0x05
ENEMY_MOVE_X                    =   0x06
ENEMY_MOVE_Y                    =   0x07
ENEMY_SPEED_X                   =   0x08
ENEMY_SPEED_Y                   =   0x09
ENEMY_SIZE                      =   0x0a
ENEMY_ANIMATION                 =   0x0b
ENEMY_SPRITE_L                  =   0x0c
ENEMY_SPRITE_H                  =   0x0d
ENEMY_PARAM_0                   =   0x0e
ENEMY_PARAM_1                   =   0x0f
ENEMY_LENGTH                    =   0x10
ENEMY_ENTRY                     =   0x08

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_BOMB                 =   0x01
ENEMY_TYPE_BOSS                 =   0x02
ENEMY_TYPE_I                    =   0x03
ENEMY_TYPE_N                    =   0x04
ENEMY_TYPE_S                    =   0x05
ENEMY_TYPE_J                    =   0x06

; 状態
ENEMY_STATE_NULL                =   0x00

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_HIT_BIT              =   0x00
ENEMY_FLAG_HIT                  =   (1 << ENEMY_FLAG_HIT_BIT)

; ライフ
ENEMY_LIFE_NULL                 =   0x00

; 位置
ENEMY_POSITION_NULL             =   0x00

; 移動
ENEMY_MOVE_NULL                 =   0x00

; 速度
ENEMY_SPEED_NULL                =   0x00

; 大きさ
ENEMY_SIZE_NULL                 =   0x00

; アニメーション
ENEMY_ANIMATION_NULL            =   0x00

; スプライト
ENEMY_SPRITE_NULL               =   0x00

; パラメータ
ENEMY_PARAM_NULL                =   0x00

; 生成
ENEMY_GENERATE_TYPE             =   0x00
ENEMY_GENERATE_COUNT            =   0x01
ENEMY_GENERATE_INTERVAL         =   0x02
ENEMY_GENERATE_FRAME            =   0x03
ENEMY_GENERATE_LENGTH           =   0x04

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyGenerate
    .globl  _EnemyGenerateOne
    .globl  _EnemyRemove
    .globl  _EnemyKill
    .globl  _EnemyHit
    .globl  _EnemyMove
    .globl  _EnemyAnimation

; 外部変数宣言
;

    .globl  _enemy

