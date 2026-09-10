LazDatasnap Visual Web IDE - Class Definitions

This directory is the component registration directory for the HTML editor.

Each .ini file registers one component in the Component Palette, similar to
RegisterComponents in Lazarus/Delphi.

Format:

[Component]
Name=Button
Category=Buttons
HTML=<button class="btn btn-primary">Button</button>
Icon=icons/button.bmp
Enabled=1
Order=1

Icon:
- relative to libs/editor
- 24x24 bitmap
- shown alone in the palette button
- component Name is shown as the Hint

To add a new visual HTML component:
1. create its 24x24 icon in libs/editor/icons
2. create its class definition .ini here
3. restart/reopen the PageProducer designer

No source-code registration is required for components defined here.
