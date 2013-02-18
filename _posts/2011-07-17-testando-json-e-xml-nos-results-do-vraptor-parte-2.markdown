---
layout: post
title: Testando JSON e XML nos Results do VRaptor - Parte 2
tags:
- Java
- JSON
- JUnit
- Mock
- Mockito
- Pessoal
- TDD
- VRaptor
- XML
status: publish
type: post
published: true
meta:
  _edit_last: '1'
  _thumbnail_id: '415'
  dsq_thread_id: '360856452'
---
<a href="http://marcelotozzi.com.br/wp-content/uploads/2011/09/jason_up.jpg"><img class="aligncenter size-full wp-image-415" title="jason_up" src="http://marcelotozzi.com.br/wp-content/uploads/2011/09/jason_up.jpg" alt="" width="520" height="347" /></a>

Continuando com o código do <a title="Testando JSON e XML nos Results do VRaptor" href="http://marcelotozzi.com.br/2011/07/testando-json-e-xml-nos-results-do-vraptor/" target="_blank">post anterior</a> ...

Agora é criar uma classe de testes separada para os testes de serialização. Desta vez usei o <code>MockSerializationResult</code> que é o mock que o VRaptor 3.4 disponibiliza e como eu disse no post anterior não existia no SNAPSHOT 3.3.
<pre class="brush:java">public class SerializeEventoControllerTest {
	private MockSerializationResult result;
	private EventoController controller;
	@Mock
	private EventoDAO eventoDAO;

	@Before
	public void setup(){
		MockitoAnnotations.initMocks(this);
		this.result = new MockSerializationResult();
		this.controller = new EventoController(this.result, this.eventoDAO);
	}
}</pre>
Agora é hora de criar os métodos de teste, eles são bem parecidos com os anteriores a diferença é como pegamos o objeto serializado, precisamos chamar o método <code>serializedResult</code> do <code>MockSerializationResult</code>.
<pre class="brush:java">@Test
public void deveRetornarUmEventoNoFormatoJSON() throws Exception {
	Evento evento = Dado.umEvento(1L, "BACONSP", "Bacon Conference SP", "Av Paulista", Calendar.getInstance());
	Mockito.when(this.eventoDAO.load(evento.getId())).thenReturn(evento);

	this.controller.showJSON(1L);

	String esperado = Entao.deveRetornaJSONde(evento);
	String retornado = this.result.serializedResult();

	Assert.assertThat(retornado, is(equalTo(esperado)));
}

@Test
public void deveRetornarUmaListaDeEventoNoFormatoJSON() throws Exception {
	List&lt;Evento&gt; eventos = Dado.umaListaCadastrada();
	Mockito.when(this.eventoDAO.list()).thenReturn(eventos);

	this.controller.listJSON();

	String esperado = Entao.deveRetornaListaJSONde(eventos);
	String retornado = this.result.serializedResult();

	Assert.assertThat(retornado , is(equalTo(esperado)));
}</pre>
Também criei novos métodos na classe <code>Entao</code> para me ajudar nos <code>assert</code>'s. Para não ter que ficar criando o JSON na mão usei o <code><a href="http://xstream.codehaus.org/" target="_blank">XStream</a></code>, a mesma coisa que o VRaptor internamente usa.
<pre class="brush:java">public static String deveRetornaJSONde(Evento evento) {
	XStream xstream = getXStreamJSON();

	xstream.alias("evento", Evento.class);
	return xstream.toXML(evento);
}

public static String deveRetornaListaJSONde(List&lt;Evento&gt; eventos) {
	XStream xstream = getXStreamJSON();

	xstream.alias("eventos", List.class);
	return xstream.toXML(eventos);
}</pre>
Poréms se você usar o <code>XStream</code> diretamente com o <a href="http://jettison.codehaus.org/" target="_blank">Jettison</a>, seus testes não vão passar, pois o VRaptor utiliza uma indentação diferente do padrão do XStream para o JSON. Por isso o método <code>getStreamJSON()</code> na classe <code>Entao</code>. Esse código peguei da classe do VRaptor <code><a href="https://github.com/caelum/vraptor/blob/master/vraptor-core/src/main/java/br/com/caelum/vraptor/serialization/xstream/XStreamJSONSerialization.java" target="_blank">XStreamJSONSerialization</a></code>. Dá pra melhorar pra classe de teste mas vou deixar assim mesmo, eu só não sei por que eles colocaram esse espaço internamente no framework.
<pre class="brush:java">private static final String DEFAULT_NEW_LINE = "";
private static final char[] DEFAULT_LINE_INDENTER = {};
private static final String INDENTED_NEW_LINE = "\n";
private static final char[] INDENTED_LINE_INDENTER = { ' ', ' ' };
private static boolean withoutRoot = false;
private static boolean indented = false;

private static XStream getXStreamJSON() {
	final String newLine = (indented ? INDENTED_NEW_LINE : DEFAULT_NEW_LINE);
	final char[] lineIndenter = (indented ? INDENTED_LINE_INDENTER : DEFAULT_LINE_INDENTER);

	XStream xstream = new XStream(new JsonHierarchicalStreamDriver(){
		public HierarchicalStreamWriter createWriter(Writer writer) {
			if (withoutRoot) {
				return new JsonWriter(writer, lineIndenter, newLine, JsonWriter.DROP_ROOT_MODE);
			}
			return new JsonWriter(writer, lineIndenter, newLine);
		}
	});
	return xstream;
}</pre>
Agora vamos criar os testes para o XML na classe <code>SerializeEventoControllerTest</code> que são praticamente a mesma coisa:
<pre class="brush:java">@Test
public void deveRetornarUmEventoNoFormatoXML() throws Exception {
	Evento evento = Dado.umEvento(1L, "BACONSP", "Bacon Conference SP", "Av Paulista", Calendar.getInstance());
	Mockito.when(this.eventoDAO.load(evento.getId())).thenReturn(evento);

	this.controller.showXML(1L);

	String esperado = Entao.deveRetornaXMLde(evento);
	String retornado = this.result.serializedResult();

	Assert.assertThat(retornado, is(equalTo(esperado)));
}

@Test
public void deveRetornarUmaListaDeEventoNoFormatoXML() throws Exception {
	List&lt;Evento&gt; eventos = Dado.umaListaCadastrada();
	Mockito.when(this.eventoDAO.list()).thenReturn(eventos);

	this.controller.listXML();

	String esperado = Entao.deveRetornaListaXMLde(eventos);
	String retornado = this.result.serializedResult();

	Assert.assertThat(retornado , is(equalTo(esperado)));
}</pre>
E também os métodos de <code>assert</code> que pra XML são mais simples:
<pre class="brush:java">public static String deveRetornaXMLde(Evento evento) {
	XStream xstream = new XStream();

	xstream.alias("evento", Evento.class);
	return xstream.toXML(evento);
}</pre>
Um detalhe é que para uma lista, temos que indicar ao XStream para serializar a lista e os objetos que ela contém:
<pre class="brush:java">public static String deveRetornaListaXMLde(List&lt;Evento&gt; eventos) {
	XStream xstream = new XStream();

	xstream.alias("eventos", List.class);
	xstream.alias("evento", Evento.class);
	return xstream.toXML(eventos);
}</pre>
Finalmente vamos criar os métodos no EventoController que transformar os eventos e listas de eventos em XML e/ou JSON. Para isso precisamos indicar para o Result qual o formato que ele deve disponibilizar para a view, inserir o objeto e "mandar" serializar. Essa seria a forma programática, para outras formas<a href="http://vraptor.caelum.com.br/documentacao/view-e-ajax/" target="_blank"> tente isso</a>.
<pre class="brush:java">public void showXML(Long id) {
	this.result.use(Results.xml()).from(this.eventoDAO.load(id), "evento").serialize();
}

public void showJSON(Long id) {
	this.result.use(Results.json()).from(this.eventoDAO.load(id), "evento").serialize();
}

public void listXML() {
	this.result.use(Results.xml()).from(this.eventoDAO.list(), "eventos").serialize();
}

public void listJSON() {
	this.result.use(Results.json()).from(this.eventoDAO.list(), "eventos").serialize();
}</pre>
Era isso que queria compartilhar, simples não? :)

O código está <a href="https://github.com/marcelotozzi/vraptor-result-test" target="_blank">AQUI</a>.

Inté manolos...
