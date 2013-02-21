---
layout: post
title: VRaptor - Entre interceptors e annotations!
tags:
- title: Annotation
  slug: annotation
- title: Interceptor
  slug: interceptor
- title: Java
  slug: java
- title: Pessoal
  slug: pessoal
- title: VRaptor
  slug: vraptor
status: publish
type: post
published: true
meta:
  _edit_last: '1'
  _thumbnail_id: '294'
  dsq_thread_id: '313110859'
  _wp_old_slug: vraptorentre-interceptors-e-annotations
---
<p style="text-align: left;">Atualmente estou re-escrevendo meu TCC, pois na época que fizemos o grupo que desenvolveu não estava aberto a idéia de usar TDD e afins, isso me deixou incomodado.</p>
<p style="text-align: left;">Usamos o <a href="http://vraptor.caelum.com.br/" target="_blank">VRaptor</a> para o pattern MVC. Estava eu refazendo e corrigindo os controllers e fui então recriar os interceptors de acesso para recursos que só seriam acessíveis com usuário logado (caso não entenda bulhufas dos interceptors no VRaptor, <a href="http://vraptor.caelum.com.br/documentacao/interceptadores/" target="_blank">leia isso</a>) então me deparei com isso:</p>

<pre class="brush:java">@Intercepts
public class XPTOInterceptor implements Interceptor {
	@Override
	public boolean accepts(ResourceMethod method) {
		return method.getResource().getType()
			     .isAssignableFrom(XPTOController.class) ||
		       method.getResource().getType()
			     .isAssignableFrom(AccountController.class);
	}

	@Override
	public void intercept(InterceptorStack stack, ResourceMethod method,
			Object resourceInstance) throws InterceptionException {
		//Faz alguma coisa
	}
}</pre>
<p style="text-align: left;">Se fosse chamado XPTOController ou FooController a chamada seria interceptada. Porém eu queria liberar alguns métodos do meu Controller, por exemplo o show de XPTOController pra mostrar um cadastro ou o authenticates do AccountController. Teria que verificar qual método estava sendo chamado pelo nome, então ficaria assim o accepts:</p>

<pre class="brush:java">@Override
public boolean accepts(ResourceMethod method) {
	return (method.getResource().getType().isAssignableFrom(XPTOController.class)
			    &amp;&amp; !method.getMethod().getName().equals("show")) ||
	       (method.getResource().getType().isAssignableFrom(AccountController.class)
			    &amp;&amp; !method.getMethod().getName().equals("authenticates"));
}</pre>
method.getMethod() retorna o método java que está sendo chamado e method.getResource().getType() a classe que está sendo executada.
<p style="text-align: justify;"><a href="/images_posts/philosoraptor.jpg"><img class="alignright size-medium wp-image-294" title="philosoraptor" src="/images_posts/philosoraptor-300x300.jpg" alt="" width="350" height="350" /></a>Porém se eu precisar interceptar e liberar mais métodos e controllers nesse accepts, ficaria uma coisa bem feia e chata de mexer. Então o que fiz?
Para não ter q ficar alterando meu interceptor a todo método ou controller que eu criar ou quiser liberar resolvi criar annotations para facilitar a verificação. Uma annotation para verificar se aquele recurso deve ser interceptado chamada @InterceptResource.
Beleza, ai todos os métodos do controller anotado são interceptados, mas e os métodos que eu quero liberar, como o show dito anteriormente, como ficam? Pra solucionar isso criei outra annotation chamada @NoInterceptMethod para verificar também no interceptor se aquele método pode ser acessado sem verificação de acesso. Mas vamos ver como eu usei.</p>
A annotation @InterceptResource.
<pre class="brush:java">@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface InterceptResource {
}</pre>
A annotation @NoInterceptMethod.
<pre class="brush:java">@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface NoInterceptMethod {
}</pre>
Então anoto meu controller e método.
<pre class="brush:java">@Resource
@InterceptResource
public class XPTOController {

	//...

	@NoInterceptMethod
	public void show() {
	}
}</pre>
E finalmente depois de toda essa ladainha, como ficou meu método accepts apenas verificando se controller e método estão anotados. Sempre intercepto minha chamada se o recurso estiver anotado com @InterceptResource e se o método não estiver anotado com @NoInterceptMethod.
<pre class="brush:java">public boolean accepts(ResourceMethod method) {
	return method.getResource().getType().isAnnotationPresent(InterceptResource.class) &amp;&amp;
		!method.getMethod().isAnnotationPresent(NoInterceptMethod.class);
}</pre>
Não sei se existem alguma outra alternativa no VRaptor, se exister me avisem, hehe.

Mas é isso ai, abraço
