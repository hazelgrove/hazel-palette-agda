open import Nat
open import Prelude
open import List
open import core

module type-assignment-unicity where
  type-assignment-unicity : (Γ : ·ctx) (e : ë) (t' t : τ̇) (Δ : ·ctx) →
                              Δ , Γ ⊢ e :: t →
                              Δ , Γ ⊢ e :: t' →
                              t == t'
  type-assignment-unicity = {!!}
