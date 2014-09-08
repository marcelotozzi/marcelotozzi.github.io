---
layout: post
title:  "Encoding UTF-8 no Tomcat com Spring"
categories: [Java]
tags:
- java
- encoding
- spring
---

Você esta lá, criando sua aplicação com Spring, Hibernate e afins. Seguindo aquele padrão que quase todo mundo usa <s>#sad</s> ou usou. 

Você já definiu seu `web.xml` do Spring com `UTF-8`.

{% highlight xml linenos %}
<web-app xmlns="http://java.sun.com/xml/ns/javaee" 
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
          http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
         version="3.0">

	<!-- suas configurações -->
	
	<filter>
        <filter-name>charsetFilter</filter-name>
        <filter-class>
        	org.springframework.web.filter.CharacterEncodingFilter
    	</filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>UTF-8</param-value>
        </init-param>
        <init-param>
            <param-name>forceEncoding</param-name>
            <param-value>true</param-value>
        </init-param>
    </filter>

    <!-- Mais configurações suas -->

    <jsp-config>
        <jsp-property-group>
            <url-pattern>*.jsp</url-pattern>
            <page-encoding>UTF-8</page-encoding>
        </jsp-property-group>
    </jsp-config>
</web>
{% endhighlight %}

Ai você faz deploy da sua app no seu Tomcat, porém aparece aquele problema de encoding danado, aqueles caracteres com `��`. Por que? 

Fazendo deploy, mesmo você setando no seu `web.xml`, será usado o encoding do Tomcat. 

Pra resolver isso crie o arquivo `setenv.sh` na pasta `bin` do seu tomcat:

{% highlight bash linenos %}
export JAVA_OPTS="${JAVA_OPTS} -Dfile.encoding=UTF8"
{% endhighlight %}

"Restarte" o seu Tomcat e, como diria Salomão Schvartzman: Seja feliz!. 

<s>Eu sempre esqueço o setenv.sh</s> 

*PS: Aqui resolveu, e pra você ai?*