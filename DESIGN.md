---
name: Modern Haven
version: alpha
colors:
  primary: "#1E293B"
  primary-container: "#334155"
  on-primary: "#FFFFFF"
  secondary: "#D97706"
  on-secondary: "#FFFFFF"
  tertiary: "#0D9488"
  on-tertiary: "#FFFFFF"
  background: "#F8FAFC"
  surface: "#FFFFFF"
  on-background: "#0F172A"
  on-surface: "#1E293B"
  error: "#E11D48"
  success: "#10B981"
  neutral-variant: "#64748B"
typography:
  h1:
    fontFamily: Outfit
    fontSize: 2.25rem
    fontWeight: 700
  h2:
    fontFamily: Outfit
    fontSize: 1.75rem
    fontWeight: 600
  body-lg:
    fontFamily: Inter
    fontSize: 1.125rem
    fontWeight: 400
  body-md:
    fontFamily: Inter
    fontSize: 1rem
    fontWeight: 400
  label-sm:
    fontFamily: Inter
    fontSize: 0.75rem
    fontWeight: 500
rounded:
  sm: 8px
  md: 12px
  lg: 24px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.md}"
    padding: 16px
  button-secondary:
    backgroundColor: "{colors.secondary}"
    textColor: "{colors.on-secondary}"
    rounded: "{rounded.md}"
    padding: 16px
  card-apartment:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.md}"
    padding: 16px
---

## Overview

Modern Haven is a premium, clean design system tailored for the **Apartment Building Management System**. It balances institutional trust with modern residential warmth. The style is inspired by modern hospitality and luxury real estate dashboards: crisp typography, spacious layouts, subtle elevation, and a balanced warm-cool color palette.

---

## Colors

The color system uses deep slate tones for primary structure, paired with a warm golden amber for active branding and interaction, and an emerald teal for secondary highlights/success states.

- **Primary (`#1E293B`):** Dark Slate. Conveys authority, safety, and modern structural engineering.
- **Secondary (`#D97706`):** Warm Amber. Evokes residential warmth, keys, sunlight, and premium hospitality. Used for key action highlights and notifications.
- **Tertiary (`#0D9488`):** Teal. Used for utility payments, financial states, and successful transactions.
- **Background (`#F8FAFC`):** Very soft warm slate tint. Reduces eye strain while remaining crisp.
- **Surface (`#FFFFFF`):** Pure white for cards, sheets, and interactive elements to stand out against the soft background.

---

## Typography

We employ two typeface families to distinguish structural and editorial tone:

- **Outfit (Display):** A geometric sans-serif with a warm, friendly character. Used for all primary headings, metrics, and key numbers.
- **Inter (Body/Label):** A highly legible workhorse typeface designed for screen interfaces. Used for body copy, form fields, and dense UI labels.

---

## Layout & Spacing

A strict 8dp grid governs all layout, margins, and padding.

- **`xs` (4px):** Tight text-to-icon spacing, micro-adjustments.
- **`sm` (8px):** Padding inside list items, spacing between related elements.
- **`md` (16px):** Default standard mobile margin. Padding inside cards, list items, and standard components.
- **`lg` (24px):** Layout padding for screen edges, spacing between major content sections.
- **`xl` (32px):** Hero component margins, empty-state illustration gaps.

---

## Elevation & Depth

To preserve the clean hospitality aesthetic, depth is suggested through subtle shadows and tint overlays rather than heavy outlines.

- **Level 0 (Flat):** Inputs, lists, and background surface.
- **Level 1 (Card):** Standard interactive cards. Shadow: `0px 2px 8px rgba(15, 23, 42, 0.04)`.
- **Level 2 (Active/Modal):** Sheets, dialogs, dropdowns. Shadow: `0px 8px 24px rgba(15, 23, 42, 0.08)`.

---

## Shapes

Rounded corners follow a hierarchical scale based on element size to maintain a soft, friendly UI.

- **`sm` (8px):** Small elements: tags, badges, input fields.
- **`md` (12px):** Medium elements: primary cards, buttons, dialog containers.
- **`lg` (24px):** Large elements: bottom sheets, floating action buttons (FABs), chips.

---

## Components

### Buttons
Primary actions occupy full width with a rounded corner and prominent brand contrast. Secondary actions utilize outline or minimal style using secondary colors.

### Cards
Building modules and apartment cards use a white surface background, subtle `Level 1` shadow, and `rounded.md` curves to form clean containers for content.

---

## Do's and Don'ts

### Do:
- Keep background clean and let whites/slate cards structure the page.
- Apply `Outfit` strictly for metrics (e.g., "$150.00", "Room 402") to make numbers legible and elegant.
- Use `spacing.md` (16dp) as the default spacing standard for all mobile margins.

### Don't:
- Do not use solid black text; always use `colors.on-background` (Slate 900) or `colors.on-surface` (Slate 800) for softer contrast.
- Do not use high-saturation primaries for backgrounds.
- Do not mix corner radiuses arbitrarily on the same page.
