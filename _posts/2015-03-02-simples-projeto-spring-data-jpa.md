---
layout: post
title: "Banco de dados com Spring Data"
tags: [java, spring, spring data, banco de dados]
modified: 2015-03-02
image:
  feature: posts/2015-03-02/spring-framework.png
comments: true
share: true
---

Nesse tutorial mostrarei como configurar um projeto com [Spring Data JPA](http://projects.spring.io/spring-data-jpa/) e usando o banco de dados [PostgreSQL](http://www.postgresql.org/).

As tecnologias usadas serão:

- Spring 4.1.5.RELEASE
- Hibernate
- PostgreSQL
- JDK 1.7
- Maven 3
- JUnit (apenas para testes)

Aqui considerarei que o leitor já conhece o [Hibernate](http://hibernate.org/) e a [JPA (Java Persistence API)](http://www.oracle.com/technetwork/java/javaee/tech/persistence-jsp-140049.html).

Se você quiser o exemplo já pronto pode clonar o [repositório](https://github.com/paflopes/spring-data-jpa):

{% highlight bash %}
git clone https://github.com/paflopes/spring-data-jpa.git
{% endhighlight %}

### Criando a estrutura de diretórios

{% highlight bash %}
spring-data-jpa/
├── pom.xml
└── src
    ├── main
    │   ├── java
    │   │   └── com
    │   │       └── phillipe
    │   │           ├── config
    │   │           │   └── Hibernate.java
    │   │           ├── Config.java
    │   │           ├── main
    │   │           │   └── Main.java
    │   │           ├── modelo
    │   │           │   ├── Carro.java
    │   │           │   ├── Id.java
    │   │           │   └── Motorista.java
    │   │           └── repositorio
    │   │               ├── RepositorioCarro.java
    │   │               └── RepositorioMotorista.java
    │   └── resources
    └── test
        └── java
            └── com
                └── phillipe
                    └── repositorio
                        ├── AbstractionTest.java
                        └── RepositoriosTest.java
{% endhighlight %}

### Configurando as dependências do projeto

Copie e cole o código abaixo no `pom.xml`:

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.phillipe</groupId>
    <artifactId>spring-data-jpa</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <!-- Versões das bibliotecas utilizadas -->
        <spring.version>4.1.5.RELEASE</spring.version>
        <spring.data.version>1.7.2.RELEASE</spring.data.version>
        <hibernate.orm.version>4.3.8.Final</hibernate.orm.version>
        <postgres.driver.version>9.1-901.jdbc4</postgres.driver.version>
        <junit.version>4.12</junit.version>

        <!-- Configuração da codificação do projeto -->
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    </properties>

    <dependencies>
        <!-- Base do spring framework -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>${spring.version}</version>
        </dependency>

        <!-- Persistência -->
        <dependency>
            <groupId>org.springframework.data</groupId>
            <artifactId>spring-data-jpa</artifactId>
            <version>${spring.data.version}</version>
        </dependency>
        <dependency>
            <groupId>org.hibernate</groupId>
            <artifactId>hibernate-entitymanager</artifactId>
            <version>${hibernate.orm.version}</version>
        </dependency>

        <!-- Driver do PostgreSQL -->
        <dependency>
            <groupId>postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <version>${postgres.driver.version}</version>
        </dependency>

        <!-- Dependências de teste -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-test</artifactId>
            <version>${spring.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>${junit.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <!-- Configuração da compilação -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.1</version>
                <configuration>
                    <source>1.7</source>
                    <target>1.7</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
{% endhighlight %}

### Configurando o Spring com o Hibernate

Edite o arquivo `spring-data-jpa/src/main/java/com/phillipe/config/Hibernate.java`:

{% highlight java %}
@Configuration
public class Hibernate {

    @Bean
    public DataSource dataSource() {
        final DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("org.postgresql.Driver");
        // Conecta no servidor "localhost" e no banco de dados "carros"
        dataSource.setUrl("jdbc:postgresql://localhost:5432/carros");
        // Usando o usuário "usuario"
        dataSource.setUsername("usuario");
        // E a senha "senha"
        dataSource.setPassword("senha");

        return dataSource;
    }

    @Bean
    @Autowired
    public LocalContainerEntityManagerFactoryBean entityManagerFactory(DataSource dataSource) {
        LocalContainerEntityManagerFactoryBean emf = new LocalContainerEntityManagerFactoryBean();
        Map<String, String> properties = new HashMap<>();

        // Configuração do dialeto a ser utilizado pelo Hibernate.
        properties.put("hibernate.dialect", "org.hibernate.dialect.PostgreSQL82Dialect");
        // A opção "update" cria um schema no banco de dados se não houver um.
        properties.put("hibernate.hbm2ddl.auto", "update");

        // Pacote base para procurar classes anotadas com @Entity
        // Substitui o arquivo beans.xml
        emf.setPackagesToScan("com.phillipe");
        emf.setDataSource(dataSource);
        emf.setJpaVendorAdapter(new HibernateJpaVendorAdapter());
        emf.setJpaPropertyMap(properties);
        return emf;
    }

    @Bean
    @Autowired
    public JpaTransactionManager transactionManager(EntityManagerFactory managerFactory) {
        // Cria um gerenciador de transações. Executa as transações de forma automática.
        return new JpaTransactionManager(managerFactory);
    }
}
{% endhighlight %}

Repare que nesse arquivo configuramos 3 `Beans`: `dataSource`, `entityManagerFactory`, `transactionManager`. O `dataSource` tem como objetivo configurar a conexão com o banco de dados e o `entityManagerFactory` configura o Hibernate. Reparem que esse último se utiliza do `dataSource`.

### Configurando a aplicação e o Spring Data JPA

Edite o arquivo `spring-data-jpa/src/main/java/com/phillipe/Config.java`:

{% highlight java %}
@Configuration
// Procura por componentes a partir desse pacote.
@ComponentScan(basePackages = "com.phillipe")
// Ativa o Spring Data JPA
@EnableJpaRepositories
public class Config {

}
{% endhighlight %}

Reparem que apenas uma Annotation já ativa o Spring Data.

### Programando o domínio do problema

O nosso domínio é composto de duas classes: `Carro` e `Motorista`. Os dois tem um relacionamento do tipo *muitos-para-muitos*. Infelizmente não focarei muito no JPA, mas a documentação da api pode ser encontrada [aqui](http://docs.oracle.com/javaee/7/api/javax/persistence/package-summary.html).

`spring-data-jpa/src/main/java/com/phillipe/modelo/Id.java`:

{% highlight java %}
@Entity
// Esse tipo de herança junta as propriedades do da classe pai com as da classe filho.
@Inheritance(strategy = InheritanceType.TABLE_PER_CLASS)
public abstract class Id {

    @javax.persistence.Id
    @Column
    // Gera um Id automaticamente
    @GeneratedValue
    private Long id;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }
}
{% endhighlight %}

`spring-data-jpa/src/main/java/com/phillipe/modelo/Carro.java`:

{% highlight java %}
@Entity
public class Carro  extends Id {

    @Column
    private String modelo;
    @Column
    private String marca;
    @Temporal(DATE)
    private Calendar ano;
    @ManyToMany(fetch = FetchType.EAGER, mappedBy = "carros", cascade = CascadeType.ALL)
    private List<Motorista> motoristas;

    public Carro() {
    }

    public Carro(String modelo, String marca, Calendar ano, List<Motorista> motoristas) {
        this.modelo = modelo;
        this.marca = marca;
        this.ano = ano;
        this.motoristas = motoristas;
    }

    public String getModelo() {
        return modelo;
    }

    public void setModelo(String modelo) {
        this.modelo = modelo;
    }

    public String getMarca() {
        return marca;
    }

    public void setMarca(String marca) {
        this.marca = marca;
    }

    public Calendar getAno() {
        return ano;
    }

    public void setAno(Calendar ano) {
        this.ano = ano;
    }

    public List<Motorista> getMotoristas() {
        return motoristas;
    }

    public void setMotoristas(List<Motorista> motoristas) {
        this.motoristas = motoristas;
    }
}
{% endhighlight %}

`spring-data-jpa/src/main/java/com/phillipe/modelo/Motorista.java`:

{% highlight java %}
@Entity
public class Motorista extends Id {

    @Column
    private String cpf;
    @Column
    private String nome;
    @ManyToMany(fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private List<Carro> carros;

    public Motorista() {
    }

    public Motorista(String cpf, String nome, List<Carro> carros) {
        this.cpf = cpf;
        this.nome = nome;
        this.carros = carros;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public List<Carro> getCarros() {
        return carros;
    }

    public void setCarros(List<Carro> carros) {
        this.carros = carros;
    }
}
{% endhighlight %}

### Criando os repositórios

Os repositórios são as classes onde é possível acessar ao banco de dados. O Spring Data já traz por padrão todos os métodos mais utilizados já prontos por padrão. Além disso ele permite a criação de consultas apenas criando métodos no repositório. Esses métodos são chamados de *query methods* e poupam um grande tempo de programação. A documentação completa para a criação de *query methods* se encontra [aqui](http://docs.spring.io/spring-data/jpa/docs/1.7.2.RELEASE/reference/html/#jpa.query-methods.query-creation).

`spring-data-jpa/src/main/java/com/phillipe/repositorio/RepositorioCarro.java`:

{% highlight java %}
@Repository
public interface RepositorioCarro extends JpaRepository<Carro, Long> {

    public Carro findByModelo(String modelo);
}
{% endhighlight %}

`spring-data-jpa/src/main/java/com/phillipe/repositorio/RepositorioMotorista.java`:

{% highlight java %}
@Repository
public interface RepositorioMotorista extends JpaRepository<Motorista, Long> {
}
{% endhighlight %}

A annotation `@Repository` cuida de escolher a implementação certa para você.

### Acessando os repositórios criados

Ok, o projeto já está pronto para funcionar. Existem dois modos de chamar os repositórios no seu código. Se você já está acostumado a usar o Spring Framework sabe que pode usar o `@Autowired` dentro de alguma classe anotada com `@Service`, `@Controller`, etc. No [repositório do projeto de exemplo](https://github.com/paflopes/spring-data-jpa) tem um [exemplo](https://github.com/paflopes/spring-data-jpa/blob/master/src/test/java/com/phillipe/repositorio/RepositoriosTest.java#L15) de como utilizar um `@Autowired` dentro de um teste.

Caso você queira usar os repositórios a partir de um contexto estático aqui vai um exemplo:

`spring-data-jpa/src/main/java/com/phillipe/main/Main.java`

{% highlight java %}
public class Main {

    public static void main(String[] args) {
        // Acessa o contexto do Spring Framework a partir de um método estático.
        ApplicationContext context = new AnnotationConfigApplicationContext(Config.class);
        RepositorioCarro repositorio = context.getBean(RepositorioCarro.class);
        Carro carro = new Carro();
        carro.setAno(Calendar.getInstance());
        carro.setMarca("Volkswagen");
        carro.setModelo("Amarok");
        carro = repositorio.save(carro);
    }
}
{% endhighlight %}

Isso é tudo pessoal!

Sugestões ou erros no exemplo? Comente :)

Download:

- [https://github.com/paflopes/spring-data-jpa.git](https://github.com/paflopes/spring-data-jpa.git)

Referências:

- [Documentação de referência do Spring Data JPA](http://docs.spring.io/spring-data/jpa/docs/1.7.2.RELEASE/reference/html/)
- [Documentação de referência do Spring Framework](http://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/)
- [Documentação de referência do Hibernate](http://docs.jboss.org/hibernate/orm/4.3/manual/en-US/html_single/)
