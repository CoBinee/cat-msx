; Bullet.s : 敵弾
;


; モジュール宣言
;
    .module Bullet

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Math.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "Bullet.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 敵弾を初期化する
;
_BulletInitialize::
    
    ; レジスタの保存

    ; 敵弾の初期化
    ld      hl, #(_bullet + 0x0000)
    ld      de, #(_bullet + 0x0001)
    ld      bc, #(BULLET_LENGTH * BULLET_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; スプライトの初期化
    xor     a
    ld      (bulletSprite), a

    ; レジスタの復帰
    
    ; 終了
    ret

; 敵弾を更新する
;
_BulletUpdate::
    
    ; レジスタの保存
    
    ; 敵弾の走査
    ld      ix, #_bullet
    ld      de, #BULLET_LENGTH
    ld      b, #BULLET_ENTRY
100$:
    ld      a, BULLET_SIZE(ix)
    or      a
    jp      z, 190$

    ; X の移動
    ld      a, BULLET_MOVE_X(ix)
    add     a, BULLET_SPEED_X(ix)
    jp      p, 110$
    neg
    ld      c, a
    and     #0x0f
    neg
    ld      BULLET_MOVE_X(ix), a
    ld      a, c
    and     #0xf0
    jr      z, 119$
    rrca
    rrca
    rrca
    rrca
    ld      c, a
    ld      a, BULLET_POSITION_X(ix)
    sub     c
    jr      c, 180$
    ld      BULLET_POSITION_X(ix), a
    jr      119$
110$:
    ld      c, a
    and     #0x0f
    ld      BULLET_MOVE_X(ix), a
    ld      a, c
    and     #0xf0
    jr      z, 119$
    rrca
    rrca
    rrca
    rrca
    add     a, BULLET_POSITION_X(ix)
    jr      c, 180$
    ld      BULLET_POSITION_X(ix), a
;   jr      119$
119$:

    ; Y の移動
    ld      a, BULLET_MOVE_Y(ix)
    add     a, BULLET_SPEED_Y(ix)
    jp      p, 120$
    neg
    ld      c, a
    and     #0x0f
    neg
    ld      BULLET_MOVE_Y(ix), a
    ld      a, c
    and     #0xf0
    jr      z, 129$
    rrca
    rrca
    rrca
    rrca
    ld      c, a
    ld      a, BULLET_POSITION_Y(ix)
    sub     c
    jr      c, 180$
    ld      BULLET_POSITION_Y(ix), a
    jr      129$
120$:
    ld      c, a
    and     #0x0f
    ld      BULLET_MOVE_Y(ix), a
    ld      a, c
    and     #0xf0
    jr      z, 129$
    rrca
    rrca
    rrca
    rrca
    add     a, BULLET_POSITION_Y(ix)
    cp      #0xc8
    jr      nc, 180$
    ld      BULLET_POSITION_Y(ix), a
;   jr      129$
129$:

    ; アニメーションの更新
    inc     BULLET_ANIMATION(ix)
    jr      190$

    ; 敵弾の削除
180$:
    ld      BULLET_SIZE(ix), #BULLET_SIZE_NULL
;   jr      190$

    ; 次の敵弾へ
190$:
    add     ix, de
    dec     b
    jp      nz, 100$

    ; レジスタの復帰
    
    ; 終了
    ret

; 敵弾を描画する
;
_BulletRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      ix, #_bullet
    ld      a, (bulletSprite)
    ld      e, a
    ld      d, #0x00
    ld      b, #BULLET_ENTRY
10$:
    push    bc
    ld      a, BULLET_SIZE(ix)
    or      a
    jr      z, 19$
    push    de
    sub     #BULLET_SIZE_SMALL
    ld      c, a
    ld      a, BULLET_ANIMATION(ix)
    and     #0x03
    add     a, c
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #(_sprite + GAME_SPRITE_BULLET)
    add     hl, de
    ex      de, hl
    ld      hl, #bulletAnimation
    add     hl, bc
    ld      a, BULLET_POSITION_Y(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, BULLET_POSITION_X(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld       a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld       a, (hl)
    ld      (de), a
    inc     hl
;   inc     de
    pop     de
    ld      a, e
    add     a, #0x04
    ld      e, a
    cp      #(BULLET_ENTRY * 0x04)
    jr      c, 19$
    ld      e, #0x00
19$:
    ld      bc, #BULLET_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; スプライトの更新
    ld      hl, #bulletSprite
    ld      a, (hl)
    add     a, #0x04
    cp      #(BULLET_ENTRY * 0x04)
    jr      c, 20$
    xor     a
20$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret
    
; 敵弾を撃つ
;
_BulletFireDirection::

    ; レジスタの保存
    push    hl
    push    bc
    push    ix

    ; c  < 敵弾の大きさ
    ; b  < 敵弾の方向
    ; de < Y/X 座標

    ; 敵弾の登録
    ld      h, b
    ld      ix, #_bullet
    ld      b, #BULLET_ENTRY
10$:
    ld      a, BULLET_SIZE(ix)
    or      a
    jr      z, 11$
    push    de
    ld      de, #BULLET_LENGTH
    add     ix, de
    pop     de
    djnz    10$
    jr      19$
11$:
    ld      BULLET_SIZE(ix), c
    ld      BULLET_POSITION_X(ix), e
    ld      BULLET_POSITION_Y(ix), d
    xor     a
    ld      BULLET_MOVE_X(ix), a
    ld      BULLET_MOVE_Y(ix), a
    ld      a, c
    sub     #BULLET_SIZE_SMALL
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    ld      a, h
    and     #0xf8
    rrca
    rrca
    add     a, c
    ld      c, a
    ld      b, #0x00
    ld      hl, #bulletSpeed
    add     hl, bc
    ld      a, (hl)
    ld      BULLET_SPEED_X(ix), a
    inc     hl
    ld      a, (hl)
    ld      BULLET_SPEED_Y(ix), a
    call    _GameGetRandom
    ld      BULLET_ANIMATION(ix), a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     bc
    pop     hl

    ; 終了
    ret

_BulletFirePlayer::

    ; レジスタの保存
    push    hl

    ; c  < 敵弾の大きさ
    ; de < Y/X 座標

    ; 発射
    ld      a, (_player + PLAYER_POSITION_X)
    ld      l, e
    srl     a
    srl     l
    sub     l
    ld      l, a
    jp      p, 10$
    neg
10$:
    ld      b, a
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      h, d
    srl     a
    srl     h
    sub     h
    ld      h, a
    jp      p, 11$
    neg
11$:
    add     a, b
    cp      #0x1c
    jr      c, 19$
    call    _MathGetAtan2
    and     #0xf8
    ld      b, a
    call    _GameGetRandom
    and     #0x18
    jr      z, 12$
    sub     #0x10
12$:
    add     a, b
    ld      b, a
    call    _BulletFireDirection
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 敵弾のヒットを判定する
;
_BulletHit::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = ヒット

    ; ヒットカウントの設定
    ld      h, #0x00

    ; ヒット判定
    ld      ix, #_bullet
    ld      b, #BULLET_ENTRY
10$:
    push    bc
    ld      a, BULLET_SIZE(ix)
    or      a
    jr      z, 19$
    ld      c, a
    ld      a, BULLET_POSITION_X(ix)
    sub     e
    jp      p, 11$
    neg
11$:
    cp      c
    jr      nc, 19$
    ld      a, BULLET_POSITION_Y(ix)
    sub     d
    jp      p, 12$
    neg
12$:
    cp      c
    jr      nc, 19$
    ld      BULLET_SIZE(ix), #0x00
    inc     h
19$:
    ld      bc, #BULLET_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; 結果の取得
    ld      a, h
    or      a
    jr      z, 29$
    scf
29$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 速度
;
bulletSpeed:

    ; x4
    .db      0x00,  0x40
    .db      0x0c,  0x3e
    .db      0x18,  0x3b
    .db      0x23,  0x35
    .db      0x2d,  0x2d
    .db      0x35,  0x23
    .db      0x3b,  0x18
    .db      0x3e,  0x0c
    .db      0x40,  0x00
    .db      0x3e, -0x0c
    .db      0x3b, -0x18
    .db      0x35, -0x23
    .db      0x2d, -0x2d
    .db      0x23, -0x35
    .db      0x18, -0x3b
    .db      0x0c, -0x3e
    .db      0x00, -0x40
    .db     -0x0c, -0x3e
    .db     -0x18, -0x3b
    .db     -0x23, -0x35
    .db     -0x2d, -0x2d
    .db     -0x35, -0x23
    .db     -0x3b, -0x18
    .db     -0x3e, -0x0c
    .db     -0x40,  0x00
    .db     -0x3e,  0x0c
    .db     -0x3b,  0x18
    .db     -0x35,  0x23
    .db     -0x2d,  0x2d
    .db     -0x23,  0x35
    .db     -0x18,  0x3b
    .db     -0x0c,  0x3e
    ; x3
    .db      0x00,  0x30
    .db      0x09,  0x2f
    .db      0x12,  0x2c
    .db      0x1a,  0x27
    .db      0x21,  0x21
    .db      0x27,  0x1a
    .db      0x2c,  0x12
    .db      0x2f,  0x09
    .db      0x30,  0x00
    .db      0x2f, -0x09
    .db      0x2c, -0x12
    .db      0x27, -0x1a
    .db      0x21, -0x21
    .db      0x1a, -0x27
    .db      0x12, -0x2c
    .db      0x09, -0x2f
    .db      0x00, -0x30
    .db     -0x09, -0x2f
    .db     -0x12, -0x2c
    .db     -0x1a, -0x27
    .db     -0x21, -0x21
    .db     -0x27, -0x1a
    .db     -0x2c, -0x12
    .db     -0x2f, -0x09
    .db     -0x30,  0x00
    .db     -0x2f,  0x09
    .db     -0x2c,  0x12
    .db     -0x27,  0x1a
    .db     -0x21,  0x21
    .db     -0x1a,  0x27
    .db     -0x12,  0x2c
    .db     -0x09,  0x2f

; アニメーション
;
bulletAnimation:

    ; 小
    .db     0xf8 - 0x01, 0xf8, 0x18, VDP_COLOR_LIGHT_RED
    .db     0xf8 - 0x01, 0xf8, 0x18, VDP_COLOR_LIGHT_GREEN
    .db     0xf8 - 0x01, 0xf8, 0x18, VDP_COLOR_LIGHT_BLUE
    .db     0xf8 - 0x01, 0xf8, 0x18, VDP_COLOR_LIGHT_YELLOW
    ; 大
    .db     0xf8 - 0x01, 0xf8, 0x1c, VDP_COLOR_LIGHT_RED
    .db     0xf8 - 0x01, 0xf8, 0x1c, VDP_COLOR_LIGHT_GREEN
    .db     0xf8 - 0x01, 0xf8, 0x1c, VDP_COLOR_LIGHT_BLUE
    .db     0xf8 - 0x01, 0xf8, 0x1c, VDP_COLOR_LIGHT_YELLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 敵弾
;
_bullet::
    
    .ds     BULLET_LENGTH * BULLET_ENTRY

; スプライト
;
bulletSprite:

    .ds     0x01