## Blackbook UI components (Tailwind)

We use Tailwind utility classes in views, but when a pattern repeats across the app, we extract it into a **small** set of component classes using `@apply`.

- **Source of truth**: `app/assets/tailwind/application.css` (Tailwind v4 input; includes `@layer components`)
- **Naming**: `bb-*` to avoid collisions with Tailwind or third-party CSS
- **Rule of thumb**: don’t invent a component unless the same utility bundle appears repeatedly.

### Layout

- **`bb-page`**: standard page section wrapper
  - **Use when**: the page should have consistent vertical spacing and background
  - **Example**: `<section class="bb-page">…</section>`

- **`bb-container`**: standard wide container (`max-w-7xl`)
  - **Example**: `<div class="bb-container">…</div>`

- **`bb-container-md`**: standard form/container width (`max-w-md`)
  - **Example**: `<div class="bb-container-md">…</div>`

### Surfaces

- **`bb-card`**: base card surface (white, rounded, shadow)
- **`bb-card--form`**: form padding (pairs with `bb-card`)
- **`bb-card--panel`**: panel padding (pairs with `bb-card`)

Examples:

- `<div class="bb-card bb-card--form">…</div>`
- `<div class="bb-card bb-card--panel">…</div>`

### Typography

- **`bb-heading-xl`**: standard page heading
- **`bb-subtitle`**: standard muted subtitle text

### Forms

- **`bb-label`**: standard bold field label
- **`bb-input`**: standard text/select input styling

Notes:

- If you need an icon inside an input, use `bb-input` plus padding overrides:
  - `class="bb-input pl-10 pr-3"`

### Links

- **`bb-link`**: standard primary link styling

### Buttons

- **`bb-btn`**: base button styling (padding, weight, radius, transitions)
- **`bb-btn--full`**: full-width button
- **`bb-btn-primary`**: primary action color
- **`bb-btn-danger`**: destructive action color

Examples:

- `class="bb-btn bb-btn-primary"`
- `class="bb-btn bb-btn-primary bb-btn--full"`
- `class="bb-btn bb-btn-danger bb-btn--full"`

### Navigation

- **`bb-nav-link`**: standard navbar link

### Pills

- **`bb-pill`**: base pill shape
- **`bb-pill-blue`**: blue pill variant
- **`bb-pill-gray`**: gray pill variant

Example:

- `<span class="bb-pill bb-pill-blue">Tag</span>`

