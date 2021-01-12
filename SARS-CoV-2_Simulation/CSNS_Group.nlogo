;________________________________
;
; Author: Eleonora Misino
; Date: 3 Jan, 2021
;________________________________



;___________________
;____EXTENSIONS_____
;___________________
;; NW -> network layout
;; rnd -> roulette wheel selection

extensions [NW rnd]


;________________
;____GLOBALS_____
;________________


globals
  [
    population_size   ;; Company headcount
    expon             ;; Power-law exponent

   ;; ================================================ ;;
   ;;             Epidemic Model Parameters            ;;
   ;; ================================================ ;;

   alpha                       ;; Infection chance
   epsilon_E                   ;; Exposed people has an infectivity reduced by teh factor epsilon_E
   diagnose_eff                ;; Diagnose efficiency
   CT_eff                      ;; Contact Tracing efficiency
   exposed_transition_rates    ;; Exposed class transition rates
   infected_transition_rates   ;; Infected class transition rates
   quarantine-susceptible      ;; Transfition rate: Quarantined -> Susceptible
   hospitalized-susceptible    ;; Transfition rate: Hospitalized -> Susceptible
   death_rate                  ;; COVID-19 death rate


   ;; ============================= ;;
   ;;             Monitors          ;;
   ;; ============================= ;;

    victims              ;; total number of deaths
    %hospitalized        ;; % of the population in Hospitalized class
    %exposed             ;; % of the population in Exposed class
    %immune              ;; % of the population in Immune class
    %infected            ;; % of the population in Infected class
    %quarantined         ;; % of the population in Quarantined class
    %susceptible         ;; % of the population in Susceptible class
    %traced_contacts     ;; % of the contacts is traced
  ]

;----------------------------------------------------------------------

;________________
;_____BREEDS_____
;________________

breed [employees employee]
undirected-link-breed [contacts contact]


employees-own [
  status                    ;; An employee can be susceptible, exposed, infected, quarantined, hospitalized or immune
  number_of_contacts        ;; total number of working contacts
  number_of_traced_contacts ;; number of traced working contacts
  ]

contacts-own [
  traced? ;; Whether this contact is traced or not
  ]


;_______________________
;____SETUP PROCEDURE____
;_______________________


to setup

  clear-all

  ;; ------------------------Epidemic Model Parameters------------------------

     set epsilon_E 0.6


     ;; DIAGNOSE EFFICIENCY

     if diagnose_efficiency = "perfect"
        [set infected_transition_rates [ [ "infected->hospitalized" 100 ] ]
         set diagnose_eff 100
         set death_rate 0]

     if diagnose_efficiency = "high" [
        set diagnose_eff 90
        set death_rate 3.4
        set infected_transition_rates [  [ "infected->hospitalized" 90 ]
                                          [ "infected->susceptible" 1.32 ]
                                          [ "remain-infected" 5.28]
                                          [ "die" 3.4]]]

     if diagnose_efficiency = "medium" [
        set diagnose_eff 50
        set death_rate 3.4
        set infected_transition_rates [  [ "infected->hospitalized" 50 ]
                                          [ "infected->susceptible" 9.32 ]
                                          [ "remain-infected" 37.28]
                                          [ "die" 3.4]]]

     if diagnose_efficiency = "low" [
        set diagnose_eff 10
        set death_rate 3.4
        set infected_transition_rates [ [ "infected->hospitalized" 10 ]
                                         [ "infected->susceptible" 17.32 ]
                                         [ "remain-infected" 69.28]
                                         [ "die" 3.4]]]

     if diagnose_efficiency = "zero" [
        set diagnose_eff 0
        set death_rate 3.4
        set infected_transition_rates [ [ "infected->susceptible" 19.32 ]
                                         [ "remain-infected" 77.28]
                                         [ "die" 3.4]]]


     ;; CONTACT TRACING EFFICIENCY

     if CT_efficiency = "perfect"
        [set CT_eff 100]
     if CT_efficiency = "high"
        [set CT_eff 90]
     if CT_efficiency = "medium"
        [set CT_eff 50]
     if CT_efficiency = "low"
        [set CT_eff 10]
     if CT_efficiency = "zero"
        [set CT_eff 0]


     ;; FACE MASKS

     ifelse face_masks? = True
      [set alpha 95 - 0.65 * 95]
      [set alpha 95]


     ;; TRANSITION RATES
     set quarantine-susceptible 20
     set hospitalized-susceptible 30
     set exposed_transition_rates [ [ "exposed->susceptible" 20 ]
                                    [ "exposed->infected" 70 ]
                                    ["remain-exposed" 10]]

  ;; ------------------------------------------------------------------------------


  ;; Graphical Setting
  let size-of-world 50
  resize-world 0 (size-of-world - 1) 0 (size-of-world - 1)
  set-patch-size (500 / max-pxcor)

  ;; Populate the world
  set population_size 100
  create-employees population_size [
      set shape "person"
      set color white
      set size 1.5
      setxy random-xcor random-ycor
      set status "susceptible"]

  ;; Initial infected employees
  let n_initial_infected initial_infected
  ask n-of  n_initial_infected employees [
    set status "infected"
    set color red]

  ;; Make working contacts according to the power-law distribution
  set expon 2
  ask employees [
    make-contacts]

  ;; Count traced and not traced contacts after having made all of them
  ask employees [
    set number_of_contacts count my-contacts
    set number_of_traced_contacts count my-contacts with [traced? = True] ]

  ;; Apply Fruchterman-Reingold layout algorithm on the network of contacts
  repeat 20 [layout-spring employees contacts 0.2 5 1]


  ;; ------------------------Epidemic Model Parameters------------------------

     set %infected count employees with [status = "infected"] / count employees * 100
     set %susceptible  count employees with [status = "susceptible"] / count employees * 100
     set %immune  count employees with [status = "immune"] / count employees * 100
     set %exposed count employees with [status = "exposed"] / count employees * 100
     set %quarantined count employees with [status = "quarantined"] / count employees * 100
     set %hospitalized count employees with [status = "hospitalized"] / count employees * 100
     set victims 0
     let n_traced_contacts round (sum [number_of_contacts] of employees / 2)
     ifelse n_traced_contacts > 0
       [set %traced_contacts (sum [number_of_traced_contacts] of employees / 2) / n_traced_contacts * 100]
       [set %traced_contacts 0]


  ;; ------------------------------------------------------------------------------



  ;; If nw_analysis? is True,
  ;; then the network of contacts is saved each year.
  if nw_analysis? = True [
     let graph (word "initial_graph.gexf")
     nw:set-context employees contacts
     nw:save-gexf graph
     show (word "saved "  graph)]


   reset-ticks

end


;____________________
;____GO PROCEDURE____
;____________________

to go

  ;---------------------- DAILY ROUTINE AT CSNS GROUP -------------------------


     ;; Update the infection chance according to personal protective equipment
     ifelse face_masks? = True
       [set alpha 95 - 0.65 * 95]
       [set alpha 95]

     ;; Check and update employees status coherently with the epidemic models
     ask employees [check-status]

     ;; Ripopulation with new susceptible employees to keep the headcount steady at 100
     let current_population_size count employees
     create-employees (population_size - current_population_size) [
        ;; Graphic setting
        set shape "person"
        set color white
        set size 1.5
        setxy random-xcor random-ycor
        ;; Status
        set status "susceptible"
        ;; Make working contacts
        make-contacts]

     ;; Count contacts
     ask employees [
       set number_of_contacts count my-contacts
       set number_of_traced_contacts count my-contacts with [traced? = True]]

     ;; Update statistics
     set %infected count employees with [status = "infected"] / count employees * 100
     set %susceptible  count employees with [status = "susceptible"] / count employees * 100
     set %immune  count employees with [status = "immune"] / count employees * 100
     set %exposed count employees with [status = "exposed"] / count employees * 100
     set %quarantined count employees with [status = "quarantined"] / count employees * 100
     set %hospitalized count employees with [status = "hospitalized"] / count employees * 100

     let n_traced_contacts round (sum [number_of_contacts] of employees / 2)
     ifelse n_traced_contacts > 0
       [set %traced_contacts (sum [number_of_traced_contacts] of employees / 2) / n_traced_contacts * 100]
       [set %traced_contacts 0]

     ;; Virus eradicated -> stop simulation
     if (count employees with [status = "infected"] +
        count employees with [status = "hospitalized"] +
        count employees with [status = "quarantined"] +
        count employees with [status = "exposed"] )
        = 0
         [stop]


     ;;------------------------------------------------------
     ;; NB: comment the line below to speed up the simulation
     ;;------------------------------------------------------
     ;; Apply Fruchterman-Reingold layout algorithm on the network of contacts
     repeat 20 [layout-spring employees contacts 0.2 5 1]

  ;----------------------------------------------------------------------------

  ;; New day
  tick

  ;; If nw_analysis? is True,
  ;; then the network of contacts is saved each year.
  if nw_analysis? = True [
    if (remainder ticks  365) = 0 [
      let graph (word "graph" (ticks / 365) ".gexf")
      nw:set-context employees contacts
      nw:save-gexf graph
      show (word "saved "  graph)]]

  ;; Uncomment the line below to stop the simulation after 10 years
  ;if ticks >= 365 * 10  [stop]

end




;____________________
;____CHECK STATUS____
;____________________


to check-status

     ;_______________
     ;  SUBSCEPTIBLE
     ;_______________

     if status = "susceptible" [
       ;; Only susceptible employees can be vaccinated
       if random 100 < vaccination_chance [vaccination]]

     ;_____________
     ;  EXPOSED
     ;_____________

     if status = "exposed" [
       ; Infect Susceptibles
       infectE
       ; Roulette wheel selection for Exposed class
       let choice first rnd:weighted-one-of-list exposed_transition_rates [ [action] -> last action ]
       if choice = "exposed->susceptible" [recover]
       if choice = "exposed->infected" [become-infected]]


     ;___________________
     ;   QUARANTINED
     ;___________________

     if status = "quarantined" [
       ; Infect Susceptibles
       infectQ
       ; Quarantined employees may recover
       if random 100 < quarantine-susceptible [recover]]

     ;_____________
     ;  INFECTED
     ;_____________

     if status = "infected" [
       ; Infect Susceptibles
       infectI
       ; Roulette wheel selection for Infected class
       let choice first rnd:weighted-one-of-list infected_transition_rates [ [action] -> last action ]
       if choice = "infected->susceptible" [recover]
       if choice = "infected->hospitalized" [diagnose]
       if choice = "die" [
         ask my-contacts [die]
         set victims victims + 1
         die]]


     ;_____________
     ;  ISOLATED
     ;_____________

     if status = "hospitalized" [
       ; Hospitalized employees may recover and exit isolation
       if random 100 < hospitalized-susceptible [exit-isolation]]

end




;_____________________________
;____MAKE WORKING CONTACTS____
;_____________________________
;; An employee can make at most max_contacts contacts,
;; since hospitalized employees are completely isolated.
;; If there is at least one potential contacts (i.e. max_contacts > 0),
;; the employee make a number of new contacts equal to the minimum between the sampled number and max_contacts;
;; otherwise it does not make new contacts.


 to make-contacts

   let max_contacts (count employees with [status != "hospitalized"] - 1)
   let n_contacts 0
   if max_contacts > 0
    [ let sampled_num round exp(ln(random-float 1) / (- expon))
      set n_contacts min list sampled_num max_contacts ]
   ;; New contacts can be made with not hospitalized employees only.
   create-contacts-with n-of n_contacts other employees with [status != "hospitalized"]

   ;; According to Contact Tracing efficiency (CT_eff), a cretain fraction of new contacts are traced
   ask [my-contacts] of self [
    ifelse random 100 < CT_eff
     [set color pink
      set thickness 0.2
      set traced?  True]
     [set color 5
      set thickness 0
      set traced? False]]

 end





;___________________________________
;____INFECTION RELATED FUNCTIONS____
;___________________________________
;; Exposed, Infected and Quarantined employees may infect their susceptible contacts,
;; and the infection chance is determined by alpha, epsilon_E and epsilon_Q.
;; Traced employees get quarantined when infected,
;; while not-traced employees do not get quarantined.

;; Exposed
 to infectE

   ask my-contacts [
    if random 100 < (epsilon_E * alpha) [
     ifelse traced? = True
       [ask other-end [if status = "susceptible" [quarantine]]]
       [ask other-end [if status = "susceptible" [
         set status "exposed"
         set color orange]]]]]

 end

;; Infected
 to infectI

   ask my-contacts [
     if random 100 < alpha [
      ifelse traced? = True
        [ask other-end [if status = "susceptible" [quarantine]]]
        [ask other-end [if status = "susceptible" [
          set status "exposed"
          set color orange]]]]]

 end

;; Quarantined
 to infectQ

   ask my-contacts [
     if random 100 < (epsilon_Q * (epsilon_E * alpha)) [
      ifelse traced? = True
        [ask other-end [if status = "susceptible" [quarantine]]]
        [ask other-end [if status = "susceptible" [
          set status "exposed"
          set color orange]]]]]

 end



;____________________________
;____TRANSITION FUNCTIONS____
;____________________________


to become-infected

  set status "infected"
  set shape "person"
  set color red

end



to quarantine

  set status  "quarantined"
  set color yellow
  set shape "quarantined"

end


to recover

    set color white
    set shape "person"
    set status "susceptible"

end


to diagnose

    set status "hospitalized"
    set color black
    set shape "diagnosed"
    ask my-contacts [die] ;; Isolation

end


to exit-isolation

    set status "susceptible"
    set color white
    set shape "person"
    make-contacts ;; Hospitalized employees were isolated -> new contacts when they come back at work

end

to vaccination

    set status "immune"
    set color green
    set shape "person"

end
@#$#@#$#@
GRAPHICS-WINDOW
310
67
828
586
-1
-1
10.204081632653061
1
10
1
1
1
0
0
0
1
0
49
0
49
1
1
1
days
30.0

BUTTON
461
601
531
634
NIL
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

BUTTON
546
599
617
635
NIL
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

PLOT
849
25
1300
304
Population Status
days
employees
0.0
31.0
0.0
100.0
true
true
"" ""
PENS
"infective" 1.0 0 -2674135 true "" "plot count employees with [ status = \"infected\"  ]"
"immune" 1.0 0 -14439633 true "" "plot count employees with [ status = \"immune\" ]"
"susceptible" 1.0 0 -13345367 true "" "plot count employees with [status = \"susceptible\" ]"
"quarantined" 1.0 0 -1184463 true "" "plot count employees with [status = \"quarantined\"]"
"isolated" 1.0 0 -16448764 true "" "plot count employees with [status = \"hospitalized\"]"
"exposed" 1.0 0 -955883 true "" "plot count employees with [status = \"exposed\"]"

MONITOR
1410
126
1475
171
NIL
%infected
3
1
11

MONITOR
1314
55
1364
100
days
ticks
0
1
11

PLOT
850
318
1302
560
Contact Tracing
days
contacts
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Traced Contacts" 1.0 0 -7858858 true "" "plot sum [number_of_traced_contacts] of turtles / 2"
"Total Contact" 1.0 0 -16777216 true "" "plot sum [number_of_contacts] of turtles / 2"

MONITOR
1502
181
1567
226
NIL
%immune
1
1
11

TEXTBOX
69
10
219
67
-------------------------\nControl Parameters\n-------------------------
15
0.0
1

SLIDER
10
403
158
436
vaccination_chance
vaccination_chance
0
100
0.0
5
1
%
HORIZONTAL

MONITOR
1318
322
1438
367
% Traced Contacts
%traced_contacts
1
1
11

MONITOR
1316
126
1403
171
NIL
%susceptible
1
1
11

MONITOR
1317
181
1398
226
NIL
%quarantined
2
1
11

MONITOR
1405
181
1495
226
NIL
%hospitalized
2
1
11

MONITOR
1485
127
1560
172
NIL
%exposed
2
1
11

SLIDER
11
297
132
330
epsilon_Q
epsilon_Q
0
1
0.5
0.1
1
NIL
HORIZONTAL

SWITCH
12
349
123
382
face_masks?
face_masks?
1
1
-1000

MONITOR
74
541
230
586
Infection Chance - Class I
alpha
17
1
11

MONITOR
125
163
205
208
Diagnose Eff.
diagnose_eff
17
1
11

CHOOSER
9
163
112
208
diagnose_efficiency
diagnose_efficiency
"perfect" "high" "medium" "low" "zero"
2

MONITOR
1398
53
1455
98
Victims
victims
17
1
11

CHOOSER
8
228
112
273
CT_efficiency
CT_efficiency
"perfect" "high" "medium" "low" "zero"
2

MONITOR
124
229
202
274
Tracing Eff.
CT_eff
17
1
11

TEXTBOX
94
467
244
524
----------------------\nInfection Chance\n----------------------
15
0.0
1

INPUTBOX
11
81
98
141
initial_infected
3.0
1
0
Number

PLOT
849
572
1302
761
Contacts Distribution
# contacts
# people
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [number_of_contacts] of turtles"

MONITOR
1319
259
1404
304
Employees
count employees
17
1
11

MONITOR
75
661
234
706
Infection Chance - Class Q
(epsilon_Q * (epsilon_E * alpha))
17
1
11

MONITOR
74
601
233
646
Infection Chance - Class E
(epsilon_E * alpha)
17
1
11

BUTTON
629
601
704
634
go once
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

MONITOR
216
162
293
207
Death Rate
death_rate
17
1
11

SWITCH
520
682
648
715
nw_analysis?
nw_analysis?
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

This model is designed to simulate the spread of SARS-CoV-2 virus in a fictional and simplified small-medium company called _CSNS Group_. 
_CSNS Group_ is completely isolated from the external world and it has a team-based organizational structure, which is simulated by using a power-law distribution to build the network of contacts.  

The simulation is based on an epidemic model with 5 control parameters to test several epidemic scenarios with different population-wide countermeasures. 

_**NB:** the model was built with NetLogo 6.1.1 and requires [NW](https://ccl.northwestern.edu/netlogo/docs/nw.html) and [rnd](https://ccl.northwestern.edu/netlogo/docs/rnd.html) extensions to work properly._

## HOW IT WORKS

According to the epidemic model each employee can be:

* susceptible (white)
* exposed (orange)
* infected (red)
* hospitalized (black) [_not present if DIAGNOSE_EFFICIENCY = `"zero"`_]
* quarantined (yellow) [_not present if CT_EFFICIENCY = `"zero"`_]
* immune (green) [_not present if VACCINATION CHANCE = 0_]

The simulation is daily-based and continues until there are only susceptible or immune people. 

**At day 0** (`setup`):

* 100 employees come to their offices and make working contacts following a power-law distribution with exponent 2.
    All the employees are susceptible except for an initial number of infected, which can be set by the observer (_INITIAL_INFECTED_).
* A fraction of working contacts may be traced accordingly to CT_EFFICIENCY (see Section *HOW TO USE IT* and the tracing last forever). This means that a traced contact cannot become untraced; it can only disappear due to the death or the isolation of one of its nodes.


**Each day** (`go`):

* Infected, exposed and quarantined employees may infect their susceptible.
* Then, according to the correpsonding transition rates:
	* infected people may be diagnosed and isolated; they may also recover, die or remain infected;
	* exposed people can recover or move to the infected class or even remain exposed;
	* quarantined people may either recover or remain quarantined, as well as hospitalized people, who can either recover or remain isolated;
	* susceptible people may be vaccinated and enter in the immune class.
* At the end of the day, missing people are replaced by new susceptible employees, so the headcount remains steady.


## HOW TO USE IT

1. Adjust the **control parameters** (see below) to define the epidemic scenario.
2. Press `setup` button.
4. Press `go` (or `go once`) button to run the simulation.

### Control Parameters

#### INITIAL_INFECTED
Number of initial infected employees.

#### DIAGNOSE_EFFICIENCY
Chance of the infected employees to be diagnosed and hospitalized.

#### CT_EFFICIENCY
Chance of a new working contacts to be traced.
whenever an employee _A_ is infected by a colleague _B_ and their contact _A−B_ is traced, _A_ self-quarantines.

#### EPSILON_Q
Self-quarantine is not perfect: a quarantined employee may still infect his colleagues with an infection chance determined by `alpha` * EPSILON_Q * EPSILON_E, where:

* `alpha` is the infectivity of infected employees (see **FACE_MASKS?**)
* ESPILON_E is equal to 0.6 and determines the reduced infectivity of the exposed class w.r.t. the infected class.
* EPSILON_Q goes from 0 (perfect isolation) to 1 (no isolation).


#### FACE_MASKS?
_CSNS Group_ employees may or may not wear face masks:

* without wearing face masks the infection chance (`alpha`) is equal to 95%; 
* with face masks `alpha` is reduced by a 65% ([reference](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)31142-9/fulltext)).

#### VACCINATION_CHANCE

Susceptible employees have a chance of being vaccinated equal to VACCINATION_CHANCE.

#### NW_ANALYSIS?

If it is True, then the network of contacts is saved each year (365 ticks) in a _gexf_ file.

### Monitors

**Efficiency and Death Rate**

* Next to DIAGNOSE_EFFICIENCY chooser we display the corresponding diagnose efficiency value (i.e. the transition rate from infected class to hospitalized class) and the model death rate. 
NB: death rate is zero when the diagnose efficiency is `"perfect"` (100%).
* Next to CT_EFFICIENCY chooser we display the corresponding contact tracing efficiency.

**Infection Chance**
The monitors reported the infection chance of the 3 infective classes (Infected, Exposed and Quarantined), which depend on the epidemic model parameters.

**Population Status**
The distribution of the employees in the 6 epidemic model classes is displayed in the _Population Status_ chart and in the corresponding monitors, along with days and victims counters.

**Contact Tracing**
Total number of contacts (black line) and number of traced contacts (purple line).
The current percentage of traced contacts is displayed in the dedicated monitor on the right.

**Contact Distribution**
The histogram reports the degree distribution of _CSNS Group_ graph (i.e. number of contacts of each employee).

## THINGS TO TRY

Try different scenarios by setting the **control parameters**:

* How could you explain the dynamic evolution of your scenario?
* Are you able to eradicate the virus within 10 years? And within 6 months?
* Which is the scenario that has the lowest number of victims? And the highest?

## EXTENDING THE MODEL

We could allow new infected people to join the company. How will that affect the simulation? 

What would happen if we split the company in clusters to locally quarantined different areas of the company(_Local Lockdown_)?  

We could exploit the contact tracing network to identify hubs. How could we use this additional information to build a more re-fined quarantine strategy? 

What would happen if we change the contacts distribution? 


## CREDITS

Copyright 2021 Eleonora Misino

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 License.  To view a copy of this license, visit [this page](https://creativecommons.org/licenses/by-nc-sa/4.0/).
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

diagnosed
false
0
Circle -2674135 true false -2 -2 304
Circle -1 true false 15 15 270
Rectangle -7500403 true true 142 90 165 124
Polygon -7500403 true true 195 105 240 150 225 180 165 105
Polygon -7500403 true true 105 105 120 165 90 255 105 270 120 270 150 195 180 270 195 270 210 255 180 165 195 105
Circle -7500403 true true 120 45 60
Polygon -7500403 true true 105 105 60 150 75 180 135 105

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
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -7500403 true true 195 90 240 150 225 180 165 105

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

quarantined
false
0
Rectangle -1184463 true false 0 0 300 300
Rectangle -16777216 true false 15 15 285 285
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Rectangle -1184463 true false 60 285 240 315
Rectangle -1184463 true false 45 0 240 15
Line -13345367 false 135 255 270 150
Line -13345367 false 45 225 255 60
Line -13345367 false 30 135 165 30

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
