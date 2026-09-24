;; Trusted startup only; no configuration API is registered as a command skill.
!(import! &self (library MetaMo applications/omegaclaw_v1/host_dispatch_config.py))
(= (prepareHostStartup)
   (progn
      (change-state! &new-msg-flag (get-state &core-loop-new-message))
      (py-call (host_dispatch_config.provision_startup))
      (initializeNativeTaskProjection)
      1))

;; Seed the legacy task projection from an actual admitted native frame. Do not
;; overwrite a live task or an explicit commitment, or infer task completion.
(= (initializeNativeTaskProjection)
   (if (and (== (commitmentSnapshot) NoCommitment)
            (and (not (get-state &task-open))
                 (== (get-state &cfv2-current-status) Active)))
       (let $deliverables (get-state &cfv2-current-deliverables)
          (if (== $deliverables ()) False
              (progn
                 (change-state! &active-task (car-atom $deliverables))
                 (change-state! &task-open True))))
       False))
(= (initializeHostStartup)
   (progn
      (py-call (host_dispatch_config.configure_startup))
      (if (== (eval (configureCoreLoopContext metaMoContext)) True)
          True (py-call (host_operations.incompatible_core)))
      (if (== (eval (configureCoreLoopPrepare prepareHostStartup)) True)
          True (py-call (host_operations.incompatible_core)))))
