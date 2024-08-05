# README

This project is has utility scripts to manually convert an SVG steno diagram to React syntax for use in [Typey Type for Stenographers](https://didoesdigital.com/typey-type).

For each new steno layout, 3 things are needed:

- The full steno order for the layout's main theory as it would be used in a dictionary (including dashes, for example).
- An SVG diagram with sensible on/off colors for keys and letters.
- A mapping of steno order characters to steno diagram keys.

For designing the diagram itself, if [Overpass Mono](https://fonts.google.com/specimen/Overpass+Mono) does not support all the glyphs needed for a language’s characters, then you’ll also need an alternative Google Fonts hosted monospace typeface that supports all the characters needed.

In Typey Type, tests need to be written that at least cover:

- Numbers
- Punctuation
- Alternatives that may appear in a dictionary such as `#T` for `3` in English and `-` for middle keys that aren’t specified by keys.
- Distinguishing duplicated letters in the theory’s steno order (e.g. left-hand and right-hand "S")
- Distinguishing black and white keys for certain theories.

Use the scripts in this project to convert exported SVGs into React syntax.

# Installation

Pre-requisites. You need ruby and node.js before installing:

```sh
$ gem install nokogiri
$ yarn install
$ chmod +x ./italian-michela-prepare-optimized-svg-for-react-component.rb
$ chmod +x ./japanese-prepare-optimized-svg-for-react-component.rb
$ chmod +x ./brazilian-portuguese-prepare-optimized-svg-for-react-component.rb
```



# Usage

Before making changes to diagrams, run the code at least once and check the git diff to make sure the output doesn't change and works as expected. This will catch any issues in build tools like version changes.

For hobbyist layouts with no number bar and with outer number keys:

```sh
./no-number-bar-inner-thumb-numbers-prepare-optimized-svg-for-react-component.rb source-svgs/no-number-bar-inner-thumb-numbers.svg target-js/NoNumberBarInnerThumbNumbersStenoDiagram.js
```

```sh
./no-number-bar-outer-thumb-numbers-prepare-optimized-svg-for-react-component.rb source-svgs/no-number-bar-outer-thumb-numbers.svg target-js/NoNumberBarOuterThumbNumbersStenoDiagram.js
```

For Brazilian Portuguese:

```sh
./brazilian-portuguese-prepare-optimized-svg-for-react-component.rb source-svgs/brazilian-portuguese.svg target-js/BrazilianPortugueseStenoDiagram.js
```

For Italian Michela:

```sh
./italian-michela-prepare-optimized-svg-for-react-component.rb source-svgs/italian-michela.svg target-js/ItalianMichelaStenoDiagram.js
```

For Japanese:

```sh
./japanese-prepare-optimized-svg-for-react-component.rb source-svgs/japanese.svg target-js/JapaneseStenoDiagram.js
```

## Adding new layout diagrams

In Figma:

- Make an "off" vector diagram with proper text as an editable source
- Name all the layers correctly considering left/right, lower/upper, one/two, star, numberBar, and numbers (and not starting JavaScript variable names with numbers) e.g. `leftTKey` and `leftT` for the key and letter, respectively, `starKey`, `rightDLower`, `numberBar`, `leftCapitalC`, `leftPlusOne`, `rightCaretOne`, `the8Key`
- Order the layers in *reverse* steno order so they end up in steno order in code
- Make sure "Clip content" on the outer frame is turned off
- Make an "on" version of the diagram just to make sure it looks sensible and legible
- When ready to export, convert the "off" version's text to outlines
- In the Export settings, make sure `Include "id" attribute` is checked in order to `Explort layer names using id`
- Export the SVG

In this repo:

- Add the exported SVG into `source-svgs/*.svg`
- Check key and letter IDs in exported SVG for any duplicates or mistakes
- Duplicate the most relevant `*prepare-optimized-svg-for-react-component.rb` script file
- Copy source SVG IDs into script `KEYS` and `SYMBOLS` constants
- Update this README and run the script

To add the finalised diagram to Typey Type:

- Duplicate `src/StenoLayout/BrazilianPortugueseStenoDiagram.js`.
- Copy optimized and react-ified SVG into `src/StenoLayout/NEWDiagram.js`.
- Fix hard-coded width to `width={diagramWidth}`
- Import new diagram in intended locations (search for `BrazilianPortuguese`):
    - Add map keys to briefs function:
        - Duplicate `src/utils/stenoLayouts/mapBriefToBrazilianPortugueseStenoKeys.ts` and `src/utils/stenoLayouts/mapBriefToBrazilianPortugueseStenoKeys.test.ts`.
        - Amend test and logic until they make sense and pass.
    - Add user setting.
        - Decide on name and order in UI
    - Double-check all imports are from the correct files.



# Archive

Here are the previous steps for Sketch diagrams…

For preparing and exporting the SVG diagram from Sketch:

- The Sketch Artboard or main `<g>`s `id` must be the layout’s name e.g. `italian-michela`.
- The Sketch layers or shape `id`s for keys must match the test case’s key names e.g. `leftCapitalX`.
- Letters created using the monospace type must be converted to outlines (and then renamed).
    - Layer names get borked by Sketch when converting to outlines.
- The Sketch layers or shape `id`s for letters should match the test case’s key names plus "Letter" e.g. `leftCapitalXLetter`.
- The following is handled by command line `svgo`:
    - Drag the diagram into [SVGOMG icon optimizer](https://jakearchibald.github.io/svgomg/):
        - `Prettify markup`
        - `Remove xmlns`
        - Do NOT `Clean IDs`
        - Do NOT `Collapse useless groups`
        - `Remove <title>`
        - `Remove <desc>`

