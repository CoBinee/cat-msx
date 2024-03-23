; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
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

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存

    ; エネミーのクリア
    call    EnemyClear

    ; ジェネレータの初期化
    xor     a
    ld      (enemyGenerate + ENEMY_GENERATE_TYPE), a

    ; スプライトの初期化
    xor     a
    ld      (enemySprite), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存
    
    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; エネミーの存在
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$

    ; エネミー別の処理
    ld      hl, #19$
    push    hl
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
19$:

    ; 次のエネミーへ
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      ix, #_enemy
    ld      a, (enemySprite)
    ld      e, a
    ld      d, #0x00
    ld      b, #ENEMY_ENTRY
10$:
    push    bc
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 12$
    cp      #ENEMY_TYPE_BOSS
    jr      z, 11$
    ld      l, ENEMY_SPRITE_L(ix)
    ld      h, ENEMY_SPRITE_H(ix)
    ld      a, h
    or      l
    jr      z, 12$
    call    20$
    jr      12$
11$:
    call    _EnemyBossRender
;   jr      12$
12$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    jr      90$

    ; ひとつのスプライトの描画
20$:
    push    de
    push    hl
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, de
    pop     de
    ex      de, hl
    ld      a, ENEMY_POSITION_X(ix)
    ld      bc, #0x0000
    cp      #0x80
    jr      nc, 21$
    ld      bc, #0x2080
21$:
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, ENEMY_POSITION_X(ix)
    add     a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    or      c
    ld      (de), a
    inc     hl
;   inc     de
    pop     de
    ld      a, e
    add     a, #0x04
    ld      e, a
    cp      #(ENEMY_ENTRY * 0x04)
    jr      c, 29$
    ld      e, #0x00
29$:
    ret

    ; スプライトの更新
90$:
    ld      hl, #enemySprite
    ld      a, (hl)
    add     a, #0x04
    cp      #(ENEMY_ENTRY * 0x04)
    jr      c, 91$
    xor     a
91$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーをクリアする
;
EnemyClear:

    ; レジスタの保存

    ; 初期値の設定
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_LENGTH * ENEMY_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      a, #ENEMY_ENTRY
    ld      (enemyRest), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを生成する
;
_EnemyGenerate::

    ; レジスタの保存

    ; リクエストの監視
    ld      hl, #(_game + GAME_REQUEST)
    bit     #GAME_REQUEST_BOSS_BIT, (hl)
    jr      z, 09$
    push    hl
    ld      hl, #enemyGenerateBoss
    ld      de, #enemyGenerate
    ld      bc, #ENEMY_GENERATE_LENGTH
    ldir
    pop     hl
    res     #GAME_REQUEST_BOSS_BIT, (hl)
09$:

    ; 次に生成するエネミーの取得
    ld      a, (enemyGenerate + ENEMY_GENERATE_TYPE)
    or      a
    jr      nz, 19$
    call    _GameGetRandom
    rlca
    rlca
    and     #0x1c
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyGenerateDefault
    add     hl, de
    ld      de, #enemyGenerate
    ld      bc, #ENEMY_GENERATE_LENGTH
    ldir
    call    _GameGetRandom
    rrca
    and     #0x03
    add     a, #0x03
    ld      (enemyGenerate + ENEMY_GENERATE_COUNT), a
19$:

    ; エネミーの生成
    ld      hl, #(enemyGenerate + ENEMY_GENERATE_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 20$
    dec     (hl)
    jr      29$
20$:
    ld      a, (enemyGenerate + ENEMY_GENERATE_COUNT)
    ld      c, a
    ld      a, (enemyRest)
    cp      c
    jr      c, 29$
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
21$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 22$
    add     ix, de
    djnz    21$
    jr      29$
22$:
    ld      a, (enemyGenerate + ENEMY_GENERATE_TYPE)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDefault
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    ld      a, (enemyGenerate + ENEMY_GENERATE_INTERVAL)
    ld      (enemyGenerate + ENEMY_GENERATE_FRAME), a
    ld      hl, #enemyRest
    dec     (hl)
    ld      hl, #(enemyGenerate + ENEMY_GENERATE_COUNT)
    dec     (hl)
    jr      nz, 29$
    xor     a
    ld      (enemyGenerate + ENEMY_GENERATE_TYPE), a
29$:

    ; レジスタの復帰

    ; 終了
    ret

_EnemyGenerateOne::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; a  < エネミーの種類
    ; de < 位置

    ; エネミーの生成
    ld      ix, #_enemy
    ld      c, a
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 11$
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    jr      19$
11$:
    push    de
    ld      a, c
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDefault
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 爆発を生成する
;
EnemyGenerateBomb:

    ; レジスタの保存

    ; ix < エネミー

    ; 爆発の設定
    ld      ENEMY_TYPE(ix), #ENEMY_TYPE_BOMB
    ld      ENEMY_STATE(ix), #ENEMY_STATE_NULL
    ld      ENEMY_FLAG(ix), #ENEMY_FLAG_NULL

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを削除する
;
_EnemyRemove::

    ; レジスタの保存

    ; ix < エネミー

    ; エネミーの削除
    ld      ENEMY_TYPE(ix), #0x00
    ld      hl, #enemyRest
    inc     (hl)

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを殺す
;
_EnemyKill::

    ; レジスタの保存

    ; エネミーの爆発
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$
    cp      #ENEMY_TYPE_BOMB
    jr      z, 19$
    cp      #ENEMY_TYPE_BOSS
    jr      z, 11$
    call    EnemyGenerateBomb
    jr      19$
11$:
    ld     ENEMY_STATE(ix), #0xff
;   jr      19$
19$:
    add     ix, de
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; エネミーのヒットを判定する
;
_EnemyHit::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = ヒット

    ; ヒットカウントの設定
    ld      h, #0x00

    ; ヒット判定
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    push    bc
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$
    bit     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
    jr      z, 19$
    ld      a, ENEMY_POSITION_X(ix)
    sub     e
    jp      p, 11$
    neg
11$:
    cp      ENEMY_SIZE(ix)
    jr      nc, 19$
    ld      a, ENEMY_POSITION_Y(ix)
    sub     d
    jp      p, 12$
    neg
12$:
    cp      ENEMY_SIZE(ix)
    jr      nc, 19$
    dec     ENEMY_LIFE(ix)
    jr      nz, 13$
    ld      c, #BULLET_SIZE_SMALL
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _BulletFirePlayer
    call    EnemyGenerateBomb
    jr      14$
13$:
    ld      a, #SOUND_SE_HIT
    call    _SoundPlaySe
;   jr      14$
14$:
    call    _GameAddScore
    inc     h
19$:
    ld      bc, #ENEMY_LENGTH
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

; エネミーが移動する
;
_EnemyMove::

    ; レジスタの保存

    ; ix < エネミー

    ; X の移動
    ld      a, ENEMY_MOVE_X(ix)
    add     a, ENEMY_SPEED_X(ix)
    jp      p, 10$
    neg
    ld      c, a
    and     #0x0f
    neg
    ld      ENEMY_MOVE_X(ix), a
    ld      a, c
    and     #0xf0
    jr      z, 19$
    rrca
    rrca
    rrca
    rrca
    ld      c, a
    ld      a, ENEMY_POSITION_X(ix)
    sub     c
    jr      c, 80$
    ld      ENEMY_POSITION_X(ix), a
    jr      19$
10$:
    ld      c, a
    and     #0x0f
    ld      ENEMY_MOVE_X(ix), a
    ld      a, c
    and     #0xf0
    jr      z, 19$
    rrca
    rrca
    rrca
    rrca
    add     a, ENEMY_POSITION_X(ix)
    jr      c, 80$
    ld      ENEMY_POSITION_X(ix), a
;   jr      19$
19$:

    ; Y の移動
    ld      a, ENEMY_MOVE_Y(ix)
    add     a, ENEMY_SPEED_Y(ix)
    jp      p, 20$
    neg
    ld      c, a
    and     #0x0f
    neg
    ld      ENEMY_MOVE_Y(ix), a
    ld      a, c
    and     #0xf0
    jr      z, 29$
    rrca
    rrca
    rrca
    rrca
    ld      c, a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     c
    jr      c, 80$
    ld      ENEMY_POSITION_Y(ix), a
    jr      29$
20$:
    ld      c, a
    and     #0x0f
    ld      ENEMY_MOVE_Y(ix), a
    ld      a, c
    and     #0xf0
    jr      z, 29$
    rrca
    rrca
    rrca
    rrca
    add     a, ENEMY_POSITION_Y(ix)
    cp      #0xc8
    jr      nc, 80$
    ld      ENEMY_POSITION_Y(ix), a
;   jr      29$
29$:
    jr      90$

    ; エネミーの削除
80$:
    call    _EnemyRemove
;   jr      90$

    ; 移動の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーがアニメーションする
;
_EnemyAnimation::

    ; レジスタの保存

    ; ix < エネミー
    ; hl < スプライト

    ; スプライトの設定
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$
    ld      a, ENEMY_SPEED_X(ix)
    add     a, #0x80
    and     #0x80
    rrca
    rrca
    rrca
    ld      e, a
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x08
    add     a, e
    rrca
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h
19$:

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
enemyProc:
    
    .dw     _EnemyNull
    .dw     _EnemyBomb
    .dw     _EnemyBoss
    .dw     _EnemyI
    .dw     _EnemyN
    .dw     _EnemyS
    .dw     _EnemyJ

; エネミーの初期値
;
enemyDefault:

    .dw     _enemyNullDefault
    .dw     _enemyBombDefault
    .dw     _enemyBossDefault
    .dw     _enemyIDefault
    .dw     _enemyNDefault
    .dw     _enemySDefault
    .dw     _enemyJDefault

; ジェネレータ
;
enemyGenerateDefault:

    .db     ENEMY_TYPE_I, 0x00, 0x08, 0x08
    .db     ENEMY_TYPE_N, 0x00, 0x06, 0x06
    .db     ENEMY_TYPE_S, 0x00, 0x08, 0x08
    .db     ENEMY_TYPE_J, 0x00, 0x08, 0x08
    .db     ENEMY_TYPE_I, 0x00, 0x08, 0x08
    .db     ENEMY_TYPE_N, 0x00, 0x06, 0x06
    .db     ENEMY_TYPE_S, 0x00, 0x08, 0x08
    .db     ENEMY_TYPE_J, 0x00, 0x08, 0x08

enemyGenerateBoss:

    .db     ENEMY_TYPE_BOSS, 0x01, 0x01, 0x01


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

enemyRest:

    .ds     0x01

; ジェネレータ
;
enemyGenerate:

    .ds     ENEMY_GENERATE_LENGTH

; スプライト
;
enemySprite:

    .ds     0x01
