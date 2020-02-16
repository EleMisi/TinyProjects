;--------------------------------
;Author: Eleonora Misino
;Date: Mar. 18, 2019
;--------------------------------

;_______________
;____BREEDS_____
;_______________

;The model has patients from an infinite population N
;and a finite number c of front offices.
breed [patients patient]
breed [fOffices fOffice]

;Each patient knows when he enters the queue and when he leaves to be served;
;he also knows is state: not served or served.
patients-own [
  time-entered-queue
  time-entered-service
  total-time-in-queue
  served ; 0 = not served, 1 = being served
]

;Each front office could be avaible (GREEN) or busy (RED)
;and it knows the identity of its current patient.
;For each service requested there is a specific completion time
fOffices-own [
  current-patient
  next-completion-time
]


;________________
;____GLOBALS_____
;________________

globals [

  ;graphical variables for front offices and patients
  fOffice-ycor
  yellow-line
  patient-shape

  queue ;list of patients waiting to be served
  available-fOffices ;list of avaible front offices

  total-patients
  waiting-patients
  time-in-queue
  ave-time-in-queue

  mean-patients
  mean-waiting-patients
  mean-time-in-queue
  mean-waiting-time

  m-patients
  w-patients
  m-time-in-queue
  time

  prec ; parameter of "precision" function, necessary to solve the error introducted by "tick-advance" function:
       ;"tick-advance 0.1" returns 0.1000000007 instead of 0.1

  ticked ; NetLogo Web view updating

]

;_______________
;____BUTTONS____
;_______________


;setup the world with the finite number of fOffices
to setup

  clear-all
  reset-ticks

  setup-globals
  setup-fOffices

end

;----------------------------------------------------------------------

;_________________________________
;____NETLOGO WEB VIEW UPDATING____
;_________________________________

to go-repeat
  set ticked (ticked + 1)
  go

  if (ticked * time-grain > update-every) [
    set ticked 0
    stop
  ]
end


;----------------------------------------------------------------------

;Patients arrive
;Front offices start their tasks.
;Queue slides
;Front offices end their tasks according to times-service distribution
to go

  if (ticks) > 0 [

  set total-patients lput count patients total-patients
  set waiting-patients lput length queue waiting-patients
  set ave-time-in-queue lput mean time-in-queue ave-time-in-queue


  ]

  if ticks = 0  [

  set total-patients lput 0 total-patients
  set waiting-patients lput 0 waiting-patients
  set ave-time-in-queue lput 0 ave-time-in-queue
  set time-in-queue lput 0 time-in-queue

  ]

  if (precision ticks prec =  ceiling (precision ticks prec)) [

    patients-arrive

    set mean-patients mean total-patients
    set mean-waiting-patients mean waiting-patients
    set mean-time-in-queue (mean ave-time-in-queue)


    set time (precision ticks prec)

    set m-patients lput (list time mean-patients) m-patients
    set w-patients lput (list time mean-waiting-patients) w-patients
    set m-time-in-queue lput (list time mean-time-in-queue) m-time-in-queue



    update-plots

    set total-patients []
    set waiting-patients []
    set ave-time-in-queue []

  ]

  end-service
  begin-service

  tick-advance time-grain ;Advances the tick counter by time-grain.

  if (precision ticks prec =  200) [

    stop
  ]
end

;_______________________
;____SETUP FUNCTIONS____
;_______________________

;Setup global variables
to setup-globals

  set queue []

  set fOffice-ycor (max-pycor - 2)
  set yellow-line (fOffice-ycor - 3)
  set available-fOffices []
  set patient-shape ["patient 1" "patient 2"]

  set mean-patients 0
  set mean-waiting-patients 0
  set mean-time-in-queue 0

  set mean-waiting-time 0
  set ave-time-in-queue []

  set total-patients []
  set waiting-patients []
  set time-in-queue []


  set m-patients []
  set w-patients []
  set m-time-in-queue []
  set time  0

  if time-grain = 1.0 [
    set prec 1
  ]

    if time-grain = 0.1 [
    set prec 2
  ]

    if time-grain = 0.01 [
    set prec 3
  ]

    if time-grain = 0.001 [
    set prec 3
  ]

    if time-grain = 0.0001 [
    set prec 4
  ]

    if time-grain = 0.00001 [
    set prec 5
  ]


  set ticked 0

end

;----------------------------------------------------------------------

;Create a finite number-of-fOffices equispatiated on horizontal axis
to setup-fOffices

  let horizontal-interval (world-width / number-of-fOffices)

  create-fOffices number-of-fOffices [

    set color green
    set shape "front office 2"
    set size 2.75
    setxy (min-pxcor - 0.5 + horizontal-interval * (0.5 + who)) fOffice-ycor
    set current-patient nobody
    set next-completion-time  0

  ]

;draw the yellow line
  ask patches [

    if pycor = yellow-line [
      set pcolor yellow
    ]

  ]

end

;______________________
;____MAIN FUNCTIONS_____
;______________________

to patients-arrive

  ;ARRIVALS DISTRIBUTION:
  ;Poisson Process with mean = arrival-rate
  create-patients random-poisson (arrival-rate) [

    set color 138
    set shape one-of patient-shape
    set size 2
    set queue (lput self queue)
    set served 0

    ;Arrival time is simulated in a more realistic way by adding a random floating number to time-entered-queue
    let rndm-float1 random-float 1
    set time-entered-queue ticks + rndm-float1
    set time-entered-service rndm-float1

    setxy random-xcor random-ycor

    if ycor > yellow-line or ycor < min-pycor + 1 [

      setxy xcor yellow-line - 1 - random 8
  ]
  ]

end

;----------------------------------------------------------------------

;The service starts if and only if there is an avaible front office
to begin-service

    ask fOffices with  [current-patient = nobody] [

      if not empty? queue [

      let next-patient (first queue)
      set queue (but-first queue)
      let current-fOffice self
      set current-patient next-patient

      ;SERVICE TIMES DISTRIBUTION:
      ;Exponential distribution with mean = 1 / service-rate

      let interval-time (random-exponential (1 / service-rate))


      set next-completion-time (ticks + interval-time)

      set color red

      ask next-patient [

        set time-entered-service (time-entered-service + ticks)
        set total-time-in-queue (time-entered-service - time-entered-queue)

        set time-in-queue lput total-time-in-queue time-in-queue

        move-to current-fOffice
        set served 1

      ]

    ]
  ]
end

;----------------------------------------------------------------------

;A busy front office has to wait until next-completion-time
;to be avaible again
;The newly-served patient leaves the system
to end-service

  ask fOffices with [current-patient != nobody] [

    if ticks >= next-completion-time [

      ask current-patient [
        die
      ]
      set next-completion-time 0
      set color green
    ]
  ]

end

;-----------------------------------------------

@#$#@#$#@
GRAPHICS-WINDOW
23
10
319
307
-1
-1
8.73
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
30
320
93
353
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
20
369
192
402
number-of-fOffices
number-of-fOffices
1
20
10.0
1
1
NIL
HORIZONTAL

BUTTON
225
319
288
352
go
go-repeat
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
204
368
376
401
arrival-rate
arrival-rate
0
50
10.0
0.01
1
NIL
HORIZONTAL

PLOT
405
19
721
209
Patients
time
# patients
0.0
200.0
0.0
5.0
true
true
"" ""
PENS
"Total patients" 1.0 1 -3026479 true "" "plot mean-patients "
"Waiting patients" 1.0 0 -5298144 true "" "plot mean-waiting-patients "

SLIDER
19
419
204
452
service-rate
service-rate
0
10
6.0
0.01
1
NIL
HORIZONTAL

PLOT
406
222
628
439
Waiting time
time
time
0.0
200.0
0.0
0.005
true
false
"" ""
PENS
"default" 1.0 0 -14730904 true "" "plot mean-time-in-queue"

MONITOR
643
223
722
268
Rho
arrival-rate / ( number-of-fOffices * service-rate )
5
1
11

CHOOSER
226
412
364
457
time-grain
time-grain
1 0.1 0.01 0.001 1.0E-4 1.0E-5
0

SLIDER
21
463
193
496
update-every
update-every
0
500
100.0
10
1
 ticks
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

We use the queueing theory to model the reception as a M/M/c queue. 

In this queueing system the customers are the patients, while the servers
are the front offces. 

We imagine an hospital with a infite number of front offices and a potentially infnite number of patients to be accepted. The patients require different services, each of them with a different time to be computed.

We assume that each front office is appointed to provide any required service and we decide that the first patient entering the queue is the first to be
served, so we have a FIFO queueing discipline.

## HOW IT WORKS

There are two breeds interacting to eachother: front offices and patients. 

The patients' arrival is governed by a Poisson process, while the service time has an exponential distribution. 

The time discretization is realized by advancing the tick counter by a floating point number. 

In each iteration the first patient in the queue reaches an available (green) front office to request for a service; the front offices turns red and remains busy until the requested service is provided. Then, the served patient leaves the reception and the front office turns available again.

## HOW TO USE IT

1. Adjust the slider parameters (see below), or use the default settings.
2. Press the SETUP button.
4. Press the GO button to begin the model run.
5. The program stops  after _update-every_  ticks, re-press the GO button to run another _update-every_ ticks.

NUMBER-OF-FOFFICES is the number of front offices in the reception

ARRIVAL-RATE determines the mean of the Poisson's distribution for the patients' arrival.

SERVICE-RATE determines the service time rate, that is the inverse of the mean for the exponential distribution.

TIME-GRAIN is the parameter for the time discretization obteined using the NetLogo function [tick-advance](http://ccl.northwestern.edu/netlogo/docs/dict/tick-advance.html)

PATIENTS chart displays the trend of both the total number of patients and the number of waiting patients.

WAITING TIME chart displays the trend of the average time spent in queue.

RHO shows the value of the equilibrium parameter: the ratio between the arrival rate and the number of front offices times the service rate


## THINGS TO TRY


Let's try different parameter configurations and observe the graphs: 


* which is the model behaviour for 'rho' < 1? 
* And for rho > 1? 
* Does the time-grain affected the equilibrium condition?



## CREDITS AND REFERENCES

Copyright 2019 Eleonora Misino

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/.
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

front office
false
4
Rectangle -1184463 false true 44 44 254 254
Line -1184463 true 240 240 240 60
Line -1184463 true 240 240 60 240
Line -1184463 true 60 240 60 60
Line -1184463 true 240 60 60 60
Polygon -1184463 true true 255 255 240 240 240 45 255 45 255 255
Polygon -1184463 true true 240 60 45 60 45 45 255 45
Polygon -1184463 true true 255 255 45 255 60 240 240 240 255 255
Polygon -1184463 true true 60 240 60 60 45 60 45 255 60 240

front office 2
false
15
Polygon -7500403 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true true 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true true 123 90 149 141 177 90
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true true 152 143 9
Circle -1 true true 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -13345367 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Rectangle -16777216 true false 118 129 141 140
Circle -7500403 true false 110 5 80
Polygon -13345367 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Rectangle -16777216 true false 120 120 135 135
Rectangle -6459832 true false 0 180 315 300
Line -13791810 false 0 180 0 0
Line -13791810 false 0 0 300 0
Line -13791810 false 300 0 300 180
Line -13791810 false 300 180 300 15
Line -13791810 false 300 0 300 180
Line -13791810 false 30 90 90 15
Line -13791810 false 45 120 90 60
Line -13791810 false 210 75 255 30
Line -13791810 false 210 120 270 60
Circle -1 true true 96 186 108

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

patient 1
false
0
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -6459832 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -11221820 true false 120 195 180 195 195 90 105 90 120 195

patient 2
false
0
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2064490 true false 120 195 180 195 195 90 105 90 120 195
Polygon -5825686 true false 120 195 90 270 210 270 180 195 120 195

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

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
NetLogo 6.1.1
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
