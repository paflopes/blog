---
layout: post
title: Escopo de variáveis de JavaScript
description: Entenda como funciona o escopo de variáveis da linguagem mais popular do mundo
modified: 2015-05-04
tags: [javascript, programação]
image:
  feature: posts/2015-05-04/js-logo.png
comments: true
share: true
---
Quem nunca já passou um aperto com JavaScript, rodando um código simples que não executava como o esperado? Nesse post explicarei como funciona o escopo de variáveis de JavaScript. Se você ainda não sabe que *JavaScript é funcional*, dê uma olhada [aqui]({% post_url 2015-02-27-como-funciona-o-javascript %}).

## Criando o ambiente de testes
Em uma pasta crie dois arquivos: `code.js` e `index.html`.

No arquivo `index.html` escreva o código abaixo e abra o arquivo no navegador:

{% highlight html %}
<!DOCTYPE html>
<html>
<body>
<pre><script type="text/javascript" src="code.js"></script></pre>
</body>
</html>
{% endhighlight %}

Agora abra o arquivo `code.js` para edição. Para testar escreva `document.writeln('Hello, world!');` e atualize a página no navegador.

Ok! Agora podemos começar.

## Variáveis são globais são o padrão
Isso mesmo que você leu! As pessoas erram de vez em quando. No navegador o objeto que representa o contexto global é o `Window`. No node.js essa variável é o `Global`.

{% highlight javascript %}
var teste = 'Variavel global aqui!';
document.writeln(window.teste); // Opa!, nossa variável é global.

var i;
for (i = 0; i < 10; i++) {
    var outraVarGlobal = 'Nao era pra estar disponivel so no for?';
}

document.writeln(window.outraVarGlobal); // Isso funciona! :o
{% endhighlight %}

Todos sabem que variável globais são maléficas. Em outras linguagens que usam chaves ( { } ) o escopo começa e acaba quando as chaves começam e acabam. Em JavaScript o escopo é dado por funções. As variáveis definidas dentro de uma função não podem ser acessadas fora dela.

{% highlight javascript %}
var funcVariavelLocal = function () {
  var variavelLocal = 'local';
  document.writeln(window.variavelLocal); // undefined
};

funcVariavelLocal();
{% endhighlight %}

Outra coisa interessante é que funções podem acessar o escopo acima delas.

{% highlight javascript %}
(function(){
  var local = 'Variavel local';
  document.writeln(window.local); // undefined

  (function(){
    document.writeln(local); // Variavel local
  })();
})();
{% endhighlight %}

Só para explicar, esse tipo de código: `(function () { executaAlgo(); })();` cria uma função e a executa logo em seguida. Em JavaScript esse tipo de coisa é permitida e é uma grande vantagem.


## Padrão *Closure*
Agora um código um pouco mais estranho.

{% highlight javascript %}
(function(){
  var count;

  // Deveria imprimir os números de 0 a 9.
  for (count = 0; count < 10; count++) {
    setTimeout(function (e) {
      document.writeln(count);
    });
  }
})();
{% endhighlight %}

No código acima, passamos uma função por *callback* para `setTimeout`. Como essa função tem acesso ao escopo da função externa, mandamos imprimir a variável `count` 10 vezes. Porém quando executamos esse código vemos um monte de números *10* na saída. O que aconteceu aqui é que a nossa função imprimiu apenas o *último* valor de `count`, pois quando `setTimeout` resolveu executar o *callback* o laço de repetição já tinha acabado.

É provável que você já tenha passado por isso com a biblioteca *JQuery* ou alguma outra que receba *callbacks* por parâmetro. A solução para isso é um padrão chamado *closure*.

Como uma função tem acesso as variáveis da função externa e já que podemos retornar funções (visto que são objetos), aplicaremos essa solução:

{% highlight javascript linenos %}
(function(){
  var count;

  // Imprime os números de 0 a 9.
  for (count = 0; count < 10; count++) {
    // Uma função externa é criada e executada passando
    // a variável count por parâmetro.
    setTimeout((function(e){
      // Uma outra função é retornada, pois setTimeout
      // precisa de uma variável do tipo Function.
      return function () {
        // Aqui utilizamos o parâmetro da linha 8. Como a
        // função externa é executada a cada iteração, essa
        // função escreve os valores corretos na tela.
        document.writeln(e);
      };
    })(count));
  }
})();
{% endhighlight %}

Isso é difícil de abstrair no começo, mas não desista! Faça quantos testes você achar necessário. Aqui vai mais um exemplo para ajudar na sua criatividade com os testes:

## Padrão *Module*

{% highlight javascript %}
(function(){
  var animal = (function(){
    var qtdPatas = 4;
    var passos = 0;

    // Retornando um objeto literal.
    return {
      getPatas: function () {
        return qtdPatas;
      },
      setPatas: function (qtd) {
        qtdPatas = qtd;
      },
      anda: function () {
        passos++;
      },
      getPassos: function () {
        return passos;
      }
    };

  })();

  document.writeln("Patas: " + animal.getPatas());
  animal.setPatas(6);
  document.writeln("Mais patas: " + animal.getPatas());
  animal.anda();
  animal.anda();
  document.writeln("Passos: " + animal.getPassos());
  document.writeln(animal.qtdPatas); // Opa, variável privada!
})();
{% endhighlight %}

O código acima representa o padrão *Module*. Você também pode retornar uma função ao invés de um objeto. Teste a vontade!

## Dicas finais
Para cada arquivo que você criar, utilize o *wrapper*:

{% highlight javascript %}
(function(){
  // Algum código incrível, limpo e testado aqui.
})();
{% endhighlight %}

Quando alguma coisa der errado na sua chamada de *callback*, como algum `undefined` inesperado, verifique se o padrão *Closure* é aplicável.

{% highlight javascript %}
var varQueMudaOTempoTodo;

// Um monte de operações aqui.

algumaFuncaoQuePedeCallbacks(function (varInterna) {
  // Esse que é o callback de verdade.
  return function (event) {
    // faz coisas.
    fazAlgo(varInterna);
    // faz mais coisas.
  };
})(varQueMudaOTempoTodo));
{% endhighlight %}

E quando quiser um pouco de encapsulamento utilize o padrão *Module*.

{% highlight javascript %}
var funcao = (function () {
  var variavelPrivada = null;
  var funcaoPrivada = function(parametro) {
    fazAlgo(variavelPrivada);
  };

  return function () {
    funcaoPrivada(variavelPrivada);
  };
})();

funcao();

var objeto = (function () {
  var variavelPrivada = null;
  var funcaoPrivada = function(parametro) {
    fazAlgo(variavelPrivada);
  };

  return {
    varPublica: 'Alguma coisa',
    manipulaVar: function () {
      return variavelPrivada;
    },
    metodo: function (param) {
      funcaoPrivada(param);
    }
  };
})();

objeto.metodo("Hello World!");
document.writeln(objeto.varPublica);
{% endhighlight %}

Por enquanto é isso pessoal!

No próximo post falarei sobre o funcionamento da variável `this` em JavaScript.

Sugestões ou erros? Comente :)

Referências:

JavaScript: The Good Parts by Douglas Crockford. Copyright 2008 Yahoo! Inc., 978-0-596-51774-8.