---
layout: post
title: Redis em 314 segundos
tags:
- C++
- Key-Value
- NoSQL
- Redis
status: publish
type: post
published: true
meta:
  _edit_last: '1'
  _thumbnail_id: '498'
  dsq_thread_id: '745375962'
---
<p>Um "fast post" pra desenferrujar.</p>
<p><a href="http://marcelotozzi.com.br/wp-content/uploads/2012/06/003MRD_Randall_Duk_Kim_003.jpeg"><img src="http://marcelotozzi.com.br/wp-content/uploads/2012/06/003MRD_Randall_Duk_Kim_003.jpeg" alt="" title="003MRD_Randall_Duk_Kim_003" width="852" height="480" class="aligncenter size-full wp-image-487" /></a></p>
<p>Se você tem vivido dentro de uma caverna nos últimos anos não vai saber do que se trata o termo NoSQL e o que diabos é Redis.<span style="color: #000000;"> <del>(Mas no fundo você sabe, salvar dados como arquivo, memória, etc)</del></span><br /><br />
Se você ainda não buscou <a href="http://redis.io/" target="_blank">Redis</a> no Google pra saber do que estou falando eu digo: Redis é um banco de dados chave-valor open-source escrito em C que pode armazenar string, hashes, lists, sets and sorted sets. (copiei do site do <a href="http://redis.io/" target="_blank">Redis</a> :D)</p>
<p>Ele tem várias features como Pipelining, Publish/Subscribe, Transactions, Insert Massivo, Replicação, SnapShotting e <a href="http://redis.io/documentation" target="_blank">outras "coisinhas"</a>.</p>
<p>Vamos então baixar, instalar e "startar" instâncias marotas do Redis só pra tirar um barato.</p>
<pre class="brush:shell">wget http://redis.googlecode.com/files/redis-2.4.15.tar.gz
$ tar xzf redis-2.4.15.tar.gz
$ cd redis-2.4.15
$ make</pre>
<p>Não se esqueça de rodar os testes do Redis pra ter certeza que esta tudo ok:</p>
<pre class="brush:shell">$ make test</pre>
<p>O Redis até rodaria agora na sua máquina rodando o</p>
<pre class="brush:shell">./src/redis-server</pre>
<p>na pasta compilada, porém qual é a graça disso?</p>
<p>Vamos usar o /utils/install_server.sh que vem junto com o Redis para startar o processo na máquina, podendo ter várias instâncias independentes (ou não). Esse .sh configura para você as pastas com caminhos default, porém você pode especificar onde<br /><br />
elas ficarão.</p>
<pre class="brush:shell"> $ sudo ./install_server.sh 
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
Copied /tmp/6380.conf =&gt; /etc/init.d/redis_6380
Installing service...
Starting Redis server...
Installation successful!</pre>
<p>Pronto, já tenho um Redis local respondendo na porta 6380. Caso eu não mudasse a porta, o padrão seria a porta 6379.</p>
<p>Existem vários <a href="http://redis.io/clients" target="_blank">clients</a> para acessar o Redis.</p>
<p>Mas pra dar uma olhada direto no Redis, quando fizemos o make install la em cima, agora vc tem o redis-cli instalado na sua máquina. Como mudei a porta tenho que cita-la quando conectar pois o padrão é 6379. É só mandar esse comando no terminal:</p>
<pre class="brush:shell">$ redis-cli -p 6380
redis 127.0.0.1:6380&gt; dbsize
(integer) 0
redis 127.0.0.1:6380&gt;</pre>
<p>Já era, estamos dentro e nosso banco esta zerado!</p>
<p>Por enquanto é isso, se quiser dar uma olhada nos comandos do Redis, vá para <a href="http://redis.io/commands" target="_blank">essa página</a>.</p>
<p>&nbsp;</p>
<p>Inté!</p>
