#!/bin/bash

wget -cO- https://github.com/phisch/phinger-cursors/releases/latest/download/phinger-cursors-variants.tar.bz2 \
	| sudo tar xfj - -C /usr/share/icons
