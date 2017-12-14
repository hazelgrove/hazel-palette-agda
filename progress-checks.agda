open import Nat
open import Prelude
open import List
open import core
open import contexts
open import lemmas-consistency
open import canonical-forms
open import type-assignment-unicity


-- taken together, the theorems in this file argue that for any expression
-- d, at most one summand of the labeled sum that results from progress may
-- be true at any time, i.e. that values, indeterminates, errors, and
-- expressions that step are pairwise disjoint. (note that as a consequence
-- of currying and comutativity of products, this means that there are six
-- theorems to prove)
module progress-checks where
  -- values and indeterminates are disjoint
  vi : ∀{d} → d val → d indet → ⊥
  vi VConst ()
  vi VLam ()

  -- values and errors are disjoint
  ve : ∀{d Δ} → d val → Δ ⊢ d err → ⊥
  ve VConst ()
  ve VLam ()

  -- values and expressions that step are disjoint
  vs : ∀{d Δ} → d val → (Σ[ d' ∈ dhexp ] (Δ ⊢ d ↦ d')) → ⊥
  vs VConst (d , Step (FHFinal x) () (FHFinal x₂))
  vs VConst (_ , Step (FHFinal x) () FHEHole)
  vs VConst (_ , Step (FHFinal x) () FHNEHoleEvaled)
  vs VConst (_ , Step (FHFinal x) () (FHNEHoleFinal x₂))
  vs VConst (_ , Step (FHFinal x) () (FHCastFinal x₂))
  vs VLam (d , Step (FHFinal x₁) () (FHFinal x₃))
  vs VLam (_ , Step (FHFinal x₁) () FHEHole)
  vs VLam (_ , Step (FHFinal x₁) () FHNEHoleEvaled)
  vs VLam (_ , Step (FHFinal x₁) () (FHNEHoleFinal x₃))
  vs VLam (_ , Step (FHFinal x₁) () (FHCastFinal x₃))

  -- indeterminates and errors are disjoint
  ie : ∀{d Δ} → d indet → Δ ⊢ d err → ⊥
  ie IEHole ()
  ie (INEHole (FVal x)) (ENEHole e) = ve x e
  ie (INEHole (FIndet x)) (ENEHole e) = ie x e
  ie (IAp i x) (EAp1 e) = ie i e
  ie (IAp i (FVal x)) (EAp2 e) = ve x e
  ie (IAp i (FIndet x)) (EAp2 e) = ie x e


  -- todo: these are bad names
  lem2 : ∀{d Δ d'} → d indet → Δ ⊢ d →> d' → ⊥
  lem2 IEHole ()
  lem2 (INEHole x) ()
  lem2 (IAp () x₁) (ITLam x₂)

  lem3 : ∀{d Δ d'} → d val → Δ ⊢ d →> d' → ⊥
  lem3 VConst ()
  lem3 VLam ()

  lem1 : ∀{d Δ d'} → d final → Δ ⊢ d →> d' → ⊥
  lem1 (FVal x) st = lem3 x st
  lem1 (FIndet x) st = lem2 x st

  -- indeterminates and expressions that step are disjoint
  is : ∀{d Δ} → d indet → (Σ[ d' ∈ dhexp ] (Δ ⊢ d ↦ d')) → ⊥
  is IEHole (_ , Step (FHFinal x) q _) = lem1 x q
  is IEHole (_ , Step FHEHole () (FHFinal x))
  is IEHole (_ , Step FHEHole () FHEHole)
  is IEHole (_ , Step FHEHole () FHNEHoleEvaled)
  is IEHole (_ , Step FHEHole () (FHNEHoleFinal x))
  is IEHole (_ , Step FHEHole () (FHCastFinal x))
  is (INEHole x) (_ , Step (FHFinal x₁) q _) = lem1 x₁ q
  is (INEHole x) (_ , Step FHNEHoleEvaled () (FHFinal x₁))
  is (INEHole x) (_ , Step FHNEHoleEvaled () FHEHole)
  is (INEHole x) (_ , Step FHNEHoleEvaled () FHNEHoleEvaled)
  is (INEHole x) (_ , Step FHNEHoleEvaled () (FHNEHoleFinal x₁))
  is (INEHole x) (_ , Step FHNEHoleEvaled () (FHCastFinal x₁))
  is (IAp i x) (_ , Step (FHFinal x₁) q _) = lem1 x₁ q
  is (IAp i (FVal x)) (_ , Step (FHAp1 x₁ p) q (FHAp1 x₂ r)) = vs x (_ , Step p q r)
  is (IAp i (FIndet x)) (_ , Step (FHAp1 x₁ p) q (FHAp1 x₂ r)) = is x (_ , Step p q r)
  is (IAp i x) (_ , Step (FHAp2 p) q (FHAp2 r)) = is i (_ , (Step p q r))


  -- final expressions are not errors (not one of the 6 cases for progress)
  fe : ∀{d Δ} → d final → Δ ⊢ d err → ⊥
  fe (FVal x) er = ve x er
  fe (FIndet x) er = ie x er

  -- errors and expressions that step are disjoint
  es : ∀{d Δ} → Δ ⊢ d err → (Σ[ d' ∈ dhexp ] (Δ ⊢ d ↦ d')) → ⊥
  -- cast error cases
  es (ECastError x x₁) (d' , Step (FHFinal x₂) x₃ x₄) = lem1 x₂ x₃
  es (ECastError x x₁) (_ , Step (FHCast x₂) x₃ (FHCast x₄)) = {!!}
  es (ECastError x x₁) (d' , Step (FHCastFinal x₂) (ITCast x₃ x₄ x₅) x₆)
    with type-assignment-unicity x x₄
  ... | refl = ~apart x₁ x₅

  -- ap1 cases
  es (EAp1 er) (d' , Step (FHFinal x) x₁ x₂) = lem1 x x₁
  es (EAp1 er) (_ , Step (FHAp1 x x₁) x₂ (FHAp1 x₃ x₄)) = fe x er
  es (EAp1 er) (_ , Step (FHAp2 x) x₁ (FHAp2 x₂)) = es er (_ , Step x x₁ x₂)

  -- ap2 cases
  es (EAp2 er) (d' , Step (FHFinal x) x₁ x₂) = lem1 x x₁
  es (EAp2 er) (_ , Step (FHAp1 x x₁) x₂ (FHAp1 x₃ x₄)) = es er (_ , Step x₁ x₂ x₄)
  es (EAp2 er) (_ , Step (FHAp2 x) x₁ (FHAp2 x₂)) = {!!}

  -- nehole cases
  es (ENEHole er) (d' , Step (FHFinal x) x₁ x₂) = lem1 x x₁
  es (ENEHole er) (d' , Step FHNEHoleEvaled () x₂)
  es (ENEHole er) (_ , Step (FHNEHoleInside x) x₁ (FHNEHoleInside x₂)) = es er (_ , Step x x₁ x₂)
  es (ENEHole er) (d' , Step (FHNEHoleFinal x) x₁ x₂) = fe x er

  -- castprop cases
  es (ECastProp er) (d' , Step (FHFinal x) x₁ x₂) = lem1 x x₁
  es (ECastProp er) (_ , Step (FHCast x) x₁ (FHCast x₂)) = es er (_ , Step x x₁ x₂)
  es (ECastProp er) (d' , Step (FHCastFinal x) x₁ x₂) = fe x er
