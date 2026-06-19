# Architecture

## Overview

<!-- Describe the high-level architecture of the project -->

## Key Components

<!-- Document the main components/modules and their responsibilities -->

## Design Principles

<!-- List the key design principles guiding the architecture -->

1. **Principle 1** — Description
2. **Principle 2** — Description

## Diagram Examples

### Mermaid Diagrams

Use the `{mermaid}` directive to embed diagrams directly in Markdown:

````markdown
```{mermaid}
graph TD
    A[User] --> B[Browser]
    B --> C[GitHub Pages]
    C --> D[Sphinx HTML]
```
````

Supported diagram types: flowchart, sequence, class, state, ER, Gantt, pie, and more.
See [Mermaid documentation](https://mermaid.js.org/) for syntax reference.

### Collapsible Sections

Use `{toggle}` to create collapsible content (e.g., for detailed explanations or optional content):

````markdown
:::{toggle}
This content is hidden by default and revealed on click.
:::
````

To show the section expanded by default, add the `:show:` option:

````markdown
:::{toggle} Click to collapse
:show:
This content is visible by default.
:::
````
