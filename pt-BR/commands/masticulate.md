---
comando: /masticulate
descrição: &gt;-
  Percorra uma lista numerada existente, um item por vez: apresente cada item, solicite alterações,
  e depois pergunte se deve prosseguir. Use quando o usuário disser “masticulate”, “ir item por item”,
  “analise esta lista” ou, de alguma forma, desejar uma iteração leve sobre uma lista, comparação, plano ou
  itens ordenados semelhantes.
alwaysApply: false
---
# Masticulate

Um ciclo de revisão leve sobre uma lista existente. Não se trata de um fluxo de trabalho de planejamento, proposta ou implementação.

## Comportamento

1. Identifique a lista a ser revisada. Se nenhuma estiver disponível ou houver ambiguidade, solicite-a.
2. Mantenha a ordem do usuário, a menos que ele peça para reordenar.
3. Apresente um item por vez e aguarde uma resposta antes de passar para o próximo.
4. Mostre o item de forma clara e completa: reproduza o conteúdo na íntegra, nunca truncado, resumido, parafraseado
   ou abreviado. Adicione no máximo uma frase de contexto apenas se for necessário para revisá-lo, mantida separada do item.

## Formato

```markdown
## Item N de M

<the item being reviewed>

Alterações? Continuar? (sim / editar / pular / parar)
```

## Respostas

- **Continuar** (“sim”, “próximo”, “parece bom”): apresente o próximo item.
- **Editar**: aplique ou reformule a alteração e, em seguida, pergunte novamente.
- **Pular**: marque como pulado e apresente o próximo item.
- **Parar**: encerre o ciclo; resuma apenas se solicitado.
- **Saltar/reordenar**: vá para o item solicitado, continuando um de cada vez.

## O que não fazer

- Não trunque, resuma, parafraseie, abrevie ou altere de outra forma o conteúdo do item ao apresentá-lo.
- Não adicione recomendações, dependências, critérios de aceitação ou planos de implementação, a menos que seja solicitado.
- Não decomponha a tarefa, exceto para extrair uma lista incorporada no texto.
- Não implemente alterações, a menos que o usuário solicite.
