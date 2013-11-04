---
layout: post
title:  "Heisenberg distribuindo metanfetamina pelo Amazon S3"
date:   2013-11-03 11:00:00
categories: Amazon,Breaking Bad,Heisenberg,Shell,Bash,S3,Los Pollos Hermanos,Log
---
***OBS: spoilers de Breaking Bad, se você não assistiu, não leia!***

![padrao]({{ site.url }}/assets/walterwhite.jpg)

Digamos que eu sou um professor de química e estou precisando de grana pra sustentar minha família, minha mulher esta grávida e meu salário é uma porcaria. Pra ajudar, descobri que estou com câncer.
Meu cunhado é policial e me mostra quanto dinheiro ele aprendeu na última "batida policial" de metanfetamina que ele fez.

Minha vida esta indo pro lixo e provavelmente meu câncer vai me matar, vou dar um jeito de produzir metanfetamina e distribuir sem que me peguem para deixar dinheiro pra minha família viver bem.

Então, *`Let's cook!`*

Como eu sou um químico "muito do espertão" e os meus concorrentes não tem a minha fórmula e nem cuidado pra "cozinhar", meu produto é o mais puro desse mercado, mas por um método que uso ela tem a peculiar cor azul.

Vou ter carregamentos diários pra enviar, então vou fazer uma parceria com alguém para distribuir minha `blue meth`, e meu parceiro é o dono da empresa de fast-food `Los Pollos Hermanos`, pois ele já esta no negócio e tem uma distribuição discreta.

Eu não vou mostrar meu processo de produção, só do empacotamento pra frente, pois minha fórmula é secreta.
	
Vamos então pro empacotamento:

{% highlight bash %}#! /bin/bash
ESTOQUEDEBLUEMETH='/estoque'
DIA=$(date +%d%m%Y)
LOTE='carregamento-'$DIA
CARREGAMENTODODIA=$LOTE.meth
EXT=.tar.gz

echo "-- Empacotando blue meth ..."

CARREGAMENTO=$ESTOQUEDEBLUEMETH/$CARREGAMENTODODIA

if [[ ! -f "$CARREGAMENTO" ]]; then
	exit 1
fi

tar -P -zcpf $ESTOQUEDEBLUEMETH/$LOTE$EXT -C $ESTOQUEDEBLUEMETH $CARREGAMENTO > /dev/null
{% endhighlight %}

Ok, assim empacotamos, mas e agora para o envio?

Para enviar os nossos amigos dO Pollos Hermanos precisam do <a href="http://s3tools.org/s3cmd" target="_blank">s3cmd</a> instalado. Então, instalaremos.

Vamos baixar a última versão da lib <a href="https://github.com/s3tools/s3cmd/releases" target="_blank">aqui</a>. No meu caso é a **v1.5.0-alpha3** <s>Ah, mas vc ta usando a alpha mimimi</s>. Para instalar apenas faça o seguinte:

{% highlight bash %}#! /bin/bash
unzip s3cmd-1.5.0-alpha3.zip
cd s3cmd-1.5.0-alpha3/
python setup.py install
{% endhighlight %}

Pronto, instalado, agora precisamos configurar:

{% highlight bash %}#! /bin/bash
3cmd --configure

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3
Access Key: XXXXXXXXXXXXXXXXXXXX
Secret Key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password: 
Path to GPG program: 

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP and can't be used if you're behind a proxy
Use HTTPS protocol [No]: Yes

New settings:
  Access Key: XXXXXXXXXXXXXXXXXXXX
  Secret Key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  Encryption password: 
  Path to GPG program: None
  Use HTTPS protocol: True
  HTTP Proxy server name: 
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] Y
Please wait, attempting to list all buckets...
Success. Your access key and secret key worked fine :-)

Now verifying that encryption works...
Not configured. Never mind.

Save settings? [y/N] y
Configuration saved to '/Users/heisenberg/.s3cfg'
{% endhighlight %}

![padrao]({{ site.url }}/assets/hank.gif)

Agora, completando o envio do lote usando o s3cmd, tomara que não seja interceptado pelo meu cunhado do DEA:

{% highlight bash%}#! /bin/bash

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

{% endhighlight %}

![padrao]({{ site.url }}/assets/money.gif)

Pronto, agora é guardar a grana para a minha família. O meu produto faz sucesso na Europa, distribuido pela Madrigal e conhecido como "Blue Sky".

Eu faço isso pela minha família. 

**"Yeah Mr. White! Yeah Science!"**

Você pode [baixar o processo]({{ site.url }}/downloads/processo.sh) de envio.

![padrao]({{ site.url }}/assets/saymyname.gif)

*PS: Brincadeiras a parte, eu tive que fazer algo parecido dias atrás, para guardar logs de acesso de aplicação no S3.*