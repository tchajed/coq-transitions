From Tactical Require Import Propositional.
From Tactical Require Import ExistentialVariants.
From Transitions Require Import Relations.

Set Implicit Arguments.
Generalizable All Variables.

Definition transition A B T := A -> Return B T.
Definition comp {A B T1 C T2} (t1: transition A B T1) (t2: T1 -> transition B C T2) : transition A C T2 :=
  fun a => match t1 a with
        | Val b x => t2 x b
        | Err _ _ => Err _ _
        end.

Class Deterministic `(r: relation A B T) (t: transition A B T) :=
  { det_iff: forall s s', r s s' <-> s' = t s }.

Arguments det_iff {A B T} r t {Deterministic} s s'.

Instance puts_Deterministic `(f: A -> A) :
  Deterministic (puts f) (fun x => Val (f x) tt).
Proof.
  constructor; unfold puts; intros.
  intuition auto.
Qed.

Instance reads_Deterministic `(f: A -> T) :
  Deterministic (reads f) (fun x => Val x (f x)).
Proof.
  constructor; unfold reads; intros.
  intuition auto.
Qed.

Theorem det_exact `{Deterministic A B T r t} : forall s s',
    r s s' -> s' = t s.
Proof.
  intros.
  pose proof (det_iff r t s s'); firstorder.
Qed.

Theorem det_complete_eqn `{Deterministic A B T r t} : forall s s',
    s' = t s ->
    r s s'.
Proof.
  intros.
  pose proof (det_iff r t s (t s)); firstorder.
Qed.

Theorem det_complete `{Deterministic A B T r t} : forall s,
    r s (t s).
Proof.
  intros.
  pose proof (det_iff r t s (t s)); firstorder.
Qed.

Instance and_then_Deterministic
         `(r1: relation A B T) (f1: transition A B T)
         `(r2: T -> relation B C T') (f2: T -> transition B C T')
         {Hr1: Deterministic r1 f1} {Hr2: forall x, Deterministic (r2 x) (f2 x)} :
  Deterministic (and_then r1 r2) (comp f1 f2).
Proof.
  constructor; unfold and_then, comp; intros.
  destruct_with_eqn (f1 s); simpl; eauto.
  - destruct s'; simpl; split;
      repeat match goal with
             | [ H: _ |- _ ] => apply det_exact in H
             | |- exists _, _ => descend
             | _ => progress propositional
             | _ => progress intuition eauto using det_complete_eqn
             end;
      try congruence.
    apply det_complete_eqn; eauto.
    right; descend; intuition eauto using det_complete_eqn.
    apply det_complete_eqn; eauto.
  - destruct s';
      repeat match goal with
             | [ H: _ |- _ ] => apply det_exact in H
             | |- exists _, _ => descend
             | _ => progress propositional
             | _ => progress intuition eauto using det_complete_eqn
             end;
      try congruence.
    left; apply det_complete_eqn; congruence.
    Grab Existential Variables.
    congruence.
    congruence.
Qed.
