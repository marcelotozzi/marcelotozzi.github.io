---
layout: post
title:  "Heisenberg distribuindo metanfetamina pelo Amazon S3"
date:   2013-10-30 11:00:00
categories: Amazon,Breaking Bad,Heisenberg,Shell,Bash,S3,Los Pollos Hermanos
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
DIA=$(date +%Y%m%d%H)
CARREGAMENTODODIA='carregamento-'$DIA.meth

############## empacotando
echo "-- Empacotando blue meth ..."

CARREGAMENTO=$ESTOQUEDEBLUEMETH/$CARREGAMENTODODIA

if [[ ! -f "$CARREGAMENTO" ]]; then
	continue
fi
filename=$(basename "$CARREGAMENTO")
filename="${filename%.*}"

tar -P -zcpf $ESTOQUEDEBLUEMETH/"$filename".tar.gz -C $/$ESTOQUEDEBLUEMETH "$filename" > /dev/null

echo -ne '\n'
{% endhighlight %}

![padrao]({{ site.url }}/assets/saymyname.gif)

*PS: Qualquer semelhança nesse post com obras de ficção é mera cópia.*