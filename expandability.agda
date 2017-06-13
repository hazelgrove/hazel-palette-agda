open import Nat
open import Prelude
open import List
open import core
open import contexts
open import htype-decidable

module expandability where
  mutual
    expandability-synth : (Γ : tctx) (e : hexp) (τ : htyp) →
                          Γ ⊢ e => τ →
                          Σ[ d ∈ dhexp ] Σ[ Δ ∈ hctx ]
                            (Γ ⊢ e ⇒ τ ~> d ⊣ Δ)
    expandability-synth Γ .c .b SConst = c , ∅ , ESConst
    expandability-synth Γ _ τ (SAsc {e = e} x)
      with expandability-ana Γ e τ {!!}
    ... | d' , Δ' , τ' , D with htype-dec τ τ'
    expandability-synth Γ _ τ (SAsc x₁) | d' , Δ' , .τ , D | Inl refl = d' , Δ' , ESAsc2 D
    expandability-synth Γ _ τ (SAsc x₁) | d' , Δ' , τ' , D | Inr x = (< τ > d') , Δ' , ESAsc1 D x
    expandability-synth Γ _ τ (SVar {n = n} x) = X n , ∅ , {!ESVar!}
    expandability-synth Γ _ τ (SAp D x x₁) = {!!}
    expandability-synth Γ _ .⦇⦈ SEHole = _ , _ , ESEHole
    expandability-synth Γ _ .⦇⦈ (SNEHole D) with expandability-synth _ _ _ D
    ... | d' , Δ' , D' = _ , _ , ESNEHole D'
    expandability-synth Γ _ _ (SLam x₁ D) = {!!}

    expandability-ana : (Γ : tctx) (e : hexp) (τ : htyp) →
                         Γ ⊢ e => τ →
                          Σ[ d ∈ dhexp ] Σ[ Δ ∈ hctx ] Σ[ τ' ∈ htyp ]
                            (Γ ⊢ e ⇐ τ ~> d :: τ' ⊣ Δ)
    expandability-ana = {!!}
