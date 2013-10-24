---
layout: post
title: Design Patterns - Abstract Factory, temos que pegar, Pokémon
tags:
- title: Design Patterns
  slug: design-patterns
- title: Java
  slug: java
- title: mimimi
  slug: mimimi
- title: Padrões de Criacão
  slug: padroes-de-criacao
category: [Java,Design Patterns,Padrões de Criacão]
---

Voltando com os posts, vou começar uma série falando sobre os padrões de projeto do livro <a href="http://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612/ref=sr_1_1?s=books&ie=UTF8&qid=1305031310&sr=1-1" target="_blank">Design Patterns</a> do GoF(Gang of Four).

Mas primeiro, o que é esse troço de Design Patterns? "Kibando" o próprio livro do GoF:

*Os padrões de projeto tornam mais fácil reutilizar projetos e arquiteturas bem-sucedidas. Expressam técnicas testadas e aprovadas ... ajudam a escolher alternativas de projeto que tornam um sistema reutilizável e a evitar alternativas que comprometam a reutilização...*

Sacou?

**NEEEEXT!**

Abstract Factory
----------------
A idéia do pattern Abstract Factory é fornecer uma interface para criação de famílias de objetos relacionados ou mesmo dependentes, porém sem especificar suas classes completas.

O exemplo mais clássico é uma interface para usuário, na qual conforme uma configuração de sistema ou whatever, a construção das janelas é feita de uma forma diferente, cores, tamanho, etc.

Aplicabilidade:
----------------

* um sistema deve ser independente de como seus "produtos" são criados, compostos ou representados;
* um sistema deve ser configurado como um "produto" de uma família de múltiplos "produtos";
* uma família de "objetos-produto" for projetada para ser usada em conjunto, e você necessita garantir esta restrição;
* você quer fornecer uma biblioteca de classes de "produtos" e quer revelar somente suas interfaces, não suas implementações.

<s>(kibado da versão em pt-br, por isso tá estranho)</s>

Mais do que ficar explicando, vamos para o que importa.Mas como eu gosto de exemplos diferentes, vou fazer um bem bizarro. :P

Pokémon, temos que pegar...
---------------------------

![eevee]({{ site.url }}/assets/eevee.gif)

Tenho este pokémon, <a title="Eevee" href="http://pt.wikipedia.org/wiki/Fam%C3%ADlia_de_Eevee" target="_blank">Eevee</a>, vou querer evoluí-lo. E como eu sou um grande mestre-pokémon ele já está para evoluir. E as evoluções naturais dele são Espeon e Umbreon (peguei as informações <a href="http://pt.wikipedia.org/wiki/Fam%C3%ADlia_de_Eevee" target="_blank">aqui</a>). Porém ele tem restrições, quando ele estiver no ponto de evoluir, se for dia, evoluir para Espeon, se for noite para Umbreon.

Antes de tudo vou precisar do meu Pokémon
{% highlight java %}public class Pokemon {
	private String nome;

	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}
}{% endhighlight %}

E agora precisamos criar uma classe abstrata declarando uma interface genérica para criação das subclasses que fabricam as evoluções do Eevee.

{% highlight java %}
abstract class FabricaDeEvolucoesDoEevee {
	public static void obterFabrica() {
	}

	public abstract Pokemon criarEvolucao();
}
{% endhighlight %}

Mas essa classe precisa retornar uma fabrica de evoluções conforme a regra de evolução acima. Então precisamos alterar  FabricaDeEvolucoesDoEevee e criar as fabricas de cada evolução. Fazemos uma verificação se esta entre  o periodo do dia pra retornar uma fabrica de Espeon, caso não esteja retorna uma fabrica de Umbreon.

{% highlight java %}import java.util.Calendar;

abstract class FabricaDeEvolucoesDoEevee {
	private static Calendar manha;
	private static Calendar tarde;

	static {
		manha = Calendar.getInstance();
		manha.set(Calendar.HOUR_OF_DAY, 6);
		manha.set(Calendar.MINUTE, 0);
		manha.set(Calendar.SECOND, 0);

		tarde = Calendar.getInstance();
		tarde.set(Calendar.HOUR_OF_DAY, 18);
		tarde.set(Calendar.MINUTE, 0);
		tarde.set(Calendar.SECOND, 0);
	}

	public static FabricaDeEvolucoesDoEevee obterFabrica() {
		Calendar dataDaEvolucao = Calendar.getInstance();
		if (dataDaEvolucao.after(manha) && dataDaEvolucao.before(tarde)) {
			return new FabricaDeEspeon();
		}
		return new FabricaDeUmbreon();
	}

	public abstract Pokemon criarEvolucao();
}
{% endhighlight %}

A fabrica de Espeon herdando da classe abstrata.
{% highlight java %}public class FabricaDeEspeon extends FabricaDeEvolucoesDoEevee {
	@Override
	public Pokemon criarEvolucao() {
		Pokemon espeon = new Pokemon();
		espeon.setNome("Espeon");
		return espeon;
	}
}{% endhighlight %}
A fabrica de Umbreon herdando da classe abstrata.
{% highlight java %}public class FabricaDeUmbreon extends FabricaDeEvolucoesDoEevee {
	@Override
	public Pokemon criarEvolucao() {
		Pokemon umbreon = new Pokemon();
		umbreon.setNome("Umbreon");
		return umbreon;
	}
}{% endhighlight %}
Agora vamos fazer uma classe main para testar esse código.
{% highlight java %}public class AbstractFactoryMain {
	public static void main(String[] args) {
		FabricaDeEvolucoesDoEevee fabrica = FabricaDeEvolucoesDoEevee.obterFabrica();
		Pokemon pokemon = fabrica.criarEvolucao();
		System.out.println("Evoluiu para " + pokemon.getNome() + "!");
	}
}{% endhighlight %}
Devemos ver no console "Evolui para Espeon!" se estiver rodando o código da AbstractFactoryMain entre as 6hrs e 18hrs, e ver "Evolui para Umbreon!" se for entre 18hrs e 6hrs.

Se olhar esse <a href="http://pt.wikipedia.org/wiki/Fam%C3%ADlia_de_Eevee" target="_blank">link</a> poderiamos criar novas factorys para cada evolução, mas teria que definir qual critério para simular as pedras de evolução, ai poderia ser alguma configuração ou whatever.

Esse pattern é bem simples, não?

<!--more-->

<strong>[UPDATE]</strong>

Depois do <a href="http://twitter.com/#!/diegoponci" target="_blank">@diegoponc</a>i ficar me trollando no GTalk falando que "tinha que retornar o tipo específico...<strong>#mimimi</strong>" as classes foram alteradas e ficaram assim:

Criei duas classes específicas de cada tipo;
{% highlight java %}public class Umbreon extends Pokemon {
	private String nome = "Umbreon";

	@Override
	String getNome() {
		return this.nome;
	}
}

public class Espeon extends Pokemon {
	private String nome = "Espeon";

	@Override
	String getNome() {
		return this.nome;
	}
}{% endhighlight %}
Assim transformando a classe Pokemon com apenas um método abstract;
{% highlight java %}abstract class Pokemon {
	abstract String getNome();
}{% endhighlight %}
E alterei as Factories de cada tipo;
{% highlight java %}public class FabricaDeUmbreon extends FabricaDeEvolucoesDoEevee {
	@Override
	public Umbreon criarEvolucao() {
		return new Umbreon();
	}
}
public class FabricaDeEspeon extends FabricaDeEvolucoesDoEevee {
	@Override
	public Espeon criarEvolucao() {
		return new Espeon();
	}
}
{% endhighlight %}
