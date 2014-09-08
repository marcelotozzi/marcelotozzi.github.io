---
layout: post
title: Redis em 314 segundos
---
Um fast post pra desenferrujar.

![padrao]({{ site.url }}/assets/keymaster.jpeg)
Se você tem vivido dentro de uma caverna nos últimos anos não vai saber do que se trata o termo NoSQL e o que diabos é Redis. <s>(Mas no fundo você sabe, salvar dados como arquivo, memória, etc)</s>

Se você ainda não buscou <a href="http://redis.io/" target="_blank">Redis</a> no Google pra saber do que estou falando eu digo: Redis é um banco de dados chave-valor open-source escrito em C que pode armazenar string, hashes, lists, sets and sorted sets. (copiei do site do <a href="http://redis.io/" target="_blank">Redis</a> :D)

Ele tem várias features como Pipelining, Publish/Subscribe, Transactions, Insert Massivo, Replicação, SnapShotting e <a href="http://redis.io/documentation" target="_blank">outras "coisinhas"</a>.

Vamos então baixar, instalar e "startar" instâncias marotas do Redis só pra tirar um barato.

{% highlight sh %}wget http://redis.googlecode.com/files/redis-2.4.15.tar.gz
$ tar xzf redis-2.4.15.tar.gz
$ cd redis-2.4.15
$ make
{% endhighlight %}

Não se esqueça de rodar os testes do Redis pra ter certeza que esta tudo ok:

{% highlight sh %}$ make test{% endhighlight %}

O Redis até rodaria agora na sua máquina rodando o

{% highlight sh %}./src/redis-server{% endhighlight %}

na pasta compilada, porém qual é a graça disso?

Vamos usar o /utils/install_server.sh que vem junto com o Redis para startar o processo na máquina, podendo ter várias instâncias independentes (ou não). Esse .sh configura para você as pastas com caminhos default, porém você pode especificar onde
elas ficarão.
{% highlight sh %}$ sudo ./install_server.sh 
Welcome to the redis service installer
This script will help you easily set up a running redis server

Please select the redis port for this instance: [6379] 6380
Please select the redis config file name [/etc/redis/6380.conf] 
Selected default - /etc/redis/6380.conf
Please select the redis log file name [/var/log/redis_6380.log] 
Selected default - /var/log/redis_6380.log
Please select the data directory for this instance [/var/lib/redis/6380] 
Selected default - /var/lib/redis/6380
Please select the redis executable path [/usr/local/bin/redis-server] 
Copied /tmp/6380.conf => /etc/init.d/redis_6380
Installing service...
Starting Redis server...
Installation successful!{% endhighlight %}
Pronto, já tenho um Redis local respondendo na porta 6380. Caso eu não mudasse a porta, o padrão seria a porta 6379.

Existem vários <a href="http://redis.io/clients" target="_blank">clients</a> para acessar o Redis.

Mas pra dar uma olhada direto no Redis, quando fizemos o make install la em cima, agora vc tem o redis-cli instalado na sua máquina. Como mudei a porta tenho que cita-la quando conectar pois o padrão é 6379. É só mandar esse comando no terminal:

{% highlight sh %}
$ redis-cli -p 6380
redis 127.0.0.1:6380> dbsize
(integer) 0
redis 127.0.0.1:6380>
{% endhighlight %}

Já era, estamos dentro e nosso banco esta zerado!

Por enquanto é isso, se quiser dar uma olhada nos comandos do Redis, vá para <a href="http://redis.io/commands" target="_blank">essa página</a>.

Inté!
