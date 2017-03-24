---
layout: post
title: Neo4j - Quem você conhece no conjunto?
categories: NoSQL Java
tags: java nosql neo4j
image: /assets/article_images/2014-11-30-mediator_features/night-track.JPG
---
Quando estava na faculdade tinha aula de grafos e pensava: "Pow, beleza, busca em profundidade, busca em largura, entendi, mas quando vou usar isso?". Esta aí! O <a title="Neo4j" href="http://neo4j.org/" target="_blank">Neo4j</a> respondendo minha pergunta.

Mas que diabo é esse Neo4j exatamente? É um banco de dados em forma de grafo criado em Java. Essa abordagem é da "família" das soluções <a href="http://en.wikipedia.org/wiki/NoSQL" target="_blank">NoSQL</a>. Ai você já pergunta "Só posso usar em Java?". Nops meu caro, existem várias <a href="http://wiki.neo4j.org/content/Main_Page#Language_and_framework_bindings" target="_blank">integrações com linguagens</a> e um <a href="http://wiki.neo4j.org/content/Getting_Started_REST">server com interface REST</a>.

Pra quem estudou grafos ou não faltou nas aulas vai lembrar que temos um conjunto de pontos conhecidos por vértices e ligados ou não por arestas que também podem ter direção ou não.

No Neo4j temos esses objetos: o nó seria uma instância de Node no grafo tendo um identificador único; A aresta uma instância de Relationship tendo a relação entre dois nós, eles possuindo direção e qual o tipo de relacionamento. Tanto o nó quanto o relacionamento podem ter atributos, formados por chave-valor.
Nos bancos de dados relacionais podem existir estruturas de dados cheias de joins que podem (e vão) gerar problemas de perfomance. Utilizando grafos você pode navegar pelos nós independente da quantidade de dados que forma a estrutura.

Os acessos ao grafo são administrador por um sistema de transação <a href="http://en.wikipedia.org/wiki/ACID" target="_blank">ACID</a>. Para navegar pelo grafo é utilizada a <a href="http://wiki.neo4j.org/content/Traversal" target="_blank">API Traverser</a>. O Neo4j também tem suporte a <a href="http://components.neo4j.org/neo4j-index/stable/" target="_blank">indíces</a> e também oferece para isso integração com o <a href="http://components.neo4j.org/neo4j-lucene-index/stable/" target="_blank">Lucene</a>.

Vamos dar uma "testada" nesse treco então:

Corre, Paul Tergat, corre!
-------------------------

![](/assets/images/paul-tergat-300x237.jpg)

Vamos então fazer algo em Java. Eu sei que você "marotamente" já fez o <a href="http://neo4j.org/download">download do Neo4j</a> e já criou um projeto no <a href="http://www.eclipse.org/" target="_blank">Eclipse</a> e jogou nele as libs.

![]({{ site.url }}/assets/images/libs.jpg)

Agora vamos criar um Service que ira acessar nosso banco de dados em grafo.</p>

{% highlight java linenos %}
public class CorridaService {
}
{% endhighlight %}

E claro um teste deste cara.

{% highlight java linenos %}
public class CorridaServiceTest {
	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}
}
{% endhighlight %}

Antes de criar um teste vamos adicionar um método para "limpar" nosso banco antes de rodar o teste, ele vai deletar os arquivos do banco criados pelo Neo4j para não termos duplicidade no teste. Adicionamos uma propriedade String com o caminho/nome do banco e no setUp() do teste o método de exclusão:

{% highlight java linenos %}private static final String CORRIDAS_DB = "sample/corrida-db";

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
}{% endhighlight %}

O CorridaService vai precisar acessar os dados de alguma forma, claro, então vamos dar isso a ele no contrutor, e também um index pra facilitar a vida em certas buscas. Então vamos inserir isso no nosso setUp() e dar um shutdown() no tearDown(). O new EmbeddedGraphDatabase(...) cria os arquivos do grafo.

{% highlight java linenos %}public class CorridaServiceTest {
	private static final String CORRIDAS_DB = "sample/corrida-db";
	private CorridaService service;
	private GraphDatabaseService graphDatabaseService;
	private Index<Node> index;

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
}{% endhighlight %}

Agora o @Test! Precisamos criar a corrida e depois dizer quem correu, onde e a colocação.

{% highlight java linenos %}@Test
public void deveCriarCorridaEInserirOPrimeiroColocado() {
	Corrida corrida = this.service.criaCorrida("São Silvestre", "42 km");

	Colocacao primeiro = this.service.criaColocacaoParaCorredor("São Silvestre", 
		"Paul Tergat", "Primeiro");

        // blablabla depois coloco os assert's aqui
}{% endhighlight %}

Adiantando vamos criar as entidade que vamos precisar, Corrida, Colocação e Corredor. Corrida e Corredor terão a propriedade que equivale ao vértice(Node) do grafo.Porém a Colocação é a relação entre Corrida e Corredor, portanto tem em vez de um  vértice, uma aresta(Relationship).

{% highlight java linenos %}public class Corrida {
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
}{% endhighlight %}
<br>
{% highlight java linenos %}public class Corredor {
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
}{% endhighlight %}
<br>
{% highlight java linenos %}public class Colocacao {
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
}{% endhighlight %}

Também criamos um Enum que terá os tipos de relação entre os nós. Ele precisa implementar a interface RelationshipType do Neo4j.

{% highlight java linenos %}public enum TipoDeRelacionamento implements RelationshipType {
	PAI, CORREU
}{% endhighlight %}

Lá no nosso teste fizemos o construtor do CorridaService receber alguns parâmetros e chamamos alguns métodos dele.Se você esta usando o Eclipse ele deve estar berrando pra você que os métodos não existem nem o construtor. Ai estão eles então.
{% highlight java linenos %}public class CorridaService {

	private static final String CORRIDA = "corrida";
	private GraphDatabaseService graphDb;
	private Index<Node> index;

	public CorridaService(GraphDatabaseService graphDatabaseService, Index<Node> index) {
		this.graphDb = graphDatabaseService;
		this.index = index;
	}

	public Corrida criaCorrida(String nome, String distancia) {
                return null;
	}

	public Colocacao criaColocacaoParaCorredor(String nomeDaCorrida, 
		String nomeDoCorredor, String colocacaoDeChegada) {
                return null;
	}
}{% endhighlight %}

Ok, depois dessa enrolação toda vamos ao que realmente interessa, os nós no grafo.

No método criaCorrida(...) criamos uma transação  e pegamos o nó de referência do grafo, criamos um nó que representará a corrida e inserimos nele os atributos. Depois é criada a relação entre o nó de referência e no da corrida, a novaCorrida tem uma relação com o nó de referência no qual o nó de referência é o "PAI" da novaCorrida . Adicionamos também a corrida num índice para ficar mais fácil de buscar posteriormente.
{% highlight java linenos %}public Corrida criaCorrida(String nome, String distancia) {
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
}{% endhighlight %}
Agora falta o método criaColocacaoParaCorredor(...). Nele praticamente a mesma coisa, só que não usamos mais o nó de referência do grafo, e sim a corrida. E para buscar a corrida o nosso amigo índice esta aqui pra ajudar. Como esse relacionamento tem a posição de chegada como atributo criamos uma instância de Colocacao e inserimos a Relationship nela.
{% highlight java linenos %}public Colocacao criaColocacaoParaCorredor(String nomeDaCorrida, String nomeDoCorredor, 
	String colocacaoDeChegada) {
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

			Relationship relacaoColocacao = nodeCorredor.createRelationshipTo(
				nodeCorrida, TipoDeRelacionamento.CORREU);

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
	}{% endhighlight %}
Faltou só o assert no nosso teste. O teste ficou assim:
{% highlight java linenos %}@Test
public void deveCriarCorridaEInserirOPrimeiroColocado() {
	Corrida corrida = this.service.criaCorrida("São Silvestre", "42 km");

	Colocacao primeiro = this.service.criaColocacaoParaCorredor("São Silvestre", 
		"Paul Tergat", "Primeiro");

	Assert.assertNotNull(corrida.getNode());
	Assert.assertEquals("São Silvestre", corrida.getNode().getProperty("nome"));
	Assert.assertEquals("42 km", corrida.getNode().getProperty("distancia"));

	Assert.assertEquals("São Silvestre", corrida.getNome());
	Assert.assertEquals("42 km", corrida.getDistancia());

	Assert.assertEquals("Primeiro", primeiro.getRelationship().getProperty("chegada"));
	Assert.assertEquals("Primeiro", primeiro.getChegada());
}{% endhighlight %}
Se fizemos tudo certo os assert's vão passar tranquilamente.

Sei que vários assert's e chamadas no mesmo teste não é muito bonito, mas esse post era pra exemplificar sobre o Neo4j.

Não sei se expliquei bem, mas está ai e no <a href="https://github.com/marcelotozzi/corrida-neo4j" target="_blank">Github</a> também.Depois faço um exemplo mais bonito, com VRaptor, Struts 2 ou afins.

Abraço.
