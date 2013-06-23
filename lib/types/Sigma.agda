{-# OPTIONS --without-K #-}

open import lib.Basics

module lib.types.Sigma where

-- Cartesian product
_×_ : ∀ {i j} (A : Type i) (B : Type j) → Type (max i j)
A × B = Σ A (λ _ → B)

module _ {i j} {A : Type i} {B : A → Type j} where

  pair : (a : A) (b : B a) → Σ A B
  pair a b = (a , b)

  -- pair= has already been defined

  fst= : {ab a'b' : Σ A B} (p : ab == a'b') → (fst ab == fst a'b')
  fst= = ap fst

  snd= : {ab a'b' : Σ A B} (p : ab == a'b')
    → (snd ab == snd a'b' [ B ↓ fst= p ])
  snd= {._} {_} idp = idp

  fst=-β : {a a' : A} (p : a == a')
    {b : B a} {b' : B a'} (q : b == b' [ B ↓ p ])
    → fst= (pair= p q) == p
  fst=-β idp idp = idp

  snd=-β : {a a' : A} (p : a == a')
    {b : B a} {b' : B a'} (q : b == b' [ B ↓ p ])
    → snd= (pair= p q) == q [ (λ v → b == b' [ B ↓ v ]) ↓ fst=-β p q ]
  snd=-β idp idp = idp

  pair=-η : {ab a'b' : Σ A B} (p : ab == a'b')
    → p == pair= (fst= p) (snd= p)
  pair=-η {._} {_} idp = idp

  pair== : {a a' : A} {p p' : a == a'} (α : p == p')
           {b : B a} {b' : B a'} {q : b == b' [ B ↓ p ]} {q' : b == b' [ B ↓ p' ]}
           (β : q == q' [ (λ u → b == b' [ B ↓ u ]) ↓ α ])
    → pair= p q == pair= p' q'
  pair== idp idp = idp

module _ {i j} {A : Type i} {B : A → Type j} where

  Σ= : (x y : Σ A B) → Type (max i j)
  Σ= (a , b) (a' , b') = Σ (a == a') (λ p → b == b' [ B ↓ p ])

  Σ=-eqv : (x y : Σ A B) →  (Σ= x y) ≃ (x == y)
  Σ=-eqv x y =
    equiv (λ pq → pair= (fst pq) (snd pq)) (λ p → fst= p , snd= p)
          (λ p → ! (pair=-η p))
          (λ pq → pair= (fst=-β (fst pq) (snd pq)) (snd=-β (fst pq) (snd pq)))

  Σ=-path : (x y : Σ A B) → (Σ= x y) == (x == y)
  Σ=-path x y = ua (Σ=-eqv x y)

abstract

  Σ-level : ∀ {i j} {n : ℕ₋₂} {A : Set i} {P : A → Set j}
    → (has-level n A → ((x : A) → has-level n (P x))
      → has-level n (Σ A P))
  Σ-level {n = ⟨-2⟩} p q =
    ((fst p , (fst (q (fst p)))) ,
      (λ y → pair= (snd p _) (from-transp! _ _ (snd (q _) _))))
  Σ-level {n = S n} p q = λ x y → equiv-preserves-level (Σ=-eqv x y)
    (Σ-level (p _ _)
      (λ _ → equiv-preserves-level ((to-transp-equiv _ _)⁻¹) (q _ _ _)))

  ×-level : ∀ {i j} {n : ℕ₋₂} {A : Set i} {B : Set j}
    → (has-level n A → has-level n B → has-level n (A × B))
  ×-level pA pB = Σ-level pA (λ x → pB)

-- Equivalences in a Σ-type

equiv-Σ-fst : ∀ {i j k} {A : Type i} {B : Type j} (P : B → Type k) {h : A → B}
                  → is-equiv h → (Σ A (P ∘ h)) ≃ (Σ B P)
equiv-Σ-fst {A = A} {B = B} P {h = h} e = equiv f g f-g g-f
  where f : Σ A (P ∘ h) → Σ B P
        f (a , r) = (h a , r)

        g : Σ B P → Σ A (P ∘ h)
        g (b , s) = (is-equiv.g e b , transport P (! (is-equiv.f-g e b)) s)

        f-g : ∀ y → f (g y) == y
        f-g (b , s) = pair= (is-equiv.f-g e b) (trans-↓ P (is-equiv.f-g e b) s)

        g-f : ∀ x → g (f x) == x
        g-f (a , r) = 
          pair= (is-equiv.g-f e a) 
                (transport (λ q → transport P (! q) r == r [ P ∘ h ↓ is-equiv.g-f e a ]) 
                           (is-equiv.adj e a) 
                           (trans-ap-↓ P h (is-equiv.g-f e a) r) )

equiv-Σ-snd : ∀ {i j k} {A : Type i} {B : A → Type j} {C : A → Type k}
  → (∀ x → B x ≃ C x) → Σ A B ≃ Σ A C
equiv-Σ-snd {A = A} {B = B} {C = C} k = equiv f g f-g g-f
  where f : Σ A B → Σ A C
        f (a , b) = (a , fst (k a) b)

        g : Σ A C → Σ A B
        g (a , c) = (a , is-equiv.g (snd (k a)) c)

        f-g : ∀ p → f (g p) == p
        f-g (a , c) = pair= idp (is-equiv.f-g (snd (k a)) c)

        g-f : ∀ p → g (f p) == p
        g-f (a , b) = pair= idp (is-equiv.g-f (snd (k a)) b)


-- Implementation of [_∙'_] on Σ
Σ-∙' : ∀ {i j} {A : Set i} {B : A → Set j}
  {x y z : A} {p : x == y} {p' : y == z}
  {u : B x} {v : B y} {w : B z}
  (q : u == v [ B ↓ p ]) (r : v == w [ B ↓ p' ])
  → (pair= p q ∙' pair= p' r) == pair= (p ∙' p') (q ∙'dep r)
Σ-∙' {p' = idp} q idp = idp

-- Implementation of [_∙_] on Σ
Σ-∙ : ∀ {i j} {A : Set i} {B : A → Set j}
  {x y z : A} {p : x == y} {p' : y == z}
  {u : B x} {v : B y} {w : B z}
  (q : u == v [ B ↓ p ]) (r : v == w [ B ↓ p' ])
  → (pair= p q ∙ pair= p' r) == pair= (p ∙ p') (q ∙dep r)
Σ-∙ {p = idp} idp q = idp

-- Implementation of [_∙'_] on ×
×-∙' : ∀ {i j} {A : Set i} {B : Set j}
  {x y z : A} (p : x == y) (p' : y == z)
  {u v w : B} (q : u == v) (q' : v == w)
  → (pair=' p q ∙' pair=' p' q') == pair=' (p ∙' p') (q ∙' q')
×-∙' p idp q idp = idp

-- Implementation of [_∙_] on ×
×-∙ : ∀ {i j} {A : Set i} {B : Set j}
  {x y z : A} (p : x == y) (p' : y == z)
  {u v w : B} (q : u == v) (q' : v == w)
  → (pair=' p q ∙ pair=' p' q') == pair=' (p ∙ p') (q ∙ q')
×-∙ idp p' idp q' = idp

-- Special case of [ap-,]
ap-cst,id : ∀ {i j} {A : Set i} (B : A → Set j)
  {a : A} {x y : B a} (p : x == y)
  → ap (λ x → _,_ {B = B} a x) p == pair= idp p
ap-cst,id B idp = idp
