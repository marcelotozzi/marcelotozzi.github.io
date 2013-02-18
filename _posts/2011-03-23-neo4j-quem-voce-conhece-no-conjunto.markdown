---
layout: post
title: Neo4j - Quem você conhece no conjunto?
tags:
- Java
- Neo4j
- NoSQL
status: publish
type: post
published: true
meta:
  _edit_last: '1'
  _thumbnail_id: '35'
  dsq_thread_id: '261494384'
  socialize_text: If you enjoyed this post, please consider <a href="#comments">leaving
    a comment</a> or <a href="http://marcelotozzi.com.br/feed/" title="Syndicate this
    site using RSS">subscribing to the <abbr title="Really Simple Syndication">RSS</abbr>
    feed</a> to have future articles delivered to your feed reader.
  socialize: '1,2,11,12,19,23'
---
Quando estava na faculdade tinha aula de grafos e pensava: "Pow, beleza, busca em profundidade, busca em largura, entendi, mas quando vou usar isso?". Esta aí! O <a title="Neo4j" href="http://neo4j.org/" target="_blank">Neo4j</a> respondendo minha pergunta.

Mas que diabo é esse Neo4j exatamente? É um banco de dados em forma de grafo criado em Java. Essa abordagem é da "família" das soluções <a href="http://en.wikipedia.org/wiki/NoSQL" target="_blank">NoSQL</a>. Ai você já pergunta "Só posso usar em Java?". Nops meu caro, existem várias <a href="http://wiki.neo4j.org/content/Main_Page#Language_and_framework_bindings" target="_blank">integrações com linguagens</a> e um <a href="http://wiki.neo4j.org/content/Getting_Started_REST">server com interface REST</a>.

Pra quem estudou grafos ou não faltou nas aulas vai lembrar que temos um conjunto de pontos conhecidos por vértices e ligados ou não por arestas que também podem ter direção ou não.

No Neo4j temos esses objetos: o nó seria uma instância de Node no grafo tendo um identificador único; A aresta uma instância de Relationship tendo a relação entre dois nós, eles possuindo direção e qual o tipo de relacionamento. Tanto o nó quanto o relacionamento podem ter atributos, formados por chave-valor.
Nos bancos de dados relacionais podem existir estruturas de dados cheias de joins que podem (e vão) gerar problemas de perfomance. Utilizando grafos você pode navegar pelos nós independente da quantidade de dados que forma a estrutura.

Os acessos ao grafo são administrador por um sistema de transação <a href="http://en.wikipedia.org/wiki/ACID" target="_blank">ACID</a>. Para navegar pelo grafo é utilizada a <a href="http://wiki.neo4j.org/content/Traversal" target="_blank">API Traverser</a>. O Neo4j também tem suporte a <a href="http://components.neo4j.org/neo4j-index/stable/" target="_blank">indíces</a> e também oferece para isso integração com o <a href="http://components.neo4j.org/neo4j-lucene-index/stable/" target="_blank">Lucene</a>.

Vamos dar uma "testada" nesse treco então:
<h2>Corre, Paul Tergat, corre!</h2>
<a href="http://marcelotozzi.com.br/wp-content/uploads/2011/03/paul-tergat.jpg" target="_blank"><img class="alignnone size-medium wp-image-35" title="paul-tergat" src="http://marcelotozzi.com.br/wp-content/uploads/2011/03/paul-tergat-300x237.jpg" alt="" width="300" height="237" /></a>
<p style="text-align: left;">Vamos então fazer algo em Java. Eu sei que você "marotamente" já fez o <a href="http://neo4j.org/download">download do Neo4j</a> e já criou um projeto no <a href="http://www.eclipse.org/" target="_blank">Eclipse</a> e jogou nele as libs.</p>
<p style="text-align: left;"><a href="http://marcelotozzi.com.br/wp-content/uploads/2011/03/libs.png"></a><a href="http://marcelotozzi.com.br/wp-content/uploads/2011/03/libs.jpg" target="_blank"><img class="alignnone size-full wp-image-49" title="libs" src="http://marcelotozzi.com.br/wp-content/uploads/2011/03/libs.jpg" alt="" width="368" height="355" /></a></p>
<p style="text-align: left;">&nbsp;</p>
<p style="text-align: left;">Agora vamos criar um Service que ira acessar nosso banco de dados em grafo.</p>
<!-- p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 11.0px Monaco} span.s1 {color: #9a1867} --> <!-- p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 11.0px Monaco} p.p2 {margin: 0.0px 0.0px 0.0px 0.0px; font: 11.0px Monaco; min-height: 15.0px} p.p3 {margin: 0.0px 0.0px 0.0px 0.0px; font: 11.0px Monaco; color: #9a1867} span.s1 {color: #9a1867} span.s2 {color: #000000} span.s3 {color: #0023c7} span.s4 {color: #382ffa} span.Apple-tab-span {white-space:pre} -->
<pre class="brush:java">public class CorridaService {
}</pre>
E claro um teste deste cara.
<pre class="brush:java">public class CorridaServiceTest {
	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}
}</pre>
<p style="text-align: left;">&nbsp;</p>
<p style="text-align: left;">Antes de criar um teste vamos adicionar um método para "limpar" nosso banco antes de rodar o teste, ele vai deletar os arquivos do banco criados pelo Neo4j para não termos duplicidade no teste. Adicionamos uma propriedade String com o caminho/nome do banco e no setUp() do teste o método de exclusão:</p>

<pre class="brush:java">private static final String CORRIDAS_DB = "sample/corrida-db";

@Before
public void setUp() throws Exception {
        deletaArquivoOuDiretorio(new File(CORRIDAS_DB));
}

//blablabla outros métodos

private void deletaArquivoOuDiretorio(File arquivo) {
	if (!arquivo.exists()) {
		return;
	}
	if (arquivo.isDirectory()) {
		for (File child : arquivo.listFiles()) {
			deletaArquivoOuDiretorio(child);
		}
	} else {
		arquivo.delete();
	}
}</pre>
<p style="text-align: left;">&nbsp;</p>
<p style="text-align: left;">O CorridaService vai precisar acessar os dados de alguma forma, claro, então vamos dar isso a ele no contrutor, e também um index pra facilitar a vida em certas buscas. Então vamos inserir isso no nosso setUp() e dar um shutdown() no tearDown(). O new EmbeddedGraphDatabase(...) cria os arquivos do grafo.</p>

<pre class="brush:java">public class CorridaServiceTest {
	private static final String CORRIDAS_DB = "sample/corrida-db";
	private CorridaService service;
	private GraphDatabaseService graphDatabaseService;
	private Index&lt;Node&gt; index;

	@Before
	public void setUp() throws Exception {
		deletaArquivoOuDiretorio(new File(CORRIDAS_DB));

		this.graphDatabaseService = new EmbeddedGraphDatabase(CORRIDAS_DB);
		this.index = graphDatabaseService.index().forNodes("nodes");
		this.service = new CorridaService(this.graphDatabaseService, this.index);
	}

	@After
	public void tearDown() throws Exception {
		this.graphDatabaseService.shutdown();
	}
	// blablabla outros métodos
}</pre>
<p style="text-align: left;">&nbsp;</p>
<p style="text-align: left;">Agora o @Test! Precisamos criar a corrida e depois dizer quem correu, onde e a colocação.</p>

<pre class="brush:java">@Test
public void deveCriarCorridaEInserirOPrimeiroColocado() {
	Corrida corrida = this.service.criaCorrida("São Silvestre", "42 km");

	Colocacao primeiro = this.service.criaColocacaoParaCorredor("São Silvestre", "Paul Tergat", "Primeiro");

        // blablabla depois coloco os assert`s aqui
}</pre>
<p style="text-align: left;">&nbsp;</p>
<p style="text-align: left;">Adiantando vamos criar as entidade que vamos precisar, Corrida, Colocação e Corredor. Corrida e Corredor terão a propriedade que equivale ao vértice(Node) do grafo.Porém a Colocação é a relação entre Corrida e Corredor, portanto tem em vez de um  vértice, uma aresta(Relationship).</p>

<pre class="brush:java">public class Corrida {
	private Node node;
	private static final String NOME = "nome";
	private static final String DISTANCIA = "distancia";

	public void setNode(Node node) {
		this.node = node;
	}

	public Node getNode() {
		return this.node;
	}

	public void setNome(String nome) {
		this.node.setProperty(NOME, nome);
	}

	public String getNome() {
		return (String) this.node.getProperty(NOME);
	}

	public void setDistancia(String distancia) {
		this.node.setProperty(DISTANCIA, distancia);
	}

	public String getDistancia() {
		return (String) this.node.getProperty(DISTANCIA);
	}
}</pre>
<pre class="brush:java">public class Corredor {
	private Node node;
	private static final String NOME = "nome";

	public void setNode(Node node) {
		this.node = node;
	}

	public Node getNode() {
		return this.node;
	}

	public void setNome(String nome) {
		this.node.setProperty(NOME, nome);
	}
}</pre>
<pre class="brush:java">public class Colocacao {
	private static final String CHEGADA = "chegada";
	private Relationship relacao;

	public Relationship getRelationship() {
		return this.relacao;
	}

	public void setRelationship(final Relationship rel) {
		this.relacao = rel;
	}

	public String getChegada() {
		return (String) relacao.getProperty(CHEGADA, null);
	}

	public void setChegada(String chegada) {
		relacao.setProperty(CHEGADA, chegada);
	}
}</pre>
<p style="text-align: left;">&nbsp;</p>
<p style="text-align: left;">Também criamos um Enum que terá os tipos de relação entre os nós. Ele precisa implementar a interface RelationshipType do Neo4j.</p>

<pre class="brush:java">public enum TipoDeRelacionamento implements RelationshipType {
	PAI, CORREU
}</pre>
Lá no nosso teste fizemos o construtor do CorridaService receber alguns parâmetros e chamamos alguns métodos dele.Se você esta usando o Eclipse ele deve estar berrando pra você que os métodos não existem nem o construtor. Ai estão eles então.
<pre class="brush:java">public class CorridaService {

	private static final String CORRIDA = "corrida";
	private GraphDatabaseService graphDb;
	private Index&lt;Node&gt; index;

	public CorridaService(GraphDatabaseService graphDatabaseService, Index&lt;Node&gt; index) {
		this.graphDb = graphDatabaseService;
		this.index = index;
	}

	public Corrida criaCorrida(String nome, String distancia) {
                return null;
	}

	public Colocacao criaColocacaoParaCorredor(String nomeDaCorrida, String nomeDoCorredor, String colocacaoDeChegada) {
                return null;
	}
}</pre>
Ok, depois dessa enrolação toda vamos ao que realmente interessa, os nós no grafo.

No método criaCorrida(...) criamos uma transação  e pegamos o nó de referência do grafo, criamos um nó que representará a corrida e inserimos nele os atributos. Depois é criada a relação entre o nó de referência e no da corrida, a novaCorrida tem uma relação com o nó de referência no qual o nó de referência é o "PAI" da novaCorrida . Adicionamos também a corrida num índice para ficar mais fácil de buscar posteriormente.
<pre class="brush:java">public Corrida criaCorrida(String nome, String distancia) {
	Transaction tx = this.graphDb.beginTx();
	try {
		Node nodeReferencia = this.graphDb.getReferenceNode();

		Node novaCorrida = this.graphDb.createNode();

		Corrida corrida = new Corrida();
		corrida.setNode(novaCorrida);
		corrida.setNome(nome);
		corrida.setDistancia(distancia);

		novaCorrida.createRelationshipTo(nodeReferencia, TipoDeRelacionamento.PAI);

		index.add(novaCorrida, CORRIDA, nome);

		tx.success();
		return corrida;
	} finally {
		tx.finish();
	}
}</pre>
Agora falta o método criaColocacaoParaCorredor(...). Nele praticamente a mesma coisa, só que não usamos mais o nó de referência do grafo, e sim a corrida. E para buscar a corrida o nosso amigo índice esta aqui pra ajudar. Como esse relacionamento tem a posição de chegada como atributo criamos uma instância de Colocacao e inserimos a Relationship nela.
<pre class="brush:java">	public Colocacao criaColocacaoParaCorredor(String nomeDaCorrida, String nomeDoCorredor, String colocacaoDeChegada) {
		Transaction tx = this.graphDb.beginTx();
		try {
			Node nodeCorrida = this.index.get(CORRIDA, nomeDaCorrida)
					.getSingle();

			Node nodeCorredor = this.graphDb.createNode();

			Corredor corredor = new Corredor();
			corredor.setNode(nodeCorredor);
			corredor.setNome(nomeDoCorredor);

			if (nodeCorrida == null) {
				throw new IllegalArgumentException("Null corrida");
			}
			if (nodeCorredor == null) {
				throw new IllegalArgumentException("Null corredor");
			}

			Relationship relacaoColocacao = nodeCorredor.createRelationshipTo(nodeCorrida, TipoDeRelacionamento.CORREU);

			Colocacao colocacao = new Colocacao();
			colocacao.setRelationship(relacaoColocacao);

			if (colocacaoDeChegada != null) {
				colocacao.setChegada(colocacaoDeChegada);
			}
			tx.success();
			return colocacao;
		} finally {
			tx.finish();
		}
	}</pre>
Faltou só o assert no nosso teste. O teste ficou assim:
<pre class="brush:java">@Test
public void deveCriarCorridaEInserirOPrimeiroColocado() {
	Corrida corrida = this.service.criaCorrida("São Silvestre", "42 km");

	Colocacao primeiro = this.service.criaColocacaoParaCorredor("São Silvestre", "Paul Tergat", "Primeiro");

	Assert.assertNotNull(corrida.getNode());
	Assert.assertEquals("São Silvestre", corrida.getNode().getProperty("nome"));
	Assert.assertEquals("42 km", corrida.getNode().getProperty("distancia"));

	Assert.assertEquals("São Silvestre", corrida.getNome());
	Assert.assertEquals("42 km", corrida.getDistancia());

	Assert.assertEquals("Primeiro", primeiro.getRelationship().getProperty("chegada"));
	Assert.assertEquals("Primeiro", primeiro.getChegada());
}</pre>
Se fizemos tudo certo os assert`s vão passar tranquilamente.

Sei que vários assert`s e chamadas no mesmo teste não é muito bonito, mas esse post era pra exemplificar sobre o Neo4j.

Não sei se expliquei bem, mas está ai e no <a href="https://github.com/marcelotozzi/corrida-neo4j" target="_blank">Github</a> também.Depois faço um exemplo mais bonito, com VRaptor, Struts 2 ou afins.

Abraço.
