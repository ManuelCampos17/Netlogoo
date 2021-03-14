;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals
[
  pontos-verde   ;; score da equipa que joga da esquerda para a direita
  pontos-azul    ;; score da equipa que joga da direita para a esquerda
  cor-esquerda      ;; cor da equipa que joga da esquerda para a direita
  cor-direita       ;; cor da equipa que joga da direita para a esquerda
  cor-chao          ;; cor do chao

  _rod_glob_ShareTargetPatch ;; Quando banonama pode partilhar informacao com outro, usam estas variaveis
  _rod_glob_ShareWhoIAm
]


;;
;; -------------  a definicao das equipas (breeds)  ----------------
;;

breed [gauleses gaules]

breed [strumpfs strumpf]

breed [bananomans banano]

;;
; ..................................................................

;; ------------  variaveis de todos os jogadores

;; a variavel transporta regista qual a cor do disco que os jogadores transportam
;; Tem como valor a cor do disco que transportam
;; Se nao transportam tem o valor -1

;; A variavel camisola indica a equipa a cor da camisola dos jogadores
;;
turtles-own []

;;
;; ------------ variaveis locais de cada equipa  -------------------

;; variaveis dos Strumpfs
;;
strumpfs-own []

;; variaveis dos gauleses
;;
gauleses-own []

;; variaveis bananomas
bananomans-own
[
  _rod_TargetPatch
  _rod_RedPatchesInRadius
  _rod_AgentsInRadius
]

;; -----------------------   Inicializacao das variaveis de cada equipa  ----------------------------
;;
;; Inicializa as variaveis dos metralhas
;;
to inicializa-vars-gauleses
  set shape "butterfly"
end

;; Inicializa as variaveis dos daltons
;;
to inicializa-vars-Strumpfs
end

to inicializa-vars-bananomans
set shape "person"
end

;;
;; .................................................................

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Configura ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Botao de configuracao
;; Cria o mundo depois de definir as equipas e jogadores e
;; de ter inicializaod as variaveis globais
;;
to configura
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  corrige-num-baloes
  inicializa-variaveis-globais
  configura-jogadores
  define-equipas
  inicializa-baloes
end

;; O numero de baloes deve ser par por questoes de simetria do espaco
;; Incrementam-se numa unidade caso seja um numero impar.
;;
to corrige-num-baloes
  if num-baloes mod 2 = 1 [set num-baloes num-baloes + 1]
end

;; Inicializa as variaveis globais
;;
to inicializa-variaveis-globais
  set cor-esquerda green
  set cor-direita blue
  set pontos-verde 0
  set pontos-azul 0
  set cor-chao black
end


;; Configura os jogadores das duas equipas
;;
to configura-jogadores
  set-default-shape turtles "bug"
  crt 2 * jogadores [
    set size 2  ;; easier to see this way
    rt random-float 360
    ]

   ask  turtles
    [ifelse (who < jogadores)
      [ set color cor-direita]
      [ set color cor-esquerda]]
end

;; Atribui a cada uma das equipas a sua cor
;; Por omissao, os daltons sao verdes (esquerda) e os metralhas sao vermelhos (direita)
;;
to define-equipas
ask turtles [ifelse (color = cor-esquerda)
              [set breed (a-breed equipaVerde) setxy -1 * max-pxcor / 2 0]
              [if color = cor-direita [set breed (a-breed equipaAzul) setxy max-pxcor / 2 0]]
             inicializa-vars]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Configuracao das equipas todas


;; Transforma os nomes das equipas nas breeds
;;
to-report a-breed [nome]
  if nome = "Strumpfs"        [report strumpfs]
  if nome = "Gauleses"      [report gauleses]
  if nome = "Bananomans"  [report bananomans]
end

;; Inicializa as variaveis de cada equipa
;;
to inicializa-vars
  if breed = gauleses      [inicializa-vars-gauleses stop]
  if breed = strumpfs        [inicializa-vars-Strumpfs stop]
  if breed = bananomans   [inicializa-vars-bananomans stop]
end

;; Executa o comportamento do jogador
;; depende da equipa a que pertence.
;;
to executa
  if breed = gauleses    [exec-gauleses stop]
  if breed = Strumpfs    [exec-strumpfs stop]
  if breed = bananomans [exec-bananomans stop]
end


;; ---------------------------------------------------------------------
;; ----------------------  Coloca os baloes  ---------------------------

;; Distribui os baloes pelo espaco
;; Primeiro na area da esquerda
;; Depois o espelho 'a direita
;;
to inicializa-baloes
  coloca-baloes-esq
  coloca-baloes-dir
end

;;cria varios random spots
;;
to cria-spots
  repeat num-spots / 2 [cria-random-spot]
end


;; Cria um spot de raio random (entre 1 e 10)
;; centro escolhido ao calha
;;
to cria-random-spot
  cria-spot random max-raio-spot + 1
end


;; Faz spot de raio r, centro escolhido ao calha
;;
to cria-spot [r]
  let centro-spot one-of patches with [pxcor < 0]
  ask patches [if distance centro-spot < r [set pcolor red]]
end

;; Apaga os baloes no lado direito
;;
to apaga-baloes-direitos
  ask patches [if (pxcor >= 0) and (pcolor = red) [set pcolor cor-chao]]
end

;; Dissemina baloes pela area da esquerda
;;
to dissemina-baloes
  let baloes-spot count patches with [pcolor = red]
  if baloes-spot < num-baloes / 2
    [ask n-of (num-baloes / 2 - baloes-spot) (patches with [(pcolor != red) and (pxcor < 0)]) [set pcolor red ]]
end

;; Coloca os baloes na zona da esquerda
;;
to coloca-baloes-esq
  cria-spots
  apaga-baloes-direitos
  let baloes-em-excesso count patches with [pcolor = red] - num-baloes / 2
  ifelse baloes-em-excesso > 0
    [apaga-baloes-em-excesso baloes-em-excesso]
    [dissemina-baloes]
end

;; Apaga os baloes em excesso na area da esquerda
;;
to apaga-baloes-em-excesso [excesso]
 ask n-of excesso patches with [pcolor = red ] [set pcolor black]
end

;; Define a posicao dos baloes 'a esquerda
;;
to coloca-baloes-dir
  ask patches [if pcolor = red [let x pxcor let y pycor ask patch (-1 * x) y [set pcolor red]]]
end


;; -----------------------------------------------------------------------------------------

;; Comamndo que manda executar o comportamento dos varios jogadores
;; ate esgotar o tempo ou se rebentarem todos os baloes
;;
to go ; turtle procedure
  ifelse (ticks > limite-tempo) or (pontos-verde + pontos-azul = num-baloes)
       [stop]
       [ask turtles [executa]
        tick]
end


;; Comportamento dos Gauleses
;;
to exec-gauleses
  ifelse sobre-balao?
    [rebenta]
    [vagueia-zig-zag-gauleses]
end

;; Comportamento dos Strumpfs
;;
to exec-strumpfs
  ifelse sobre-balao?
    [rebenta]
    [vagueia-zig-zag-strumpfs]
end

to exec-bananomans
  ifelse sobre-balao?
  [rebenta]
  [vagueia-zig-zag-bananomans]
end
;; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; --------------------------  Funcoes auxiliares
;;

;; rebenta o balao
;;
to rebenta
;  explode-music
  set pcolor black
  act-score color 1
end



;; -----------------------------  avanca

;; mover-se x unidades para a frente (se x for positivo e menor do que 1) e
;; se nao for parar em cima dos limites do campo.
;;
to avanca
  fd 1
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; jogador sobre um disco?
;;
to-report sobre-balao?
  report (pcolor = red)
end


;;;;;; Actualiza os scores

;; actualiza o score de uma determinada cor (decrementa ou incrementa)
;;
to act-score [cor-camisola delta]
  ifelse color = cor-esquerda
    [set pontos-verde pontos-verde + delta]
    [set pontos-azul pontos-azul + delta]
end



;; Vagueio ao acaso: avanco uma unidade e rodo aleatoriamente
;;
to vagueia-zig-zag-strumpfs ; turtle procedure
  avanca
  rt random-float 60 - random-float 60
end

to vagueia-zig-zag-gauleses ; turtle procedure
  avanca
  rt random-float 60 - random-float 60
end

;; Comentarios longos para o Manel ;; ee = e com acento
;; Tudo feito por Rodrigo Amaral, Colegio Moderno de 2004 a 2011 (do infatario ate 6 ano), mas quem ee que usa netlogo para ensinar programacao????? onde esta python???, C++ with Arduino???, C## ????
to vagueia-zig-zag-bananomans ; turtle procedure

  ;; Pesquisa na grande lista dos patches in radius uma que seja vermelha, any? usado porque in-radius da um agentset [1, 4, 6, ...], em vez de um unico valor
  set _rod_RedPatchesInRadius (patches in-radius raio-visao with [pcolor = red]) ;; patches dentro do radio, quais sao vermelho, da-me um agentset
  set _rod_TargetPatch (min-one-of _rod_RedPatchesInRadius [distance myself]) ;; dos patches do agentset, qual o mais perto
  set _rod_AgentsInRadius (bananomans in-radius raio-visao) ;; dame um agentset com todos os banonamas in radius

  if (any? _rod_AgentsInRadius)
  [
    while [any? _rod_AgentsInRadius] ;; Verifica se existe algum banonama na visao, se existar da loop
    [
      ask (one-of _rod_AgentsInRadius) ;; Pergunta a um dos agents na visao, para partilhar sua TargetPatch, e quem ele ee
      [
        set _rod_glob_ShareTargetPatch _rod_TargetPatch
        set _rod_glob_ShareWhoIAm self
      ]

      if (_rod_TargetPatch = _rod_glob_ShareTargetPatch) ;; Se a TargetPatch deste bananoman for igual aa target patch partlihada,
      [
        ;; Remove esse patch do Red Patches in radius agentset, e calcula novo Target Patch
        set _rod_RedPatchesInRadius _rod_RedPatchesInRadius with [self != _rod_glob_ShareTargetPatch]
        set _rod_TargetPatch (min-one-of _rod_RedPatchesInRadius [distance myself])
      ]

      set _rod_AgentsInRadius _rod_AgentsInRadius with [self != _rod_glob_ShareWhoIAm] ;; Remove esse agent from agentset
    ]
  ]

  ifelse((is-patch? _rod_TargetPatch))
    [face _rod_TargetPatch]
    [set heading (heading + (15 - (random 40)))]

  fd 1
end


@#$#@#$#@
GRAPHICS-WINDOW
389
12
1102
726
-1
-1
5.0
1
10
1
1
1
0
1
1
1
-70
70
-70
70
1
1
1
ticks
30.0

SLIDER
188
16
360
49
jogadores
jogadores
0
100
1.0
1
1
NIL
HORIZONTAL

BUTTON
21
397
157
448
NIL
configura
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
177
397
266
447
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
7
93
179
126
num-baloes
num-baloes
0
max-pxcor * max-pycor
3528.0
1
1
NIL
HORIZONTAL

MONITOR
34
282
171
363
score-Verde
pontos-verde
0
1
20

SLIDER
187
55
359
88
Limite-tempo
Limite-tempo
0
10000
4000.0
1
1
NIL
HORIZONTAL

MONITOR
206
281
344
362
score-Azul
pontos-azul
0
1
20

SLIDER
186
95
358
128
raio-visao
raio-visao
0
20
10.0
1
1
NIL
HORIZONTAL

CHOOSER
33
237
171
282
EquipaVerde
EquipaVerde
"Gauleses" "Strumpfs" "Bananomans"
2

CHOOSER
205
236
343
281
EquipaAzul
EquipaAzul
"Gauleses" "Strumpfs" "Bananomans"
1

BUTTON
280
397
368
448
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
4
20
176
53
num-spots
num-spots
0
100
12.0
1
1
NIL
HORIZONTAL

MONITOR
61
163
185
208
Numero de Baloes
count patches with [pcolor = red]
17
1
11

SLIDER
5
56
177
89
max-raio-spot
max-raio-spot
1
max-pxcor
20.0
1
1
NIL
HORIZONTAL

MONITOR
240
162
312
207
Tempo
ticks
17
1
11

@#$#@#$#@
## O QUE E'?

Este modelo Netlogo corresponde ao jogo do furaBaloes.  
Temos duas equipas que partem das tocas respectivas (simetricas) e tentam localizar e furar o maior numero de baloes (a vermelho). 

Os baloes sao distribuidos ao acaso (de forma simetrica).  
Existem manchas com baloes e tambem existem baloes disseminados.  
Temos um slider que indica o numero de baloes, o numero de manchas e o max do raio das manchas. As machas terao um raio aleatorio cujo maximo e' esse max.  
Se depois criarmos as machas ainda n�o tivermos preenchido o numero de baloes desejado entao o resto dos baloes sao disseminados pelo espa�o.  
Mas, se as machas ultrapassarem o numero de baloes desejado entao teremos que apgara ao acaso os baloes em excesso.  
Se desejarmos um numero impar de baloes o slider e' corrigido para um numero par.  
O Jogo acaba quando o tempo limite para o jogo foi ultrapassado ou quando se rebentaram todos os baloes. Verifica-se o score de cada equipa: numero de baloes rebentados. 

Um balao corresponde a um patch pintado de vermelho. Os jogadores so' podem rebentar os baloes quando estiverem sobre o patch correspondente ao bal�o.

Cada jogador pode ver e comunicar com os jogadores vizinhos que estejam num raio limitado (definido pelo utilizador). Esse raio define a percepcao dos baloes e dos outros jogadores.

Os jogadores tem 2 accoes atomicas (fornecidas por nos): avanca e rebenta. O movimento e' sempre para a frente e e' sempre de 1 unidade.

Em cada unidade de tempo, um jogador executa o seu comportamento mas apenas pode realizar no maximo uma accao atomica. Isso quer dizer que, por exemplo, nao pode rebentar um balao e avancar um passo, nem avancar dois passos.

As equipas correspondem a turtles de um certo breed. Podem declarar-se variaveis especificas dos jogadores de cada equipa e os jogadores de cada equipa podem modificar essas variaveis trocando informacao.

Fornecemos duas equipas: os Gauleses e os Strumpfs, que sao equipas fraquinhas mas que dao o pontape' de arranque para a criacao de melhores equipas.

Cada equipa tem uma cor, a da esquerda e' o verde e a da direita o vermelho.

As Equipas

Nem os Gauleses nem os strumpfs usam a percepcao para alem do patch onde estao!

Os Gauleses

Estes estao com demasiada pocao magica e andam 'as voltas, afastando-se devagarinho da toca, mas rebentando os baloes quando estao exactamente sobre eles.

Os strumpfs

Estes zigzagueiam ate' encontrarem os baloes que depois rebentam.

                              

## COMO USAR

Podemos declarar quantos baloes queremos, quantos spots (manchas com um raio maximo) e quantos jogadores possui cada equipa. Vejam que em alguns casos podemos ter mais baloes do que os que foram definidos, quando os spots desejados ultrapassam o numero de baloes

Podemos definir o raio de percepcao dos jogadores e o limite de duracao do jogo.

O relogio aparece no ecran juntamente com o nome, o campo e o score de cada equipa.

Temos um botao <<configura>> para inicializar o relogio e distribuir simetricamente os discos e os jogadores de cada equipa.

Tempo um botao (forever) <<go>> para executar passo a passo todos os comportamentos de todos os jogadores.

Em cada tic do relogio todos os jogadores executam o respectivo comportamento mas em que estao limitados a uma unica accao atomica de movimento e nunca podem andar mais do que 1 unidade, podendo apenas andar para a frente no sentido de orientacao


## CREDITOS E REFERENCIAS

Este modelo foi feito por Paulo Urbano, da FCUL, no ambito do projecto Ciencia Viva.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
