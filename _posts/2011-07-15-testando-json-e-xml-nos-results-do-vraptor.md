---
layout: post
title: Testando JSON e XML nos Results do VRaptor
categories: Teste Java
tags:
- java
- json
- junit
- mock
- mockito
- tdd
- vraptor
- xml
image: /assets/article_images/2014-11-30-mediator_features/night-track.JPG
---

![]({{ site.url }}/assets/images/designalldll-300x300.jpg)

Antes de tudo uma historinha! Um dia desses queria testar  alguns métodos que criei utilizando <a href="http://vraptor.caelum.com.br/" target="_blank">VRaptor</a>, até ai tudo bem. Chamando eles num teste unitário eu conseguiria facilmente pois eu consigo "pegar" os objetos que o controller insere na resposta que vem dentro do `Result`. Porém me deparei com os testes que retornavam objetos serializados em <a href="http://www.json.org/" target="_blank">JSON</a> dentro do Result.

O VRaptor te disponibiliza um 'Result' "mockado" para fazer seus testes mas não funciona com esse tipo de serialização(pelo menos nos meus testes não "funfou"). Depois de buscar um pouco no código do VRaptor não encontrei o que me ajudaria nisso. Já estava pensando em fazer eu mesmo um Mock para isso até que pensei: "**GITHUB**, será que no Git tem alguma coisa que não tem nessa versão que eu estou usando?".

Dito e feito, fui verificar no <a href="https://github.com/caelum/vraptor" target="_blank">perfil da Caelum</a> e vi que existia um outro Mock que na minha versão não tinha. Eu estava com o SNAPSHOT 3.3 e esse Mock que eu precisava estava somente no SNAPSHOT 3.4. ai foi só baixar e usar. Vamos então a parte que importa, os exemplos de como usar os Mocks.

Vamos precisar, é claro, do último <a href="https://oss.sonatype.org/content/repositories/snapshots/br/com/caelum/vraptor/" target="_blank">SNAPSHOT</a> e criar um contexto simples de eventos. Uma classe `Evento`:

{% highlight java linenos %}import java.util.Calendar;

public class Evento {
	private Long id;
	private String nome;
	private String descricao;
	private String local;
	private Calendar data;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}

	public String getDescricao() {
		return descricao;
	}

	public void setDescricao(String descricao) {
		this.descricao = descricao;
	}

	public String getLocal() {
		return local;
	}

	public void setLocal(String local) {
		this.local = local;
	}

	public Calendar getData() {
		return data;
	}

	public void setData(Calendar data) {
		this.data = data;
	}
}{% endhighlight %}

Ok, agora precisamos de um controller para adicionar nosso `Result` que vai retornar os objetos. Vou também adicionar um <a href="http://java.sun.com/blueprints/corej2eepatterns/Patterns/DataAccessObject.html" target="_blank">DAO</a> que terá somente os métodos pois vamos mocka-lo.

{% highlight java linenos %}public class EventoController {
	private Result result;
	private EventoDAO eventoDAO;

	public EventoController(Result result, EventoDAO eventoDAO) {
		this.result = result;
		this.eventoDAO = eventoDAO;
	}
}{% endhighlight %}

{% highlight java linenos %}import java.util.List;

import br.com.marcelotozzi.vraptorresults.model.Evento;

public class EventoDAO {

	public Evento load(Long id) {
		return null;
	}

	public List<Evento> list() {
		return null;
	}
}{% endhighlight %}

Agora vamos criar uma classe de teste. Como não precisamos conectar com o banco nesse exemplo, vou "mockar" o DAO utilizando o <a href="http://mockito.org/" target="_blank">Mockito</a>. Para usar a funcionalidade só precisamos anotar o objeto que queremos com `@Mock` e "indicar" ao Mockito para iniciar os mocks da nossa classe antes de rodar os testes, no <a href="http://junit.sourceforge.net/doc/cookbook/cookbook.htm" target="_blank">@Before</a> do <a href="http://www.junit.org/" target="_blank">JUnit</a>.

Para o `Result` vou usar o `MockResult` como disse lá no começo do post, basta apenas instanciar o objeto e passá-lo para o controller.

{% highlight java linenos %}public class EventoControllerTest {
	private EventoController controller;
	private Result result;
	@Mock
	private EventoDAO eventoDAO;

	@Before
	public void setup() {
		MockitoAnnotations.initMocks(this);
		this.result = new MockResult();
		this.controller = new EventoController(this.result, this.eventoDAO);
	}
}
{% endhighlight %}

Vamos criar os testes para o nosso controller. Como meu DAO esta mockado ele não vai retornar nada quando chamar um método dele. Então tenho q dizer ao Mockito o que retornar quando um tal método daquele objeto mockado for chamado. Para isso utilizo a classe `Mockito` e os métodos `when` e `thenReturn` quando o controller chamar o método `load` deve retornar um evento pre estabelecido por mim.

{% highlight java linenos %}@Test
public void deveRetornarUmEvento() {
	Evento evento = Dado.umEvento(1L, "BACONSP", "Bacon Conference SP",
				"Av Paulista", Calendar.getInstance());
	Mockito.when(this.eventoDAO.load(evento.getId())).thenReturn(evento);

	this.controller.show(evento.getId());

	Evento eventoRetornado = (Evento) this.result.included().get("evento");
	Entao.deveSerOMesmoEvento(evento, eventoRetornado);
}
{% endhighlight %}

Criei também uma classe `Dado` para ajudar na "configuração" dos testes;

{% highlight java linenos %}public class Dado {
	public static Evento umEvento(Long id, String nome, String descricao,
			String local, Calendar data) {
		Evento ev = new Evento();
		ev.setId(id);
		ev.setNome(nome);
		ev.setDescricao(descricao);
		ev.setLocal(local);
		ev.setData(data);
		return ev;
	}
}
{% endhighlight %}

E uma classe `Entao` para ajudar nos `Assert`'s.

{% highlight java linenos %}public class Entao {
	public static void deveSerOMesmoEvento(Evento evento, Evento eventoRetornado) {
		Assert.assertEquals(evento.getId(), eventoRetornado.getId());
		Assert.assertEquals(evento.getNome(), eventoRetornado.getNome());
		Assert.assertEquals(evento.getDescricao(), eventoRetornado.getDescricao());
		Assert.assertEquals(evento.getLocal(), eventoRetornado.getLocal());
		Assert.assertEquals(evento.getData(), eventoRetornado.getData());
	}
}
{% endhighlight %}

No teste acima pego apenas um `Evento` do `Result`, agora vamos "pegar" uma lista s idéia é a mesma.

{% highlight java linenos %}@Test
public void deveRetornarUmaListaDeEventos() {
	List eventos = Dado.umaListaCadastrada();
	Mockito.when(this.eventoDAO.list()).thenReturn(eventos);

	this.controller.list();

	List eventosRetornados = (List) this.result.included().get("eventos");
	Entao.deveSerAMesmaLista(eventos, eventosRetornados);
}
{% endhighlight %}

Adiciono o método que popula minha lista de eventos a classe `Dado`;

{% highlight java linenos %}public static List<Evento> umaListaCadastrada() {
	List<Evento> eventos = new ArrayList<Evento>();
	eventos.add(Dado.umEvento(1L, "BACONSP", "Bacon Conference SP", "Av Paulista", 
		Calendar.getInstance()));
	eventos.add(Dado.umEvento(2L, "BrejasConf", "Conferencia de Brejas", 
		"Av Brigadeiro Faria Lima", Calendar.getInstance()));
	return eventos;
}{% endhighlight %}

E também o método que verifica se a lista está correta na classe `Entao`:

{% highlight java linenos %}public static void deveSerAMesmaLista(List<Evento> eventos, 
	List<Evento> eventosRetornados) {
	Assert.assertEquals(eventos.size(), eventosRetornados.size());
	Assert.assertTrue(eventos.containsAll(eventosRetornados));
}
{% endhighlight %}

Beleza, se rodarmos esses testes eles não vão "funfar", e provavelmente sua IDE vai gritar o por que. Faltam os métodos no controller que vão ser testados. Então vamos a eles. Eles utilizam o Result  e o DAO inserido pelo construtor.

{% highlight java linenos %}public void list() {
	this.result.include("eventos", this.eventoDAO.list());
}

public void show(Long id) {
	this.result.include("evento", this.eventoDAO.load(id));
}
{% endhighlight %}

Agora, se rodarmos os testes,deveria funfar. Se não funfar #FUUUUUU.

Nessa primeira parte o terreno esta preparado. No próximo post vou mostrar como fiz pra validar o retorno de JSON e de XML(eca!).

![]({{ site.url }}/assets/images/epic-meal-time-bacon.jpg)
