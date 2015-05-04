---
layout: post
title: Como o JavaScript funciona?
description: Os conceitos que você deve saber para se dar bem com JavaScript
modified: 2015-02-27
tags: [javascript, programação]
image:
  feature: posts/2015-02-27-como-funciona-o-javascript/js-logo.png
comments: true
share: true
---

Se você programa há algum tempo provavelmente já se deparou com um código *JavaScript* na sua frente. Também é provável que você tenha topado com várias declarações ```function``` e tenha se sentido perdido por conta disso. Isso acontece porque apesar do *JavaScript* ter uma sintaxe parecida com *C* ou *Java*, ele é muito mais parecido com *Lisp*!

### Linguagens que influenciaram o *JavaScript*

Na época que o *JavaScript* foi criado, as linguagens de programação mais populares eram *C*, *C++* e *Java*, por isso *JavaScript* acabou herdando dessas linguagens o use de **;** e **{}** em sua sintaxe.

Apesar dos colchetes, pontos-e-vírgulas e sintaxe parecida com *C*, as duas principais ideias por trás do *JavaScript* vem de outras duas linguagens bem menos populares: [*Self*](http://en.wikipedia.org/wiki/Self_(programming_language)) e [*Scheme*](http://en.wikipedia.org/wiki/Scheme_(programming_language)). Portanto, apesar de *JavaScript* se parecer muito com *C*, algumas das ideias principais não são nada parecidas com *C* (ou *Java*).

#### Scheme

[*Scheme*](http://en.wikipedia.org/wiki/Scheme_(programming_language)) é uma linguagem de programação de propósito geral considerada um dialecto de *Lisp*. Isso mesmo que você leu, *Lisp*! Mas o que *JavaScript* tem a ver com *Scheme*? As ideias que *JavaScript* pega da linguagem *Scheme* tem bases em um sistema matemático chamado *cálculo lambda*, cujas idéias recaem sobre *programação funcional*, o que é **muito** diferente de *C*, que encoraja a programação *imperativa*.

#### Self

A linguagem de programação *Self* foi criada com base em um conceito de programação conhecido como *protótipos*. Sendo baseada em protótipos, *Self* foi bem diferente das linguagens orientadas a objeto da época (*C++* e *Java*), que são baseadas em *classes*. Além disso *Self* também tinha um estilo diferente das outras linguagens orientadas a objeto: é preferível ter um conjunto de operações pequeno porém poderoso a um numeroso e elaborado.

*JavaScript* se parece de um jeito mas age de outro.

### Tá, mas e aí?

E aí que temos que pensar um pouco diferente na hora de programar em *JavaScript*. A primeira diferença que eu percebi é o uso intenso de funções. Não que não se crie muitas funções em *C* ou muitos métodos em *Java*, mas é que as funções em *JavaScript* são objetos de primeira classe. Coisas que são possíveis fazer com funções:

{% highlight javascript %}
// Atribuir uma função à uma variável
var imprime = function ( coisa_a_imprimir ) {
    console.log( coisa_a_imprimir )
};

imprime( "JavaScript é demais!" );
{% endhighlight %}

{% highlight javascript %}
// Passar uma função por parâmetro para outra função
var retorna_alguma_string = function () {
    return "JavaScript é demais!";
};

var imprime = function( funcao_que_retorna_string ) {
    // Executa a função recebida por parâmetro
    console.log(funcao_que_retorna_string());
};

// Que pode ser executado assim
imprime(retorna_alguma_string);

// Ou assim
imprime(function () {
    return "Alguma outra string!";
});
{% endhighlight %}

Qualquer semelhança com os eventos html **não** é mera coincidência. Quando um evento de `onclick` é configurado, algo como isso acontece:

{% highlight html %}
<button id="btn" onclick="myFunction()">Click me</button>
{% endhighlight %}

é igual a:

{% highlight javascript %}
// Isso
document.getElementById("btn").onclick = myFunction;

// Ou isso
document.getElementById("btn").onclick = function() {
    // Algum script aqui.
};

// Ou ainda
document.getElementById("btn").addEventListener("click", function() {
    // Algum script aqui.
});
{% endhighlight %}

Legal, né?

*JavaScript* também é *orientado a eventos*, o que torna certas tarefas mais fáceis de serem executadas.

Caso você queira se aprofundar nessa linguagem aqui vão alguns lugares por onde começar:

- [W3Schools](http://www.w3schools.com/js/)
- [Escopo de variáveis](http://javascriptbrasil.com/2013/10/11/escopo-de-variavel-e-hoisting-no-javascript-explicado/)
- [Programação web backend](http://expressjs.com/)
- [Programação web backend](http://loopback.io/)
- [Programação frontend](https://angularjs.org/)
- [Mobile](http://ionicframework.com/)

Sugestões ou erros? Comente :)

Referências: 

- [onclick Event (w3schools.com)](http://www.w3schools.com/jsref/event_onclick.asp)
- [CoffeeScript in Action - Patrick Lee](http://www.amazon.com/CoffeeScript-Action-Patrick-Lee/dp/1617290629)