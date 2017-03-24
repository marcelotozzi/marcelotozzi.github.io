---
layout: post
title: VRaptor - Entre interceptors e annotations!
categories: Java
tags: annotation interceptor java vraptor
image: /assets/images/background/night-track.JPG
---
Atualmente estou re-escrevendo meu TCC, pois na época que fizemos o grupo que desenvolveu não estava aberto a idéia de usar TDD e afins, isso me deixou incomodado.

Usamos o <a href="http://vraptor.caelum.com.br/" target="_blank">VRaptor</a> para o pattern MVC. Estava eu refazendo e corrigindo os controllers e fui então recriar os interceptors de acesso para recursos que só seriam acessíveis com usuário logado (caso não entenda bulhufas dos interceptors no VRaptor, <a href="http://vraptor.caelum.com.br/documentacao/interceptadores/" target="_blank">leia isso</a>) então me deparei com isso:

{% highlight java linenos %}@Intercepts
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
}{% endhighlight %}

Se fosse chamado XPTOController ou FooController a chamada seria interceptada. Porém eu queria liberar alguns métodos do meu Controller, por exemplo o show de XPTOController pra mostrar um cadastro ou o authenticates do AccountController. Teria que verificar qual método estava sendo chamado pelo nome, então ficaria assim o accepts:

{% highlight java linenos %}@Override
public boolean accepts(ResourceMethod method) {
	return (method.getResource().getType().isAssignableFrom(XPTOController.class)
			    && !method.getMethod().getName().equals("show")) ||
	       (method.getResource().getType().isAssignableFrom(AccountController.class)
			    && !method.getMethod().getName().equals("authenticates"));
}{% endhighlight %}

method.getMethod() retorna o método java que está sendo chamado e method.getResource().getType() a classe que está sendo executada.

![](/assets/article_images/2011-05-25-vraptor-entre-interceptors-e-annotations/philosoraptor-300x300.jpg)

Porém se eu precisar interceptar e liberar mais métodos e controllers nesse accepts, ficaria uma coisa bem feia e chata de mexer. Então o que fiz?

Para não ter q ficar alterando meu interceptor a todo método ou controller que eu criar ou quiser liberar resolvi criar annotations para facilitar a verificação. Uma annotation para verificar se aquele recurso deve ser interceptado chamada @InterceptResource.

Beleza, ai todos os métodos do controller anotado são interceptados, mas e os métodos que eu quero liberar, como o show dito anteriormente, como ficam? Pra solucionar isso criei outra annotation chamada @NoInterceptMethod para verificar também no interceptor se aquele método pode ser acessado sem verificação de acesso. Mas vamos ver como eu usei.

A annotation @InterceptResource.

{% highlight java linenos %}@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface InterceptResource {
}{% endhighlight %}

A annotation @NoInterceptMethod.

{% highlight java linenos %}@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface NoInterceptMethod {
}{% endhighlight %}

Então anoto meu controller e método.

{% highlight java linenos %}@Resource
@InterceptResource
public class XPTOController {

	//...

	@NoInterceptMethod
	public void show() {
	}
}{% endhighlight %}

E finalmente depois de toda essa ladainha, como ficou meu método accepts apenas verificando se controller e método estão anotados. Sempre intercepto minha chamada se o recurso estiver anotado com @InterceptResource e se o método não estiver anotado com @NoInterceptMethod.

{% highlight java linenos %}public boolean accepts(ResourceMethod method) {
	return method.getResource().getType().isAnnotationPresent(InterceptResource.class) &&
		!method.getMethod().isAnnotationPresent(NoInterceptMethod.class);
}{% endhighlight %}

Não sei se existem alguma outra alternativa no VRaptor, se exister me avisem, hehe.

Mas é isso ai, abraço
