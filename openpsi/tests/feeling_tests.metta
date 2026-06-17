!(import! &self ../../core/helper)
!(import! &self "../../core/helpers.py")
!(import! &self ../../core/state)
!(import! &self ../../core/state_accessors)
!(import! &self ../config)
!(import! &self ../feeling)

;; est fixtures
;; Paper Table 3 modulator levels, mapped to this repo's modulator slots:
;; arousal=0.4247 resolution=0.3466 securing=0.8436 threshold=0.7752 valence(pleasure)=0.7245
;; vector order: (valence arousal approach resolution threshold securing)
(= (paperState)
    (motivation
        (0.25 0.75 0.5 0.5 0.5 0.5 0.5 0.5)
        (0.7245 0.4247 0.5 0.3466 0.7752 0.8436)
    )
)
;; Flat state: all modulators at 0.5 (no strong emotion -> neutral)
(= (flatState)
    (motivation
        (0.25 0.75 0.5 0.5 0.5 0.5 0.5 0.5)
        (0.5 0.5 0.5 0.5 0.5 0.5)
    )
)

;; Fuzzy membership primitives (eqs. 2, 16, 17)
!(test (fuzzyEqual 0.5 0.5 50.0) 1.0)
!(test (fuzzyHigh 0.8 0.70 50.0) 1.0)
!(test (fuzzyLow 0.2 0.30 50.0) 1.0)
!(test (eval (roundNum (fuzzyHigh 0.4247 0.70 50.0) 6)) 0.20879)
!(test (eval (roundNum (fuzzyLow 0.3466 0.30 50.0) 6)) 0.902057)

;; indicatorMembership: one assertion per indicator case (eq. 15)
!(test (indicatorMembership 0.8 H) 1.0)
!(test (indicatorMembership 0.2 L) 1.0)
!(test (indicatorMembership 0.1 EL) 1.0)
!(test (indicatorMembership 0.9 EH) 1.0)
!(test (eval (roundNum (indicatorMembership 0.5 M) 6)) 1.0)
!(test (indicatorMembership 0.8 U) 0.0)

;; indicator lookups from Table 2
!(test (emotionIndicator happy arousal) H)
!(test (emotionIndicator sad resolution) H)
!(test (emotionIndicator angry threshold) L)
!(test (emotionIndicator fear resolution) EH)
!(test (emotionIndicator happy securing) U)

;; emotion intensities at paper Table 3 levels (eq. 14, alpha=50)
!(test (eval (roundNum (emotionIntensity (paperState) happy) 6)) 0.622169)
!(test (eval (roundNum (emotionIntensity (paperState) sad) 6)) 0.161286)
!(test (eval (roundNum (emotionIntensity (paperState) angry) 6)) 0.249869)
!(test (eval (roundNum (emotionIntensity (paperState) fear) 6)) 0.080637)

;; dominant emotion + gamma threshold
!(test (let ($n $v) (dominantEmotion (paperState)) ($n (eval (roundNum $v 6)))) (happy 0.622169))
!(test (let ($n $v) (dominantEmotion (flatState)) $n) neutral)
