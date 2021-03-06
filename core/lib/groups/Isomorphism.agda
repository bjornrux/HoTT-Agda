{-# OPTIONS --without-K #-}

open import lib.Basics
open import lib.Equivalence2
open import lib.Function2
open import lib.NType2
open import lib.types.Group
open import lib.types.Pi
open import lib.types.Subtype
open import lib.types.Truncation
open import lib.groups.Homomorphism
open import lib.groups.SubgroupProp

module lib.groups.Isomorphism where

GroupStructureIso : ∀ {i j} {GEl : Type i} {HEl : Type j}
  (GS : GroupStructure GEl) (HS : GroupStructure HEl) → Type (lmax i j)
GroupStructureIso GS HS = Σ (GroupStructureHom GS HS) (λ φ → is-equiv (GroupStructureHom.f φ))

infix 30 _≃ᴳˢ_ -- [ˢ] for structures
_≃ᴳˢ_ = GroupStructureIso

GroupIso : ∀ {i j} (G : Group i) (H : Group j) → Type (lmax i j)
GroupIso G H = Σ (G →ᴳ H) (λ φ → is-equiv (GroupHom.f φ))

infix 30 _≃ᴳ_
_≃ᴳ_ = GroupIso

≃ᴳˢ-to-≃ᴳ : ∀ {i j} {G : Group i} {H : Group j}
  → (Group.group-struct G ≃ᴳˢ Group.group-struct H) → (G ≃ᴳ H)
≃ᴳˢ-to-≃ᴳ (φ , φ-is-equiv) = →ᴳˢ-to-→ᴳ φ , φ-is-equiv

≃-to-≃ᴳ : ∀ {i j} {G : Group i} {H : Group j} (e : Group.El G ≃ Group.El H)
  → preserves-comp (Group.comp G) (Group.comp H) (–> e) → G ≃ᴳ H
≃-to-≃ᴳ (f , f-is-equiv) pres-comp = group-hom f pres-comp , f-is-equiv

≃-to-≃ᴳˢ : ∀ {i j} {GEl : Type i} {HEl : Type j}
  {GS : GroupStructure GEl} {HS : GroupStructure HEl} (e : GEl ≃ HEl)
  → preserves-comp (GroupStructure.comp GS) (GroupStructure.comp HS) (–> e)
  → GS ≃ᴳˢ HS
≃-to-≃ᴳˢ (f , f-is-equiv) pres-comp = group-structure-hom f pres-comp , f-is-equiv

private
  inverse-preserves-comp : ∀ {i j} {A : Type i} {B : Type j}
    (A-comp : A → A → A) (B-comp : B → B → B) {f : A → B} (f-ie : is-equiv f)
    → preserves-comp A-comp B-comp f
    → preserves-comp B-comp A-comp (is-equiv.g f-ie)
  inverse-preserves-comp Ac Bc ie pc b₁ b₂ = let open is-equiv ie in
    ap2 (λ w₁ w₂ → g (Bc w₁ w₂)) (! (f-g b₁)) (! (f-g b₂))
    ∙ ! (ap g (pc (g b₁) (g b₂)))
    ∙ g-f (Ac (g b₁) (g b₂))

module GroupIso {i j} {G : Group i} {H : Group j} (iso : GroupIso G H) where

  f-hom : G →ᴳ H
  f-hom = fst iso

  open GroupHom {G = G} {H = H} f-hom public

  f-is-equiv : is-equiv f
  f-is-equiv = snd iso

  open is-equiv f-is-equiv public

  f-equiv : Group.El G ≃ Group.El H
  f-equiv = f , f-is-equiv

  g-hom : H →ᴳ G
  g-hom = group-hom g (inverse-preserves-comp (Group.comp G) (Group.comp H) f-is-equiv pres-comp)

  g-is-equiv : is-equiv g
  g-is-equiv = is-equiv-inverse f-is-equiv

  g-equiv : Group.El H ≃ Group.El G
  g-equiv = g , g-is-equiv

idiso : ∀ {i} (G : Group i) → (G ≃ᴳ G)
idiso G = idhom G , idf-is-equiv _

coeᴳ-equiv : ∀ {i} {G H : Group i} → G == H → G ≃ᴳ H
coeᴳ-equiv idp = idiso _

transportᴳ-equiv : ∀ {i j} {A : Type i} (B : A → Group j) {a₁ a₂ : A} (p : a₁ == a₂)
  → B a₁ ≃ᴳ B a₂
transportᴳ-equiv B p = coeᴳ-equiv (ap B p)

{- equality of isomomorphisms -}
abstract
  group-hom=-to-iso= : ∀ {i j} {G : Group i} {H : Group j} {φ ψ : G ≃ᴳ H}
    → GroupIso.f-hom φ == GroupIso.f-hom ψ → φ == ψ
  group-hom=-to-iso= = Subtype=-out (is-equiv-prop ∘sub GroupHom.f)

  group-iso= : ∀ {i j} {G : Group i} {H : Group j} {φ ψ : G ≃ᴳ H}
    → GroupIso.f φ == GroupIso.f ψ → φ == ψ
  group-iso= {H = H} p = group-hom=-to-iso= $ group-hom= p

{- compositions -}

infixr 80 _∘eᴳ_

_∘eᴳ_ : ∀ {i j k} {G : Group i} {H : Group j} {K : Group k}
  → H ≃ᴳ K → G ≃ᴳ H → G ≃ᴳ K
(φ₂ , ie₂) ∘eᴳ (φ₁ , ie₁) = (φ₂ ∘ᴳ φ₁ , ie₂ ∘ise ie₁)

infixr 10 _≃ᴳ⟨_⟩_
infix  15 _≃ᴳ∎

_≃ᴳ⟨_⟩_ : ∀ {i j k} (G : Group i) {H : Group j} {K : Group k}
  → G ≃ᴳ H → H ≃ᴳ K → G ≃ᴳ K
G ≃ᴳ⟨ e₁ ⟩ e₂ = e₂ ∘eᴳ e₁

_≃ᴳ∎ : ∀ {i} (G : Group i) → (G ≃ᴳ G)
_≃ᴳ∎ = idiso

infixl 120 _⁻¹ᴳ

_⁻¹ᴳ : ∀ {i j} {G : Group i} {H : Group j} → G ≃ᴳ H → H ≃ᴳ G
_⁻¹ᴳ {G = G} {H = H} (φ , ie) = GroupIso.g-hom (φ , ie) , is-equiv-inverse ie

{- mimicking notations for equivalences -}

–>ᴳ : ∀ {i j} {G : Group i} {H : Group j} → (G ≃ᴳ H) → (G →ᴳ H)
–>ᴳ = GroupIso.f-hom

<–ᴳ : ∀ {i j} {G : Group i} {H : Group j} → (G ≃ᴳ H) → (H →ᴳ G)
<–ᴳ = GroupIso.g-hom

{- univalence -}

module _ {i} {G H : Group i} (iso : GroupIso G H) where
  private
    module G = Group G
    module H = Group H
    open module φ = GroupIso {G = G} {H = H} iso
  El= = ua f-equiv

  private
    ap3-lemma : ∀ {i j k l} {C : Type i} {D : C → Type j} {E : C → Type k}
      {F : Type l} {c₁ c₂ : C} {d₁ : D c₁} {d₂ : D c₂} {e₁ : E c₁} {e₂ : E c₂}
      (f : (c : C) → D c → E c → F) (p : c₁ == c₂)
      → (d₁ == d₂ [ D ↓ p ]) → (e₁ == e₂ [ E ↓ p ])
      → (f c₁ d₁ e₁ == f c₂ d₂ e₂)
    ap3-lemma f idp idp idp = idp

    ap3-lemma-El : ∀ {i} {G H : Group i}
      (p : Group.El G == Group.El H)
      (q : Group.El-level G == Group.El-level H [ _ ↓ p ])
      (r : Group.group-struct G == Group.group-struct H [ _ ↓ p ])
      → ap Group.El (ap3-lemma group p q r) == p
    ap3-lemma-El idp idp idp = idp

  {- a homomorphism which is an equivalence gives a path between groups -}
  abstract
    uaᴳ : G == H
    uaᴳ =
      ap3-lemma group
        El=
        (prop-has-all-paths-↓ has-level-is-prop)
        (↓-group-structure= (G.El-level) El= ident= inv= comp=)
      where
      ident= : G.ident == H.ident [ (λ C → C) ↓ El= ]
      ident= = ↓-idf-ua-in _ pres-ident

      inv= : G.inv == H.inv [ (λ C → C → C) ↓ El= ]
      inv= =
        ↓-→-from-transp $ λ= λ a →
          transport (λ C → C) El= (G.inv a)
            =⟨ to-transp (↓-idf-ua-in _ idp) ⟩
          f (G.inv a)
            =⟨ pres-inv a ⟩
          H.inv (f a)
            =⟨ ap H.inv (! (to-transp (↓-idf-ua-in _ idp))) ⟩
          H.inv (transport (λ C → C) El= a) =∎

      comp=' : (a : G.El)
        → G.comp a == H.comp (f a) [ (λ C → C → C) ↓ El= ]
      comp=' a =
        ↓-→-from-transp $ λ= λ b →
          transport (λ C → C) El= (G.comp a b)
            =⟨ to-transp (↓-idf-ua-in _ idp) ⟩
          f (G.comp a b)
            =⟨ pres-comp a b ⟩
          H.comp (f a) (f b)
            =⟨ ! (to-transp (↓-idf-ua-in _ idp))
               |in-ctx (λ w → H.comp (f a) w) ⟩
          H.comp (f a) (transport (λ C → C) El= b) =∎

      comp= : G.comp == H.comp [ (λ C → C → C → C) ↓ El= ]
      comp= =
        ↓-→-from-transp $ λ= λ a →
          transport (λ C → C → C) El= (G.comp a)
            =⟨ to-transp (comp=' a) ⟩
          H.comp (f a)
            =⟨ ! (to-transp (↓-idf-ua-in _ idp)) |in-ctx (λ w → H.comp w) ⟩
          H.comp (transport (λ C → C) El= a) =∎

    -- XXX This stretches the naming convention a little bit.
    El=-β : ap Group.El uaᴳ == El=
    El=-β = ap3-lemma-El El= _ _

{- homomorphism from equality of groups -}

coeᴳ : ∀ {i} {G H : Group i} → G == H → (G →ᴳ H)
coeᴳ idp = idhom _

coe!ᴳ : ∀ {i} {G H : Group i} → G == H → (H →ᴳ G)
coe!ᴳ idp = idhom _

coeᴳ-fun : ∀ {i} {G H : Group i} (p : G == H)
  → GroupHom.f (coeᴳ p) == coe (ap Group.El p)
coeᴳ-fun idp = idp

coe!ᴳ-fun : ∀ {i} {G H : Group i} (p : G == H)
  → GroupHom.f (coe!ᴳ p) == coe! (ap Group.El p)
coe!ᴳ-fun idp = idp

coeᴳ-β : ∀ {i} {G H : Group i} (iso : G ≃ᴳ H)
  → coeᴳ (uaᴳ iso) == GroupIso.f-hom iso
coeᴳ-β iso = group-hom= $
  coeᴳ-fun (uaᴳ iso)
  ∙ ap coe (El=-β iso)
  ∙ λ= (coe-β (GroupIso.f-equiv iso))

-- triviality

iso-preserves-trivial : ∀ {i j} {G : Group i} {H : Group j}
  → G ≃ᴳ H → is-trivialᴳ G → is-trivialᴳ H
iso-preserves-trivial iso G-is-trivial h =
    ! (GroupIso.f-g iso h)
  ∙ ap (GroupIso.f iso) (G-is-trivial _)
  ∙ GroupIso.pres-ident iso

iso-preserves'-trivial : ∀ {i j} {G : Group i} {H : Group j}
  → G ≃ᴳ H → is-trivialᴳ H → is-trivialᴳ G
iso-preserves'-trivial iso H-is-trivial g =
    ! (GroupIso.g-f iso g)
  ∙ ap (GroupIso.g iso) (H-is-trivial _)
  ∙ GroupHom.pres-ident (GroupIso.g-hom iso)

-- a surjective and injective homomorphism is an isomorphism
module _ {i j} {G : Group i} {H : Group j} (φ : G →ᴳ H)
  (surj : is-surjᴳ φ) (inj : is-injᴳ φ) where
  private
    module G = Group G
    module H = Group H
    module φ = GroupHom φ

    image-prop : (h : H.El) → is-prop (hfiber φ.f h)
    image-prop h = all-paths-is-prop $ λ {(g₁ , p₁) (g₂ , p₂) →
      pair= (inj g₁ g₂ (p₁ ∙ ! p₂)) (prop-has-all-paths-↓ (H.El-level _ _))}

  surjᴳ-and-injᴳ-is-equiv : is-equiv φ.f
  surjᴳ-and-injᴳ-is-equiv = contr-map-is-equiv
    (λ h → let (g₁ , p₁) = Trunc-rec (image-prop h) (idf _) (surj h) in
      ((g₁ , p₁) , (λ {(g₂ , p₂) →
        pair= (inj g₁ g₂ (p₁ ∙ ! p₂))
                (prop-has-all-paths-↓ (H.El-level _ _))})))

  surjᴳ-and-injᴳ-iso : G ≃ᴳ H
  surjᴳ-and-injᴳ-iso = φ , surjᴳ-and-injᴳ-is-equiv


-- isomorphisms preserve abelianess.
module _ {i} {G H : Group i} (iso : G ≃ᴳ H) (G-abelian : is-abelian G) where
  private
    module G = Group G
    module H = Group H
    open GroupIso iso

  abstract
    iso-preserves-abelian : is-abelian H
    iso-preserves-abelian h₁ h₂ =
      H.comp h₁ h₂
        =⟨ ap2 H.comp (! $ f-g h₁) (! $ f-g h₂) ⟩
      H.comp (f (g h₁)) (f (g h₂))
        =⟨ ! $ pres-comp (g h₁) (g h₂) ⟩
      f (G.comp (g h₁) (g h₂))
        =⟨ G-abelian (g h₁) (g h₂) |in-ctx f ⟩
      f (G.comp (g h₂) (g h₁))
        =⟨ pres-comp (g h₂) (g h₁) ⟩
      H.comp (f (g h₂)) (f (g h₁))
        =⟨ ap2 H.comp (f-g h₂) (f-g h₁) ⟩
      H.comp h₂ h₁
        =∎
