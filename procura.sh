#!/bin/bash

if [ "$1" == "" ];
	then
		echo "Digite a palavra-chave para pesquisar conteudo: "
		read keyword

		echo "Digite a extensao (format) que deseja filtrar: "
		echo "Exemplos: .pdf, .txt, .wmv, .mp3, .mp4"
		read format


	else
		keyword=$1
		if [ "$2" == "" ]; then
			format=""
		else
			format=$2
		fi
fi

if [ "$keyword" == "" ]; then
	echo "A palavra-chave não pode ser vazia."
else
	if [ "$format" == "" ]; then
		find | grep -i $keyword
	else
		find | grep -i $keyword | grep $format
	fi
fi

