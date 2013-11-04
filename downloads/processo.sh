#! /bin/bash

ESTOQUEDEBLUEMETH='/estoque'
DIA=$(date +%d%m%Y)
LOTE='carregamento-'$DIA
CARREGAMENTODODIA=$LOTE.meth
MADRIGAL='madrigal'
EXT=.tar.gz

if [ -z $(which s3cmd) ]; then
        echo "Instale e configure o s3cmd. - http://s3tools.org/s3cmd"
        exit 0
fi

fnError(){
        echo "======= Ocorreu um erro! ======="
        echo "======= Carga não foi distribuida! ======="
        exit 1
}

trap 'fnError $ESTOQUEDEBLUEMETH' ERR

############## empacotando
echo "-- Empacotando blue meth ..."

CARREGAMENTO=$ESTOQUEDEBLUEMETH/$CARREGAMENTODODIA

if [[ ! -f "$CARREGAMENTO" ]]; then
	exit 1
fi

tar -P -zcpf $ESTOQUEDEBLUEMETH/$LOTE$EXT -C $ESTOQUEDEBLUEMETH $CARREGAMENTO > /dev/null

PACOTEDODIA=$LOTE$EXT
PACOTE=$ESTOQUEDEBLUEMETH/$PACOTEDODIA

echo "-- Enviando carga para o S3. Destino: s3://$MADRIGAL"

if [[ ! -f "$PACOTE" ]]; then
	exit 1
fi

s3cmd put "$PACOTE" s3://$MADRIGAL/  > /dev/null

echo "-- Enviado!"