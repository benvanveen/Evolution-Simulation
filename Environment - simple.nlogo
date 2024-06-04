; My model is an example of phenomena-based modeling, where i intend to replicate the effect of real life adaptation through a set of rules given to agents. Here our reference pattern is the tooth sharpness and wool thickness' increasing with time.
; I also designed this model with a top down design, as i already understand how wolves, sheep and grass interact in the real world.



; TURTLE TYPES:
breed[sheeps sheep]
breed[wolves wolf]

;AGENT PROPERTIES:

; SHEEP PROPERTIES
sheeps-own[
  energy
  cooldown
  wool-thickness
]

; WOLF PROPERTIES
wolves-own[
  energy
  cooldown
  teeth-sharpness
  target
]

;AGENT BEHAVIOURS:
to setup
  clear-all
  reset-ticks

  setup-sheeps
  setup-grass
  setup-wolves
end

to go
  ask patches[
    regrow-grass
  ]
  ask sheeps[
    move-sheep
    eat-sheeps
    mate-sheep
  ]
  ask wolves[
    mate-wolves
    move-wolves
    eat-wolves
  ]
  ask turtles [
    starve
  ]
  tick
end


;SETUP FUNCTIONS FOR AGENTS


to setup-sheeps
  create-sheeps num-sheeps[

    ; the turtles are created at random points in the environment
    set shape "sheep"
    setxy random-pxcor random-pycor
    set energy sheep-birth-energy
    set cooldown 0

    ; As the sheeps wool thickness and the wolves teeth sharpness increase the sheep will get whiter and the wolves darker, allowing us to see the progresion
    ; in the change in wool thickness other than just by analysing the plot, although past a wool thickness of 200 they will no longer become lighter
    set wool-thickness random 100
    set color scale-color white wool-thickness 0 300
    ]
end

to setup-grass
  ask patches [ set pcolor green ]
end

to setup-wolves
  create-wolves num-wolves[

    ; the turtles are created at random points in the environment
    set shape "wolf"
    setxy random-pxcor random-pycor
    set energy wolf-birth-energy
    set size 1.2
    set cooldown 0

    ; As the sheeps wool thickness and the wolves teeth sharpness increase the sheep will get whiter and the wolves darker, allowing us to see the progresion in
    ; the change in teeth sharpness other than just by analysing the plot, although past a teeth sharpness of 200 they will no longer become darker
    set teeth-sharpness random 100
    set color scale-color black (300 - teeth-sharpness) 0 300
  ]
end

;GRASS BEHAVIOUR

; the regow grass function replensihes grass eaten by the sheep turtles.
to regrow-grass
  if pcolor = brown [
    if random-float 1 < growthRate-grass[
      set pcolor green
    ]
  ]
end


;TURTLE BEHAVIOUR

; the starve function causes animals to die when their hunger (energy) gets critically low
to starve
  if energy < 1[
    die
  ]
end

;WOLF BEHAVIOUR

; this function describes the movement of the wolf turtles
to move-wolves
  ask wolves [

   ; causes the wolves to hunt sheep and move towards potential wolf mates, although caused issues as the sheep where often hunted to extinction and wolves clustered execcively
   if wolf-packs[
    ;if any? other wolves in-radius vision-wolves ;and cooldown < 0
    ;  [
    ;  set target min-one-of wolves [ distance myself ]
    ;  face target
    ;  forward 1
    ;  set energy energy - 1
     ; set cooldown cooldown - 1

      ifelse any? other wolves in-radius vision-wolves and count wolves-here < 2[

      set heading (towards one-of other wolves in-radius vision-wolves)
      forward 1
      set energy energy - 1
      set cooldown cooldown - 1
      ]
      [
;     causes the wolves to randomly move around the environment

        right random 360
        forward 1

        set energy energy - 1
        set cooldown cooldown - 1
    ]

    ]

    if wolf-hunt[
    if any? sheeps in-radius vision-wolves [
      set heading (towards one-of sheeps in-radius vision-wolves)
      forward 1
      set energy energy - 1
      set cooldown cooldown - 1
    ]]

    if wolf-hunt = false and wolf-packs = false[
;     causes the wolves to randomly move around the environment

        right random 360
        forward 1

        set energy energy - 1
        set cooldown cooldown - 1
    ]
  ]
end

; function that causes wolves to "eat" sheeps on the same patch as them
to eat-wolves
  let prey one-of sheeps-here
  if prey != nobody and [random wool-thickness] of prey < random teeth-sharpness
    [ ask prey [ die ]
      set energy energy + wolf-gain-from-food ]
end

; allows wolves to mate and create new wolves with those on the same patch as them, necicary for "evolution" to occur in the envioronment
to mate-wolves
  ask wolves[
    if random-float 1 < reproductionRate-wolves and cooldown < 1  and count wolves < 50[
    ask other wolves-here[
        hatch-wolves 1 [
          set shape "wolf"
          set energy wolf-birth-energy
          set cooldown 45 + random 15
          set teeth-sharpness teeth-sharpness + random wolf-mutation-multiplier - random wolf-mutation-multiplier
          set color scale-color black (300 - teeth-sharpness) 0 300
        ]
       set cooldown 20 + random 15
      ]
      set cooldown 20 + random 15
    ]
  ]
end

;SHEEP BEHAVIOUR
to move-sheep
  ask sheeps [
    ;ifelse any? other sheeps in-radius vision-sheeps and energy > 20 and cooldown < 0[
    ;
    ;  set heading (towards one-of other sheeps in-radius vision-sheeps)
    ;  forward 1
    ;  set energy energy - 1
    ;  set cooldown cooldown - 1
    ; ]
    ;[
        right random 360
        forward 1
        set energy energy - 1
      set cooldown cooldown - 1
      ;]
  ]
end

; allows sheep to mate and create new sheep with those on the same patch as them, necicary for "evolution" to occur in the envioronment
to mate-sheep
  ask sheeps[
    ask other sheeps-here[
      let mum-wool wool-thickness
      if random-float 1 < reproductionRate-sheeps and cooldown < 1[
        hatch-sheeps 1 [

          set shape "sheep"

          ; the amount of steps a new born sheep can take without food before starving
          set energy sheep-birth-energy

          ; the amount of ticks before the baby sheep can reproduce or until they "mature", to stop sheep explosions
          set cooldown 5 + random 15

          ; the sheep-mutation-multiplier controls the potential difference in the childs wool-thickness gene from their parents
          set wool-thickness mum-wool + random sheep-mutation-multiplier - random sheep-mutation-multiplier

          ; visualising the wool-thickness in the environment
          set color scale-color white wool-thickness 0 300
          if wool-thickness < 10[
             set wool-thickness 10
          ]
        ]
        ; the amount of ticks before the sheep can reproduce again, to stop sheep explosions
        set cooldown 25 + random 15
      ]
      ; the amount of ticks before the sheep can reproduce again, to stop sheep explosions
      set cooldown 25 + random 15
    ]
  ]
end

; allows sheep to eat the grass below them, the removal of grass also helps prevent the overpopulation of sheeps as whenn there are an eccese of sheep the lack of grass will cause starvation
to eat-sheeps
  ask sheeps [
    if pcolor = green [

      ; if a sheep is hungry (ten steps before starvation) they will "eat" the grass patch agent beneath them
      if energy < 10 [
        set pcolor brown
        set energy energy + sheep-gain-from-food
      ]
    ]
  ]
end

;MEASURES:

; shows us the amount of wolf and sheep turtles alive in the environment and the average teeth sharpness and wool thickness, useful for seeing how the average teeth sharpness and wool thickness can impact the populations
to-report population-sheeps
  let pop-sheeps count sheeps
  report pop-sheeps
end

to-report population-wolves
  let pop-wolves count wolves
  report pop-wolves
end


to-report evolution-sheep
  report mean [wool-thickness] of sheeps
end

to-report evolution-wolves
  report mean [teeth-sharpness] of wolves
end
@#$#@#$#@
GRAPHICS-WINDOW
62
21
420
380
-1
-1
10.61
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
487
108
550
141
setup
setup
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
803
30
975
63
num-sheeps
num-sheeps
0
200
61.0
1
1
NIL
HORIZONTAL

BUTTON
485
62
548
95
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
1020
29
1192
62
growthRate-grass
growthRate-grass
0
1
0.28
0.01
1
NIL
HORIZONTAL

SLIDER
803
98
998
131
reproductionRate-sheeps
reproductionRate-sheeps
0
1
0.19
0.01
1
NIL
HORIZONTAL

PLOT
854
366
1054
516
Sheep Population
Time
Number of Sheep
0.0
10.0
0.0
50.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot population-sheeps"

SLIDER
585
30
757
63
num-wolves
num-wolves
0
200
27.0
1
1
NIL
HORIZONTAL

SLIDER
583
131
755
164
wolf-gain-from-food
wolf-gain-from-food
0
300
300.0
1
1
NIL
HORIZONTAL

SLIDER
803
130
975
163
sheep-gain-from-food
sheep-gain-from-food
0
100
18.0
1
1
NIL
HORIZONTAL

SLIDER
584
97
779
130
reproductionRate-wolves
reproductionRate-wolves
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
584
63
756
96
wolf-birth-energy
wolf-birth-energy
0
3000
1007.0
1
1
NIL
HORIZONTAL

SLIDER
803
64
975
97
sheep-birth-energy
sheep-birth-energy
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
583
165
755
198
vision-wolves
vision-wolves
0
30
3.0
1
1
NIL
HORIZONTAL

SLIDER
582
200
754
233
wolf-max-food
wolf-max-food
0
500
500.0
1
1
NIL
HORIZONTAL

PLOT
855
216
1053
358
sheep-thickness
NIL
NIL
0.0
10000.0
0.0
300.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot evolution-sheep"

PLOT
1060
216
1257
358
wolf-sharpness
NIL
NIL
0.0
10000.0
0.0
300.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot evolution-wolves"

PLOT
1059
367
1259
517
Wolf Population
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot population-wolves"

SLIDER
803
164
987
197
sheep-mutation-multiplier
sheep-mutation-multiplier
0
50
5.0
1
1
NIL
HORIZONTAL

SLIDER
583
235
755
268
wolf-mutation-multiplier
wolf-mutation-multiplier
0
50
5.0
1
1
NIL
HORIZONTAL

SWITCH
555
273
669
306
wolf-packs
wolf-packs
1
1
-1000

SWITCH
673
274
782
307
wolf-hunt
wolf-hunt
1
1
-1000

@#$#@#$#@
## Driving question:

How does survival of the fittest cause a change of traits in animals?

## DESCRIPTION

My model is an example of phenomena-based modeling, where i intend to replicate the effect of real life adaptation through a set of rules given to agents. Here our reference pattern is the tooth sharpness and wool thickness' increasing with time. I also designed this model with a top down design, as i already understand how wolves, sheep and grass interact in the real world.

## AGENT TYPES:

TURTLES: 
wolves - agent thats survival depends on eating the sheep agents
sheep - agent that is eaten by the wolf agents and eats the grass agents

PATCHES: 
Grass - eaten by the sheep agents

## AGENT PROPERTIES:

WOLF PROPERTIES: 
energy - the amount of steps they can take before the starve function is called and the agent dies
cooldown - the amount of steps that must be taken before the agent can reproduce, increased when an agent reproduces
teeth-sharpness - the higher the teeth-sharpness the higher the chance that the wolf agent will successfully eat a sheep agent
target

SHEEP PROPERTIES: 
energy - the amount of steps they can take before the starve function is called and the agent dies
cooldown - the amount of steps that must be taken before the agent can reproduce, increased when an agent reproduces
wool-thickness - the higher the wool-thickness the higher the chance that the sheep agent will successfully evade a wolf agent trying to eat it

## AGENT BEHAVIOURS:

Turtle Behaviours:
move - the functions that allow the turtles to move around the environment, for the sheep agents this just means moving in a random direction but for the wolves it could also mean moving towards a sheep or another wolf depending on the wolf-packs and wolf-hunt booleans.
eat - the functions that allow the turtles to consume another agent, whether its a sheep or grass agent to gain more energy to not starve.
mate - creates a new agent which has wool-thickness or teeth-sharpness similar to its parents.
starve - when an agents energy reaches zero, this function causes it to die

Patch Behaviour:
regrow - replenishes an eaten patch of grass so it can be consumed again, helps to control the sheep population as if there are too many sheep the grass will not regrow fast enough and they will starve, balancing the sheep population.

## PARAMETERS:

Wolves: 
num-wolves - the number of wolves created in the environment when the setup function is called
wolf-birth-energy - the initial value for the energy property when a wolf is created
reproductionRate-wolves - the chance that two wolves will produce a new wolf turtle when on the same patch.
wolf-gain-from-food - the increase in energy that a wolf recieves when it eats a sheep agent
wolf-max-food - the amount of energy a wolf reaches where it will no longer consume more sheep until their energy falls back below the threshold
wolf-mutation-multiplier - the possible increase or decrease in the teeth-sharpness from their parents teeth-sharpness
vision - the distance that a wolf will be able to detect sheep or other wolves to move towards
wolf-packs - a boolean that decides whether or not the wolves movement behaviour will cause them to form clusters
wolf-hunt - a boolean that decides whether wolves will move towards sheep to eat.

Sheep:
num-sheeps - the number of sheep created in the environment when the setup function is
sheep-birth-energy - the initial value for the energy property when a sheep is created
reproductionRate-sheeps - the chance that two sheep will produce a new sheep turtle when on the same patch.
sheep-gain-from-food - the increase in energy that a sheep recieves when it eats a grass agent
sheep-mutation-multiplier - the possible increase or decrease in the wool-thickness from their parents wool-thickness

Grass:
growthRate-grass - the chance for a grass patch to regrow each tick

## MEASURES:
Sheep and wolf populations, wool and tooth thickness and sharpness.

## EXAMPLES:

Below are five test runs of my model, in every model you can see that the tooth sharpness of the wolves and the wool thickness of the sheep increased with time by looking at the plots and the final outcome of the environment, where the wolves become darker as their teeth-sharpness increases and the sheep become whiter as their wool-thickness increases. This relates to the real world phenomena of evolution that i intended to model where over extended periods of time random variation in the offspring of animals can lead to adaptations better suited to the world around them. 

The plots show the increase of these agents properties over the span of 10000 ticks and also the corresponding populations of wolves and sheep at these points in time. The parameters used for the plots where kept constant across each run and are available to see below.

From the plots it may also be reasonable to assume that the increase in the teeth-sharpness and wool-thickness is proportional to the population of wolvesand sheep at that point in time, for example in run four there was a significantly smaller increase in teeth-sharpness over the 10000 ticks which i believe to be caused by the fact that the wolves where very close to extinction for an extended period of time in this run, meaning less wolves where reproducing and less potentially better offspring where being produced.

## FIRST RUN:

![Example](file:run%20one.png)

## SECOND RUN:

![Example](file:run%202.png)

## THIRD RUN:

![Example](file:run%203.png)

## FOURTH RUN:

![Example](file:run%204.png)

## FIFTH RUN:

![Example](file:run%205.png)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
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
