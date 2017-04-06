#!/bin/bash

# Install adobe crack dll into folder

FOLDER="/cygdrive/c/Program Files/Adobe/Adobe Photoshop CS6 (64 Bit)/"
DLL_CRACK="/cygdrive/c/Temp/PS6/Adobe Photoshop CS6 13.0.1 Final  Multilanguage (cracked dll) [ChingLiu]/cracked dll/64 bit/amtlib.dll";

if [[ ! -d $FOLDER ]]; then
	echo "Diretorio nao existe";
	exit 1;
fi

if [[ ! -f $DLL_CRACK ]]; then
	echo "DLL crack nao existe";
	exit 1;
fi

cp "$DLL_CRACK" "$FOLDER"

if [[ $? == 0 ]]; then
	echo "DLL crackeada copiada com sucesso.";
else
	echo "DLL crackeada nao foi copiada.";
	exit 1;
fi
exit 0;
