import Std

namespace ConfigOverlay

/-- Pure option-field overlay contract: an absent override keeps the base. -/
def overlay {α : Type} (base replacement : Option α) : Option α :=
  match replacement with
  | none => base
  | some value => some value

theorem missingKeepsBase {α : Type} (base : Option α) :
    overlay base none = base := rfl

theorem presentWins {α : Type} (base : Option α) (value : α) :
    overlay base (some value) = some value := rfl

theorem idempotent {α : Type} (base replacement : Option α) :
    overlay (overlay base replacement) replacement = overlay base replacement := by
  cases replacement <;> rfl

end ConfigOverlay
