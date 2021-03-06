{-# OPTIONS --without-K #-}

open import lib.Basics
open import lib.types.Sigma
open import lib.types.Paths

module lib.types.CommutingSquare where

{- maps between two functions -}

infix 0 _□$_
_□$_ = CommSquare.commutes

CommSquare-∘v : ∀ {i₀ i₁ i₂ j₀ j₁ j₂}
  {A₀ : Type i₀} {A₁ : Type i₁} {A₂ : Type i₂}
  {B₀ : Type j₀} {B₁ : Type j₁} {B₂ : Type j₂}
  {f₀ : A₀ → B₀} {f₁ : A₁ → B₁} {f₂ : A₂ → B₂}
  {hA : A₀ → A₁} {hB : B₀ → B₁}
  {kA : A₁ → A₂} {kB : B₁ → B₂}
  → CommSquare f₁ f₂ kA kB
  → CommSquare f₀ f₁ hA hB
  → CommSquare f₀ f₂ (kA ∘ hA) (kB ∘ hB)
CommSquare-∘v {hA = hA} {kB = kB} (comm-sqr □₁₂) (comm-sqr □₀₁) =
  comm-sqr λ a₀ → ap kB (□₀₁ a₀) ∙ □₁₂ (hA a₀)

CommSquare-inverse-v : ∀ {i₀ i₁ j₀ j₁}
  {A₀ : Type i₀} {A₁ : Type i₁} {B₀ : Type j₀} {B₁ : Type j₁}
  {f₀ : A₀ → B₀} {f₁ : A₁ → B₁} {hA : A₀ → A₁} {hB : B₀ → B₁}
  → CommSquare f₀ f₁ hA hB → (hA-ise : is-equiv hA) (hB-ise : is-equiv hB)
  → CommSquare f₁ f₀ (is-equiv.g hA-ise) (is-equiv.g hB-ise)
CommSquare-inverse-v {f₀ = f₀} {f₁} {hA} {hB} (comm-sqr □) hA-ise hB-ise =
  comm-sqr λ a₁ → ap hB.g (! (□ (hA.g a₁) ∙ ap f₁ (hA.f-g a₁))) ∙ hB.g-f (f₀ (hA.g a₁))
  where module hA = is-equiv hA-ise
        module hB = is-equiv hB-ise

abstract
  -- 'r' with respect to '∘v'
  CommSquare-inverse-inv-r : ∀ {i₀ i₁ j₀ j₁}
    {A₀ : Type i₀} {A₁ : Type i₁} {B₀ : Type j₀} {B₁ : Type j₁}
    {f₀ : A₀ → B₀} {f₁ : A₁ → B₁} {hA : A₀ → A₁} {hB : B₀ → B₁}
    (cs : CommSquare f₀ f₁ hA hB) (hA-ise : is-equiv hA) (hB-ise : is-equiv hB)
    → ∀ a₁ → (CommSquare-∘v cs (CommSquare-inverse-v cs hA-ise hB-ise) □$ a₁)
          == is-equiv.f-g hB-ise (f₁ a₁) ∙ ! (ap f₁ (is-equiv.f-g hA-ise a₁))
  CommSquare-inverse-inv-r {f₀ = f₀} {f₁} {hA} {hB} (comm-sqr □) hA-ise hB-ise a₁ =
    ap hB ( ap hB.g (! (□ (hA.g a₁) ∙ ap f₁ (hA.f-g a₁)))
            ∙ hB.g-f (f₀ (hA.g a₁)))
    ∙ □ (hA.g a₁)
      =⟨ ap-∙ hB (ap hB.g (! (□ (hA.g a₁) ∙ ap f₁ (hA.f-g a₁)))) (hB.g-f (f₀ (hA.g a₁)))
          |in-ctx _∙ □ (hA.g a₁) ⟩
    ( ap hB (ap hB.g (! (□ (hA.g a₁) ∙ ap f₁ (hA.f-g a₁))))
      ∙ ap hB (hB.g-f (f₀ (hA.g a₁))))
    ∙ □ (hA.g a₁)
      =⟨ ap2 _∙_
          (∘-ap hB hB.g (! (□ (hA.g a₁) ∙ ap f₁ (hA.f-g a₁))))
          (hB.adj (f₀ (hA.g a₁)))
          |in-ctx _∙ □ (hA.g a₁) ⟩
    ( ap (hB ∘ hB.g) (! (□ (hA.g a₁) ∙ ap f₁ (hA.f-g a₁)))
      ∙ hB.f-g (hB (f₀ (hA.g a₁))))
    ∙ □ (hA.g a₁)
      =⟨ ! (↓-app=idf-out $ apd hB.f-g (! (□ (hA.g a₁) ∙ ap f₁ (hA.f-g a₁))))
          |in-ctx _∙ □ (hA.g a₁) ⟩
    ( hB.f-g (f₁ a₁)
      ∙' (! (□ (hA.g a₁) ∙ ap f₁ (hA.f-g a₁))))
    ∙ □ (hA.g a₁)
      =⟨ lemma (hB.f-g (f₁ a₁)) (□ (hA.g a₁)) (ap f₁ (hA.f-g a₁)) ⟩
    hB.f-g (f₁ a₁) ∙ ! (ap f₁ (hA.f-g a₁))
      =∎
    where module hA = is-equiv hA-ise
          module hB = is-equiv hB-ise

          lemma : ∀ {i} {A : Type i} {a₀ a₁ a₂ a₃ : A}
            (p₀ : a₀ == a₁) (p₁ : a₃ == a₂) (p₂ : a₂ == a₁)
            → (p₀ ∙' (! (p₁ ∙ p₂))) ∙ p₁ == p₀ ∙ ! p₂
          lemma idp idp idp = idp

  -- 'l' with respect to '∘v'
  CommSquare-inverse-inv-l : ∀ {i₀ i₁ j₀ j₁}
    {A₀ : Type i₀} {A₁ : Type i₁} {B₀ : Type j₀} {B₁ : Type j₁}
    {f₀ : A₀ → B₀} {f₁ : A₁ → B₁} {hA : A₀ → A₁} {hB : B₀ → B₁}
    (cs : CommSquare f₀ f₁ hA hB) (hA-ise : is-equiv hA) (hB-ise : is-equiv hB)
    → ∀ a₀ → (CommSquare-∘v (CommSquare-inverse-v cs hA-ise hB-ise) cs □$ a₀)
          == is-equiv.g-f hB-ise (f₀ a₀) ∙ ! (ap f₀ (is-equiv.g-f hA-ise a₀))
  CommSquare-inverse-inv-l {f₀ = f₀} {f₁} {hA} {hB} (comm-sqr □) hA-ise hB-ise a₀ =
    ap hB.g (□ a₀)
    ∙ ( ap hB.g (! (□ (hA.g (hA a₀)) ∙ ap f₁ (hA.f-g (hA a₀))))
        ∙ hB.g-f (f₀ (hA.g (hA a₀))))
      =⟨ ! (hA.adj a₀) |in-ctx ap f₁
          |in-ctx □ (hA.g (hA a₀)) ∙_
          |in-ctx ! |in-ctx ap hB.g
          |in-ctx _∙ hB.g-f (f₀ (hA.g (hA a₀)))
          |in-ctx ap hB.g (□ a₀) ∙_ ⟩
    ap hB.g (□ a₀)
    ∙ ( ap hB.g (! (□ (hA.g (hA a₀)) ∙ ap f₁ (ap hA (hA.g-f a₀))))
        ∙ hB.g-f (f₀ (hA.g (hA a₀))))
      =⟨ ∘-ap f₁ hA (hA.g-f a₀)
          |in-ctx □ (hA.g (hA a₀)) ∙_
          |in-ctx ! |in-ctx ap hB.g
          |in-ctx _∙ hB.g-f (f₀ (hA.g (hA a₀)))
          |in-ctx ap hB.g (□ a₀) ∙_ ⟩
    ap hB.g (□ a₀)
    ∙ ( ap hB.g (! (□ (hA.g (hA a₀)) ∙ ap (f₁ ∘ hA) (hA.g-f a₀)))
        ∙ hB.g-f (f₀ (hA.g (hA a₀))))
      =⟨ ↓-='-out' (apd □ (hA.g-f a₀))
          |in-ctx ! |in-ctx ap hB.g
          |in-ctx _∙ hB.g-f (f₀ (hA.g (hA a₀)))
          |in-ctx ap hB.g (□ a₀) ∙_ ⟩
    ap hB.g (□ a₀)
    ∙ ( ap hB.g (! (ap (hB ∘ f₀) (hA.g-f a₀) ∙' □ a₀))
        ∙ hB.g-f (f₀ (hA.g (hA a₀))))
      =⟨ lemma hB.g (□ a₀) (ap (hB ∘ f₀) (hA.g-f a₀)) (hB.g-f (f₀ (hA.g (hA a₀)))) ⟩
    ! (ap hB.g (ap (hB ∘ f₀) (hA.g-f a₀)))
    ∙' hB.g-f (f₀ (hA.g (hA a₀)))
      =⟨ ∘-ap hB.g (hB ∘ f₀) (hA.g-f a₀)
          |in-ctx ! |in-ctx _∙' hB.g-f (f₀ (hA.g (hA a₀))) ⟩
    ! (ap (hB.g ∘ hB ∘ f₀) (hA.g-f a₀))
    ∙' hB.g-f (f₀ (hA.g (hA a₀)))
      =⟨ !-ap (hB.g ∘ hB ∘ f₀) (hA.g-f a₀)
          |in-ctx _∙' hB.g-f (f₀ (hA.g (hA a₀))) ⟩
    ap (hB.g ∘ hB ∘ f₀) (! (hA.g-f a₀))
    ∙' hB.g-f (f₀ (hA.g (hA a₀)))
      =⟨ ! (↓-='-out' (apd (hB.g-f ∘ f₀) (! (hA.g-f a₀)))) ⟩
    hB.g-f (f₀ a₀) ∙ ap f₀ (! (hA.g-f a₀))
      =⟨ ap-! f₀ (hA.g-f a₀) |in-ctx hB.g-f (f₀ a₀) ∙_ ⟩
    hB.g-f (f₀ a₀) ∙ ! (ap f₀ (hA.g-f a₀))
      =∎
    where module hA = is-equiv hA-ise
          module hB = is-equiv hB-ise

          lemma : ∀ {i j} {A : Type i} {B : Type j} (f : A → B)
            {a₀ a₁ a₂ : A} {b : B}
            (p₀ : a₀ == a₁) (p₁ : a₂ == a₀) (q₀ : f a₂ == b)
            → ap f p₀ ∙ (ap f (! (p₁ ∙' p₀)) ∙ q₀) == ! (ap f p₁) ∙' q₀
          lemma f idp idp idp = idp
