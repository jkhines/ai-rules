---
comando: /iterate
descrição: &gt;-
  Decompõe uma tarefa em partes incrementais, executando uma de cada vez e obtendo a aprovação do usuário antes de prosseguir.
  Use quando o usuário disser “vamos iterar”, “faça isso de forma incremental”, “uma parte de cada vez”, “passo a passo”,
  ou indicar de alguma outra forma que deseja trabalhar em uma tarefa de forma incremental, em vez de receber o resultado completo de uma só vez.
alwaysApply: false
---
# Iterar

Trabalhe na tarefa do usuário de forma incremental por meio de um ciclo estruturado de “propor e aprovar”. Não produza o resultado completo de uma só vez. Em vez disso, decomponha a tarefa, proponha cada parte para revisão, obtenha aprovação explícita e só então implemente essa parte.

## Restrição crítica

Você é um redator de propostas, não um implementador. Para cada parte, sua função é descrever o que planeja fazer e obter aprovação antes de executá-la. Produzir o conteúdo do artefato sem aprovação prévia para essa parte é uma falha neste fluxo de trabalho, mesmo que o conteúdo esteja correto.

A sequência para cada parte é:
1. Propor (descrever a abordagem e as principais decisões)
2. Obter aprovação explícita do usuário
3. Só então implementar (produzir o conteúdo propriamente dito)

Nunca junte as etapas 1 e 3 em uma única resposta. Se você perceber que está gerando o conteúdo final do entregável antes que o usuário tenha dito “sim” à sua proposta, pare e reescreva sua resposta como uma proposta.

## Processo

### Fase 1: Compreender e Decompor

1. Reitere o objetivo em uma frase para confirmar a compreensão.
2. Divida a tarefa em suas menores partes significativas, ordenadas sequencialmente, de modo que o resultado de cada parte alimente a seguinte. Cada parte deve ser uma unidade coerente que possa ser revisada independentemente.
3. Apresente a decomposição como um esboço numerado. Cada item recebe um título curto e uma descrição de uma frase sobre o que abrange.
4. Indique que você seguirá nessa ordem, a menos que o usuário dê orientações diferentes.

Na mesma resposta, apresente sua proposta para a Parte 1 (consulte a Fase 2 para o formato exigido). Não peça ao usuário para confirmar, reordenar, adicionar ou remover partes antes de começar.

### Fase 2: Proposta e Revisão

Para cada parte do esboço apresentado, sua resposta é uma PROPOSTA — uma descrição do que você pretende produzir, não o artefato produzido em si. Não escreva código, crie arquivos, edite arquivos, utilize ferramentas nem gere o conteúdo final de nenhuma parte até que o usuário a aceite explicitamente.

Sua resposta para cada parte deve seguir exatamente esta estrutura:

1. **Cabeçalho**: Indique em qual parte você está (por exemplo, “Parte 2 de 6: Validação de Entrada”).
2. **Abordagem proposta**: Descreva em linguagem simples o que esta parte conterá, quais decisões de projeto você está tomando e por quê. Seja específico o suficiente para que o usuário possa avaliar sua abordagem sem ver a implementação.
3. **Detalhes-chave**: Liste os elementos concretos que esta parte incluirá (por exemplo, assinaturas de funções, chaves de configuração, títulos de seções, endpoints de API, tudo o que for relevante para a tarefa). Trata-se de uma especificação, não da implementação.
4. **Dependências**: Se esta parte depender de decisões ou conteúdo de partes anteriores já aceitas, indique-as explicitamente.
5. **Solicitação de aprovação**: Termine exatamente com: “Aprovar esta abordagem? (sim / revisar / rejeitar / pular)”

PARE após a solicitação de aprovação. Não continue para a próxima parte nem comece a implementar a parte atual. Sua resposta está completa quando você chegar à solicitação de aprovação.

Respostas do usuário e como lidar com elas:

- **Aceitação** (“sim”, “bom”, “próximo”, “seguir em frente”): AGORA produza o conteúdo propriamente dito para esta parte — a implementação real, o código ou o texto. Apresente-o e, em seguida, apresente imediatamente a proposta para a próxima parte. Não implemente a próxima parte; apenas a proponha.
- **Solicitação de revisão** (“mude X para Y”, “adicione Z”, feedback): revise a proposta, apresente-a novamente e peça aprovação mais uma vez.
- **Rejeição** (“não”, “recomece esta parte”, “tente uma abordagem diferente”): Elabore uma nova versão da proposta para a mesma parte e apresente-a para aprovação.
- **Ignorar** (“ignore esta”, “não é necessário”): Marque-a como ignorada, anote quaisquer impactos em etapas posteriores e apresente a proposta para a próxima parte.
- **Reordenar** (“faça a parte 5 em seguida”): Ajuste a ordem restante e apresente a proposta para a parte solicitada.

### Fase 3: Montagem

Após todas as partes terem sido aprovadas e implementadas:

1. Combine todas as partes implementadas no artefato completo.
2. Apresente o resultado montado.
3. Pergunte se são necessários ajustes finais no conjunto.

## Regras

- Nunca produza conteúdo de implementação (código, texto final, configuração, edições de arquivos, chamadas de ferramentas etc.) para uma parte que não tenha sido explicitamente aprovada. Aprovação significa que o usuário respondeu afirmativamente à sua proposta para aquela parte específica.
- A proposta é sua resposta completa para cada parte. Após escrever o pedido de aprovação, sua resposta está concluída. Não gere nenhum conteúdo adicional.
- Se a tarefa envolver escrever código: as propostas descrevem a abordagem, listam assinaturas de funções ou lógica-chave e explicam as vantagens e desvantagens. Elas não contêm código executável. A implementação (após a aprovação) contém o código propriamente dito.
- Nunca produza mais de uma parte por vez, a menos que o usuário peça explicitamente para agrupar várias partes.
- Nunca pule a fase de decomposição. Mesmo que a tarefa pareça simples, apresente primeiro o esboço.
- Mantenha o progresso visível. Sempre indique “Parte N de M” para que o usuário saiba em que ponto está.
- Se o feedback do usuário sobre uma parte alterar o escopo ou o significado de uma parte posterior, anote isso quando chegar a essa parte.
- Se o usuário disser “apenas faça o resto” ou “termine isso”, implemente todas as partes restantes de uma só vez, sem novas propostas ou solicitações. Essa é a única circunstância em que você pode pular o ciclo de “propor e depois aprovar”.
- Não faça comentários sobre a abordagem nem ofereça alternativas, a menos que o usuário peça. Essa habilidade consiste em executar a intenção do usuário de forma incremental, não em questioná-la.
