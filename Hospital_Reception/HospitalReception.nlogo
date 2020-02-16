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
