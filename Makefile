all: run

run: manifest.json content.js LICENSE
	zip firefoxpkg.zip manifest.json content.js LICENSE icons/*

clean:
	$(RM) firefoxpkg.zip
