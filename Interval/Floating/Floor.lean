import Interval.Floating.Basic
import Interval.Floating.Order

/-!
## Floating point floor, producing `Int64`
-/

open Set
open scoped Real
namespace Floating

/-- Floor -/
@[irreducible] def floor (x : Floating) : Fixed 0 :=
  bif x == nan || 2^63 < x.s then nan else
  ⟨x.n.shiftRightRound (2^63 - x.s) false⟩

/-- `floor` is conservative -/
@[approx] lemma mem_approx_floor (x : Floating) : ↑⌊x.val⌋ ∈ approx x.floor := by
  rw [floor]
  simp only [bif_eq_if, Bool.or_eq_true, beq_iff_eq, decide_eq_true_eq]
  by_cases xn : x = nan
  · simp only [xn, s_nan, true_or, n_nan, decide_True, ite_true, Fixed.approx_nan, mem_univ]
  simp only [xn, false_or]
  by_cases s63 : 2^63 < x.s
  · simp only [s63, ite_true, Fixed.approx_nan, mem_univ]
  simp only [s63, ite_false, approx, mem_if_univ_iff]
  intro n; clear n
  rw [val, Fixed.val]
  simp only [not_lt] at s63
  have eq : ((x.n : ℤ) : ℝ) * 2^(x.s.toInt - 2 ^ 63) =
      ((x.n : ℤ) / (2^(2^63 - x.s.toNat) : ℕ) : ℚ) := by
    simp only [UInt64.le_iff_toNat_le, UInt64.toNat_2_pow_63] at s63
    simp only [UInt64.toInt, Nat.cast_pow, Nat.cast_ofNat, Rat.cast_div, Rat.cast_intCast,
      Rat.cast_pow, Rat.cast_ofNat, ←neg_sub (2^63 : ℤ), zpow_neg, ←div_eq_mul_inv,
      ←zpow_natCast, Nat.cast_sub s63, Rat.cast_zpow, Rat.cast_ofNat]
  simp only [mul_neg_iff, Int.cast_pos, Int64.coe_pos_iff, two_zpow_not_neg, and_false,
    Int.cast_lt_zero, two_zpow_pos, and_true, false_or, Int64.coe_shiftRightRound,
    UInt64.toNat_sub'' s63, UInt64.toNat_2_pow_63, Int64.coe_zero, zpow_zero, mul_one,
    mem_singleton_iff, Int.cast_inj, eq, Rat.floor_cast, Rat.floor_int_div_nat_eq_div]
  rw [Int.rdiv, Nat.cast_pow, Nat.cast_ofNat, cond_false]

@[simp] lemma floor_nan : (nan : Floating).floor = nan := by
  rw [floor]; simp only [beq_self_eq_true, s_nan, Bool.true_or, n_nan, cond_true]

@[simp] lemma ne_nan_of_floor {x : Floating} (n : x.floor ≠ nan) : x ≠ nan := by
  contrapose n; simp only [not_not] at n; simp [n]

lemma floor_mono {x y : Floating} (le : x ≤ y) (yn : y.floor ≠ nan) : x.floor ≤ y.floor := by
  by_cases xn : x.floor = nan
  · simp [xn]
  have hx := mem_approx_floor x
  have hy := mem_approx_floor y
  simp only [approx, xn, ↓reduceIte, mem_singleton_iff, yn] at hx hy
  simp only [Fixed.le_iff, ← hx, ← hy, Int.cast_le]
  bound
