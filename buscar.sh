#!/bin/bash
echo "Buscar por: "
read keyword

echo "Formato/Extensao: "
read format

if [ "$format" != "" ]; then
	echo "Formato '$format' selecionado."
	locate -d .indice *$keyword*.$format
	echo "Efetuando busca ..."
else
	echo "Nenhum formato selecionado."
	echo "Efetuando busca ..."
	locate -d .indice *$keyword*
fi


