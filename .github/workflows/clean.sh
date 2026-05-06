#!/bin/bash
REPO_DIR="./x86_64"

echo "--- Rozpoczynam porządki w Bashu ---"

# 1. Usuwanie fizyczne plików debug
echo "Usuwanie plików *-debug-*"
rm -f $REPO_DIR/*-debug-*

# 2. Usuwanie starych wersji (zostawiamy 2 najnowsze)
echo "Czyszczenie starych wersji..."
# Pobieramy listę unikalnych nazw pakietów (wszystko przed pierwszym myślnikiem i cyfrą)
PKG_NAMES=$(ls $REPO_DIR/*.pkg.tar.zst 2>/dev/null | sed 's/-[0-9].*//' | sort -u)

for pkg in $PKG_NAMES; do
    # Liczymy ile jest wersji danego pakietu
    COUNT=$(ls -1t $pkg-* 2>/dev/null | wc -l)
    if [ "$COUNT" -gt 2 ]; then
        # Usuwamy wszystko poza 2 najnowszymi (sortowanie po czasie -t)
        ls -1t $pkg-* | tail -n +3 | xargs rm -f
        echo "Usunięto stare wersje dla: $(basename $pkg)"
    fi
done

# 3. Aktualizacja bazy danych
echo "Aktualizacja bazy danych aur_repo.db..."
repo-add $REPO_DIR/aur_repo.db.tar.gz $REPO_DIR/*.pkg.tar.zst
