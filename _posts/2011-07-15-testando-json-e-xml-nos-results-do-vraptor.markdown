---
layout: post
title: Testando JSON e XML nos Results do VRaptor
tags:
- title: Bacon
  slug: bacon
- title: Java
  slug: java
- title: JSON
  slug: json
- title: JUnit
  slug: junit
- title: Mock
  slug: mock
- title: Mockito
  slug: mockito
- title: TDD
  slug: tdd
- title: VRaptor
  slug: vraptor
- title: XML
  slug: xml
status: publish
type: post
published: true
meta:
  _edit_last: '1'
  _thumbnail_id: '375'
  dsq_thread_id: '358904271'
---
&nbsp;

<a href="http://marcelotozzi.com.br/wp-content/uploads/2011/07/designalldll.jpeg"><img class="alignright size-medium wp-image-375" title="designalldll" src="http://marcelotozzi.com.br/wp-content/uploads/2011/07/designalldll-300x300.jpg" alt="" width="300" height="300" /></a>Antes de tudo uma historinha! Um dia desses queria testar  alguns métodos que criei utilizando <a href="http://vraptor.caelum.com.br/" target="_blank">VRaptor</a>, até ai tudo bem. Chamando eles num teste unitário eu conseguiria facilmente pois eu consigo "pegar" os objetos que o controller insere na resposta que vem dentro do <code>Result</code>. Porém me deparei com os testes que retornavam objetos serializados em <a href="http://www.json.org/" target="_blank">JSON</a> dentro do Result.

O VRaptor te disponibiliza um <code>Result</code> "mockado" para fazer seus testes mas não funciona com esse tipo de serialização(pelo menos nos meus testes não "funfou"). Depois de buscar um pouco no código do VRaptor não encontrei o que me ajudaria nisso. Já estava pensando em fazer eu mesmo um Mock para isso até que pensei: "<strong>GITHUB</strong>, será que no Git tem alguma coisa que não tem nessa versão que eu estou usando?".

Dito e feito, fui verificar no <a href="https://github.com/caelum/vraptor" target="_blank">perfil da Caelum</a> e vi que existia um outro Mock que na minha versão não tinha. Eu estava com o SNAPSHOT 3.3 e esse Mock que eu precisava estava somente no SNAPSHOT 3.4. ai foi só baixar e usar. Vamos então a parte que importa, os exemplos de como usar os Mocks.

Vamos precisar, é claro, do último <a href="https://oss.sonatype.org/content/repositories/snapshots/br/com/caelum/vraptor/" target="_blank">SNAPSHOT</a> e criar um contexto simples de eventos. Uma classe <code>Evento</code>:
<pre class="brush:java">import java.util.Calendar;

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
}</pre>
Ok, agora precisamos de um controller para adicionar nosso <code>Result</code> que vai retornar os objetos. Vou também adicionar um <a href="http://java.sun.com/blueprints/corej2eepatterns/Patterns/DataAccessObject.html" target="_blank">DAO</a> que terá somente os métodos pois vamos mocka-lo.
<pre class="brush:java">public class EventoController {
	private Result result;
	private EventoDAO eventoDAO;

	public EventoController(Result result, EventoDAO eventoDAO) {
		this.result = result;
		this.eventoDAO = eventoDAO;
	}
}</pre>
<pre class="brush:java">import java.util.List;

import br.com.marcelotozzi.vraptorresults.model.Evento;

public class EventoDAO {

	public Evento load(Long id) {
		return null;
	}

	public List&lt;Evento&gt; list() {
		return null;
	}
}</pre>
Agora vamos criar uma classe de teste. Como não precisamos conectar com o banco nesse exemplo, vou "mockar" o DAO utilizando o <a href="http://mockito.org/" target="_blank">Mockito</a>. Para usar a funcionalidade só precisamos anotar o objeto que queremos com <code>@Mock</code> e "indicar" ao Mockito para iniciar os mocks da nossa classe antes de rodar os testes, no <code><a href="http://junit.sourceforge.net/doc/cookbook/cookbook.htm" target="_blank">@Before</a></code> do <a href="http://www.junit.org/" target="_blank">JUnit</a>.

Para o <code>Result</code> vou usar o <code>MockResult</code> como disse lá no começo do post, basta apenas instanciar o objeto e passá-lo para o controller.
<pre class="brush:java">public class EventoControllerTest {
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
}</pre>
Vamos criar os testes para o nosso controller. Como meu DAO esta mockado ele não vai retornar nada quando chamar um método dele. Então tenho q dizer ao Mockito o que retornar quando um tal método daquele objeto mockado for chamado. Para isso utilizo a classe <code>Mockito</code> e os métodos <code>when</code> e <code>thenReturn</code> quando o controller chamar o método <code>load</code> deve retornar um evento pre estabelecido por mim.
<pre class="brush:java">@Test
public void deveRetornarUmEvento() {
	Evento evento = Dado.umEvento(1L, "BACONSP", "Bacon Conference SP",
				"Av Paulista", Calendar.getInstance());
	Mockito.when(this.eventoDAO.load(evento.getId())).thenReturn(evento);

	this.controller.show(evento.getId());

	Evento eventoRetornado = (Evento) this.result.included().get("evento");
	Entao.deveSerOMesmoEvento(evento, eventoRetornado);
}</pre>
Criei também uma classe <code>Dado</code> para ajudar na "configuração" dos testes;
<pre class="brush:java">public class Dado {
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
}</pre>
E uma classe <code>Entao</code> para ajudar nos <code>Assert<code>'s.</code></code>
<pre class="brush:java">public class Entao {
	public static void deveSerOMesmoEvento(Evento evento, Evento eventoRetornado) {
		Assert.assertEquals(evento.getId(), eventoRetornado.getId());
		Assert.assertEquals(evento.getNome(), eventoRetornado.getNome());
		Assert.assertEquals(evento.getDescricao(), eventoRetornado.getDescricao());
		Assert.assertEquals(evento.getLocal(), eventoRetornado.getLocal());
		Assert.assertEquals(evento.getData(), eventoRetornado.getData());
	}
}</pre>
No teste acima pego apenas um <code>Evento</code> do <code>Result</code>, agora vamos "pegar" uma lista s idéia é a mesma.
<pre class="brush:java">@Test
public void deveRetornarUmaListaDeEventos() {
	List eventos = Dado.umaListaCadastrada();
	Mockito.when(this.eventoDAO.list()).thenReturn(eventos);

	this.controller.list();

	List eventosRetornados = (List) this.result.included().get("eventos");
	Entao.deveSerAMesmaLista(eventos, eventosRetornados);
}</pre>
Adiciono o método que popula minha lista de eventos a classe <code>Dado</code>;
<pre class="brush:java">public static List&lt;Evento&gt; umaListaCadastrada() {
	List&lt;Evento&gt; eventos = new ArrayList&lt;Evento&gt;();
	eventos.add(Dado.umEvento(1L, "BACONSP", "Bacon Conference SP", "Av Paulista", Calendar.getInstance()));
	eventos.add(Dado.umEvento(2L, "BrejasConf", "Conferencia de Brejas", "Av Brigadeiro Faria Lima", Calendar.getInstance()));
	return eventos;
}</pre>
E também o método que verifica se a lista está correta na classe <code>Entao</code>:
<pre class="brush:java">public static void deveSerAMesmaLista(List&lt;Evento&gt; eventos, List&lt;Evento&gt; eventosRetornados) {
	Assert.assertEquals(eventos.size(), eventosRetornados.size());
	Assert.assertTrue(eventos.containsAll(eventosRetornados));
}</pre>
Beleza, se rodarmos esses testes eles não vão "funfar", e provavelmente sua IDE vai gritar o por que. Faltam os métodos no controller que vão ser testados. Então vamos a eles. Eles utilizam o Result  e o DAO inserido pelo construtor.
<pre class="brush:java">public void list() {
	this.result.include("eventos", this.eventoDAO.list());
}

public void show(Long id) {
	this.result.include("evento", this.eventoDAO.load(id));
}</pre>
Agora, se rodarmos os testes,deveria funfar. Se não funfar #FUUUUUU.

Nessa primeira parte o terreno esta preparado. No próximo post vou mostrar como fiz pra validar o retorno de JSON e de XML(eca!).

&nbsp;

<a href="http://marcelotozzi.com.br/wp-content/uploads/2011/07/epic-meal-time-bacon.jpg"><img class="aligncenter size-full wp-image-357" title="epic-meal-time-bacon" src="http://marcelotozzi.com.br/wp-content/uploads/2011/07/epic-meal-time-bacon.jpg" alt="" width="550" height="300" /></a>
