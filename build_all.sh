#!/usr/bin/env bash

set -euo pipefail

echo building diagrams:
echo Brazilian Portugese
ruby ./brazilian-portuguese-prepare-optimized-svg-for-react-component.rb source-svgs/brazilian-portuguese.svg target-js/BrazilianPortugueseStenoDiagram.js

echo Italian Michela
ruby ./italian-michela-prepare-optimized-svg-for-react-component.rb source-svgs/italian-michela.svg target-js/ItalianMichelaStenoDiagram.js

echo Japanese
ruby ./japanese-prepare-optimized-svg-for-react-component.rb source-svgs/japanese.svg target-js/JapaneseStenoDiagram.js

echo Inner Thumbers
ruby ./no-number-bar-inner-thumb-numbers-prepare-optimized-svg-for-react-component.rb source-svgs/no-number-bar-inner-thumb-numbers.svg target-js/NoNumberBarInnerThumbNumbersStenoDiagram.js

echo Outer Thumbers
ruby ./no-number-bar-outer-thumb-numbers-prepare-optimized-svg-for-react-component.rb source-svgs/no-number-bar-outer-thumb-numbers.svg target-js/NoNumberBarOuterThumbNumbersStenoDiagram.js

echo Yawei Chinese
ruby ./yawei-chinese-prepare-optimized-svg-for-react-component.rb source-svgs/yawei-chinese.svg target-js/YaweiChineseStenoDiagram.js

echo Lapwing
ruby lapwing-prepare-optimized-svg-for-react-component.rb source-svgs/lapwing.svg target-js/LapwingStenoDiagram.js
