# README

For each new steno layout, 3 things are needed:

- The full steno order for the layout's main theory as it would be used in a dictionary (including dashes, for example).
- An SVG diagram with sensible on/off colors for keys and letters.
- A mapping of steno order characters to steno diagram keys.

If [Overpass Mono](https://fonts.google.com/specimen/Overpass+Mono) does not support all the glyphs needed for a language’s characters, then you’ll also need an alternative Google Fonts hosted monospace typeface that supports all the characters needed.

Tests need to be written that at least cover:

- Numbers
- Punctuation
- Alternatives that may appear in a dictionary such as `#T` for `3` in English and `-` for middle keys that aren’t specified by keys.
- Distinguishing duplicated letters in the theory’s steno order (e.g. left-hand and right-hand "S")
- Distinguishing black and white keys for certain theories.

For an SVG diagram:

- The Sketch Artboard or main `<g>`s `id` must be the layout’s name e.g. `italian-michela`.
- The Sketch layers or shape `id`s for keys must match the test case’s key names e.g. `leftCapitalX`.
- Letters created using the monospace type must be converted to outlines.
- The Sketch layers or shape `id`s for letters should match the test case’s key names plus "Letter" e.g. `leftCapitalXLetter`.
- Drag the diagram into [SVGOMG icon optimizer](https://jakearchibald.github.io/svgomg/):
    - `Prettify markup`
    - `Remove xmlns`
    - Do NOT `Clean IDs`
    - Do NOT `Collapse useless groups`
    - `Remove <title>`
    - `Remove <desc>`

Add to Typey Type:

- Duplicate `src/StenoLayout/DanishStenoDiagram.js`.
- Copy optimized and react-ified SVG into `src/StenoLayout/NEWDiagram.js`.
- Import new diagram in intended locations (search for `Danish`):
    - Add map keys to briefs function.
    - Add user setting.



# Installation

```
$ gem install nokogiri
$ yarn add svg-to-jsx
$ chmod +x ./prepare-optimized-svg-for-react-component.rb
```



# Usage

```
$ ./prepare-optimized-svg-for-react-component.rb source-svgs/italian-michela.svg target-js/ItalianMichelaStenoDiagram.js
```



# TODO

- [ ] abstract Italian to work for any language:
    - [ ] duplicate script for Korean, make it work for that, see what is in common, then combine
    - [ ] generalise config to live in a JSON file
- [ ] add command line svgo with given set of arguments instead of using web UI

