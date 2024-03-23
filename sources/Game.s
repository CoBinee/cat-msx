; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Back.inc"
    .include    "Player.inc"
    .include    "Shot.inc"
    .include    "Enemy.inc"
    .include    "Bullet.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName

    ; サウンドの停止
    call    _SoundStop

    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir

    ; 背景の初期化
    call    _BackInitialize
    
    ; プレイヤの初期化
    call    _PlayerInitialize

    ; ショットの初期化
    call    _ShotInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; 敵弾の初期化
    call    _BulletInitialize

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 状態の設定
    ld      a, #GAME_STATE_START
    ld      (gameState), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (gameState)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをスタートする
;
GameStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; スタートの描画
    call    GamePrintStart

    ; BGM の再生
    ld      a, #SOUND_BGM_INTRO
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; BGM の監視
    call    _SoundIsPlayBgm
    jr      c, 19$

    ; BGM の再生
    ld      a, #SOUND_BGM_GAME
    call    _SoundPlayBgm

    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

;   ; BGM の再生
;   ld      a, #SOUND_BGM_GAME
;   call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; ヒット判定
    call    GameHit

    ; 入力の更新
    call    GameInput

    ; 背景の更新
    call    _BackUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; ショットの更新
    call    _ShotUpdate

    ; エネミーの生成
    call    _EnemyGenerate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 敵弾の更新
    call    _BulletUpdate

    ; ステータスの更新
    call    GameUpdateStatus

    ; 背景の描画
    call    _BackRender

    ; プレイヤの描画
    call    _PlayerRender

    ; ショットの描画
    call    _ShotRender

    ; エネミーの描画
    call    _EnemyRender

    ; 敵弾の描画
    call    _BulletRender

    ; ステータスの描画
    call    GamePrintStatus

    ; 時間の監視
    ld      hl, (_game + GAME_TIME_0010)
    ld      a, h
    or      l
    jr      nz, 89$
    
    ; ゲームオーバー
    ld      hl, (_game + GAME_TIME_1000)
    ld      a, h
    or      l
    jr      nz, 80$
    ld      a, #GAME_STATE_OVER
    ld      (gameState), a
    jr      89$

    ; 背景のアウト
80$:
    ld      a, l
    cp      #0x01
    jr      nz, 81$
    ld      a, h
    cp      #0x02
    jr      nz, 81$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_BACK_OUT_BIT, (hl)
    jr      89$

    ; ボスの登場
81$:
    ld      a, l
    cp      #0x01
    jr      nz, 89$
    ld      a, h
    or      a
    jr      nz, 89$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_BOSS_BIT, (hl)
    ld      a, #SOUND_BGM_BOSS
    call    _SoundPlayBgm
    jr      89$

    ; 時間監視の完了
89$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; エネミーを殺す
    call    _EnemyKill

    ; 入力のクリア
    xor     a
    ld      (_game + GAME_INPUT), a

    ; BGM の再生
    ld      a, #SOUND_BGM_OVER
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; 背景の更新
    call    _BackUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; ショットの更新
    call    _ShotUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 敵弾の更新
    call    _BulletUpdate

    ; ステータスの更新
    call    GameUpdateStatus

    ; 背景の描画
    call    _BackRender

    ; プレイヤの描画
    call    _PlayerRender

    ; ショットの描画
    call    _ShotRender

    ; エネミーの描画
    call    _EnemyRender

    ; 敵弾の描画
    call    _BulletRender

    ; ステータスの描画
    call    GamePrintStatus

    ; BGM の監視
    call    _SoundIsPlayBgm
    jr      c, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_RESULT
    ld      (gameState), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 結果を表示する
;
GameResult:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; スコアの更新
    ld      de, #(_game + GAME_SCORE_10000000)
    call    _AppUpdateScore

    ; 結果の描画
    push    af
    call    GamePrintResult
    pop     af
    call    c, GamePrintResultUpdate

    ; BGM の再生
    ld      a, #SOUND_BGM_RESULT
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; スペースキーの押下
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 乱数を取得する
;
_GameGetRandom::
    
    ; レジスタの保存
    push    hl
    push    de

    ; a > random number
    
    ; 乱数の生成
    ld      hl, (_game + GAME_RANDOM_L)
    ld      e, l
    ld      d, h
    add     hl, hl
    add     hl, hl
    add     hl, de
    ld      de, #0x2018
    add     hl, de
    ld      (_game + GAME_RANDOM_L), hl
    ld      a, h
    
    ; レジスタの復帰
    pop     de
    pop     hl
    
    ; 終了
    ret

; ヒット判定を行う
;
GameHit:

    ; レジスタの保存

    ; ショットの判定
    ld      iy, #_shot
    ld      b, #SHOT_ENTRY
10$:
    push    bc
    ld      a, SHOT_TYPE(iy)
    or      a
    jr      z, 19$

    ; 位置の取得
    ld      e, SHOT_POSITION_X(iy)
    ld      d, SHOT_POSITION_Y(iy)

    ; ショット→背景
    call    _BackHit
    jr      c, 18$

    ; ショット→エネミー
    call    _EnemyHit
    jr      c, 18$
    jr      19$

    ; ショットの削除
18$:
    ld      SHOT_TYPE(iy), #0x00
;   jr      19$

    ; 次のショットへ
19$:
    ld      bc, #SHOT_LENGTH
    add     iy, bc
    pop     bc
    djnz    10$

    ; プレイヤの判定
    ld      a, (_player + PLAYER_DAMAGE)
    or      a
    jr      nz, 29$

    ; 位置の取得
    ld      de, (_player + PLAYER_POSITION_X)

    ; プレイヤ→エネミー
    call    _EnemyHit
    jr      c, 28$

    ; プレイヤー→敵弾
    call    _BulletHit
    jr      c, 28$
    jr      29$

    ; プレイヤのダメージ
28$:
    ld      a, #PLAYER_DAMAGE_FRAME
    ld      (_player + PLAYER_DAMAGE), a
;   jr      29$

    ; プレイヤの判定の完了
29$:

    ; レジスタの復帰

    ; 終了
    ret

;  入力を更新する
;
GameInput:

    ; レジスタの保存

    ; 手動での操作
    call    _AppIsReplayOperate
    jr      c, 110$
100$:
    ld      c, #GAME_INPUT_NULL
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 101$
    set     #GAME_INPUT_UP_BIT, c
101$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 102$
    set     #GAME_INPUT_DOWN_BIT, c
102$:
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 103$
    set     #GAME_INPUT_LEFT_BIT, c
103$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 104$
    set     #GAME_INPUT_RIGHT_BIT, c
104$:
    ld      hl, #(_game + GAME_INPUT_FIRE_REPEAT)
    ld      a, (_input + INPUT_BUTTON_SPACE)
    or      a
    jr      nz, 105$
    ld      a, #(GAME_INPUT_FIRE_REPEAT_INTERVAL - 0x01)
    jr      106$
105$:
    inc     (hl)
    ld      a, (hl)
    cp      #GAME_INPUT_FIRE_REPEAT_INTERVAL
    jr      c, 106$
    set     #GAME_INPUT_FIRE_BIT, c
    xor     a
106$:
    ld      (hl), a
    ld      a, (_input + INPUT_BUTTON_SHIFT)
    dec     a
    jr      nz, 107$
    set     #GAME_INPUT_CHANGE_BIT, c
107$:
    ld      a, c
    call    _AppRecordOperate
    ld      a, c
    jr      190$

    ; リプレイの再生
110$:
    call    _AppReplayOperate
;   jr      190$

    ; 操作の完了
190$:
    ld      (_game + GAME_INPUT), a

    ; 乱数を混ぜる
    and     #(GAME_INPUT_LEFT | GAME_INPUT_UP)
    call    nz, _GameGetRandom

    ; レジスタの復帰

    ; 終了
    ret

; ステータスを更新する
;
GameUpdateStatus:

    ; レジスタの保存

    ; 時間の更新
    ld      hl, #(_game + GAME_TIME_0001)
    ld      b, #(GAME_TIME_LENGTH)
10$:
    ld      a, (hl)
    or      a
    jr      nz, 18$
    ld      (hl), #0x09
    dec     hl
    djnz    10$
    xor     a
    ld      b, #(GAME_TIME_LENGTH)
11$:
    inc     hl
    ld      (hl), a
    djnz    11$
    jr      19$
18$:
    dec     (hl)
;   jr      19$
19$:

    ; 倍率の更新
    ld      hl, #(_game + GAME_RATE_00_01)
    ld      bc, #0x0a01
    ld      a, (hl)
    sub     #0x07
    jr      nc, 28$
    add     a, b
    ld      (hl), a
    dec     hl
    ld      a, (hl)
    sub     c
    jr      nc, 28$
    add     a, b
    ld      (hl), a
    dec     hl
    ld      a, (hl)
    sub     c
    jr      nz, 21$
    dec     hl
    ld      a, (hl)
    inc     hl
    or      a
    jr      z, 20$
    xor     a
    jr      28$
20$:
    ld      (hl), c
    xor     a
    inc     hl
    ld      (hl), a
    inc     hl
    jr      28$
21$:
    jr      nc, 28$
    add     a, b
    ld      (hl), a
    dec     hl
    ld      a, (hl)
    sub     c
28$:
    ld      (hl), a
;   jr      29$
29$:

    ; レジスタの復帰

    ; 終了
    ret

; ステータスを描画する
;
GamePrintStatus:

    ; レジスタの保存

    ; 表示エリアのクリア
    ld      hl, #gameStatusPatternName
    ld      de, #(_patternName + 0x0000)
    ld      bc, #0x0020
    ldir

    ; 時間の表示
    ld      hl, #(_patternName + 0x0001)
    ld      de, #(_game + GAME_TIME_1000)
    ld      b, #(GAME_TIME_LENGTH - 0x01)
10$:
    ld      a, (de)
    or      a
    jr      nz, 11$
    ld      (hl), a
    inc     de
    inc     hl
    djnz    10$
11$:
    ld      a, #0x01
    add     a, b
    ld      b, a
12$:
    ld      a, (de)
    add     a, #0x10
    ld      (hl), a
    inc     de
    inc     hl
    djnz    12$

    ; 得点の表示
    ld      hl, #(_patternName + 0x000b)
    ld      de, #(_game + GAME_SCORE_10000000)
    ld      b, #(GAME_SCORE_LENGTH - 0x01)
20$:
    ld      a, (de)
    or      a
    jr      nz, 21$
    ld      (hl), a
    inc     de
    inc     hl
    djnz    20$
21$:
    ld      a, #0x01
    add     a, b
    ld      b, a
22$:
    ld      a, (de)
    add     a, #0x10
    ld      (hl), a
    inc     de
    inc     hl
    djnz    22$

    ; 倍率の表示
    ld      hl, #(_patternName + 0x001b)
    ld      de, #(_game + GAME_RATE_10_00)
    ld      a, (de)
    or      a
    jr      z, 30$
    add     a, #0x10
30$:
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    add     a, #0x10
    ld      (hl), a
    inc     de
    inc     hl
    inc     hl
    ld      a, (de)
    add     a, #0x10
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    add     a, #0x10
    ld      (hl), a

    ; パターンネームの登録
    ld      hl, #(_patternName + 0x0000)
    ld      (_patternNameLine + 0x0000), hl

    ; レジスタの復帰

    ; 終了
    ret

; スコアを加算する
;
_GameAddScore::

    ; レジスタの保存
    push    hl

    ; スコアの加算
    ld      hl, #(_game + GAME_SCORE_00000001)
    ld      de, #(_game + GAME_RATE_00_01)
    ld      b, #(GAME_RATE_LENGTH)
    or      a
10$:
    ld      a, (de)
    adc     a, (hl)
    ld      (hl), a
    sub     #0x0a
    jr      c, 11$
    ld      (hl), a
11$:
    dec     de
    dec     hl
    ccf
    djnz    10$
    ld      bc, #(((GAME_SCORE_LENGTH - GAME_RATE_LENGTH) << 8) | 0x00)
12$:
    ld      a, (hl)
    adc     a, c
    ld      (hl), a
    sub     #0x0a
    jr      c, 13$
    ld      (hl), a
13$:
    dec     hl
    ccf
    djnz    12$
    jr      nc, 19$
    ld      a, #0x09
    ld      b, #GAME_SCORE_LENGTH
14$:
    inc     hl
    ld      (hl), a
    djnz    14$
19$:

    ; 倍率の増加
    ld      hl, #(_game + GAME_RATE_01_00)
    ld      a, (hl)
    inc     a
    cp      #0x0a
    jr      c, 28$
    ld      (hl), #0x00
    dec     hl
    ld      a, (hl)
    inc     a
    cp      #0x0a
    jr      c, 28$
    ld      a, #0x09
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
28$:
    ld      (hl), a
;   jr      29$
29$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; スタートを描画する
;
GamePrintStart:

    ; レジスタの保存

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; スタートの描画
    ld      hl, #gameStartPatternName
    ld      de, #(_patternName + 0x016e)
    ld      bc, #0x0004
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; リザルトを描画する
;
GamePrintResult:

    ; レジスタの保存

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; 結果の描画
    ld      hl, #gameResultPatternNameResult
    ld      de, #(_patternName + 0x00ce)
    ld      bc, #0x0003
    ldir
    ld      hl, #gameResultPatternNameScore
    ld      de, #(_patternName + 0x0189)
    ld      bc, #0x000e
    ldir
    ld      hl, #gameResultPatternNameTop
    ld      de, #(_patternName + 0x01c9)
    ld      bc, #0x000e
    ldir

    ; スコアの描画
    ld      hl, #(_patternName + 0x0018d)
    ld      de, #(_game + GAME_SCORE_10000000)
    ld      b, #GAME_SCORE_LENGTH
    call    10$
    ld      hl, #(_patternName + 0x001cd)
    ld      de, #(_appScore + APP_SCORE_10000000)
    ld      b, #APP_SCORE_LENGTH
    call    10$
    jr      19$
10$:
    dec     b
11$:
    ld      a, (de)
    or      a
    jr      nz, 12$
    ld      (hl), a
    inc     de
    inc     hl
    djnz    11$
12$:
    ld      a, #0x01
    add     a, b
    ld      b, a
13$:
    ld      a, (de)
    add     a, #0x10
    ld      (hl), a
    inc     de
    inc     hl
    djnz    13$
    ret
19$:

    ; レジスタの復帰

    ; 終了
    ret

GamePrintResultUpdate:

    ; レジスタの保存

    ; 更新の描画
    ld      hl, #gameResultPatternNameUpdate
    ld      de, #(_patternName + 0x022a)
    ld      bc, #0x000c
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameStart
    .dw     GamePlay
    .dw     GameOver
    .dw     GameResult

; ゲームの初期値
;
gameDefault:

    .db     GAME_REQUEST_NULL
    .db     GAME_FRAME_NULL
    .dw     GAME_RANDOM_SEED
    .db     0x03 ; GAME_TIME_NULL
    .db     0x00 ; GAME_TIME_NULL
    .db     0x00 ; GAME_TIME_NULL
    .db     0x00 ; GAME_TIME_NULL
    .db     0x00 ; GAME_SCORE_NULL
    .db     0x00 ; GAME_SCORE_NULL
    .db     0x00 ; GAME_SCORE_NULL
    .db     0x00 ; GAME_SCORE_NULL
    .db     0x00 ; GAME_SCORE_NULL
    .db     0x00 ; GAME_SCORE_NULL
    .db     0x00 ; GAME_SCORE_NULL
    .db     0x00 ; GAME_SCORE_NULL
    .db     0x00 ; GAME_RATE_NULL
    .db     0x01 ; GAME_RATE_NULL
    .db     0x00 ; GAME_RATE_NULL
    .db     0x00 ; GAME_RATE_NULL
    .db     GAME_INPUT_NULL
    .db     GAME_INPUT_FIRE_REPEAT_NULL

; ステータス
;
gameStatusPatternName:

    .db     0x1a, 0x10, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x05, 0x06, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x1b, 0x10, 0x10, 0x1c, 0x10, 0x10

; スタート
;
gameStartPatternName:

    .db     0x01, 0x02, 0x03, 0x04

; 結果
;
gameResultPatternNameResult:

    .db     0x09, 0x0a, 0x0b

gameResultPatternNameScore:

    .db     0x01, 0x07, 0x08, 0x00, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x05, 0x06

gameResultPatternNameTop:

    .db     0x04, 0x0a, 0x0c, 0x00, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x05, 0x06

gameResultPatternNameUpdate:

    .db     0x04, 0x0a, 0x0c, 0x01, 0x07, 0x08, 0x00, 0x07, 0x0d, 0x0e, 0x06, 0x0f


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
gameState:
    
    .ds     1

; ゲーム
;
_game:

    .ds     GAME_LENGTH
