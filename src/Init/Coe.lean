/-
Copyright (c) 2020 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import Init.HasCoe -- import legacy HasCoe
import Init.Core

universes u v w w'

class Coe (α : Sort u) (β : Sort v) :=
(coe : α → β)

class CoeDep (α : Sort u) (a : α) (β : Sort v) :=
(coe : β)

/-- Auxiliary class that contains the transitive closure of `Coe` and `CoeDep`. -/
class CoeTC (α : Sort u) (a : α) (β : Sort v) :=
(coe : β)

/- Expensive coercion that can only appear at the beggining of a sequence of coercions. -/
class CoeHead (α : Sort u) (β : Sort v) :=
(coe : α → β)

/- Expensive coercion that can only appear at the end of a sequence of coercions. -/
class CoeTail (α : Sort u) (β : Sort v) :=
(coe : α → β)

/- CoeHead + CoeTC + CoeTail -/
class CoeT (α : Sort u) (a : α) (β : Sort v) :=
(coe : β)

class CoeFun (α : Sort u) (a : α) (γ : outParam (Sort v)) :=
(coe : γ)

class CoeSort (α : Sort u) (a : α) (β : outParam (Sort v)) :=
(coe : β)

abbrev coeB {α : Sort u} {β : Sort v} (a : α) [Coe α β] : β :=
@Coe.coe α β _ a

abbrev coeHead {α : Sort u} {β : Sort v} (a : α) [CoeHead α β] : β :=
@CoeHead.coe α β _ a

abbrev coeTail {α : Sort u} {β : Sort v} (a : α) [CoeTail α β] : β :=
@CoeTail.coe α β _ a

abbrev coeD {α : Sort u} {β : Sort v} (a : α) [CoeDep α a β] : β :=
@CoeDep.coe α a β _

abbrev coeTC {α : Sort u} {β : Sort v} (a : α) [CoeTC α a β] : β :=
@CoeTC.coe α a β _

/-- Apply coercion manually. -/
abbrev coe {α : Sort u} {β : Sort v} (a : α) [CoeT α a β] : β :=
@CoeT.coe α a β _

abbrev coeFun {α : Sort u} {γ : Sort v} (a : α) [CoeFun α a γ] : γ :=
@CoeFun.coe α a γ _

abbrev coeSort {α : Sort u} {β : Sort v} (a : α) [CoeSort α a β] : β :=
@CoeSort.coe α a β _

instance coeDepTrans {α : Sort u} {β : Sort v} {δ : Sort w} (a : α) [CoeTC α a β] [CoeDep β (coeTC a) δ] : CoeTC α a δ :=
{ coe := coeD (coeTC a : β) }

instance coeTrans {α : Sort u} {β : Sort v} {δ : Sort w} (a : α) [CoeTC α a β] [Coe β δ] : CoeTC α a δ :=
{ coe := coeB (coeTC a : β) }

instance coeBase {α : Sort u} {β : Sort v} (a : α) [Coe α β] : CoeTC α a β :=
{ coe := coeB a }

instance coeDepBase {α : Sort u} {β : Sort v} (a : α) [CoeDep α a β] : CoeTC α a β :=
{ coe := coeD a }

instance coeOfHeafOfTCOfTail {α : Sort u} {β : Sort v} {δ : Sort w} {γ : Sort w'} (a : α) [CoeHead α β] [CoeTC β (coeHead a) δ] [CoeTail δ γ] : CoeT α a γ :=
{ coe := coeTail (coeTC (coeHead a : β) : δ) }

@[inferTCGoalsLR]
instance coeOfHeadOfTC {α : Sort u} {β : Sort v} {δ : Sort w} (a : α) [CoeHead α β] [CoeTC β (coeHead a) δ] : CoeT α a δ  :=
{ coe := coeTC (coeHead a : β) }

instance coeOfTCOfTail {α : Sort u} {β : Sort v} {δ : Sort w} (a : α) [CoeTC α a β] [CoeTail β δ] : CoeT α a δ :=
{ coe := coeTail (coeTC a : β) }

instance coeOfHead {α : Sort u} {β : Sort v} (a : α) [CoeHead α β] : CoeT α a β :=
{ coe := coeHead a }

instance coeOfTail {α : Sort u} {β : Sort v} (a : α) [CoeTail α β] : CoeT α a β :=
{ coe := coeTail a }

instance coeOfTC {α : Sort u} {β : Sort v} (a : α) [CoeTC α a β] : CoeT α a β :=
{ coe := coeTC a }

@[inferTCGoalsLR]
instance coeFunDepTrans {α : Sort u} {β : Sort v} {γ : Sort w} (a : α) [CoeDep α a β] [CoeFun β (coe a) γ] : CoeFun α a γ :=
{ coe := coeFun (coeD a : β) }

@[inferTCGoalsLR]
instance coeSortDepTrans {α : Sort u} {β : Sort v} {δ : Sort w} (a : α) [CoeDep α a β] [CoeSort β (coe a) δ] : CoeSort α a δ :=
{ coe := coeSort (coeD a : β) }

@[inferTCGoalsLR]
instance coeFunTrans {α : Sort u} {β : Sort v} {γ : Sort w} (a : α) [Coe α β] [CoeFun β (coe a) γ] : CoeFun α a γ :=
{ coe := coeFun (coeB a : β) }

@[inferTCGoalsLR]
instance coeSortTrans {α : Sort u} {β : Sort v} {δ : Sort w} (a : α) [Coe α β] [CoeSort β (coe a) δ] : CoeSort α a δ :=
{ coe := coeSort (coeB a : β) }

/- Basic instances -/

instance boolToProp : Coe Bool Prop :=
{ coe := fun b => b = true }

instance coeDecidableEq (x : Bool) : Decidable (coe x) :=
inferInstanceAs (Decidable (x = true))

instance decPropToBool (p : Prop) [Decidable p] : CoeDep Prop p Bool :=
{ coe := decide p }

instance optionCoe {α : Type u} : CoeTail α (Option α) :=
{ coe := some }

instance subtypeCoe {α : Sort u} {p : α → Prop} : CoeHead { x // p x } α :=
{ coe := fun v => v.val }

/- Coe & HasOfNat bridge -/

/-
  Remark: one may question why we use `HasOfNat α` instead of `Coe Nat α`.
  Reason: `HasOfNat` is for implementing polymorphic numeric literals, and we may
  want to have numberic literals for a type α and **no** coercion from `Nat` to `α`.
-/
instance hasOfNatOfCoe {α : Type u} {β : Type v} [HasOfNat α] [∀ a, CoeTC α a β] : HasOfNat β :=
{ ofNat := fun (n : Nat) => coe (HasOfNat.ofNat α n) }
