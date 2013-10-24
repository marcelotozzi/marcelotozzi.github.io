---
layout: post
title: Design Patterns - Composite, com batata grande...
tags:
- title: Design Patterns
  slug: design-patterns
- title: Java
  slug: java
- title: Padrões Estruturais
  slug: padroes-estruturais
categories: java design patterns Padrões Estruturais
---
Depois do **<a title="Design Patterns – Abstract Factory, temos que pegar, Pokémon" href="/blog/design-patterns-abstract-factory-temos-que-pegar-pokemon/" target="_blank">Abstract Factory</a>** vamos para outro pattern simples. O **Composite**.

O pattern Composite server para que os componentes individuais e composições de objetos sejam tratados de forma parecida.

A parte principal do pattern Composite é a criação de uma classe abstrata/interface que representa tanto os componentes individuais como as composições. Essa classe também define métodos que os objetos compartilham, como métodos para administrar seus componentes/filhos.

Aplicabilidade:
---------------

* Quando quiser tratar igualmente objetos ignorando a diferença entre composições de objetos e componentes individuais .
* Quando quiser representar hierarquias partes-todo(é parte de) de objetos.

O cliente usa a interface para interagir  com os objetos do componente composto. Quando é um objeto individual a chamada de um método é tratada diretamente no objeto. Porém se é um objeto composto,  ele repassa a chamada de método para seus componentes filhos.

Esse pattern deixa mais fácil  adicionar novos componentes sem ter que alterar os "clientes" que usam os componentes, porém isso pode atrapalhar se você quiser limitar quais tipos de objetos podem fazer parte de uma composição. Ai você terá que usar verificações e testes em tempo de execução.

![bigmac]({{ site.url }}/assets/enjoado_de_big_mac-300x237.jpg)

Batata frita grande acompanha, senhor?
======================================
Bora fazer um exemplo então. E continuando com os exemplos doidões, quem não curte um hamburguer maroto?

Então vamos fazer um belo Whooper com queijo usando o padão Composite para compor nosso rango.

Primeiro vamos criar a interface citada acima que vai ser utilizada como "contrato" tanto para o componente individual quando para o componente composto. Vou definir um método que deve retornar as calorias do alimento e outro pra mostrar o nome dele.
{% highlight java %}public interface Alimento {
	public int retornaCalorias();
	public void mostrar();
}{% endhighlight %}
Precisamos também dos componentes individuais.Vamos criar todos, cada um deles sobreescreve os métodos da interface.
{% highlight java %}public class Alface implements Alimento {
	@Override
	public void mostrar() {
		System.out.println("Alface");
	}

	@Override
	public int retornaCalorias() {
		return 25;
	}
}

public class Cebola implements Alimento {
	@Override
	public void mostrar() {
		System.out.println("Cebola");
	}

	@Override
	public int retornaCalorias() {
		return 50;
	}
}

public class Hamburguer implements Alimento {
	@Override
	public void mostrar() {
		System.out.println("Hamburguer");
	}

	@Override
	public int retornaCalorias() {
		return 300;
	}
}

public class Pao implements Alimento {
	@Override
	public int retornaCalorias() {
		return 150;
	}

	@Override
	public void mostrar() {
		System.out.println("Pao");
	}
}

public class Picles implements Alimento {
	@Override
	public void mostrar() {
		System.out.println("Picles");
	}

	@Override
	public int retornaCalorias() {
		return 50;
	}
}

public class Queijo implements Alimento {
	@Override
	public void mostrar() {
		System.out.println("Queijo");
	}

	@Override
	public int retornaCalorias() {
		return 125;
	}
}

public class Tomate implements Alimento {
	@Override
	public void mostrar() {
		System.out.println("Tomate");
	}

	@Override
	public int retornaCalorias() {
		return 100;
	}
}{% endhighlight %}
Agora vamos começar com o nosso teste e ir incrementando conforme necessário. Vou criar alguns componentes/ingredientes únicos no teste.
{% highlight java %}public class BurgerKingTest {
	@Test
	public void deveriaMontarUmWhopperComQueijoImprimirNoConsoleERetornar800Kcal() {
		Alimento hamburguer = new Hamburguer();
		Alimento queijo = new Queijo();
		Alimento picles = new Picles();
		Alimento alface = new Alface();
		Alimento tomate = new Tomate();
		Alimento cebola = new Cebola();
		Alimento pao = new Pao();

		Rango whopperComQueijo = new Rango();

		Assert.assertEquals(800, rango.retornaCalorias());
	}
}{% endhighlight %}
O codigo acima tem uma coisa de que ainda não falamos, a classe Rango, sem ela não vamos conseguir fazer esse teste mega bizarro passar.Então...
{% highlight java %}import java.util.ArrayList;
import java.util.List;

import br.com.marcelotozzi.designpatterns.composite.ingredientes.Alimento;

public class Rango implements Alimento {
	private List<Alimento> ingredientes = new ArrayList<Alimento>();
	private int calorias;

	@Override
	public void mostrar() {
		for (Alimento alimento : this.ingredientes) {
			alimento.mostrar();
		}
	}

	public void adiciona(Alimento alimento) {
		this.ingredientes.add(alimento);
	}

	@Override
	public int retornaCalorias() {
		for (Alimento alimento : this.ingredientes) {
			calorias += alimento.retornaCalorias();
		}
		return calorias;
	}
}{% endhighlight %}

Essa classe implementa a interface Alimento e sobre escreve seus métodos, porém , diferente dos componentes individuais de ingredientes, essa classe é um componente composto.Os métodos em vez de chamar algo dentro da classe Rango, delega a chamada para os seus componentes.

Agora só precisamos terminar nosso teste.

{% highlight java %}public class BurgerKingTest {
	@Test
	public void deveriaMontarUmWhopperComQueijoImprimirNoConsoleERetornar800Kcal() {
		Alimento hamburguer = new Hamburguer();
		Alimento queijo = new Queijo();
		Alimento picles = new Picles();
		Alimento alface = new Alface();
		Alimento tomate = new Tomate();
		Alimento cebola = new Cebola();
		Alimento pao = new Pao();

		Rango whopperComQueijo = new Rango();

		whopperComQueijo.adiciona(hamburguer);
		whopperComQueijo.adiciona(queijo);
		whopperComQueijo.adiciona(picles);
		whopperComQueijo.adiciona(alface);
		whopperComQueijo.adiciona(tomate);
		whopperComQueijo.adiciona(cebola);
		whopperComQueijo.adiciona(pao);

		Rango rango = new Rango();

		rango.adiciona(whopperComQueijo);

		rango.mostrar();

		Assert.assertEquals(800, whopperComQueijo.retornaCalorias());
		Assert.assertEquals(800, rango.retornaCalorias());
	}
}{% endhighlight %}

Basicamente adicione o nosso whooper(que é um objeto composto) em um outro objeto composto rango. Os dois devem retornar o mesmo valor calorias. Qualquer um dos nossos objetos nesse teste podem ser tratados igualmente.
