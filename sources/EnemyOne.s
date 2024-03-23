; EnemyOne.s : 種類別のエネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Math.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "EnemyOne.inc"
    .include    "Bullet.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 何もしない
;
_EnemyNull::

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; 爆発を更新する
;
_EnemyBomb::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #(0x04 + 0x01)

    ; SE の再生
    ld      a, #SOUND_SE_BOMB
    call    _SoundPlaySe

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; アニメーションの更新
    dec     ENEMY_ANIMATION(ix)
    jr      z, 10$

    ; スプライトの設定
    ld      a, ENEMY_ANIMATION(ix)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyBombSprite
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h
    jr      19$

    ; 削除
10$:
    call    _EnemyRemove
;   jr      19$

    ; 更新の完了
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ボスが行動する
;
_EnemyBoss::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    ld      ENEMY_POSITION_X(ix), #0x80
    ld      ENEMY_POSITION_Y(ix), #0x80

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #0x30

    ; パラメータの設定
    ld      a, #0x01
    ld      ENEMY_PARAM_0(ix), a
    ld      ENEMY_PARAM_1(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ライフの復帰
    ld      ENEMY_LIFE(ix), #0xff

    ; 登場
10$:
    ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 20$
    dec     ENEMY_ANIMATION(ix)
    jr      nz, 19$
    set     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
    inc     ENEMY_STATE(ix)
19$:
    jp      90$

    ; 移動と発射
20$:

    ; 移動
    dec     a
    jp      nz, 30$
    call    _EnemyMove
    ld      a, ENEMY_POSITION_X(ix)
    cp      #0x28
    jr      nc, 210$
    ld      ENEMY_POSITION_X(ix), #0x28
    ld      ENEMY_SPEED_X(ix), #0x10
    jr      211$
210$:
    cp      #0xe0
    jr      c, 211$
    ld      ENEMY_POSITION_X(ix), #0xdf
    ld      ENEMY_SPEED_X(ix), #-0x10
;   jr      211$
211$:
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #0x70
    jr      nc, 212$
    ld      ENEMY_POSITION_Y(ix), #0x70
    ld      ENEMY_SPEED_Y(ix), #0x10
    jr      213$
212$:
    cp      #0x98
    jr      c, 213$
    ld      ENEMY_POSITION_Y(ix), #0x97
    ld      ENEMY_SPEED_Y(ix), #-0x10
;   jr      213$
213$:

    ; 発射
    dec     ENEMY_PARAM_0(ix)
    jr      nz, 220$
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x10
    ld      d, a
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x0a
    ld      e, a
    ld      bc, #((0x80 << 8) | BULLET_SIZE_LARGE)
    call    _BulletFireDirection
    ld      a, e
    add     a, #0x14
    ld      e, a
    call    _BulletFireDirection
    call    _GameGetRandom
    and     #0x0f
    add     a, #0x18
    ld      ENEMY_PARAM_0(ix), a
;   jr      220$
220$:
    dec     ENEMY_PARAM_1(ix)
    jr      nz, 229$
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    jr      nc, 221$
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x18
    ld      d, a
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x24
    ld      e, a
    jr      222$
221$:
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x08
    ld      d, a
    ld      a, ENEMY_POSITION_X(ix)
    add     a, #0x24
    ld      e, a
;   jr      222$
222$:
    ld      c, #BULLET_SIZE_LARGE
    call    _BulletFirePlayer
    call    _GameGetRandom
    and     #0x0f
    add     a, #0x10
    ld      ENEMY_PARAM_1(ix), a
;   jr      229$
229$:
    jr      90$

    ; 死亡
30$:
    inc     ENEMY_ANIMATION(ix)
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x07
    jr      nz, 39$
    call    _GameGetRandom
    and     #0x3f
    sub     #0x20
    add     a, ENEMY_POSITION_X(ix)
    ld      e, a
    call    _GameGetRandom
    and     #0x3f
    sub     #0x20
    add     a, ENEMY_POSITION_Y(ix)
    ld      d, a
    ld      a, #ENEMY_TYPE_BOMB
    call    _EnemyGenerateOne
;   jr      39$
39$:
    jr      90$

    ; 行動の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

_EnemyBossRender::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; パターンネームの設定
    bit     #0x00, ENEMY_ANIMATION(ix)
    jr      nz, 19$
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #0x18
    and     #0xf8
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #_patternNameLine
    add     hl, de
    ld      de, #(_patternName + 0x0020)
    ld      b, #0x09
10$:
    push    bc
    push    hl
    push    de
    ld      a, (hl)
    inc     hl
    ld      h, (hl)
    ld      l, a
    ld      bc, #0x0020
    ldir
    pop     bc  ; < de
    pop     hl
    ld      (hl), c
    inc     hl
    ld      (hl), b
    inc     hl
    pop     bc
    djnz    10$
    ld      a, ENEMY_POSITION_X(ix)
    sub     #0x28
    and     #0xf8
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_patternName + 0x0020)
    add     hl, de
    ex      de, hl
    ld      hl, #enemyBossPatternName
    ld      b, #0x0009
11$:
    push    bc
    ld      bc, #0x000a
    ldir
    ex      de, hl
    ld      bc, #(0x0020 - 0x000a)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    11$
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; I が行動する
;
_EnemyI::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    call    _GameGetRandom
    and     #0xf0
    add     a, #0x08
    ld      ENEMY_POSITION_X(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    _EnemyMove

    ; アニメーション
    ld      hl, #enemyISprite
    call    _EnemyAnimation

    ; レジスタの復帰

    ; 終了
    ret

; N が行動する
;
_EnemyN::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    ld      a, (_player + PLAYER_POSITION_X)
    and     #0x80
    add     a, #0xc0
    ld      ENEMY_POSITION_X(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    _EnemyMove

    ; 直進１
    ld      a, ENEMY_STATE(ix)
10$:
    dec     a
    jr      nz, 20$
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, #0x10
    cp      ENEMY_POSITION_Y(ix)
    jr      c, 19$
    ld      a, ENEMY_SPEED_Y(ix)
    neg
    ld      c, a
    rrca
    ld      ENEMY_SPEED_Y(ix), a
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    ld      a, c
    jr      nc, 11$
    neg
11$:
    ld      ENEMY_SPEED_X(ix), a
    inc     ENEMY_STATE(ix)
19$:
    jr      90$

    ; 後退
20$:
    dec     a
    jr      nz, 30$
    ld      a, ENEMY_SPEED_X(ix)
    or      a
    jp      p, 21$
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    jr      c, 29$
    jr      22$
21$:
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    jr      nc, 29$
;   jr      22$
22$:
    ld      ENEMY_SPEED_X(ix), #0x00
    ld      a, ENEMY_SPEED_Y(ix)
    add     a, a
    neg
    ld      ENEMY_SPEED_Y(ix), a
    inc     ENEMY_STATE(ix)
29$:
    jr      90$
    
    ; 直進２
30$:
39$:
    jr      90$

    ; 行動の完了
90$:

    ; アニメーション
    ld      hl, #enemyNSprite
    call    _EnemyAnimation

    ; レジスタの復帰

    ; 終了
    ret

; S が行動する
;
_EnemyS::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    ld      a, (_player + PLAYER_POSITION_X)
    rlca
    ld      a, #0x20
    jr      c, 00$
    ld      a, #0xe0
00$:
    ld      ENEMY_POSITION_X(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 速度の更新
    ld      a, ENEMY_POSITION_X(ix)
    rlca
    ld      a, ENEMY_SPEED_X(ix)
    jr      c, 10$
    add     a, #0x03
    jp      m, 11$
    ld      c, #0x60
    cp      c
    jr      c, 11$
    ld      a, c
    jr      11$
10$:
    ld      c, #-0x60
    sub     #0x03
    jp      p, 11$
    cp      c
    jr      nc, 11$
    ld      a, c
;   jr      11$
11$:
    ld      ENEMY_SPEED_X(ix), a

    ; 移動
    call    _EnemyMove

    ; アニメーション
    ld      hl, #enemySSprite
    call    _EnemyAnimation

    ; レジスタの復帰

    ; 終了
    ret

; J が行動する
;
_EnemyJ::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    call    _GameGetRandom
    and     #0xf0
    add     a, #0x08
    ld      ENEMY_POSITION_X(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 速度の更新
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    ld      a, ENEMY_SPEED_X(ix)
    jr      c, 10$
    add     a, #0x02
    jp      m, 11$
    ld      c, #0x40
    cp      c
    jr      c, 11$
    ld      a, c
    jr      11$
10$:
    ld      c, #-0x40
    sub     #0x02
    jp      p, 11$
    cp      c
    jr      nc, 11$
    ld      a, c
;   jr      11$
11$:
    ld      ENEMY_SPEED_X(ix), a

    ; 移動
    call    _EnemyMove

    ; アニメーション
    ld      hl, #enemyJSprite
    call    _EnemyAnimation

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; なし
_enemyNullDefault:

    .db     ENEMY_TYPE_NULL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_LIFE_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_MOVE_NULL
    .db     ENEMY_MOVE_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SIZE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyNullSprite:

    .db     0xcc, 0xcc, 0x00, 0x00

; 爆発
_enemyBombDefault:

    .db     ENEMY_TYPE_BOMB
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_LIFE_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_MOVE_NULL
    .db     ENEMY_MOVE_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SIZE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyBombSprite:

    .db     0xf8 - 0x01, 0xf8, 0x5c, VDP_COLOR_WHITE
    .db     0xf8 - 0x01, 0xf8, 0x58, VDP_COLOR_WHITE
    .db     0xf8 - 0x01, 0xf8, 0x3c, VDP_COLOR_WHITE
    .db     0xf8 - 0x01, 0xf8, 0x38, VDP_COLOR_WHITE

; ボス
_enemyBossDefault:

    .db     ENEMY_TYPE_BOSS
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     0xff ; ENEMY_LIFE_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_MOVE_NULL
    .db     ENEMY_MOVE_NULL
    .db     0x10 ; ENEMY_SPEED_NULL
    .db     0x10 ; ENEMY_SPEED_NULL
    .db     0x11 ; ENEMY_SIZE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyBossPatternName:

    .db     0x78, 0x00, 0x00, 0x00, 0x7c, 0x7d, 0x00, 0x00, 0x00, 0x00
    .db     0x79, 0x00, 0x00, 0x80, 0x81, 0x82, 0x83, 0x00, 0x00, 0x00
    .db     0x7a, 0x00, 0x00, 0x84, 0x85, 0x86, 0x87, 0x00, 0x70, 0x71
    .db     0x74, 0x90, 0x91, 0x88, 0x89, 0x8a, 0x8b, 0x98, 0x72, 0x73
    .db     0x7b, 0x92, 0x93, 0x8c, 0x8d, 0x8e, 0x8f, 0x9a, 0x9b, 0x00
    .db     0x7b, 0x94, 0x95, 0x7e, 0xa0, 0xa1, 0x7f, 0x9c, 0x9d, 0x00
    .db     0x7b, 0x96, 0x97, 0xa4, 0xa2, 0xa3, 0xa4, 0x9e, 0x9f, 0x00
    .db     0x7b, 0x00, 0x00, 0xa4, 0x00, 0xa4, 0xa4, 0xa4, 0x00, 0x00
    .db     0x7b, 0x00, 0x00, 0x00, 0xa4, 0x00, 0xa4, 0x00, 0x00, 0x00

; I
_enemyIDefault:

    .db     ENEMY_TYPE_I
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_HIT
    .db     0x01 ; ENEMY_LIFE_NULL
    .db     0x80 ; ENEMY_POSITION_NULL
    .db     0xc8 ; ENEMY_POSITION_NULL
    .db     ENEMY_MOVE_NULL
    .db     ENEMY_MOVE_NULL
    .db     0x00 ; ENEMY_SPEED_NULL
    .db     -0x30 ; ENEMY_SPEED_NULL
    .db     0x09 ; ENEMY_SIZE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyISprite:

    .db     0xf8 - 0x01, 0xf8, 0x60, VDP_COLOR_LIGHT_YELLOW
    .db     0xf8 - 0x01, 0xf8, 0x64, VDP_COLOR_LIGHT_YELLOW
    .db     0xf8 - 0x01, 0xf8, 0x60, VDP_COLOR_LIGHT_YELLOW
    .db     0xf8 - 0x01, 0xf8, 0x64, VDP_COLOR_LIGHT_YELLOW

; N
_enemyNDefault:

    .db     ENEMY_TYPE_N
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_HIT
    .db     0x01 ; ENEMY_LIFE_NULL
    .db     0x80 ; ENEMY_POSITION_NULL
    .db     0xc8 ; ENEMY_POSITION_NULL
    .db     ENEMY_MOVE_NULL
    .db     ENEMY_MOVE_NULL
    .db     0x00 ; ENEMY_SPEED_NULL
    .db     -0x40 ; ENEMY_SPEED_NULL
    .db     0x09 ; ENEMY_SIZE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyNSprite:

    .db     0xf8 - 0x01, 0xf8, 0x68, VDP_COLOR_LIGHT_RED
    .db     0xf8 - 0x01, 0xf8, 0x6c, VDP_COLOR_LIGHT_RED
    .db     0xf8 - 0x01, 0xf8, 0x68, VDP_COLOR_LIGHT_RED
    .db     0xf8 - 0x01, 0xf8, 0x6c, VDP_COLOR_LIGHT_RED

; S
_enemySDefault:

    .db     ENEMY_TYPE_S
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_HIT
    .db     0x01 ; ENEMY_LIFE_NULL
    .db     0x80 ; ENEMY_POSITION_NULL
    .db     0xc8 ; ENEMY_POSITION_NULL
    .db     ENEMY_MOVE_NULL
    .db     ENEMY_MOVE_NULL
    .db     0x00 ; ENEMY_SPEED_NULL
    .db     -0x10 ; ENEMY_SPEED_NULL
    .db     0x09 ; ENEMY_SIZE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemySSprite:

    .db     0xf8 - 0x01, 0xf8, 0x70, VDP_COLOR_CYAN
    .db     0xf8 - 0x01, 0xf8, 0x74, VDP_COLOR_CYAN
    .db     0xf8 - 0x01, 0xf8, 0x78, VDP_COLOR_CYAN
    .db     0xf8 - 0x01, 0xf8, 0x7c, VDP_COLOR_CYAN

; J
_enemyJDefault:

    .db     ENEMY_TYPE_J
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_HIT
    .db     0x01 ; ENEMY_LIFE_NULL
    .db     0x80 ; ENEMY_POSITION_NULL
    .db     0xc8 ; ENEMY_POSITION_NULL
    .db     ENEMY_MOVE_NULL
    .db     ENEMY_MOVE_NULL
    .db     0x00 ; ENEMY_SPEED_NULL
    .db     -0x20 ; ENEMY_SPEED_NULL
    .db     0x09 ; ENEMY_SIZE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyJSprite:

    .db     0xf8 - 0x01, 0xf8, 0x80, VDP_COLOR_LIGHT_GREEN
    .db     0xf8 - 0x01, 0xf8, 0x84, VDP_COLOR_LIGHT_GREEN
    .db     0xf8 - 0x01, 0xf8, 0x88, VDP_COLOR_LIGHT_GREEN
    .db     0xf8 - 0x01, 0xf8, 0x8c, VDP_COLOR_LIGHT_GREEN


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

