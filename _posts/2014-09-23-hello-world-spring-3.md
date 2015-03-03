---
layout: post
title: "Hello World Spring 3"
tags: [spring, spring mvc, java, java web, webdev]
image:
  feature: posts/2014-09-23/spring-framework.png
comments: true
share: true
---

Nesse post explicarei como fazer criar um projeto spring mvc de forma rápida e fácil.

Nosso projeto terá:

- Um controlador que recebe uma requisição `GET` e retorna uma mensagem

As tecnologias usadas serão utilizadas:

- Spring 3.2.11-RELEASE
- JDK 1.7
- Maven 3
- Intellij IDEA 13

### Criando a estrutura de diretórios

Essa é a estrutura necessária para a criação de aplicativos web com o maven.

{% highlight bash %}
springHelloWorld/
├── pom.xml
└── src
    └── main
        ├── java
        │   └── com
        │       └── phillipe
        │           └── web
        │               └── controllers
        │                   └── HelloController.java
        ├── resources
        └── webapp
            └── WEB-INF
                ├── mvc-dispatcher-servlet.xml
                ├── pages
                │   └── hello.jsp
                └── web.xml
{% endhighlight %}

### Configurando a aplicação

Nessa parte, vamos editar os arquivos *pom.xml*, *mvc-dispatcher-servlet.xml* e *web.xml*.

- **mvc-dispatcher-servlet.xml**: Contém as configurações do Spring MVC. O *bean* que será configurado aqui vai dizer onde estão as páginas do projeto e qual sua extensão (.html, .jsp, .jsf, .xhtml, etc);
- **web.xml**: Também conhecido como [*Deployment Descriptor* (DD)](https://cloud.google.com/appengine/docs/java/config/webxml). Aqui configuramos o *servlet* e o *listener* do Spring. Uma boa referência para se entender bem sobre *servlets* é o livro *Use a Cabeça! Servlets & JSP*.

Vamos para o que interessa! No *pom.xml* adicionamos as dependências para o Spring MVC:

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.phillipe</groupId>
    <artifactId>springHelloWorld</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>

    <properties>
        <spring.version>3.2.11.RELEASE</spring.version>
    </properties>

    <dependencies>
        <!-- As dependências do Spring 3 -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
            <version>${spring.version}</version>
        </dependency>

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-web</artifactId>
            <version>${spring.version}</version>
        </dependency>

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
            <version>${spring.version}</version>
        </dependency>

    </dependencies>
</project>
{% endhighlight %}

Configuramos o pacote onde o Spring procurará pelo controller e onde e qual o formato das páginas no *mvc-dispatcher-servlet.xml*:

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context-3.0.xsd">

    <!-- Procura por @Controller, @Component -->
    <context:component-scan base-package="com.phillipe.web.controllers"/>

    <!-- Onde estão os JSPs -->
    <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/pages/"/>
        <property name="suffix" value=".jsp"/>
    </bean>
</beans>
{% endhighlight %}

Configuramos o servlet do Spring e criamos um mapeamento para ele no *web.xml*:

{% highlight xml %}
<web-app id="WebApp_ID" version="2.4"
         xmlns="http://java.sun.com/xml/ns/j2ee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee
    http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">

    <display-name>Spring MVC Application</display-name>

    <!-- Servlet do Spring -->
    <servlet>
        <servlet-name>mvc-dispatcher</servlet-name>
        <servlet-class>
            org.springframework.web.servlet.DispatcherServlet
        </servlet-class>
        <load-on-startup>1</load-on-startup>
    </servlet>

    <!-- Mapeamento do servlet acima -->
    <servlet-mapping>
        <servlet-name>mvc-dispatcher</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>

    <!-- Arquivo de configuração -->
    <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>/WEB-INF/mvc-dispatcher-servlet.xml</param-value>
    </context-param>

    <!-- Recebe os eventos de quando a aplicação é inicializada ou finalizada. -->
    <!-- Consegue criar a conexão com o banco de dados antes da aplicação inicializar, por exemplo. -->
    <listener>
        <listener-class>
            org.springframework.web.context.ContextLoaderListener
        </listener-class>
    </listener>
</web-app>
{% endhighlight %}

### Programando o controller

Agora que já temos tudo configurado, criamos um controller. Só lembrando que ele deve estar dentro do pacote configurado no *mvc-dispatcher-servlet.xml*.

{% highlight java %}
package com.phillipe.web.controllers;

@Controller
@RequestMapping
public class HelloController {

    /*Captura a url '/hello'. */
    @RequestMapping(value = "/hello", method = RequestMethod.GET)
    public String helloWorldMethod(ModelMap model) {
 
    /*
    Adicionamos um atributo com nome 'message'.
    Poderemos acessar esse atributo na página depois.
    Note que no lugar de "Hello World!" também podemos colocar qualquer objeto!.
    */
        model.addAttribute("message", "Hello World!");

        // "hello" é o nome sem sufixo da página que a gente criou,
        // no caso é hello.jsp
        return "hello";
    }
}
{% endhighlight %}

### Programando a página

Agora só resta criar a view. É um html simples que exibe a mensagem que criamos no controller.

{% highlight jsp %}
<html>
<body>
<%-- Usamos ${nomeDoAtributo} para poder acessar 
os atributos adicionados pelo controller. --%>
<h1>Message : ${message}</h1>
</body>
</html>
{% endhighlight %}

Isso é tudo, agora é só dar deploy no container de sua preferência e ver o resultado.

<hr>

Sugestões ou erros no exemplo? Comente :)

Download:

- [https://github.com/paflopes/springHelloWorld.git](https://github.com/paflopes/springHelloWorld.git)

Referências: 

- [Spring 3 MVC hello world example (mkyong.com)](http://www.mkyong.com/spring3/spring-3-mvc-hello-world-example/)
- Head First Servlets & JSP - 2nd edition