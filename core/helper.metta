 

(= (listDifference $arr1 $arr2)
    (py-call (helpers.list_difference $arr1 $arr2))
)
(= (norm $arr)
    (py-call (helpers.norm $arr))
)
(= (calculateNormDifference $arr1 $arr2)
    (py-call (helpers.calculate_norm_difference $arr1 $arr2))
)



(= (normalizeVector $arr)
    (py-call (helpers.normalize_vector $arr))
)
(= (roundNum $value $digits)
    (py-call (helpers.round_number $value $digits))
)

(= (split $arr $indices_or_sections)
    (py-call (helpers.split $arr $indices_or_sections))
)
(= (sum $arr)
    (py-call (helpers.sum_array $arr))
)
(= (product $arr)
    (py-call (helpers.prod_array $arr ))
)
(= (mean $arr)
    (py-call (helpers.mean_array $arr))
)
(= (std $arr)
    (py-call (helpers.std_array $arr))
)

(= (variance $arr)
    (py-call (helpers.var_array $arr))
)

(= (dotProduct $arr1 $arr2)
    (py-call (helpers.dot_array $arr1 $arr2))
)

;--- additional helper function ---
(= (softmax $arr)
    (py-call (helpers.softmax $arr))
)

(= (vectorAdd $arr1 $arr2)
    (py-call (helpers.vector_add $arr1 $arr2))
)

(= (averageArrays $arr1 $arr2)
    (py-call (helpers.average_arrays $arr1 $arr2))
)

(= (clipVector $arr $minValue $maxValue)
    (py-call (helpers.clip_vector $arr $minValue $maxValue))
)

(= (matrixIsSquare $matrix)
    (py-call (helpers.matrix_is_square $matrix))
)

(= (matrixVectorDot $matrix $vector)
    (py-call (helpers.matrix_vector_dot $matrix $vector))
)

(= (absNumber $value)
    (py-call (helpers.abs_number $value))
)

(= (expNum $value)
    (py-call (helpers.exp_number $value))
)

(= (sigmoidNum $value)
    (py-call (helpers.sigmoid_number $value))
)

(= (probeVector $delta $step $threshold)
    (py-call (helpers.probe_vector $delta $step $threshold))
)

;; Merge two goal vectors using parameterized index categories
;; Example: (parallelMergeGoals goalsA goalsB 0.05 0 (0 2 6) (1 3 4 5) (7))
(= (parallelMergeGoals $goalsA $goalsB $coherenceCorrection $weightIdx $safetyIdx $exploratoryIdx $socialIdx)
    (py-call (helpers.parallel_merge_goals $goalsA $goalsB $coherenceCorrection $weightIdx $safetyIdx $exploratoryIdx $socialIdx))
)

;; Merge two modulator vectors using parameterized index categories
;; Example: (parallelMergeModulators modsA modsB goalsA goalsB 0.05 0 (4 5) (1 2) (0 3))
(= (parallelMergeModulators $modsA $modsB $goalsA $goalsB $coherenceCorrection $weightIdx $cautionIdx $exploratoryIdx $sharedIdx)
    (py-call (helpers.parallel_merge_modulators $modsA $modsB $goalsA $goalsB $coherenceCorrection $weightIdx $cautionIdx $exploratoryIdx $sharedIdx))
)

;; Update Atoms in a space
(= (updateAtom $oatom $natom $space) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

(= (getIndex $goals $idx)
   (index-atom $goals $idx))

;; Round all elements in a list to the given number of decimal places
;; Example: (roundList (0.12345 0.67891) 3) → (0.123 0.679)
(= (roundList $arr $digits)
    (py-call (helpers.round_list $arr $digits))
)