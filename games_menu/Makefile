default: all

clean:
	rm -rf build

all:
	mkdir -p build build/windows build/MENU
	cp D.GAMESDB.TXT D.GAMES D.GAMES.inf The_Games_Menu.txt build/
	for f in \!BOOT CHCODE CHE00 MENU A.GAMES D.GAMES; do cp "MENU/$$f" "MENU/$$f.inf" build/MENU/; done
	cp windows/GamesDB.mdb windows/MakeGameData.exe build/windows/
