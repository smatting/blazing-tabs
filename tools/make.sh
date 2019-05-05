rm -f build/*
elm make src/Main.elm --output=build/elm.js
# sed -i 's/http:\/\/localhost:8888/https:\/\/bibot-stage1.askby.net/g' build/elm.js
cp assets/*.css build/
# cp assets/index.html build/index.html
