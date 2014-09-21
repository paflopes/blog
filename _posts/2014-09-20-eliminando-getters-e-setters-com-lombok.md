---
layout: post
title: "Eliminando Getters e Setters com Lombok"
tags: [java, lombok]
image:
  feature: abstract-12.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
comments: true
share: true
---

Não é chato quando vamos criar nossas classes em Java que temos que fazer esse tipo de código? 

<a name="classe_vanilla"></a>
{% highlight java %}
public class Classe {

    private String string;
    private boolean bool;
    private final int constante;
    private final AtomicReference<Object> cached = new AtomicReference<>();

    public Classe(int constante) {
        this.constante = constante;
    }

    public Classe(String string, boolean bool, int constante) {
        this.string = string;
        this.bool = bool;
        this.constante = constante;
    }

    public String getString() {
        return string;
    }

    public void setString(String string) {
        this.string = string;
    }

    public boolean isBool() {
        return bool;
    }

    public void setBool(boolean bool) {
        this.bool = bool;
    }

    public int getConstante() {
        return constante;
    }

    public double[] getCached() {
        java.lang.Object value = this.cached.get();
        if (value == null) {
            synchronized (this.cached) {
                value = this.cached.get();
                if (value == null) {
                    final double[] actualValue = expensive();
                    value = actualValue == null ? this.cached : actualValue;
                    this.cached.set(value);
                }
            }
        }
        return (double[]) (value == this.cached ? null : value);
    }

    private double[] expensive() {
        double[] result = new double[1000000];
        for (int i = 0; i < result.length; i++) {
            result[i] = Math.asin(i);
        }
        return result;

    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Classe classe = (Classe) o;

        return bool == classe.bool && constante == classe.constante && cached.equals(classe.cached) && !(string != null ? !string.equals(classe.string) : classe.string != null);

    }

    @Override
    public int hashCode() {
        int result = string != null ? string.hashCode() : 0;
        result = 31 * result + (bool ? 1 : 0);
        result = 31 * result + constante;
        result = 31 * result + (
                cached.hashCode());
        return result;
    }
}
{% endhighlight %}

Para esse problema existe uma biblioteca incrível chamada [lombok](http://projectlombok.org) que faz muito além de criar getters e setters para nós. Nesse post vamos criar uma classe simples, que contém:

- Um construtor que recebe parâmetros para todos os atributos;
- Um construtor para os atributos que **precisam** ser instanciados (os que tem o modificador `final`, por exemplo);
- Um campo com inicialização [lazy](https://en.wikipedia.org/wiki/Lazy_initialization);
- Os métodos `equals()` e `hashCode()`;

### Preparando o ambiente

Para esse projeto utilizaremos o maven 3 e o Intellij IDEA 13. Para o suporte no Intellij IDEA é necessário intalar o `Lombok Plugin`, para isso aperte `ctrl+shift+A`, digite `install plugin` e clique em `Browse repositories`. Pesquise por `Lombok Plugin`, instale o plugin com esse nome e reinicie a IDE.

Caso você esteja utilizando o Eclipse, baixe o lombok [nesse link](http://projectlombok.org/downloads/lombok.jar), execute `java -jar lombok.jar` e selecione a pasta onde o Eclipse está instalado.

Agora no `pom.xml` adicionamos a seguinte dependência:

{% highlight xml %}
<dependencies>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.14.8</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
{% endhighlight %}

O arquivo todo deve ficar assim:

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.paflopes.lombok</groupId>
    <artifactId>lombokTest</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.14.8</version>
            <scope>provided</scope>
        </dependency>
    </dependencies>
</project>
{% endhighlight %}

A estrutura de diretórios deve ser parecida com essa:

{% highlight bash %}
lombokTest/
├── pom.xml
└── src
    ├── main
    │   ├── java
    │   │   └── com
    │   │       └── paflopes
    │   │           └── lombok
    │   │               └── Classe.java
    │   └── resources
    └── test
        └── java
{% endhighlight %}

### Programando a classe

Como o prometido, usando o lombok, a [classe exibida no começo](#classe_vanilla) desse post fica assim:

{% highlight java %}
@Getter
@Setter
@RequiredArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class Classe {

    private String string;
    private boolean bool;
    private final int constante;
    @Getter(lazy = true)
    private final double[] cached = expensive();

    private double[] expensive() {
        double[] result = new double[1000000];
        for (int i = 0; i < result.length; i++) {
            result[i] = Math.asin(i);
        }
        return result;
    }

}
{% endhighlight %}

Pronto, só isso! O lombok oferece ainda mais facilidades, tudo isso se encontra na [documentação](http://projectlombok.org/features/index.html).

Sugestões ou erros no exemplo? Comente :)

Download:

- [https://github.com/paflopes/lombokTest.git](https://github.com/paflopes/lombokTest.git)

Referências: 

- [http://projectlombok.org](http://projectlombok.org)
