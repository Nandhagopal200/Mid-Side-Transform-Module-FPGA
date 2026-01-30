# Design Rationale

This document explains why the Mid-Side block is designed the way it is.

---

## Single-Purpose Core Philosophy

The design is split into:

- arithmetic cores (`mid_side_core`, `mid_side_inverse`)
- an AXI wrapper handling protocol and control

This separation ensures:

- predictable behavior
- reusable arithmetic logic
- clean protocol boundaries

---

## Fixed-Point Arithmetic

- Input and output width: 16-bit signed
- Internal expansion: 24-bit signed
- Explicit truncation and saturation

All numeric behavior is intentional and documented.

---

## Reset Strategy

The arithmetic cores do not contain reset logic.

Reasons:
- no internal state
- deterministic behavior
- easier composition in pipelines

Reset is handled exclusively at the wrapper level.

---

## Saturation Policy

Saturation is applied only in the inverse transform.

Rationale:
- Forward Mid-Side transform is inherently safe after scaling
- Inverse reconstruction may overflow
- Saturation is preferable to wrap-around in audio pipelines

---

## Scope Control

This design intentionally does not include:

- gain control
- mid/side weighting
- application-specific logic

Those belong at higher integration levels.
