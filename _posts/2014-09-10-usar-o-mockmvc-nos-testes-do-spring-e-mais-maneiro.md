---
layout: post
title:  "Usar o MockMvc nos testes do Spring é mais maneiro"
categories: [Teste,Java]
tags:
- java
- spring
---
Não sei como vocês testam seus controllers feitos usando Spring <s>ou se testam :P</s>, mas normalmente o que eu vejo sendo feito é algo parecido com isso. 

Um suposto controller:

{% highlight java linenos %}
@Controller
@RequestMapping("api")
public class MeuController {
    @RequestMapping(value = "show/{id}", 
    				method = RequestMethod.GET, 
    				produces = {"application/json"})
    public
    @ResponseBody
    ResponseEntity<String> show(
                @PathVariable(value = "id") final Integer id, 
                final HttpServletRequest request, 
                final HttpServletResponse response) {
        HttpHeaders headers = new HttpHeaders();
        try {
            // Chamos minhas classes que fazem a mágica acontecer s2
            headers.setContentType(MediaType.APPLICATION_JSON);
            return new ResponseEntity<>("Retorno algo", headers, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(headers, HttpStatus.BAD_REQUEST);
        }
    }
}
{% endhighlight %}

E o teste dele:

{% highlight java linenos %}
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {"/applicationContext-test.xml"})
public class MeuControllerTest {
    @Autowired
    private MeuController meuController;

    @Test
    public void testandoAMinhaFuncionalidadeMagica() {
        ResponseEntity<String> resultado = meuController.show(1, 
            new MockHttpServletRequest(), new MockHttpServletResponse());

        assertThat(resultado.getStatusCode(), is(equalTo(HttpStatus.OK)));
        assertThat(resultado.getHeaders().getContentType(), 
                    is(equalTo(MediaType.APPLICATION_JSON)));
        assertThat(resultado.getBody(), is(equalTo("Retorno algo")));
    }
}
{% endhighlight %}


Isso faz o que? Testa praticamente o retorno do método. Se olharmos no controller temos anotações de MediaType, verbo HTTP, qual o caminho da url. Fazendo o teste apenas chamando o método essas coisas não são testadas.

Mesmo usando o ResponseEntity, como eu fiz, você só consegue testar dados de retorno. Mas será que o meu JSON seria convertido corretamente pelo Spring caso eu recebesse no meu método um `@RequestBody MeuObjeto meuObj`?

Usando o `MockMVC` você pode validar essas coisas. Olhe isso, e depois eu explico:

{% highlight java linenos %}
private MockMvc mockMvc;

@Before
public void setUp() {
    mockMvc = MockMvcBuilders.standaloneSetup(meuController).build();
}

@Test
public void testandoAMinhaFuncionalidadeMagicaComMockMVC() throws Exception {
    ResultActions response = mockMvc.perform(
                get("/api/show/1")
                        .contentType(MediaType.TEXT_HTML)
                        .header("meu header", "valor do meu header"));

    response.andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(content().string("Retorno algo"));
}
{% endhighlight %}

Dá para ver que você consegue testar os verbos HTTP, Content-types, headers. Quando você "starta" o seu teste o `MockMvcBuilders` no `@Before` constrói os controllers para você usar no teste. Quando você chama o método `get("/api/show/1")` você esta fazendo uma requisição `GET` para aquela url do seu controller setado no `@Before`. 

O resultado disso, independente de erro ou acerto na requisição, é o `ResultActions` que te dá a oportunidade de validar o retorno da requisição, onde você pode testar o status HTTP (com o `andExpect(status().isOk())`), os dados retornados no header (com o `andExpect(header().string("Location","xxxx"))`), o conteúdo retornado (`andExpect(content().string("Retorno algo"))`), entre outros.

Olha o log aqui do mapeamento que o `MockMvcBuilders` faz:

{% highlight java linenos %}
INFO - Mapped "{[/api/show/{id}],methods=[GET],params=[],headers=[],consumes=[],produces=[application/json],custom=[]}" onto public org.springframework.http.ResponseEntity<java.lang.String> br.com.meuprojeto.controller.MeuController.show(java.lang.Integer,javax.servlet.http.HttpServletRequest,javax.servlet.http.HttpServletResponse)
INFO - Initializing Spring FrameworkServlet ''
INFO - FrameworkServlet '': initialization started
INFO - FrameworkServlet '': initialization completed in 0 ms
{% endhighlight %} 

Fui



